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
      <.header testid="page-title">
        {gettext("Grupos")}
      </.header>

      <div class="card">
        <div class="card-body">
          <.table :if={@groups != []} id="groups-table" rows={@groups}>
            <:col :let={group} label={gettext("Nome")}>{group.name}</:col>
          </.table>

          <p :if={@groups == []} data-testid="empty-state">
            {gettext("Nenhum grupo encontrado.")}
          </p>
        </div>
      </div>
    </.main_layout>
    """
  end
end
