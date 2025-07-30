defmodule CMSWeb.PrayerLive.Index do
  use CMSWeb, :live_view

  alias CMS.Prayers

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope

    {:ok,
     socket
     |> assign(:current_scope, scope)
     |> assign(:page_title, "Pedidos de oração")
     |> assign(:prayer_requests, Prayers.list_prayer_requests(scope))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <:nav_actions>
        <.button_nav path={~p"/prayers/new"} icon="hero-plus-solid" />
      </:nav_actions>

      <div class="space-y-4">
        <%= if @prayer_requests == [] do %>
          <div class="mt-6">
            <p class="text-center" data-testid="empty-state">
              Não existem pedidos de oração.<br />
              <.link href={~p"/prayers/new"} class="link" data-testid="new-prayer-request-link">
                Crie um aqui.
              </.link>
            </p>
          </div>
        <% else %>
          <ul class="list" data-testid="prayer-requests-list">
            <%= for prayer_request <- @prayer_requests do %>
              <li class="list-row">
                <div class="list-col-grow">
                  <div class="flex items-center justify-between gap-4">
                    <h3 class="font-semibold">{prayer_request.user.name}</h3>
                    <p class="text-sm text-base-content/60 whitespace-nowrap">
                      {prayer_request.inserted_at}
                    </p>
                  </div>
                  <p class="text-base-content/80 pt-2">{prayer_request.body}</p>
                </div>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </.main_layout>
    """
  end
end
