defmodule CMSWeb.BottomDockTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest
  import CMSWeb.BottomDock

  describe "bottom_dock/1" do
    test "renders prayers button for logged in users" do
      assigns = %{current_scope: %{user: %{}}}
      html = render_component(&bottom_dock/1, assigns)
      assert html =~ ~s(<a href="/prayers")
    end

    test "does not render prayers button for visitors" do
      assigns = %{current_scope: %{user: nil}}
      html = render_component(&bottom_dock/1, assigns)
      refute html =~ ~s(<a href="/prayers")
    end
  end
end
