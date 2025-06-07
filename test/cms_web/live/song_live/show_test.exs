defmodule CMSWeb.SongLive.ShowTest do
  use CMSWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures
  import CMS.SongsFixtures

  setup do
    user = user_fixture()

    {:ok,
     conn: log_in_user(build_conn(), user), user: user, organization_id: user.organization_id}
  end

  describe "Song Show LiveView (/songs/:id)" do
    test "mounts with the requested song", %{conn: conn, organization_id: org_id} do
      song = song_fixture(%{organization_id: org_id})

      {:ok, _view, html} = live(conn, ~p"/songs/#{song.id}")

      assert html =~ song.title
    end
  end
end
