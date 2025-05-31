defmodule CMSWeb.PageController do
  use CMSWeb, :controller
  alias CMS.Liturgies

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    scope = conn.assigns.current_scope
    today = Date.utc_today()
    liturgy = Liturgies.get_liturgy_by_date(scope, today)
    render(conn, :home, liturgy: liturgy, layout: false)
  end
end
