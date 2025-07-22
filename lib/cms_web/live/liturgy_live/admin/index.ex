defmodule CMSWeb.LiturgyLive.Admin.Index do
  use CMSWeb, :live_view

  alias CMS.Liturgies

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <:nav_actions>
        <li>
          <.button_nav path={~p"/admin/liturgies/new"} icon="hero-plus-solid" />
        </li>
      </:nav_actions>

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
end
