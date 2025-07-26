defmodule CMSWeb.BottomDock do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: CMSWeb.Endpoint, router: CMSWeb.Router
  use Gettext, backend: CMSWeb.Gettext

  import CMSWeb.CoreComponents

  attr :current_scope, :map, required: true

  def bottom_dock(assigns) do
    ~H"""
    <div class="dock dock-center sm:hidden z-40 print:hidden">
      <.link navigate={~p"/liturgies/latest"} class="dock-item">
        <.icon name="hero-book-open-solid" class="w-5 h-5" />
        <span class="dock-label">{gettext("Liturgy")}</span>
      </.link>
      <.link navigate={~p"/songs"} class="dock-item">
        <.icon name="hero-musical-note-solid" class="w-5 h-5" />
        <span class="dock-label">{gettext("Songs")}</span>
      </.link>
      <.link :if={@current_scope.user} navigate={~p"/prayers"} class="dock-item">
        <.icon name="hero-user-group-solid" class="w-5 h-5" />
        <span class="dock-label">{gettext("Prayers")}</span>
      </.link>
      <.link id="settings-button" class="dock-item">
        <.icon name="hero-cog-6-tooth-solid" class="w-5 h-5" />
        <span class="dock-label">{gettext("Settings")}</span>
      </.link>
    </div>
    """
  end
end
