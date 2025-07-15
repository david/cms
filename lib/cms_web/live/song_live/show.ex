defmodule CMSWeb.SongLive.Show do
  use CMSWeb, :live_view

  alias CMS.Songs

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    song = Songs.get_song!(socket.assigns.current_scope, id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:song, song)}
  end

  defp page_title(:show), do: "Show Song"

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope}>
      <.song title={@song.title} body={@song.body} />
    </.main_layout>
    """
  end
end
