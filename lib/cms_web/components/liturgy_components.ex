defmodule CMSWeb.LiturgyComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: CMSWeb.Endpoint,
    router: CMSWeb.Router

  import CMSWeb.CoreComponents
  alias Phoenix.LiveView.JS
  alias CMS.Liturgies.Liturgy

  attr :verses, :map, required: true

  def verse_list(assigns) do
    ~H"""
    <div>
      <%= for %{verse_number: number, body: body} <- (@verses || []) do %>
        <span class="align-super text-xs text-neutral-500">{number}</span>
        <span>{body}</span>
      <% end %>
    </div>
    """
  end

  attr :liturgy, Liturgy, required: true

  def liturgy_sidebar_nav(assigns) do
    ~H"""
    <ul class="menu menu-md">
      <li :for={block <- @liturgy.blocks}>
        <.link
          href={"#block-#{block.id}"}
          class="text-ellipsis overflow-hidden tooltip tooltip-right"
          data-tip={block.title}
          phx-click={JS.dispatch("close-sidebar")}
        >
          <.icon name={block_icon(block.type)} />
          <span class="text-ellipsis overflow-hidden">
            {block.title}
          </span>
        </.link>
      </li>
    </ul>
    """
  end

  defp block_icon(:passage), do: "hero-book-open"
  defp block_icon(:song), do: "hero-musical-note"
  defp block_icon(:text), do: "hero-document-text"
end
