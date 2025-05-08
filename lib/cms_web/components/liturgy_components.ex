defmodule CMSWeb.LiturgyComponents do
  use Phoenix.Component

  attr :verses, :map, required: true

  def verse_list(assigns) do
    ~H"""
    <div>
      <%= if @verses do %>
        <%= for %{number: number, body: body} <- @verses do %>
          <span class="align-super text-xs text-neutral-500">{number}</span>
          <span>{body}</span>
        <% end %>
      <% end %>
    </div>
    """
  end
end
