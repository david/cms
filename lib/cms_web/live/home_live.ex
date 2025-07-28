defmodule CMSWeb.HomeLive do
  use CMSWeb, :live_view

  alias CMS.Liturgies

  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    today = Date.utc_today()
    liturgy = Liturgies.get_last(scope, today)

    socket =
      assign(socket,
        liturgy: liturgy,
        page_title: "Home"
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.main_layout current_scope={@current_scope} page_title={@page_title}>
      <Layouts.flash_group flash={@flash} />

      <div class="flex items-center justify-center h-full">
        <p class="text-lg pb-24">Um dia esta página mostrará qualquer coisa útil.</p>
      </div>
    </.main_layout>
    """
  end
end
