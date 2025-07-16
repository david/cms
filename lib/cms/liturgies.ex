defmodule CMS.Liturgies do
  @moduledoc """
  The Liturgies context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Bibles
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

  @doc """
  Subscribes to public notifications for a single liturgy.
  """
  def subscribe(%Liturgy{} = liturgy) do
    Phoenix.PubSub.subscribe(CMS.PubSub, "liturgy:#{liturgy.id}")
  end

  defp broadcast(%Scope{organization: org}, message) do
    key = org.id

    Phoenix.PubSub.broadcast(CMS.PubSub, "user:#{key}:liturgies", message)
  end

  defp broadcast_public(%Liturgy{} = liturgy, message) do
    Phoenix.PubSub.broadcast(CMS.PubSub, "liturgy:#{liturgy.id}", message)
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
        preload: [blocks: [:song]]
      )

    query
    |> Repo.one!()
    |> populate_blocks()
  end

  @doc """
  Gets a single liturgy without scope checks for public viewing.

  Raises `Ecto.NoResultsError` if the Liturgy does not exist.
  """
  def get_public_liturgy!(id) do
    query =
      from(l in Liturgy,
        where: l.id == ^id,
        preload: [blocks: [:song]]
      )

    query
    |> Repo.one!()
    |> populate_blocks()
  end

  defp populate_blocks(%{blocks: blocks} = liturgy) do
    Map.put(
      liturgy,
      :blocks,
      blocks |> Enum.map(&populate_block/1) |> Enum.sort_by(& &1.position)
    )
  end

  defp populate_block(block) do
    Map.put(
      block,
      :resolved_body,
      case block.type do
        :passage -> Bibles.get_verses(block.title)
        :song -> get_in(block.song.body)
        _ -> block.body
      end
    )
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
           |> Repo.insert() do
      broadcast(scope, {:created, liturgy})
      {:ok, liturgy}
    end
  end

  @doc """
  Copy a liturgy.

  Returns a new liturgy with the same blocks as the source liturgy, with a service date
  set to the same day on next week, without checking whether there is already a liturgy
  for that day.
  """
  def get_copy!(%Scope{} = scope, id) do
    source = get_liturgy!(scope, id)

    source
    |> Liturgy.make_template()
    |> Map.put(:service_on, Date.add(source.service_on, 7))
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
           |> Repo.update() do
      broadcast(scope, {:updated, liturgy})
      broadcast_public(liturgy, {:updated, %{id: liturgy.id}})
      {:ok, liturgy}
    end
  end

  @doc """
  Deletes a liturgy.

  ## Examples

      iex> delete_liturgy(liturgy)
      {:ok, %Liturgy{}}

      iex> delete_liturgy( liturgy)
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

  @doc """
  Gets a single liturgy by service_on date.

  Returns `nil` if the Liturgy does not exist.
  """
  def get_last(%Scope{} = scope, service_date) do
    from(l in Liturgy,
      where: l.organization_id == ^scope.organization.id and l.service_on <= ^service_date,
      order_by: [desc: l.service_on],
      limit: 1
    )
    |> Repo.one()
  end
end
