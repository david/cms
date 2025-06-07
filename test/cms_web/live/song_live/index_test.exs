defmodule CMSWeb.SongLive.IndexTest do
  use CMSWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures
  import CMS.SongsFixtures

  setup do
    user = user_fixture()

    {:ok,
     conn: log_in_user(build_conn(), user), user: user, organization_id: user.organization_id}
  end

  describe "Songs LiveView (/songs)" do
    test "mounts with songs for the current organization, sorted alphabetically", %{
      conn: conn,
      organization_id: org_id
    } do
      song_c = song_fixture(%{title: "Song C", organization_id: org_id})
      song_a = song_fixture(%{title: "Song A", organization_id: org_id})
      song_b = song_fixture(%{title: "Song B", organization_id: org_id})

      {:ok, _view, html} = live(conn, ~p"/songs")

      assert html =~ song_a.title
      assert html =~ song_b.title
      assert html =~ song_c.title
    end

    test "displays message when no songs are found for the current organization", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/songs")

      assert html =~ "<p>No songs found for this organization.</p>"
      refute html =~ ~r/<li><a>.*?<\/a><\/li>/
    end
  end
end
