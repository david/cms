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

      <div class="flex flex-col items-center p-10">
        <.link href={~p"/liturgies/latest"} class="btn btn-primary self-stretch">Liturgias</.link>
        <.link navigate={~p"/songs"} class="btn btn-primary mt-4 self-stretch">Hinos</.link>
      </div>
    </.main_layout>
    """
  end
end
