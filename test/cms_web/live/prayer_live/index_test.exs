defmodule CMSWeb.PrayerLive.IndexTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest

  @moduletag :capture_log

  describe "Index" do
    test "displays an empty state message when there are no prayer requests", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prayers")

      assert has_element?(view, "[data-testid=empty-state]")
      assert has_element?(view, "[data-testid=new-prayer-request-link]")
    end
  end
end
