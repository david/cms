defmodule CMSWeb.LiturgyController do
  use CMSWeb, :controller

  alias CMS.Liturgies

  def latest(conn, _params) do
    scope = conn.assigns.current_scope
    # TODO: Fails if there are no liturgies
    liturgy_id = scope |> Liturgies.get_last(Date.utc_today()) |> Map.get(:id)

    redirect(conn, to: ~p"/liturgies/#{liturgy_id}")
  end
end
