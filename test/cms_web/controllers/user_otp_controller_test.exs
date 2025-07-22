defmodule CMSWeb.UserOTPControllerTest do
  use CMSWeb.ConnCase, async: true

  import CMS.AccountsFixtures
  alias CMS.Repo
  alias CMS.Accounts.UserToken

  @otp_validity_in_minutes 5

  setup %{conn: conn} do
    org = organization_fixture(%{hostname: "www.example.com"})
    %{conn: conn, organization: org}
  end

  defp create_user_and_otp(organization, user_attrs) do
    user = user_fixture(user_attrs, organization)
    {otp_string, token_struct_template} = UserToken.build_otp_token(user, "login_otp")
    inserted_token_struct = Repo.insert!(token_struct_template)
    {user, otp_string, inserted_token_struct}
  end

  describe "GET /users/lobby" do
    test "renders lobby page with valid email", %{conn: conn, organization: org} do
      user = user_fixture(%{}, org)
      conn = get(conn, ~p"/users/lobby?email=#{user.email}")

      assert html_response(conn, 200) =~ "Verificar Código"
      assert html_response(conn, 200) =~ user.email
    end

    test "redirects to login page if email is missing", %{conn: conn, organization: org} do
      conn =
        %Plug.Conn{conn | host: org.hostname}
        |> get(~p"/users/lobby")

      assert redirected_to(conn) == ~p"/users/log-in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "An email address is required to enter the OTP lobby."
    end

    test "redirects to login page if email is empty", %{conn: conn, organization: org} do
      conn =
        %Plug.Conn{conn | host: org.hostname}
        |> get(~p"/users/lobby?email=")

      assert redirected_to(conn) == ~p"/users/log-in"

      assert Phoenix.Flash.get(conn.assigns.flash, :error) ==
               "An email address is required to enter the OTP lobby."
    end
  end

  describe "POST /users/verify-otp" do
    test "logs in user with correct OTP and redirects to root", %{conn: conn, organization: org} do
      {user, otp_string, _token_struct} =
        create_user_and_otp(org, %{email: "otp_user@example.com"})

      conn =
        post(conn, ~p"/users/verify-otp", %{
          "_csrf_token" => get_csrf_token_for_conn(conn),
          "user" => %{"email" => user.email, "otp_code" => otp_string}
        })

      assert get_session(conn, :user_token) != nil
      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) == "Welcome back!"
      assert Repo.get_by(UserToken, context: "login_otp", user_id: user.id) == nil
    end

    test "redirects to lobby with error for incorrect OTP", %{conn: conn, organization: org} do
      user = user_fixture(%{email: "incorrect_otp_user@example.com"}, org)

      conn =
        post(conn, ~p"/users/verify-otp", %{
          "_csrf_token" => get_csrf_token_for_conn(conn),
          "user" => %{"email" => user.email, "otp_code" => "000000"}
        })

      assert get_session(conn, :user_token) == nil
      assert redirected_to(conn) == ~p"/users/lobby?email=#{user.email}"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid or expired OTP"
    end

    test "redirects to lobby with error for expired OTP", %{conn: conn, organization: org} do
      user = user_fixture(%{email: "expired_otp_login@example.com"}, org)
      {otp_string, token_template} = UserToken.build_otp_token(user, "login_otp")

      expired_inserted_at =
        DateTime.utc_now()
        |> DateTime.add(-(@otp_validity_in_minutes + 5), :minute)
        |> DateTime.truncate(:second)

      Repo.insert!(%{token_template | inserted_at: expired_inserted_at})

      conn =
        post(conn, ~p"/users/verify-otp", %{
          "_csrf_token" => get_csrf_token_for_conn(conn),
          "user" => %{"email" => user.email, "otp_code" => otp_string}
        })

      assert get_session(conn, :user_token) == nil
      assert redirected_to(conn) == ~p"/users/lobby?email=#{user.email}"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid or expired OTP"
    end

    test "redirects to login for non-existent user email", %{conn: conn, organization: org} do
      conn =
        %Plug.Conn{conn | host: org.hostname}
        |> post(~p"/users/verify-otp", %{
          "_csrf_token" => get_csrf_token_for_conn(conn),
          "user" => %{"email" => "nonexistent@example.com", "otp_code" => "123456"}
        })

      assert get_session(conn, :user_token) == nil
      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "User not found"
    end

    test "redirects to login for invalid parameters", %{conn: conn, organization: org} do
      conn =
        %Plug.Conn{conn | host: org.hostname}
        |> post(~p"/users/verify-otp", %{
          "_csrf_token" => get_csrf_token_for_conn(conn),
          "user" => %{"email" => "onlyemail@example.com"}
        })

      assert redirected_to(conn) == ~p"/users/log-in"
      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~ "Invalid request"
    end
  end

  defp get_csrf_token_for_conn(_conn) do
    # Relies on get_csrf_token/0 being available from ConnCase (via Phoenix.Controller)
    Plug.CSRFProtection.get_csrf_token()
  end
end
