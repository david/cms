defmodule CMSWeb.SongLive.IndexTest do
  use CMSWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  import CMS.SongsFixtures

  setup :register_and_log_in_user

  describe "Songs LiveView (/songs)" do
    test "mounts with songs for the current organization, sorted alphabetically", %{
      conn: conn,
      scope: scope
    } do
      song_c = song_fixture(%{title: "Song C"}, scope)
      song_a = song_fixture(%{title: "Song A"}, scope)
      song_b = song_fixture(%{title: "Song B"}, scope)

      {:ok, _view, html} = live(conn, ~p"/songs")

      assert html =~ song_a.title
      assert html =~ song_b.title
      assert html =~ song_c.title
    end

    test "displays message when no songs are found for the current organization", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/songs")

      assert html =~ "<p>Nenhuma música encontrada para esta organização.</p>"
      refute html =~ ~r/<li><a>.*?<\/a><\/li>/
    end
  end
end
