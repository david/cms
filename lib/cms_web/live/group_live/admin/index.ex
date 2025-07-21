defmodule CMSWeb.GroupLive.Admin.Index do
  use CMSWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <.header testid="page-title">
      {gettext("Grupos")}
    </.header>

    <div class="card">
      <div class="card-body">
        <p data-testid="empty-state">{gettext("Nenhum grupo encontrado.")}</p>
      </div>
    </div>
    """
  end
end
