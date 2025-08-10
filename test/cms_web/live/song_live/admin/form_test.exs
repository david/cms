defmodule CMSWeb.SongLive.Admin.FormTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.SongsFixtures

  alias CMS.Songs
  alias CMS.Accounts.Scope

  describe "as an admin" do
    setup :register_and_log_in_admin

    test "updates a song with valid data", %{conn: conn, user: admin} do
      scope = Scope.for_user(admin, admin.organization)
      song = song_fixture(%{}, scope)

      {:ok, view, _html} = live(conn, ~p"/admin/songs/#{song}/edit")

      {:ok, _view, html} =
        view
        |> form("#song-form", song: %{title: "New Title", body: "New Body"})
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Música actualizada com sucesso."
      assert html =~ "New Title"
      assert Songs.get_song!(scope, song.id).title == "New Title"
    end

    test "shows a validation error when the title is blank", %{conn: conn, user: admin} do
      scope = Scope.for_user(admin, admin.organization)
      song = song_fixture(%{}, scope)

      {:ok, view, _html} = live(conn, ~p"/admin/songs/#{song}/edit")

      html =
        view
        |> form("#song-form", song: %{title: ""})
        |> render_submit()

      assert html =~ "não pode estar em branco"
    end
  end
end
