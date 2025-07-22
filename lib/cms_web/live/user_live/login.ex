defmodule CMSWeb.UserLive.Login do
  use CMSWeb, :live_view

  alias CMS.Accounts

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="mx-auto max-w-sm space-y-4">
        <.header class="text-center">
          <p>Entrar</p>
        </.header>

        <div :if={local_mail_adapter?()} class="alert alert-info">
          <.icon name="hero-information-circle" class="w-6 h-6 shrink-0" />
          <div>
            <p>You are running the local mail adapter.</p>
            <p>
              To see sent emails, visit <.link href="/dev/mailbox" class="underline">the mailbox page</.link>.
            </p>
          </div>
        </div>

        <.form
          :let={f}
          for={@form}
          id="login_form_magic"
          action={~p"/users/log-in"}
          phx-submit="submit_magic"
        >
          <.input
            readonly={!!@current_scope.user}
            field={f[:email]}
            type="email"
            label="Email"
            autocomplete="username"
            required
            phx-mounted={JS.focus()}
          />
          <.button class="mt-4 w-full" variant="primary">
            Enviar código <span aria-hidden="true">→</span>
          </.button>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email_param}}, socket) do
    info = "If your email is in our system, you will receive an OTP code shortly."

    if user = Accounts.get_user_by_email(email_param) do
      Accounts.deliver_otp_login_instructions(user)
    end

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/lobby?email=#{email_param}")}
  end

  defp local_mail_adapter? do
    Application.get_env(:cms, CMS.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
