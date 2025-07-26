defmodule CMSWeb.Navbar do
  use Phoenix.Component
  use Gettext, backend: CMSWeb.Gettext

  use Phoenix.VerifiedRoutes,
    endpoint: CMSWeb.Endpoint,
    router: CMSWeb.Router

  import CMSWeb.CoreComponents

  @doc """
  Renders a navigation button.

  ## Examples

      <.button_nav path={~p"/prayers/new"} icon="hero-plus-solid" />
      <.button_nav path={~p"/prayers/edit"} icon="hero-pencil-square" />

  """
  attr :path, :any, required: true
  attr :icon, :string, required: true

  def button_nav(assigns) do
    ~H"""
    <li>
      <.link patch={@path}>
        <.icon name={@icon} class="h-5 w-5" />
      </.link>
    </li>
    """
  end

  attr :current_scope, :map, required: true
  attr :page_title, :string, default: nil
  attr :qr_code_svg, :string, default: nil
  attr :show_sidebar_button, :boolean, default: true
  slot :actions, required: false

  def navbar(assigns) do
    ~H"""
    <div class="sticky top-0 z-80 px-2 flex items-center flex-shrink-0 bg-base-100 shadow-md">
      <.hamburger_button :if={@show_sidebar_button} />
      <div class="navbar z-50">
        <div class="navbar-start">
          <span class="font-medium">{@page_title}</span>
        </div>
        <div class="navbar-end">
          <ul class="menu menu-horizontal">
            {render_slot(@actions)}
            <.user_menu current_scope={@current_scope} />
          </ul>
        </div>
      </div>
    </div>
    """
  end

  def hamburger_button(assigns) do
    ~H"""
    <label for="sidebar-drawer" class="btn btn-ghost mx-1 px-2 z-100">
      <.icon name="hero-bars-3" class="h-5 w-5" />
    </label>
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
            <.link href={~p"/admin/users"}>{gettext("Utilizadores")}</.link>
          </li>
          <li :if={@current_scope.user.role == :admin}>
            <.link href={~p"/admin/liturgies"}>{gettext("Liturgias")}</.link>
          </li>
          <li><.link href={~p"/users/settings"}>{gettext("Definições")}</.link></li>
          <li><.link href={~p"/users/log-out"} method="delete">{gettext("Sair")}</.link></li>
        </ul>
      </li>
    <% else %>
      <li>
        <.link href={~p"/users/log-in"}>{gettext("Iniciar sessão")}</.link>
      </li>
    <% end %>
    """
  end
end
