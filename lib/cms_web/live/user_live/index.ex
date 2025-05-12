defmodule CMSWeb.UserLive.Index do
  use CMSWeb, :live_view

  alias CMS.Accounts
  alias CMS.Accounts.User
  alias CMSWeb.Layouts

  @impl true
  def mount(_params, _session, socket) do
    organization = socket.assigns.current_scope.organization
    initial_users = Accounts.list_users(socket.assigns.current_scope)

    socket =
      socket
      |> stream(:users, initial_users)
      |> assign(:organization, organization)
      |> assign(:page_title, "Listing Users")

    {:ok, socket}
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
          <.button variant="primary" navigate={~p"/users/new"}>
            <.icon name="hero-plus" /> Invite User
          </.button>
        </:actions>
      </.header>

      <.table id="users" rows={@streams.users}>
        <:col :let={{_id, user}} label="Name">{user.name}</:col>
        <:col :let={{_id, user}} label="Email">{user.email}</:col>
      </.table>
    </Layouts.app>
    """
  end
end
