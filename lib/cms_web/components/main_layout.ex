defmodule CMSWeb.MainLayout do
  use Phoenix.Component
  use Gettext, backend: CMSWeb.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: CMSWeb.Endpoint,
    router: CMSWeb.Router

  import CMSWeb.CoreComponents

  alias Phoenix.LiveView.JS

  attr :flash, :map, default: %{}
  attr :current_scope, :map, required: true
  attr :page_title, :string, default: nil
  attr :liturgy, :map, default: nil
  attr :qr_code_svg, :string, default: nil

  slot :inner_block, required: true

  def main_layout(assigns) do
    ~H"""
    <div class="drawer">
      <input id="sidebar-drawer" type="checkbox" class="drawer-toggle" />
      <div class="drawer-content flex flex-col">
        <.navbar
          current_scope={@current_scope}
          page_title={@page_title}
          liturgy={@liturgy}
          qr_code_svg={@qr_code_svg}
        />
        <CMSWeb.Layouts.app flash={@flash} id="main-content" phx-hook="FontSizeApplier">
          {render_slot(@inner_block)}
        </CMSWeb.Layouts.app>
        <.pwa_install_banner />
      </div>
      <div class="drawer-side">
        <label for="sidebar-drawer" aria-label="close sidebar" class="drawer-overlay"></label>
        <.sidebar liturgy={@liturgy} qr_code_svg={@qr_code_svg} />
      </div>
    </div>
    """
  end

  attr :current_scope, :map, required: true
  attr :page_title, :string, default: nil
  attr :liturgy, :map, default: nil
  attr :qr_code_svg, :string, default: nil

  defp navbar(assigns) do
    ~H"""
    <div class="navbar">
      <div class="navbar-start">
        <label for="sidebar-drawer" class="btn btn-ghost z-[51]">
          <.icon name="hero-bars-3" class="h-5 w-5" />
        </label>
      </div>
      <div class="navbar-center">
        {@page_title}
      </div>
      <div class="navbar-end">
        <ul class="menu menu-horizontal">
          <.user_menu current_scope={@current_scope} />
        </ul>
      </div>
    </div>
    """
  end

  attr :current_scope, :map, required: true

  defp user_menu(assigns) do
    ~H"""
    <%= if @current_scope.user do %>
      <li class="dropdown dropdown-end">
        <div tabindex="0" role="button" class="btn btn-ghost btn-circle avatar placeholder">
          <div class="bg-neutral text-neutral-content rounded-full w-10">
            <span class="text-xl">
              {@current_scope.user.name |> String.first() |> String.upcase()}
            </span>
          </div>
        </div>
        <ul
          tabindex="0"
          class="dropdown-content menu p-2 shadow bg-base-100 rounded-box w-52 mt-4 z-[1]"
        >
          <li :if={@current_scope.user.role == :admin}>
            <.link href={~p"/users"}>Users</.link>
          </li>
          <li :if={@current_scope.user.role == :admin}>
            <.link href={~p"/admin/liturgies"}>Liturgies</.link>
          </li>
          <li><.link href={~p"/users/settings"}>Settings</.link></li>
          <li><.link href={~p"/users/log-out"} method="delete">Log out</.link></li>
        </ul>
      </li>
    <% else %>
      <li>
        <.link href={~p"/users/log-in"}>Log in</.link>
      </li>
    <% end %>
    """
  end

  defp pwa_install_banner(assigns) do
    ~H"""
    <div
      id="pwa-install-banner"
      class="fixed bottom-0 left-0 w-full bg-neutral text-neutral-content p-4 text-center z-[1000] hidden"
    >
      <p class="mb-2">{gettext("Do you want to install this app on your device?")}</p>
      <button onclick="window.handleInstallClick()" class="btn btn-primary mr-2">
        {gettext("Yes")}
      </button>
      <button onclick="window.hideInstallPromotion()" class="btn btn-ghost">
        {gettext("No")}
      </button>
    </div>
    """
  end

  attr :liturgy, :map, default: nil
  attr :qr_code_svg, :string, default: nil

  defp sidebar(assigns) do
    ~H"""
    <ul class="menu p-4 w-80 min-h-full bg-base-200 text-base-content">
      <!-- Sidebar content here -->
      <li class="flex flex-row justify-end">
        <div class="flex flex-1">&nbsp;</div>
        <div class="relative flex-0 flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full p-0 w-full gap-0">
          <div class="absolute w-[33%] h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-[33%] [[data-theme=dark]_&]:left-[66%] transition-[left]" />
          <button
            phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})}
            class="flex p-2"
          >
            <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
          </button>
          <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})} class="flex p-2">
            <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
          </button>
          <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})} class="flex p-2">
            <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
          </button>
        </div>
      </li>

      <li class="flex flex-row join join-horizontal justify-between items-center my-6 gap-2">
        <button
          id="liturgy-decrease-font-size"
          aria-label="Decrease font size"
          class="btn join-item flex-1"
        >
          <.icon name="hero-magnifying-glass-minus" class="size-5" />
        </button>
        <button
          id="liturgy-increase-font-size"
          aria-label="Increase font size"
          class="btn join-item flex-1"
        >
          <.icon name="hero-magnifying-glass-plus" class="size-5" />
        </button>
      </li>

      <li><.link href={~p"/liturgy"}>Liturgia</.link></li>
      <li><.link navigate={~p"/songs"}>Hinos</.link></li>

      <li class="flex-grow bg-transparent"></li>

      <li :if={@liturgy && @qr_code_svg} class="mt-6 flex flex-col items-center">
        <img
          src={"data:image/svg+xml;base64,#{@qr_code_svg}"}
          alt="QR Code"
          class="w-48 h-48 rounded"
        />
      </li>
    </ul>
    """
  end
end
