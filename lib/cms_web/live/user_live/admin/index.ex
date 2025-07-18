defmodule CMSWeb.UserLive.Admin.Index do
  use CMSWeb, :live_view

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
      |> assign(:page_title, "Listing Users")
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

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        Users
        for {@organization.name}
        <:subtitle>This is a list of users for the selected organization.</:subtitle>
        <:actions>
          <.button variant="primary" phx-click="show_import_modal" class="ml-2">
            <.icon name="hero-arrow-up-tray" /> Import
          </.button>
          <.button variant="primary" navigate={~p"/admin/users/new"}>
            <.icon name="hero-plus" /> Invite User
          </.button>
        </:actions>
      </.header>

      <.table id="users" rows={@streams.users}>
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Family">{user.family.designation}</:col>
        <:col :let={{_id, user}} :if={{@current_scope.user.role == :admin}} label="Email">
          {user.email}
        </:col>
        <:col :let={{_id, user}} label="Role">{user.role}</:col>
        <:col :let={{_id, user}} label={~H(<div class="text-center">Confirmed?</div>)}>
          <div :if={user.confirmed_at} class="text-center">
            <.icon name="hero-check-solid" class="size-5 text-success inline-block" />
          </div>
        </:col>
        <:action :let={{_id, user}} :if={{@current_scope.user.role == :admin}}>
          <.link navigate={~p"/admin/users/#{user}/edit"}>Edit</.link>
        </:action>
      </.table>

      <.modal
        :if={@show_import_users_modal}
        id="import-users-modal"
        show={@show_import_users_modal}
        on_cancel={JS.push("cancel_import")}
      >
        <form phx-submit="save_import" phx-change="validate_import">
          <h2 class="text-lg font-semibold mb-4">Import Users</h2>
          <div class="mb-4">
            <.live_file_input
              upload={@uploads.user_import_file}
              class="file-input input-bordered w-full"
            />
          </div>

          <footer>
            <.button type="submit" variant="primary" phx-disable-with="Importing...">Import</.button>
            <.button type="button" phx-click="cancel_import" class="btn-ghost">Cancel</.button>
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
