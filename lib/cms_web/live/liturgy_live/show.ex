defmodule CMSWeb.LiturgyLive.Show do
  use CMSWeb, :live_view

  alias CMS.Liturgies

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Liturgy {@liturgy.id}
        <:subtitle>This is a liturgy record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/liturgies"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/liturgies/#{@liturgy}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit liturgy
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Service on">{@liturgy.service_on}</:item>
      </.list>

      <h2 class="mt-6 mb-4 text-xl font-semibold">Liturgy Blocks</h2>
      <div class="space-y-4">
        <div :for={block <- @liturgy.liturgy_blocks} class="p-4">
          <%= case block.type do %>
            <% :text -> %>
              <span class="text-xs uppercase text-gray-500">Text</span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
              <h4 :if={block.subtitle} class="text-md italic">{block.subtitle}</h4>
              <p :if={block.body} class="mt-2">{block.body}</p>
            <% :song -> %>
              <span class="text-xs uppercase text-gray-500">Song</span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
              <pre :if={block.body} class="mt-2 whitespace-pre-wrap"><%= block.body %></pre>
            <% :passage -> %>
              <span class="text-xs uppercase text-gray-500">Passage</span>
              <h3 :if={block.title} class="text-lg font-medium">{block.title}</h3>
              <h4 :if={block.subtitle} class="text-md italic">{block.subtitle}</h4>
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
     |> assign(:page_title, "Show Liturgy")
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
