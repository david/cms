defmodule CMSWeb.LiturgyComponents do
  use Phoenix.Component

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
end
