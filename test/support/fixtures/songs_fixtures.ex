defmodule CMS.SongsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  song entities.
  """

  alias CMS.Songs.Song
  alias CMS.Repo

  @doc """
  Generate a song.
  """
  def song_fixture(attrs \\ %{}) do
    {:ok, song} =
      %Song{
        title: "Test Song #{System.unique_integer()}"
      }
      |> Map.merge(attrs)
      |> Repo.insert()

    song
  end
end
