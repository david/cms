defmodule CMSWeb.LiturgyLive.Show do
  use CMSWeb, :live_view

  alias CMS.Liturgies

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {gettext("Liturgy")}
        <p title="Service date" class="text-sm font-normal">{@liturgy.service_on}</p>
        <:actions>
          <.button navigate={~p"/liturgies"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <%= if get_in(@current_scope.organization.id) == @liturgy.organization_id do %>
            <.button variant="primary" navigate={~p"/liturgies/#{@liturgy}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> {gettext("Edit")}
            </.button>
          <% end %>
        </:actions>
      </.header>

      <div class="space-y-10">
        <div :for={block <- @liturgy.liturgy_blocks} class="">
          <%= case block.type do %>
            <% :text -> %>
              <span :if={block.subtitle} class="text-xs uppercase text-gray-500">
                {block.subtitle}
              </span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
              <p :if={block.body} class="mt-4">{block.body}</p>
            <% :song -> %>
              <span class="text-xs uppercase text-gray-500">{gettext("Song")}</span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
              <pre :if={block.body} class="mt-4 whitespace-pre-wrap font-sans"><%= block.body %></pre>
            <% :passage -> %>
              <span :if={block.subtitle} class="text-xs uppercase text-gray-500">
                {block.subtitle}
              </span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
          <% end %>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    Liturgies.subscribe_liturgies(socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:page_title, gettext("Show Liturgy"))
     |> assign(
       :liturgy,
       Liturgies.get_liturgy!(socket.assigns.current_scope, id)
     )}
  end

  @impl true
  def handle_info(
        {:updated, %CMS.Liturgies.Liturgy{id: id} = liturgy},
        %{assigns: %{liturgy: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :liturgy, liturgy)}
  end

  def handle_info(
        {:deleted, %CMS.Liturgies.Liturgy{id: id}},
        %{assigns: %{liturgy: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current liturgy was deleted.")
     |> push_navigate(to: ~p"/liturgies")}
  end

  def handle_info({type, %CMS.Liturgies.Liturgy{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
