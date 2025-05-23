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
     |> assign(:family_suggestions, Accounts.list_families(socket.assigns.current_scope))
     |> assign(:family_address, nil)
     |> assign(:page_title, "Invite New User")}
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
        <.input field={@form[:email]} type="email" label="Email" required />
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

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
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
        # If there was a flash from family creation error, it will be overwritten by this assign.
        # This is generally fine as form errors are more specific.
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end
