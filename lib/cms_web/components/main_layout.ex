defmodule CMSWeb.MainLayout do
  use Phoenix.Component
  use Gettext, backend: CMSWeb.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: CMSWeb.Endpoint,
    router: CMSWeb.Router

  import CMSWeb.CoreComponents
  import CMSWeb.Navbar
  import CMSWeb.BottomDock
  import CMSWeb.Settings

  attr :flash, :map, default: %{}
  attr :current_scope, :map, required: true
  attr :page_title, :string, default: nil
  attr :qr_code_svg, :string, default: nil

  slot :inner_block, required: true
  slot :sidebar_top, required: false
  slot :sidebar_bottom, required: false
  slot :nav_actions, required: false

  def main_layout(assigns) do
    ~H"""
    <div class="drawer" id="content-wrapper">
      <input id="sidebar-drawer" type="checkbox" class="drawer-toggle" />
      <div id="drawer-content" class="drawer-content flex flex-col h-screen" phx-hook="SettingsDrawer">
        <.navbar
          current_scope={@current_scope}
          page_title={@page_title}
          qr_code_svg={@qr_code_svg}
          show_sidebar_button={@sidebar_top != [] or @sidebar_bottom != []}
        >
          <:actions>
            {render_slot(@nav_actions)}
          </:actions>
        </.navbar>
        <div
          id="main-content"
          class="main-margins flex-grow print:overflow-y-visible overflow-y-auto pb-16 sm:pb-0"
          phx-hook="FontSizeApplier"
        >
          <CMSWeb.Layouts.app flash={@flash}>
            {render_slot(@inner_block)}
          </CMSWeb.Layouts.app>
        </div>
        <.pwa_install_banner />
        <.pwa_ios_install_banner />
        <.drawer show={false} />
        <.bottom_dock current_scope={@current_scope} />
      </div>
      <div id="sidebar-container" class="drawer-side z-modal" phx-hook="Sidebar">
        <label for="sidebar-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
        <.sidebar qr_code_svg={@qr_code_svg}>
          <:sidebar_top>
            {render_slot(@sidebar_top)}
          </:sidebar_top>
          <:sidebar_bottom>
            {render_slot(@sidebar_bottom)}
          </:sidebar_bottom>
        </.sidebar>
      </div>
    </div>
    """
  end

  defp pwa_install_banner(assigns) do
    ~H"""
    <div
      id="pwa-install-banner"
      class="fixed bottom-0 left-0 w-full bg-neutral text-neutral-content p-4 text-center z-modal hidden"
      phx-update="ignore"
    >
      <p class="mb-2">{gettext("Deseja instalar esta aplicação no seu dispositivo?")}</p>
      <.button onclick="window.handleInstallClick()" class="mr-2">
        {gettext("Sim")}
      </.button>
      <.button onclick="window.hideInstallPromotion()" variant="ghost">
        {gettext("Não")}
      </.button>
    </div>
    """
  end

  defp pwa_ios_install_banner(assigns) do
    ~H"""
    <div
      id="pwa-ios-install-banner"
      class="fixed bottom-0 left-0 w-full bg-neutral text-neutral-content p-4 text-center z-modal hidden"
      phx-update="ignore"
    >
      <p class="mb-2">
        {gettext(
          "Para instalar esta aplicação no seu dispositivo, toque no botão Partilhar e de seguida em 'Adicionar ao ecrã principal'."
        )}
      </p>
      <.button onclick="window.hideIosInstallPromotion()" variant="ghost">
        {gettext("Ignorar")}
      </.button>
    </div>
    """
  end

  attr :qr_code_svg, :string, default: nil
  slot :sidebar_top, required: false
  slot :sidebar_bottom, required: false

  defp sidebar(assigns) do
    ~H"""
    <ul class="menu py-4 px-2 w-80 min-h-full bg-base-200 text-base-content">
      <li class="flex flex-row justify-start">
        <.hamburger_button />
      </li>

      {render_slot(@sidebar_top)}

      <li class="flex-grow bg-transparent"></li>

      {render_slot(@sidebar_bottom)}
    </ul>
    """
  end
end
