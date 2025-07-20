defmodule CMSWeb.PrayerRequestLive.Form do
  use CMSWeb, :live_view

  alias CMS.Prayers
  alias CMS.Prayers.PrayerRequest

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    changeset = Prayers.change_prayer_request(%PrayerRequest{})

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:page_title, "New Prayer Request")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        {@page_title}
        <:subtitle>
          Write your prayer request below.
        </:subtitle>
      </.header>

      <.form for={@form} id="prayer-request-form" phx-submit="save">
        <.input field={@form[:body]} type="textarea" label="Prayer Request" required />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save</.button>
          <.button navigate={~p"/prayers"}>Cancel</.button>
        </footer>
      </.form>
    </.main_layout>
    """
  end

  @impl true
  def handle_event("save", %{"prayer_request" => prayer_request_params}, socket) do
    case Prayers.create_prayer_request(socket.assigns.current_scope, prayer_request_params) do
      {:ok, _prayer_request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Prayer request created successfully.")
         |> push_navigate(to: ~p"/prayers")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
