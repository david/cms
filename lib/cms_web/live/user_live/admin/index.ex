defmodule CMSWeb.UserLive.Admin.Index do
  use CMSWeb, :live_view
  use Phoenix.VerifiedRoutes, endpoint: CMSWeb.Endpoint, router: CMSWeb.Router

  alias CMS.Accounts
  alias CMS.Accounts.Import
  alias Phoenix.LiveView.JS

  @impl true
  def mount(_params, _session, socket) do
    organization = socket.assigns.current_scope.organization
    initial_users = Accounts.list_users(socket.assigns.current_scope)

    socket =
      socket
      |> stream(:users, initial_users)
      |> assign(:organization, organization)
      |> assign(:page_title, gettext("Listando Utilizadores"))
      |> assign(:show_import_users_modal, false)
      |> assign(:uploaded_files, [])
      |> allow_upload(:user_import_file, accept: ~w(.csv), max_entries: 1)

    {:ok, socket}
  end

  @impl true
  def handle_event("show_import_modal", _params, socket) do
    {:noreply, assign(socket, :show_import_users_modal, true)}
  end

  def handle_event("cancel_import", _params, socket) do
    {:noreply, assign(socket, :show_import_users_modal, false)}
  end

  def handle_event("validate_import", _params, socket) do
    {:noreply, socket}
  end

  @impl Phoenix.LiveView
  def handle_event("save_import", _params, socket) do
    consume_uploaded_entries(socket, :user_import_file, fn %{path: path}, _entry ->
      Import.import_users_file(socket.assigns.current_scope, path)

      {:ok, true}
    end)

    {:noreply, socket}
  end

  def handle_event("invite_user", %{"id" => id}, socket) do
    user = Accounts.get_user(socket.assigns.current_scope, id)
    login_url = url(~p"/users/lobby?email=#{user.email}")

    socket =
      case Accounts.send_invitation_instructions(user, login_url) do
        {:ok, _} ->
          put_flash(socket, :info, "Convite enviado para #{user.email}")

        {:error, :already_confirmed} ->
          put_flash(socket, :error, "Usuário já confirmado.")
      end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        {gettext("Utilizadores")}
        {gettext("para")} {@organization.name}
        <:subtitle>
          {gettext("Esta é uma lista de utilizadores para a organização selecionada.")}
        </:subtitle>
        <:actions>
          <.button variant="primary" phx-click="show_import_modal" class="ml-2">
            <.icon name="hero-arrow-up-tray" /> {gettext("Importar")}
          </.button>
          <.button variant="primary" navigate={~p"/admin/users/new"}>
            <.icon name="hero-plus" /> {gettext("Convidar Utilizador")}
          </.button>
        </:actions>
      </.header>

      <.table id="users" rows={@streams.users} row_id={fn {_id, user} -> "user-#{user.id}" end}>
        <:col :let={{_id, user}} label={gettext("Nome")}>{user.name}</:col>
        <:col :let={{_id, user}} label={gettext("Família")}>{user.family.designation}</:col>
        <:col :let={{_id, user}} label={gettext("Email")}>{user.email}</:col>
        <:col :let={{_id, user}} label={gettext("Função")}>{user.role}</:col>
        <:col :let={{_id, user}} label={gettext("Confirmado?")}>
          <div :if={user.confirmed_at} class="text-center">
            <.icon name="hero-check-solid" class="size-5 text-success inline-block" />
          </div>
        </:col>
        <:action :let={{_id, user}}>
          <.link navigate={~p"/admin/users/#{user}/edit"}>{gettext("Editar")}</.link>
          <div :if={is_nil(user.confirmed_at)}>
            <.link
              phx-click="invite_user"
              phx-value-id={user.id}
              data-confirm="Tem certeza que deseja convidar este usuário?"
            >
              Convidar
            </.link>
          </div>
        </:action>
      </.table>

      <.modal
        :if={@show_import_users_modal}
        id="import-users-modal"
        show={@show_import_users_modal}
        on_cancel={JS.push("cancel_import")}
      >
        <form phx-submit="save_import" phx-change="validate_import">
          <h2 class="text-lg font-semibold mb-4">{gettext("Importar Utilizadores")}</h2>
          <div class="mb-4">
            <.live_file_input
              upload={@uploads.user_import_file}
              class="file-input input-bordered w-full"
            />
          </div>

          <footer>
            <.button type="submit" variant="primary" phx-disable-with={gettext("A importar...")}>
              {gettext("Importar")}
            </.button>
            <.button type="button" phx-click="cancel_import" class="btn-ghost">
              {gettext("Cancelar")}
            </.button>
          </footer>
        </form>
      </.modal>
    </.main_layout>
    """
  end

  def modal(assigns) do
    ~H"""
    <dialog :if={@show} id={@id} class="modal" open={@show}>
      <div class="modal-box relative max-w-lg">
        {render_slot(@inner_block)}
      </div>
    </dialog>
    """
  end
end
