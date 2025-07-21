defmodule CMSWeb.GroupLive.Admin.Index do
  use CMSWeb, :live_view

  alias CMS.Accounts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :groups, Accounts.list_groups(socket.assigns.current_scope))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.main_layout flash={@flash} current_scope={@current_scope}>
      <:nav_actions>
        <li>
          <.link patch={~p"/admin/groups/new"}>
            <.icon name="hero-plus-solid" class="h-5 w-5" />
          </.link>
        </li>
      </:nav_actions>

      <.header testid="page-title">
        {gettext("Grupos")}
      </.header>

      <div class="card">
        <div class="card-body">
          <.table :if={@groups != []} id="groups-table" rows={@groups}>
            <:col :let={group} label={gettext("Nome")}>{group.name}</:col>
          </.table>

          <div :if={@groups == []} class="card-body items-center text-center">
            <p data-testid="empty-state">
              {gettext("Nenhum grupo encontrado.")}
            </p>
            <.link
              href={~p"/admin/groups/new"}
              class="btn btn-primary btn-sm mt-2"
              data-testid="new-group-link"
            >
              {gettext("Crie o primeiro grupo!")}
            </.link>
          </div>
        </div>
      </div>
    </.main_layout>
    """
  end
end
