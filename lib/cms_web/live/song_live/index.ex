defmodule CMSWeb.SongLive.Index do
  use CMSWeb, :live_view

  alias CMS.Songs

  @impl true
  def mount(_params, _session, socket) do
    songs = Songs.list_songs(socket.assigns.current_scope)
    {:ok, assign(socket, :songs, songs)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container mx-auto p-4">
      <h1 class="text-3xl font-semibold mb-6">Songs</h1>
      <div class="w-full md:w-3/4 lg:w-1/2 mx-auto">
        <%= if Enum.empty?(@songs) do %>
          <div class="card bg-base-200 shadow-xl">
            <div class="card-body">
              <p>No songs found for this organization.</p>
            </div>
          </div>
        <% else %>
          <ul class="list-none p-0 bg-base-200 rounded-box shadow-xl w-full divide-y divide-base-300">
            <%= for song <- @songs do %>
              <li class="p-4">
                <.link href={~p"/songs/#{song.id}"}>{song.title}</.link>
              </li>
            <% end %>
          </ul>
        <% end %>
      </div>
    </div>
    """
  end
end
