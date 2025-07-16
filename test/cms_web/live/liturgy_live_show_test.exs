defmodule CMSWeb.LiturgyLive.ShowTest do
  use CMSWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import CMS.LiturgiesFixtures

  alias CMS.Repo

  @moduletag :liturgies

  setup :register_and_log_in_user

  test "updates when a public broadcast is received", %{conn: conn, scope: scope} do
    liturgy = liturgy_fixture(scope, %{"service_on" => ~D[2025-04-20]})

    {:ok, view, _html} = live(conn, ~p"/liturgies/#{liturgy}")

    assert render(view) =~ "2025-04-20"

    # Simulate an update from another source
    updated_liturgy =
      liturgy
      |> Ecto.Changeset.change(%{service_on: ~D[2025-04-21]})
      |> Repo.update!()

    # Directly broadcast the message that the frontend should be listening for
    Phoenix.PubSub.broadcast(CMS.PubSub, "liturgy:#{liturgy.id}", {:updated, updated_liturgy})

    # Re-render and check for the updated content
    assert render(view) =~ "2025-04-21"
  end

  test "displays block titles in the sidebar", %{conn: conn, scope: scope} do
    liturgy = liturgy_fixture(scope)
    {:ok, view, _html} = live(conn, ~p"/liturgies/#{liturgy}")

    html = render(view)

    for block <- liturgy.blocks do
      assert html =~ "href=\"#block-#{block.id}\""
      assert html =~ block.title
    end
  end
end
