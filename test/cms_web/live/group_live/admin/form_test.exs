defmodule CMSWeb.GroupLive.Admin.FormTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

  alias CMS.Accounts

  @moduletag :admin

  setup %{conn: conn} do
    org = organization_fixture()
    admin = admin_fixture(%{}, org)

    %{conn: log_in_user(conn, admin), user: admin}
  end

  describe "New Group page" do
    test "renders the new group form", %{conn: conn, user: _admin} do
      {:ok, view, _html} = live(conn, ~p"/admin/groups/new")

      assert view |> element("h1") |> render() =~ "Novo Grupo"
      assert view |> element("form") |> render() =~ "Nome"
      assert view |> element("form") |> render() =~ "Descrição"
    end

    test "creates a new group with valid data", %{conn: conn, user: admin} do
      {:ok, view, _html} = live(conn, ~p"/admin/groups/new")

      view
      |> form("#group-form",
        group: %{"name" => "Test Group", "description" => "Test Description"}
      )
      |> render_submit()

      assert_redirect(view, ~p"/admin/groups")

      scope = %Accounts.Scope{organization: admin.organization}
      [group] = Accounts.list_groups(scope)
      assert group.name == "Test Group"
      assert group.description == "Test Description"
    end

    test "rerenders the form with an error for invalid data", %{conn: conn, user: _admin} do
      {:ok, view, _html} = live(conn, ~p"/admin/groups/new")

      html =
        view
        |> form("#group-form", group: %{"name" => ""})
        |> render_submit()

      assert html =~ "não pode estar em branco"
    end
  end
end
