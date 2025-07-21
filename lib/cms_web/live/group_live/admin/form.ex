defmodule CMSWeb.GroupLive.Admin.Form do
  use CMSWeb, :live_view

  alias CMS.Accounts
  alias CMS.Accounts.Group

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    changeset = Accounts.change_group(%Group{}, %{}, socket.assigns.current_scope)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:page_title, "Novo Grupo")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        {@page_title}
        <:subtitle>
          Use o formulário abaixo para criar um novo grupo.
        </:subtitle>
      </.header>

      <.form for={@form} id="group-form" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Nome" required />
        <.input field={@form[:description]} type="textarea" label="Descrição" />

        <footer>
          <.button phx-disable-with="A guardar..." variant="primary">Guardar</.button>
          <.button navigate={~p"/admin/groups"}>Cancelar</.button>
        </footer>
      </.form>
    </.main_layout>
    """
  end

  @impl true
  def handle_event("save", %{"group" => group_params}, socket) do
    case Accounts.create_group(socket.assigns.current_scope, group_params) do
      {:ok, _group} ->
        {:noreply,
         socket
         |> put_flash(:info, "Grupo criado com sucesso.")
         |> push_navigate(to: ~p"/admin/groups")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
