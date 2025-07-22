defmodule CMSWeb.PrayerLive.Index do
  use CMSWeb, :live_view

  alias CMS.Prayers

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Pedidos de Oração")
     |> assign(:prayer_requests, Prayers.list_prayer_requests(socket.assigns.current_scope))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope}>
      <:nav_actions>
        <li>
          <.button_add path={~p"/prayers/new"} />
        </li>
      </:nav_actions>

      <div class="space-y-4">
        <%= if @prayer_requests == [] do %>
          <div class="card bg-base-200">
            <div class="card-body items-center text-center">
              <p data-testid="empty-state">
                Ainda não há pedidos de oração.
              </p>
              <.link
                href={~p"/prayers/new"}
                class="btn btn-primary btn-sm mt-2"
                data-testid="new-prayer-request-link"
              >
                Seja o primeiro a adicionar um!
              </.link>
            </div>
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
