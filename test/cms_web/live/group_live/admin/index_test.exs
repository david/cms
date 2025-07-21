defmodule CMSWeb.GroupLive.Admin.IndexTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

  setup do
    org = organization_fixture()
    user = user_fixture(%{role: :admin}, org)

    %{org: org, user: user}
  end

  describe "authorization" do
    test "redirects if not logged in", %{conn: conn, org: org} do
      conn = %{conn | host: org.hostname} |> get(~p"/admin/groups")

      assert redirected_to(conn) == ~p"/users/log-in"
    end

    test "redirects if logged in as a non-admin user", %{conn: conn, org: org} do
      user = user_fixture(%{role: :member}, org)

      conn =
        conn
        |> log_in_user(user)
        |> get(~p"/admin/groups")

      assert redirected_to(conn) == ~p"/"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "You are not authorized to access this page."
    end
  end

  describe "rendering" do
    test "displays the empty state message", %{conn: conn, user: user} do
      conn = conn |> log_in_user(user)
      {:ok, view, _html} = live(conn, ~p"/admin/groups")

      assert has_element?(view, "[data-testid=page-title]")
      assert has_element?(view, "[data-testid=empty-state]")
    end
  end
end
