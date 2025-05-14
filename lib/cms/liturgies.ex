defmodule CMS.Liturgies do
  @moduledoc """
  The Liturgies context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Bibles
  alias CMS.Liturgies.Block
  alias CMS.Liturgies.Liturgy

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
    from(liturgy in Liturgy,
      where: liturgy.organization_id == ^scope.organization.id,
      order_by: [desc: :service_on]
    )
    |> Repo.all()
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
    Map.put(
      liturgy,
      :liturgy_blocks,
      liturgy_blocks |> Enum.map(&populate_liturgy_block/1) |> Enum.sort_by(& &1.position)
    )
  end

  defp populate_liturgy_block(%{block: %{type: :passage}} = liturgy_block) do
    block =
      liturgy_block.block
      |> Map.take([:title, :subtitle, :body, :type])
      |> then(&Map.put(&1, :body, Bibles.get_verses(&1.title)))

    Map.merge(liturgy_block, block)
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

  @doc """
  Copy a liturgy.

  Creates a new liturgy with the same blocks as the source liturgy, with a service date
  set to the same day on next week, without checking whether there is already a liturgy
  for that day.
  """
  def copy_liturgy(%Scope{} = scope, id) do
    source = get_liturgy!(scope, id)

    Repo.transaction(fn ->
      source
      |> Liturgy.copy_changeset(scope)
      |> Repo.insert()
      |> case do
        {:ok, new_liturgy} ->
          Repo.preload(new_liturgy, [:liturgy_blocks])

        result ->
          result
      end
    end)
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
    true = liturgy.organization_id == scope.organization.id

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
    Liturgy.changeset(liturgy, attrs, scope)
  end

  def list_songs(%Scope{} = scope) do
    Block
    |> from(where: [organization_id: ^scope.organization.id, type: :song])
    |> Repo.all()
  end

  @doc """
  Returns the id of the latest liturgy on or before today.
  Returns `nil` if no such liturgy is found.
  """
  def get_latest_liturgy_id(%Scope{} = scope) do
    today = Date.utc_today()

    from(l in Liturgy,
      select: l.id,
      where: l.organization_id == ^scope.organization.id and l.service_on <= ^today,
      order_by: [desc: l.service_on],
      limit: 1
    )
    |> Repo.one()
  end
end
