defmodule CMSWeb.UserLive.InviteForm do
  use CMSWeb, :live_view

  alias CMS.Accounts
  alias CMS.Accounts.User
  alias CMSWeb.Layouts

  @impl true
  def mount(_params, _session, socket) do
    changeset = User.invitation_changeset(%User{}, %{}, socket.assigns.current_scope)

    {:ok,
     socket
     |> assign(:form, to_form(changeset))
     |> assign(:page_title, "Invite New User")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        {@page_title}
        <:subtitle>
          Enter the email of the user to invite to {@current_scope.organization.name}.
        </:subtitle>
      </.header>

      <.form for={@form} id="invite-user-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:email]} type="email" label="Email" required />
        <footer>
          <.button phx-disable-with="Inviting..." variant="primary">Invite User</.button>
          <.button navigate={~p"/users"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = User.invitation_changeset(%User{}, user_params, socket.assigns.current_scope)

    {:noreply, assign(socket, :form, to_form(changeset, action: :validate))}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    magic_link_url_fun = fn token ->
      url(~p"/users/log-in/#{token}")
    end

    case Accounts.invite_user(socket.assigns.current_scope, user_params, magic_link_url_fun) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User invited successfully.")
         |> push_navigate(to: ~p"/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
