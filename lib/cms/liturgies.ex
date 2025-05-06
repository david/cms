defmodule CMS.Liturgies do
  @moduledoc """
  The Liturgies context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Liturgies.Block
  alias CMS.Liturgies.Liturgy
  alias CMS.Liturgies.LiturgyBlock
  alias CMS.Liturgies.Song

  @doc """
  Subscribes to scoped notifications about any liturgy changes.

  The broadcasted messages match the pattern:

    * {:created, %Liturgy{}}
    * {:updated, %Liturgy{}}
    * {:deleted, %Liturgy{}}

  """
  def subscribe_liturgies(%Scope{organization: org}) do
    key = org.id

    Phoenix.PubSub.subscribe(CMS.PubSub, "user:#{key}:liturgies")
  end

  defp broadcast(%Scope{organization: org}, message) do
    key = org.id

    Phoenix.PubSub.broadcast(CMS.PubSub, "user:#{key}:liturgies", message)
  end

  @doc """
  Returns the list of liturgies.

  ## Examples

      iex> list_liturgies(scope)
      [%Liturgy{}, ...]

  """
  def list_liturgies(%Scope{} = scope) do
    Repo.all(from liturgy in Liturgy, where: liturgy.organization_id == ^scope.organization.id)
  end

  @doc """
  Gets a single liturgy.

  Raises `Ecto.NoResultsError` if the Liturgy does not exist.

  ## Examples

      iex> get_liturgy!(123)
      %Liturgy{}

      iex> get_liturgy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_liturgy!(%Scope{} = scope, id) do
    query =
      from(l in Liturgy,
        where: l.id == ^id and l.organization_id == ^scope.organization.id,
        preload: [liturgy_blocks: [:block]]
      )

    query
    |> Repo.one!()
    |> populate_liturgy_blocks()
  end

  defp populate_liturgy_blocks(%{liturgy_blocks: liturgy_blocks} = liturgy) do
    Map.put(liturgy, :liturgy_blocks, Enum.map(liturgy_blocks, &populate_liturgy_block/1))
  end

  defp populate_liturgy_block(liturgy_block) do
    Map.merge(liturgy_block, Map.take(liturgy_block.block, [:title, :subtitle, :body, :type]))
  end

  @doc """
  Creates a liturgy.

  ## Examples

      iex> create_liturgy(%{field: value})
      {:ok, %Liturgy{}}

      iex> create_liturgy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_liturgy(%Scope{} = scope, attrs) do
    # TODO: use Ecto.Multi
    # TODO: Avoid creating new blocks by matching block content

    with {:ok, liturgy = %Liturgy{}} <-
           %Liturgy{}
           |> Liturgy.changeset(attrs, scope)
           |> put_blocks(scope)
           |> Repo.insert() do
      broadcast(scope, {:created, liturgy})
      {:ok, liturgy}
    end
  end

  def put_blocks(
        %{valid?: true, changes: %{liturgy_blocks: liturgy_blocks}} = liturgy_changeset,
        scope
      ) do
    blocks_index =
      Block
      |> from(where: [organization_id: ^scope.organization.id])
      |> Repo.all()
      |> Enum.map(&{&1.id, &1})
      |> Map.new()

    Ecto.Changeset.put_assoc(
      liturgy_changeset,
      :liturgy_blocks,
      for %{action: action, changes: changes, data: data} = lb <- liturgy_blocks,
          data != %{} && action != :replace do
        merged =
          data
          |> Map.take([:type, :block_id, :title, :subtitle, :body])
          |> Map.merge(changes)

        {:ok, block} =
          merged
          |> Map.get(:block_id)
          |> case do
            nil -> %Block{type: merged.type}
            id -> Map.get(blocks_index, id)
          end
          |> then(&Block.changeset(&1, changes, scope))
          |> Repo.insert_or_update()

        Ecto.Changeset.put_change(lb, :block_id, block.id)
      end
    )
  end

  @doc """
  Updates a liturgy.

  ## Examples

      iex> update_liturgy(liturgy, %{field: new_value})
      {:ok, %Liturgy{}}

      iex> update_liturgy(liturgy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_liturgy(%Scope{} = scope, %Liturgy{} = liturgy, attrs) do
    # TODO: use Ecto.Multi
    # TODO: Avoid creating new blocks by matching block content

    true = liturgy.organization_id == scope.organization.id

    with {:ok, liturgy = %Liturgy{}} <-
           liturgy
           |> Liturgy.changeset(attrs, scope)
           |> put_blocks(scope)
           |> Repo.update() do
      broadcast(scope, {:updated, liturgy})
      {:ok, liturgy}
    end
  end

  @doc """
  Deletes a liturgy.

  ## Examples

      iex> delete_liturgy(liturgy)
      {:ok, %Liturgy{}}

      iex> delete_liturgy(liturgy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_liturgy(%Scope{} = scope, %Liturgy{} = liturgy) do
    ensure_safe_liturgy(liturgy, scope.organization)

    with {:ok, liturgy = %Liturgy{}} <-
           Repo.delete(liturgy) do
      broadcast(scope, {:deleted, liturgy})
      {:ok, liturgy}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking liturgy changes.

  ## Examples

      iex> change_liturgy(liturgy)
      %Ecto.Changeset{data: %Liturgy{}}

  """
  def change_liturgy(%Scope{} = scope, %Liturgy{} = liturgy, attrs \\ %{}) do
    ensure_safe_liturgy(liturgy, scope.organization, optional: true)

    Liturgy.changeset(liturgy, attrs, scope)
  end

  def list_songs(%Scope{} = scope) do
    Repo.all(from song in Song, where: song.organization_id == ^scope.organization.id)
  end

  defp ensure_safe_liturgy(liturgy, organization, opts \\ [optional: false])

  defp ensure_safe_liturgy(liturgy, organization, optional: true) do
    is_nil(liturgy.organization_id) or ensure_safe_liturgy(liturgy, organization)
  end

  defp ensure_safe_liturgy(liturgy, organization, _opts),
    do:
      true =
        liturgy.organization_id == organization.id &&
          safe_liturgy_blocks?(liturgy, organization) &&
          safe_blocks?(liturgy, organization)

  defp safe_blocks?(liturgy, organization) do
    liturgy.liturgy_blocks
    |> Enum.map(& &1.block_id)
    |> safe_ids?(Block, organization.id)
  end

  defp safe_liturgy_blocks?(liturgy, organization) do
    liturgy.liturgy_blocks
    |> Enum.map(& &1.id)
    |> safe_ids?(LiturgyBlock, organization.id)
  end

  defp safe_ids?(unsafe_ids, source, organization_id) do
    safe_ids =
      from(b in source, where: b.organization_id == ^organization_id, select: b.id)
      |> Repo.all()

    IO.inspect(unsafe_ids)

    unsafe_ids
    |> Enum.filter(&(&1 not in [nil, ""]))
    |> Enum.map(&parse_id/1)
    |> Kernel.--(safe_ids)
    |> Enum.empty?()
  end

  defp parse_id(str) when is_binary(str) do
    {id, _} = Integer.parse(str)

    id
  end

  defp parse_id(id) when is_integer(id), do: id
end
