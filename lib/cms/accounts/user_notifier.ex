defmodule CMS.Accounts.UserNotifier do
  import Swoosh.Email

  alias CMS.Mailer
  alias CMS.Accounts.User

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    sender_email = Application.get_env(:cms, CMS.Mailer)[:default_sender_email]
    sender_name = Application.get_env(:cms, CMS.Mailer)[:default_sender_name]

    email =
      new()
      |> to(recipient)
      |> from({sender_name, sender_email})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    else
      error -> IO.inspect(error)
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver({user.name, user.email}, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to log in with a magic link.
  """
  def deliver_login_instructions(user, url) do
    case user do
      %User{confirmed_at: nil} -> deliver_confirmation_instructions(user, url)
      _ -> deliver_magic_link_instructions(user, url)
    end
  end

  defp deliver_magic_link_instructions(user, url) do
    deliver({user.name, user.email}, "Log in instructions", """

    ==============================

    Hi #{user.email},

    You can log into your account by visiting the URL below:

    #{url}

    If you didn't request this email, please ignore this.

    ==============================
    """)
  end

  defp deliver_confirmation_instructions(user, url) do
    deliver({user.name, user.email}, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver OTP code for login.
  """
  def deliver_otp_code_instructions(%User{} = user, otp_code) when is_binary(otp_code) do
    deliver({user.name, user.email}, "Your Login OTP Code", """

    ==============================

    Hi #{user.email},

    Your One-Time Password (OTP) to log in is:

    #{otp_code}

    This code will expire in 5 minutes.

    If you didn't request this OTP, please ignore this email or contact support if you have concerns.

    ==============================
    """)
  end

  @doc """
  Deliver OTP code for login as an invitation.
  """
  def deliver_invitation_instructions(%User{} = user, otp_code, url)
      when is_binary(otp_code) and is_binary(url) do
    deliver({user.name, user.email}, "Seu convite de acesso", """

    ==============================

    Olá #{user.email},

    Recebeu um convite para aceder ao sistema. Para começar, aceda à seguinte ligação e introduza o seu código de acesso único (OTP):

    #{url}

    O seu código é:

    #{otp_code}

    Este código expira em 5 minutos.

    Se não esperava este convite, por favor ignore este e-mail.

    ==============================
    """)
  end
end
