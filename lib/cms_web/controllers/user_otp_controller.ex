defmodule CMSWeb.UserOTPController do
  use CMSWeb, :controller

  alias CMS.Accounts
  alias CMSWeb.UserAuth

  # Action to display the OTP lobby form
  def lobby(conn, %{"email" => email}) do
    if email && String.trim(email) != "" do
      # The masked CSRF token for the form
      csrf_token_for_form = get_csrf_token()
      render(conn, :lobby, email: email, csrf_token: csrf_token_for_form)
    else
      conn
      |> put_flash(:error, "An email address is required to enter the OTP lobby.")
      |> redirect(to: ~p"/users/log-in")
    end
  end

  # Fallback if email is missing
  def lobby(conn, _params) do
    conn
    |> put_flash(:error, "An email address is required to enter the OTP lobby.")
    |> redirect(to: ~p"/users/log-in")
  end

  # Action to verify OTP and log in (from previous steps)
  def verify_and_log_in(conn, %{"user" => %{"email" => email, "otp_code" => otp_code}}) do
    case Accounts.verify_and_log_in_user_by_otp(email, otp_code) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome back!")
        |> UserAuth.log_in_user(user, %{})

      {:error, :invalid_or_expired_otp} ->
        conn
        |> put_flash(:error, "Invalid or expired OTP. Please try again or request a new one.")
        |> redirect(to: ~p"/users/lobby?email=#{email}")

      {:error, :not_found} ->
        conn
        |> put_flash(:error, "User not found. Please try logging in again.")
        |> redirect(to: ~p"/users/log-in")

      {:error, :confirmation_failed} ->
        conn
        |> put_flash(
          :error,
          "Failed to confirm your account during OTP login. Please contact support."
        )
        |> redirect(to: ~p"/users/lobby?email=#{email}")

      {:error, reason} ->
        IO.inspect(reason, label: "Unknown OTP login error in UserOTPController")

        conn
        |> put_flash(:error, "An unexpected error occurred during OTP login. Please try again.")
        |> redirect(to: ~p"/users/lobby?email=#{email}")
    end
  end

  def verify_and_log_in(conn, _params) do
    conn
    |> put_flash(:error, "Invalid request for OTP verification.")
    |> redirect(to: ~p"/users/log-in")
  end
end
