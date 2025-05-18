defmodule CMSWeb.UserLive.Index do
  use CMSWeb, :live_view

  alias CMS.Accounts
  alias CMSWeb.Layouts
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
      |> assign(:upload_form, to_form(%{}))
      |> allow_upload(:user_import_file, accept: :any, max_entries: 1, auto_upload: true)

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

  def handle_event("save_import", _params, socket) do
    {:noreply,
     socket
     |> put_flash(:info, "Import functionality coming soon!")
     |> assign(:show_import_users_modal, true)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        Users
        for {@organization.name}
        <:subtitle>This is a list of users for the selected organization.</:subtitle>
        <:actions>
          <.button variant="primary" phx-click="show_import_modal" class="ml-2">
            <.icon name="hero-arrow-up-tray" /> Import
          </.button>
          <.button variant="primary" navigate={~p"/users/new"}>
            <.icon name="hero-plus" /> Invite User
          </.button>
        </:actions>
      </.header>

      <.table id="users" rows={@streams.users}>
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
        <:col :let={{_id, user}} label={~H(<div class="text-center">Confirmed?</div>)}>
          <div :if={user.confirmed_at} class="text-center">
            <.icon name="hero-check-solid" class="size-5 text-success inline-block" />
          </div>
        </:col>
      </.table>

      <.modal
        :if={@show_import_users_modal}
        id="import-users-modal"
        show={@show_import_users_modal}
        on_cancel={JS.push("cancel_import")}
      >
        <.form for={@upload_form} phx-submit="save_import" phx-change="validate_import">
          <h2 class="text-lg font-semibold mb-4">Import Users</h2>
          <div class="mb-4">
            <.live_file_input
              upload={@uploads.user_import_file}
              class="file-input input-bordered w-full"
            />
            <%= for entry <- @uploads.user_import_file.entries do %>
              <div class="mt-2 text-sm">
                File: {entry.client_name} ({entry.client_size / 1024}KB)
                <%= if Map.get(entry, :errors) do %>
                  <p class="text-error-content">{Enum.join(entry.errors, ", ")}</p>
                <% end %>
              </div>
            <% end %>
          </div>

          <footer>
            <.button type="submit" variant="primary" phx-disable-with="Importing...">Import</.button>
            <.button type="button" phx-click="cancel_import" class="btn-ghost">Cancel</.button>
          </footer>
        </.form>
      </.modal>
    </Layouts.app>
    """
  end

  def modal(assigns) do
    ~H"""
    <dialog
      :if={@show}
      id={@id}
      class="modal"
      open={@show}
      phx-window-keydown={@on_cancel}
      phx-key="escape"
      phx-click={@on_cancel}
    >
      <div class="modal-box relative max-w-lg" phx-click={JS.exec("event.stopPropagation()")}>
        {render_slot(@inner_block)}
      </div>
    </dialog>
    """
  end
end
