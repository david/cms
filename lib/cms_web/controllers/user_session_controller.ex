defmodule CMSWeb.UserSessionController do
  use CMSWeb, :controller

  alias CMS.Accounts
  alias CMSWeb.UserAuth

  def create(conn, %{"_action" => "confirmed"} = params) do
    create(conn, params, "User confirmed successfully.")
  end

  def create(conn, params) do
    create(conn, params, "Welcome back!")
  end

  # This function handles login via OTP-in-URL
  defp create(conn, %{"user" => %{"token" => otp_string} = user_params}, info) do
    case Accounts.login_user_by_otp_url(otp_string) do
      {:ok, user, tokens_to_disconnect} ->
        UserAuth.disconnect_sessions(tokens_to_disconnect)

        conn
        |> put_flash(:info, info)
        |> UserAuth.log_in_user(user, user_params)

      _ ->
        conn
        |> put_flash(:error, "The login link is invalid or it has expired.")
        |> redirect(to: ~p"/users/log-in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
