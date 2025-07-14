defmodule CMSWeb.LiturgyLive.Admin.IndexTest do
  use CMSWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures
  import CMS.LiturgiesFixtures

  describe "Index" do
    test "redirects if user is not an admin", %{conn: conn} do
      user = user_fixture()
      conn = log_in_user(conn, user)
      {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/admin/liturgies")
    end

    @describetag :as_admin
    setup %{conn: conn} do
      admin = admin_fixture()
      conn = log_in_user(conn, admin)
      {:ok, conn: conn, user: admin}
    end

    test "lists all liturgies for an admin", %{conn: conn, user: admin} do
      scope = CMS.Accounts.Scope.for_user(admin)
      liturgy = liturgy_fixture(scope)
      {:ok, _view, html} = live(conn, ~p"/admin/liturgies")

      assert html =~ "Listing Liturgies"
      assert html =~ liturgy.service_on |> to_string()
    end
  end
end
