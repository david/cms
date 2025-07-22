defmodule CMSWeb.PrayerLiveTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures
  import CMS.PrayersFixtures

  @moduletag :live_view

  setup do
    organization = organization_fixture()
    user = user_fixture(%{}, organization)
    scope = user_scope_fixture(user)

    {:ok,
     conn: log_in_user(build_conn(), user), user: user, scope: scope, organization: organization}
  end

  describe "Prayer Wall" do
    test "shows empty state when there are no prayer requests", %{conn: conn} do
      {:ok, view, html} = live(conn, ~p"/prayers")

      assert html =~ "Não existem pedidos de oração."
      assert has_element?(view, "[data-testid=empty-state]")
      refute has_element?(view, "[data-testid=prayer-requests-list]")
    end

    test "lists prayer requests from the user's organization", %{
      conn: conn,
      user: user,
      organization: org
    } do
      prayer_request_fixture(%{
        body: "Por favor, orem pela minha família.",
        user: user,
        organization: org
      })

      {:ok, view, html} = live(conn, ~p"/prayers")

      assert html =~ "Por favor, orem pela minha família."
      assert has_element?(view, "[data-testid=prayer-requests-list]")
      refute has_element?(view, "[data-testid=empty-state]")
    end

    test "does not list prayer requests from other organizations", %{
      conn: conn,
      user: user,
      organization: org
    } do
      prayer_request_fixture(%{
        body: "Isto deve ser visível.",
        user: user,
        organization: org
      })

      other_org = organization_fixture(%{name: "Other Organization"})

      other_user =
        user_fixture(
          %{
            organization_id: other_org.id,
            email: "other@example.com"
          },
          other_org
        )

      prayer_request_fixture(%{
        body: "Isto não deve ser visível.",
        user: other_user,
        organization: other_org
      })

      {:ok, view, html} = live(conn, ~p"/prayers")

      assert html =~ "Isto deve ser visível."
      refute html =~ "Isto não deve ser visível."
      assert has_element?(view, "[data-testid=prayer-requests-list]")
      refute has_element?(view, "[data-testid=empty-state]")
    end
  end

  describe "authentication" do
    test "redirects unauthenticated users to the login page" do
      organization = organization_fixture()

      conn =
        build_conn()
        |> Map.put(:host, organization.hostname)
        |> get(~p"/prayers")

      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end
end
