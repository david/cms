defmodule CMSWeb.UserLive.Form do
  use CMSWeb, :live_view

  alias CMS.Accounts
  alias CMS.Accounts.User

  alias CMSWeb.Layouts

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:family_suggestions, Accounts.list_families(socket.assigns.current_scope))
     |> assign(:family_address, nil)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    user = %User{}
    changeset = User.invitation_changeset(user, %{}, socket.assigns.current_scope)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:user, user)
    |> assign(:page_title, "Invite New User")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    user = Accounts.get_user!(socket.assigns.current_scope, id)
    changeset = User.update_changeset(user, %{}, socket.assigns.current_scope)

    socket
    |> assign(:form, to_form(changeset))
    |> assign(:user, user)
    |> assign(:page_title, "Edit User")
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope} page_title={@page_title}>
      <.header>
        {@page_title}
        <:subtitle>
          Enter the name and email of the user to invite to {@current_scope.organization.name}.
        </:subtitle>
      </.header>

      <.form for={@form} id="invite-user-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" required />
        <% # FIXME email is required for invite %>
        <.input field={@form[:email]} type="email" label="Email" />
        <.input field={@form[:birth_date]} type="date" label="Birth Date" />

        <.autocomplete
          id="family_designation_input"
          label="Family Designation"
          text_field={@form[:family_designation]}
          value_field={@form[:family_id]}
          suggestions={@family_suggestions}
          suggestion_label={:designation}
          on_value_change="update_address"
        />

        <.input
          field={@form[:family_address]}
          type="textarea"
          label="Family Address"
          value={@family_address}
        />

        <.input field={@form[:phone_number]} type="tel" label="Phone Number" />

        <.input field={@form[:role]} type="select" label="Role" options={User.roles()} />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save User</.button>
          <.button navigate={~p"/users"}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    current_scope = socket.assigns.current_scope

    form_changeset = User.invitation_changeset(%User{}, user_params, current_scope)
    socket = assign(socket, :form, to_form(form_changeset, action: :validate))
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_address", %{"user" => %{"family_id" => fam_id}}, socket) do
    case Integer.parse(fam_id) do
      {id, _} ->
        family = Enum.find(socket.assigns.family_suggestions, &(&1.id == id))

        {:noreply, assign(socket, :family_address, family.address)}

      :error ->
        {:noreply, socket}
    end
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    save_user(socket, socket.assigns.live_action, user_params)
  end

  defp save_user(socket, :new, user_params) do
    current_scope = socket.assigns.current_scope

    magic_link_url_fun = fn token ->
      url(~p"/users/log-in/#{token}")
    end

    case Accounts.invite_user(current_scope, user_params, magic_link_url_fun) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User invited successfully.")
         |> push_navigate(to: ~p"/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  defp save_user(socket, :edit, user_params) do
    current_scope = socket.assigns.current_scope

    case Accounts.update_user(current_scope, socket.assigns.user, user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "User updated successfully.")
         |> push_navigate(to: ~p"/users")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
