defmodule CMSWeb.PrayerRequestLive.FormTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.AccountsFixtures

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
        form(view, "#prayer-request-form",
          prayer_request: %{body: "Por favor, orem pela minha família."}
        )

      {:ok, _redirected_view, html} = render_submit(form) |> follow_redirect(conn)

      assert html =~ "Pedido de oração criado com sucesso."
    end

    test "fails to create prayer request with invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/prayers/new")

      form = form(view, "#prayer-request-form", prayer_request: @invalid_attrs)
      render_submit(form)

      assert has_element?(view, "p", "não pode estar em branco")
    end
  end

  describe "authentication" do
    test "redirects unauthenticated users to the login page" do
      organization = organization_fixture()

      conn =
        build_conn()
        |> Map.put(:host, organization.hostname)
        |> get(~p"/prayers/new")

      assert redirected_to(conn) == ~p"/users/log-in"
    end
  end
end
