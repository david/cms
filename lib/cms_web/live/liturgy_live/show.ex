defmodule CMSWeb.LiturgyLive.Show do
  use CMSWeb, :live_view

  alias CMS.Liturgies
  alias Earmark
  alias CMSWeb.LiturgyComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} liturgy={@liturgy}>
      <:sidebar_bottom>
        <li :if={@qr_code_svg} class="mt-6 flex flex-col items-center">
          <img
            src={"data:image/svg+xml;base64,#{@qr_code_svg}"}
            alt="QR Code"
            class="w-48 h-48 rounded"
          />
        </li>
      </:sidebar_bottom>
      <.header>
        {gettext("Liturgy")}
        <p title="Service date" class="text-sm font-normal">{@liturgy.service_on}</p>
        <:actions>
          <%= if @current_scope.user && @current_scope.organization.id == @liturgy.organization_id do %>
            <.button variant="primary" navigate={~p"/admin/liturgies/#{@liturgy}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> {gettext("Edit")}
            </.button>
          <% end %>
        </:actions>
      </.header>

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

              <LiturgyComponents.verse_list verses={block.resolved_body} />
          <% end %>
        </div>
      </div>
    </.main_layout>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    liturgy = Liturgies.get_public_liturgy!(id)

    Liturgies.subscribe(liturgy)

    {:ok,
     socket
     |> assign(:page_title, gettext("Show Liturgy"))
     |> assign(:liturgy, liturgy)}
  end

  @impl true
  def handle_params(_params, uri, socket) do
    {:ok, qr_code_svg} = uri |> QRCode.create() |> QRCode.render(:svg)

    {:noreply, assign(socket, :qr_code_svg, Base.encode64(qr_code_svg))}
  end

  @impl true
  def handle_info(
        {:updated, %{id: liturgy_id}},
        %{assigns: %{liturgy: %{id: liturgy_id}}} = socket
      ) do
    # Re-fetch the liturgy to get all populated fields
    liturgy = Liturgies.get_public_liturgy!(liturgy_id)
    {:noreply, assign(socket, :liturgy, liturgy)}
  end

  def handle_info(
        {:deleted, %{id: id}},
        %{assigns: %{liturgy: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current liturgy was deleted.")
     |> push_navigate(to: ~p"/admin/liturgies")}
  end

  def handle_info({type, %CMS.Liturgies.Liturgy{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
