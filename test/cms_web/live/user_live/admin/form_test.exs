defmodule CMSWeb.UserLive.Admin.FormTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

  alias CMS.Accounts.User

  @moduledoc false

  setup %{conn: conn} do
    org = organization_fixture()
    admin = admin_fixture(%{}, org)

    %{conn: log_in_user(conn, admin), admin: admin}
  end

  describe "edit user" do
    test "updates the user's email", %{conn: conn, admin: admin} do
      user_to_edit =
        user_fixture(%{email: "old-email@example.com"}, admin.organization)
        |> CMS.Repo.preload(:family)

      {:ok, view, _html} = live(conn, ~p"/admin/users/#{user_to_edit}/edit")

      {:ok, _view, html} =
        view
        |> form("#invite-user-form",
          user: %{
            "email" => "new-email@example.com",
            "name" => user_to_edit.name,
            "family_id" => user_to_edit.family_id,
            "family_designation" => user_to_edit.family.designation
          }
        )
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Utilizador atualizado com sucesso."

      updated_user = CMS.Repo.get(User, user_to_edit.id)
      assert updated_user.email == "new-email@example.com"
    end
  end
end
