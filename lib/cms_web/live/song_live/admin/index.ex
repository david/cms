defmodule CMSWeb.SongLive.Admin.Index do
  use CMSWeb, :live_view

  alias CMS.Songs

  @impl true
  def mount(_params, _session, socket) do
    songs = Songs.list_songs(socket.assigns.current_scope)

    socket =
      socket
      |> assign(:page_title, gettext("Músicas"))
      |> stream(:songs, songs)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout current_scope={@current_scope} page_title={@page_title}>
      <.table id="songs" rows={@streams.songs}>
        <:col :let={{_id, song}} label={gettext("Title")}>{song.title}</:col>
      </.table>
    </.main_layout>
    """
  end
end
