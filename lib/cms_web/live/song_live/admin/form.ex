defmodule CMSWeb.SongLive.Admin.Form do
  use CMSWeb, :live_view

  alias CMS.Songs
  alias CMS.Songs.Song

  import CMSWeb.CoreComponents

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Edit Song")
     |> assign_song(params)}
  end

  defp assign_song(socket, %{"id" => id}) do
    song = Songs.get_song!(socket.assigns.current_scope, id)

    socket
    |> assign(:song, song)
    |> assign_form(Song.changeset(song, %{}, socket.assigns.current_scope))
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  @impl true
  def render(assigns) do
    ~H'''
    <.main_layout current_scope={@current_scope} page_title={@page_title} flash={@flash}>
      <.form for={@form} id="song-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label={gettext("Title")} />
        <.input field={@form[:body]} type="textarea" label={gettext("Body")} />
        <footer>
          <.button phx-disable-with="Saving...">Save Song</.button>
        </footer>
      </.form>
    </.main_layout>
    '''
  end

  @impl true
  def handle_event("validate", %{"song" => song_params}, socket) do
    changeset =
      socket.assigns.song
      |> Songs.change_song(song_params, socket.assigns.current_scope)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"song" => song_params}, socket) do
    case Songs.update_song(socket.assigns.current_scope, socket.assigns.song, song_params) do
      {:ok, _song} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Song updated successfully"))
         |> push_navigate(to: ~p"/admin/songs")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end
end
