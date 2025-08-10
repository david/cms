defmodule CMSWeb.SongLive.Admin.IndexTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

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
    test "when no songs exist, prompts to add first song", %{conn: conn} do
      org = organization_fixture()
      admin = admin_fixture(%{}, org)

      conn = log_in_user(conn, admin)

      {:ok, view, html} = live(conn, ~p"/admin/songs")

      assert html =~ "Ainda não há músicas!"
      assert html =~ "Que tal adicionar a primeira?"
      refute has_element?(view, "table")
    end
  end
end
