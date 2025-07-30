defmodule CMSWeb.PrayerRequestLiveTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

  @moduledoc """
  E2E tests for prayer requests.
  """

  describe "new prayer request form" do
    setup :log_in_user

    test "shows and hides group selector based on visibility", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prayers/new")

      refute view |> element(~s(select[name="prayer_request[group_id]"])) |> has_element?()

      view
      |> element("form")
      |> render_change(%{prayer_request: %{visibility: "group"}})

      assert view |> element(~s(select[name="prayer_request[group_id]"])) |> has_element?()
    end
  end

  defp log_in_user(%{conn: conn}) do
    organization = organization_fixture()
    user = user_fixture(%{}, organization)
    conn = log_in_user(conn, user)
    {:ok, conn: conn, user: user}
  end
end
