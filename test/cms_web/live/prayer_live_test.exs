defmodule CMSWeb.PrayerLiveTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

  alias CMS.Prayers.PrayerRequest
  alias CMS.Repo

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

      assert html =~ "Ainda não há pedidos de oração."
      assert has_element?(view, "[data-testid=empty-state]")
      refute has_element?(view, "[data-testid=prayer-requests-list]")
    end

    test "lists prayer requests from the user's organization", %{
      conn: conn,
      user: user,
      organization: org
    } do
      Repo.insert!(%PrayerRequest{
        body: "Please pray for my family.",
        user_id: user.id,
        organization_id: org.id
      })

      {:ok, view, html} = live(conn, ~p"/prayers")

      assert html =~ "Please pray for my family."
      assert has_element?(view, "[data-testid=prayer-requests-list]")
      refute has_element?(view, "[data-testid=empty-state]")
    end

    test "does not list prayer requests from other organizations", %{
      conn: conn,
      user: user,
      organization: org
    } do
      Repo.insert!(%PrayerRequest{
        body: "This should be visible.",
        user_id: user.id,
        organization_id: org.id
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

      Repo.insert!(%PrayerRequest{
        body: "This should not be visible.",
        user_id: other_user.id,
        organization_id: other_org.id
      })

      {:ok, view, html} = live(conn, ~p"/prayers")

      assert html =~ "This should be visible."
      refute html =~ "This should not be visible."
      assert has_element?(view, "[data-testid=prayer-requests-list]")
      refute has_element?(view, "[data-testid=empty-state]")
    end
  end
end
