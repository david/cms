defmodule CMSWeb.LiturgyLiveTest do
  use CMSWeb.ConnCase

  import Phoenix.LiveViewTest
  import CMS.LiturgiesFixtures

  setup :register_and_log_in_user

  defp create_liturgy(%{scope: scope}) do
    liturgy = liturgy_fixture(scope)

    %{liturgy: liturgy}
  end

  describe "Index" do
    setup [:create_liturgy]

    test "lists all liturgies", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/liturgies")

      assert html =~ "Listing Liturgies"
    end

    test "saves new liturgy", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/liturgies")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Liturgy")
               |> render_click()
               |> follow_redirect(conn, ~p"/liturgies/new")

      assert render(form_live) =~ "New Liturgy"

      liturgy_date =
        Date.utc_today()
        |> Date.to_string()

      assert form_live
             |> form("#liturgy-form", liturgy: %{service_on: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#liturgy-form", liturgy: %{service_on: liturgy_date})
               |> render_submit()
               |> follow_redirect(conn, ~p"/liturgies")

      html = render(index_live)
      assert html =~ "Liturgy created successfully"
    end

    test "updates liturgy in listing", %{conn: conn, liturgy: liturgy} do
      {:ok, index_live, _html} = live(conn, ~p"/liturgies")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#liturgies-#{liturgy.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/liturgies/#{liturgy}/edit")

      assert render(form_live) =~ "Edit Liturgy"

      assert form_live
             |> form("#liturgy-form", liturgy: %{service_on: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#liturgy-form", liturgy: %{service_on: "2025-04-27"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/liturgies")

      html = render(index_live)
      assert html =~ "Liturgy updated successfully"
    end

    test "deletes liturgy in listing", %{conn: conn, liturgy: liturgy} do
      {:ok, index_live, _html} = live(conn, ~p"/liturgies")

      assert index_live |> element("#liturgies-#{liturgy.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#liturgies-#{liturgy.id}")
    end
  end

  describe "Show" do
    setup [:create_liturgy]

    test "displays liturgy", %{conn: conn, liturgy: liturgy} do
      {:ok, _show_live, html} = live(conn, ~p"/liturgies/#{liturgy}")

      assert html =~ "Liturgia"
      assert html =~ "#{liturgy.service_on}"
      assert html =~ "Opening Prayer"
      assert html =~ "Amazing Grace"
      assert html =~ "John 3:16"
    end

    test "updates liturgy and returns to show", %{conn: conn, liturgy: liturgy} do
      {:ok, show_live, _html} = live(conn, ~p"/liturgies/#{liturgy}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/liturgies/#{liturgy}/edit?return_to=show")

      assert render(form_live) =~ "Edit Liturgy"

      assert form_live
             |> form("#liturgy-form", liturgy: %{service_on: nil})
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#liturgy-form", liturgy: %{service_on: "2025-04-27"})
               |> render_submit()
               |> follow_redirect(conn, ~p"/liturgies/#{liturgy}")

      html = render(show_live)
      assert html =~ "Liturgy updated successfully"
    end
  end
end
