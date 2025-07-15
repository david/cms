defmodule CMSWeb.LiturgyLive.Admin.Index do
  use CMSWeb, :live_view

  alias CMS.Liturgies

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Liturgies
        <:actions>
          <.button variant="primary" navigate={~p"/admin/liturgies/new"}>
            <.icon name="hero-plus" /> New Liturgy
          </.button>
        </:actions>
      </.header>

      <.table
        id="liturgies"
        rows={@streams.liturgies}
        row_click={fn {_id, liturgy} -> JS.navigate(~p"/liturgies/#{liturgy}") end}
      >
        <:col :let={{_id, liturgy}} label="Service on">{liturgy.service_on}</:col>
        <:action :let={{_id, liturgy}}>
          <.link navigate={~p"/admin/liturgies/new?#{[tid: liturgy.id]}"}>
            Copy
          </.link>
        </:action>
        <:action :let={{_id, liturgy}}>
          <div class="sr-only">
            <.link navigate={~p"/liturgies/#{liturgy}"}>Show</.link>
          </div>
          <.link navigate={~p"/admin/liturgies/#{liturgy}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, liturgy}}>
          <.link
            phx-click={JS.push("delete", value: %{id: liturgy.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </.main_layout>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    Liturgies.subscribe_liturgies(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, "Listing Liturgies")
     |> stream(:liturgies, Liturgies.list_liturgies(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    liturgy = Liturgies.get_liturgy!(socket.assigns.current_scope, id)
    {:ok, _} = Liturgies.delete_liturgy(socket.assigns.current_scope, liturgy)

    {:noreply, stream_delete(socket, :liturgies, liturgy)}
  end

  @impl true
  def handle_info({type, %CMS.Liturgies.Liturgy{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply,
     stream(socket, :liturgies, Liturgies.list_liturgies(socket.assigns.current_scope),
       reset: true
     )}
  end
end
