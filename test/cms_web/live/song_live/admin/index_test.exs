defmodule CMSWeb.SongLive.Admin.IndexTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures
  import CMS.SongsFixtures

  describe "as a logged-out user" do
    test "is redirected to the login page", %{conn: conn} do
      organization_fixture(%{hostname: "www.example.com"})
      conn = get(conn, ~p"/admin/songs")

      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end

  describe "as a non-admin user" do
    test "is redirected away", %{conn: conn} do
      org = organization_fixture()
      user = user_fixture(%{}, org)
      conn = log_in_user(conn, user)
      conn = get(conn, ~p"/admin/songs")

      assert redirected_to(conn) == ~p"/"
    end
  end

  describe "as an admin" do
    setup :register_and_log_in_admin

    test "when no songs exist, it renders an empty table", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/songs")

      assert has_element?(view, "table")
      refute has_element?(view, "tbody tr")
    end

    test "lists all songs", %{conn: conn, scope: scope} do
      song = song_fixture(%{}, scope)

      {:ok, view, _html} = live(conn, ~p"/admin/songs")

      assert has_element?(view, "td", song.title)
    end
  end
end
