defmodule CMSWeb.PrayerRequestLive.FormTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest

  @invalid_attrs %{body: ""}

  describe "New Prayer Request" do
    setup [:register_and_log_in_user]

    test "renders new prayer request form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prayers/new")

      assert has_element?(view, "form[phx-submit='save']")
    end

    test "creates prayer request and redirects to prayer wall", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prayers/new")

      form =
        form(view, "#prayer-request-form", prayer_request: %{body: "Please pray for my family."})

      {:ok, _redirected_view, html} = render_submit(form) |> follow_redirect(conn)

      assert html =~ "Prayer request created successfully."
    end

    test "fails to create prayer request with invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prayers/new")

      form = form(view, "#prayer-request-form", prayer_request: @invalid_attrs)
      render_submit(form)

      assert has_element?(view, "p", "can't be blank")
    end
  end
end
