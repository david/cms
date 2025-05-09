defmodule CMSWeb.LiturgyController do
  use CMSWeb, :controller

  alias CMS.Liturgies

  def latest(conn, _params) do
    scope = conn.assigns.current_scope
    liturgy_id = Liturgies.get_latest_liturgy_id(scope)

    redirect(conn, to: ~p"/liturgies/#{liturgy_id}")
  end
end
