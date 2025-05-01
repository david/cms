defmodule CMS.Liturgies do
  @moduledoc """
  The Liturgies context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Liturgies.Liturgy
  alias CMS.Liturgies.Song

  @doc """
  Subscribes to scoped notifications about any liturgy changes.

  The broadcasted messages match the pattern:

    * {:created, %Liturgy{}}
    * {:updated, %Liturgy{}}
    * {:deleted, %Liturgy{}}

  """
  def subscribe_liturgies(%Scope{organization: org} = scope) do
    key = org.id

    Phoenix.PubSub.subscribe(CMS.PubSub, "user:#{key}:liturgies")
  end

  defp broadcast(%Scope{organization: org} = scope, message) do
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
    with {:ok, liturgy = %Liturgy{}} <-
           %Liturgy{}
           |> Liturgy.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, liturgy})
      {:ok, liturgy}
    end
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
    true = liturgy.organization_id == scope.organization.id

    with {:ok, liturgy = %Liturgy{}} <-
           liturgy
           |> Liturgy.changeset(attrs, scope)
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
    true =
      is_nil(liturgy.organization_id) or
        liturgy.organization_id == scope.organization.id

    Liturgy.changeset(liturgy, attrs, scope)
  end

  def list_songs(%Scope{} = scope) do
    Repo.all(from song in Song, where: song.organization_id == ^scope.organization.id)
  end
end
