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
    <.main_layout current_scope={@current_scope} page_title={@page_title} flash={@flash}>
      <.table id="songs" rows={@streams.songs}>
        <:col :let={{_id, song}} label={gettext("Title")}>{song.title}</:col>
        <:action :let={{_id, song}}>
          <.link navigate={~p"/admin/songs/#{song}/edit"}>
            {gettext("Edit")}
          </.link>
        </:action>
      </.table>
    </.main_layout>
    """
  end
end
