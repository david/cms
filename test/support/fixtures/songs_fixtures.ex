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
          title: "Amazing Grace",
          body: "Amazing grace! How sweet the sound\nThat saved a wretch like me!\nI once was lost, but now am found;\nWas blind, but now I see.\n"
        }),
        scope
      )
      |> Repo.insert()

    song
  end
end
