defmodule CMSWeb.SongLive.Admin.Index do
  use CMSWeb, :live_view

  alias CMS.Songs

  @impl true
  def mount(_params, _session, socket) do
    songs = Songs.list_songs(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:page_title, gettext("Músicas"))
      |> assign(:songs, songs)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout current_scope={@current_scope} page_title={@page_title}>
      <div class="text-center p-10 border-4 border-dashed rounded-lg">
        <h2 class="text-2xl font-bold">{gettext("Ainda não há músicas!")}</h2>
        <p class="mt-2">
          {gettext("Que tal adicionar a primeira?")}
        </p>
      </div>
    </.main_layout>
    """
  end
end
