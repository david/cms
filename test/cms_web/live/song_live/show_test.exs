defmodule CMSWeb.SongLive.ShowTest do
  use CMSWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CMS.SongsFixtures

  setup :register_and_log_in_user

  describe "Song Show LiveView (/songs/:id)" do
    test "mounts with the requested song", %{conn: conn, scope: scope} do
      song = song_fixture(%{}, scope)

      {:ok, _view, html} = live(conn, ~p"/songs/#{song.id}")

      assert html =~ song.title
    end
  end
end
