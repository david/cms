defmodule CMSWeb.PrayerRequestLive.Form do
  use CMSWeb, :live_view

  alias CMS.Prayers
  alias CMS.Prayers.PrayerRequest

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:groups, socket.assigns.current_scope.groups)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    prayer_request = %PrayerRequest{}
    changeset = Prayers.change_prayer_request(socket.assigns.current_scope, prayer_request)

    socket
    |> assign(:prayer_request, prayer_request)
    |> assign(:form, to_form(changeset))
    |> assign(:page_title, "Novo Pedido de Oração")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.form for={@form} id="prayer-request-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:body]} type="textarea" label="Pedido de Oração" required />
        <.input
          field={@form[:visibility]}
          type="select"
          label="Visibilidade"
          options={[
            {"Privado", "private"},
            {"Organização", "organization"},
            {"Grupo", "group"}
          ]}
          required
        />

        <div :if={@form[:visibility].value == :group}>
          <.input
            field={@form[:group_id]}
            type="select"
            label="Grupo"
            options={Enum.map(@groups, &{&1.name, &1.id})}
            required
          />
        </div>

        <footer>
          <.button phx-disable-with="A guardar..." variant="primary">Guardar</.button>
          <.button navigate={~p"/prayers"}>Cancelar</.button>
        </footer>
      </.form>
    </.main_layout>
    """
  end

  @impl true
  def handle_event("validate", %{"prayer_request" => prayer_request_params}, socket) do
    changeset =
      Prayers.change_prayer_request(
        socket.assigns.current_scope,
        socket.assigns.prayer_request,
        prayer_request_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"prayer_request" => prayer_request_params}, socket) do
    case Prayers.create_prayer_request(socket.assigns.current_scope, prayer_request_params) do
      {:ok, _prayer_request} ->
        {:noreply,
         socket
         |> put_flash(:info, "Pedido de oração criado com sucesso.")
         |> push_navigate(to: ~p"/prayers")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
