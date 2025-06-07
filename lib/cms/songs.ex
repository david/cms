defmodule CMS.Songs do
  @moduledoc """
  The Songs context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo
  alias CMS.Songs.Song
  alias CMS.Accounts.Scope

  @doc """
  Returns the list of songs for the given scope's organization,
  sorted alphabetically by title.
  """
  def list_songs(%Scope{} = scope) do
    from(s in Song,
      where: s.organization_id == ^scope.organization.id,
      order_by: [asc: s.title]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single song.

  Raises `Ecto.NoResultsError` if the song does not exist.

  ## Examples

      iex> get_song!(scope, 123)
      %song{}

      iex> get_song!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_song!(%Scope{} = scope, id) do
    Repo.get_by!(Song, id: id, organization_id: scope.organization.id)
  end

  @doc """
  Suggests an existing song by title within the given scope's organization.
  Returns the song if found, otherwise nil.
  """
  def suggest(%Scope{organization: organization}, title) when is_binary(title) do
    from(s in Song,
      where: s.organization_id == ^organization.id and s.title == ^title,
      limit: 1
    )
    |> Repo.one()
  end

  def suggest(_, _), do: nil
end
