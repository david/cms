defmodule CMSWeb.UserLive.Confirmation do
  use CMSWeb, :live_view

  alias CMS.Accounts

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm">
        <.header class="text-center">{gettext("Bem-vindo")} {@user.email}</.header>

        <.form
          :if={!@user.confirmed_at}
          for={@form}
          id="confirmation_form"
          phx-submit="submit"
          action={~p"/users/log-in?_action=confirmed"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.input
            :if={!@current_scope.user}
            field={@form[:remember_me]}
            type="checkbox"
            label={gettext("Mantenha-me ligado")}
          />
          <.button variant="primary" phx-disable-with={gettext("A confirmar...")} class="w-full">
            {gettext("Confirmar a minha conta")}
          </.button>
        </.form>

        <.form
          :if={@user.confirmed_at}
          for={@form}
          id="login_form"
          phx-submit="submit"
          action={~p"/users/log-in"}
          phx-trigger-action={@trigger_submit}
        >
          <input type="hidden" name={@form[:token].name} value={@form[:token].value} />
          <.input
            :if={!@current_scope.user}
            field={@form[:remember_me]}
            type="checkbox"
            label={gettext("Mantenha-me ligado")}
          />
          <.button variant="primary" phx-disable-with={gettext("A iniciar sessão...")} class="w-full">
            {gettext("Iniciar sessão")}
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    if user = Accounts.get_user_by_magic_link_token(token) do
      form = to_form(%{"token" => token}, as: "user")

      {:ok, assign(socket, user: user, form: form, trigger_submit: false),
       temporary_assigns: [form: nil]}
    else
      {:ok,
       socket
       |> put_flash(:error, gettext("O link de início de sessão é inválido ou expirou."))
       |> push_navigate(to: ~p"/users/log-in")}
    end
  end

  def handle_event("submit", %{"user" => params}, socket) do
    {:noreply, assign(socket, form: to_form(params, as: "user"), trigger_submit: true)}
  end
end
