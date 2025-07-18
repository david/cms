defmodule CMSWeb.PrayerLive.Index do
  use CMSWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Pedidos de Oração")
     |> assign(:prayer_requests, [])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope}>
      <.header>
        Pedidos de Oração
        <:subtitle>
          Peçam, e será dado; busquem, e encontrarão; batam, e a porta será aberta.
        </:subtitle>
      </.header>

      <div class="space-y-4" data-testid="empty-state">
        <p>
          Ainda não há pedidos de oração.
          <.link href={~p"/prayers/new"} data-testid="new-prayer-request-link">
            Seja o primeiro a adicionar um!
          </.link>
        </p>
      </div>
    </.main_layout>
    """
  end
end
