defmodule CMSWeb.LiturgyLive.Show do
  use CMSWeb, :live_view

  alias CMS.Liturgies
  alias Earmark
  import CMSWeb.LiturgyComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <:nav_actions>
        <%= if @current_scope.user && @current_scope.organization.id == @liturgy.organization_id do %>
          <.button_nav
            path={~p"/admin/liturgies/#{@liturgy}/edit?return_to=show"}
            icon="hero-pencil-square"
          />
        <% end %>
      </:nav_actions>
      <:sidebar_top>
        <.liturgy_sidebar_nav liturgy={@liturgy} />
      </:sidebar_top>
      <:sidebar_bottom>
        <.liturgy_qr_code liturgy={@liturgy} />
      </:sidebar_bottom>

      <div class="space-y-10">
        <div :for={block <- @liturgy.blocks} id={"block-#{block.id}"} class="">
          <%= case block.type do %>
            <% :text -> %>
              <span :if={block.subtitle} class="text-xs uppercase text-gray-500">
                {block.subtitle}
              </span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
              <div :if={block.resolved_body} class="mt-4 prose max-w-none [&_p]:mb-6">
                {raw(Earmark.as_html!(block.resolved_body))}
              </div>
            <% :song -> %>
              <span class="text-xs uppercase text-gray-500">{gettext("Song")}</span>
              <.song title={block.title} body={block.resolved_body} />
            <% :passage -> %>
              <span class="text-xs uppercase text-gray-500">{block.subtitle}</span>
              <h3 class="text-lg font-medium">{block.title}</h3>

              <.verse_list verses={block.resolved_body} />
          <% end %>
        </div>
      </div>
    </.main_layout>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) when not is_nil(id) do
    liturgy = Liturgies.get_public_liturgy!(id)

    Liturgies.subscribe(liturgy)

    page_title = "Liturgia (#{liturgy.service_on})"

    {:ok,
     socket
     |> assign(:liturgy, liturgy)
     |> assign(:page_title, page_title)}
  end

  @impl true
  def mount(%{}, _session, socket) do
    liturgy_id =
      socket.assigns.current_scope |> Liturgies.get_last(Date.utc_today()) |> Map.get(:id)

    {:ok, redirect(socket, to: "/liturgies/#{liturgy_id}")}
  end

  @impl true
  def handle_info(
        {:updated, %{id: liturgy_id}},
        %{assigns: %{liturgy: %{id: liturgy_id}}} = socket
      ) do
    # Re-fetch the liturgy to get all populated fields
    liturgy = Liturgies.get_public_liturgy!(liturgy_id)
    page_title = "Liturgia (#{liturgy.service_on})"
    {:noreply, assign(socket, liturgy: liturgy, page_title: page_title)}
  end

  def handle_info(
        {:deleted, %{id: id}},
        %{assigns: %{liturgy: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, gettext("A liturgia atual foi removida."))
     |> push_navigate(to: ~p"/admin/liturgies")}
  end

  def handle_info({type, %CMS.Liturgies.Liturgy{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
