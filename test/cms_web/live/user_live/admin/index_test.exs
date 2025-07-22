defmodule CMSWeb.UserLive.Admin.IndexTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

  describe "invitation action" do
    setup do
      organization = organization_fixture()
      admin = admin_fixture(%{}, organization)
      confirmed_user = user_fixture(%{name: "Confirmed User"}, organization)
      unconfirmed_user = unconfirmed_user_fixture(%{name: "Unconfirmed User"}, organization)

      {:ok,
       admin: admin,
       confirmed_user: confirmed_user,
       unconfirmed_user: unconfirmed_user,
       organization: organization}
    end

    test "admin can send invitation to unconfirmed user", %{
      conn: conn,
      admin: admin,
      unconfirmed_user: unconfirmed_user
    } do
      {:ok, view, _html} =
        conn
        |> log_in_user(admin)
        |> live(~p"/admin/users")

      assert view |> has_element?("#user-#{unconfirmed_user.id} a", "Convidar")

      view
      |> element("#user-#{unconfirmed_user.id} a", "Convidar")
      |> render_click()

      assert render(view) =~ "Convite enviado para #{unconfirmed_user.email}"
    end

    test "invite button is not rendered for confirmed users", %{
      conn: conn,
      admin: admin,
      confirmed_user: confirmed_user
    } do
      {:ok, view, _html} =
        conn
        |> log_in_user(admin)
        |> live(~p"/admin/users")

      refute view |> has_element?("#user-#{confirmed_user.id} a", "Convidar")
    end
  end
end
