defmodule CMS.SongsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CMS.Songs` context.
  """

  alias CMS.Songs.Song
  alias CMS.Repo

  def song_fixture(attrs \\ %{}, scope) do
    {:ok, song} =
      %Song{}
      |> Song.changeset(
        attrs
        |> Enum.into(%{
          title: "Amazing Grace"
        }),
        scope
      )
      |> Repo.insert()

    song
  end
end
