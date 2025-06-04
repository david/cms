defmodule CMS.AccountsOtpTest do
  use CMS.DataCase, async: true

  alias CMS.Accounts
  alias CMS.Accounts.User
  alias CMS.Accounts.UserToken
  alias CMS.Repo
  import CMS.AccountsFixtures

  @hash_algorithm :sha256
  @otp_validity_in_minutes 5

  setup do
    {:ok, organization: organization_fixture()}
  end

  describe "UserToken OTP functions" do
    test "build_otp_token/2 generates a valid OTP and UserToken struct", %{organization: org} do
      user = unconfirmed_user_fixture(%{email: "otp_builder@example.com"}, org)
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")

      assert Regex.match?(~r/^\d{6}$/, otp_string)
      assert user_token_struct.context == "login_otp"
      assert user_token_struct.user_id == user.id
      assert user_token_struct.sent_to == user.email

      expected_hash = :crypto.hash(@hash_algorithm, otp_string)
      assert user_token_struct.token == expected_hash
    end

    test "verify_otp_token_query/1 with valid, unexpired OTP", %{organization: org} do
      user = unconfirmed_user_fixture(%{email: "valid_otp@example.com"}, org)
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")
      Repo.insert!(user_token_struct)

      {:ok, query} = UserToken.verify_otp_token_query(otp_string)
      {queried_user_from_token_context, _token_record} = Repo.one(query)

      assert queried_user_from_token_context.id == user.id
    end

    test "verify_otp_token_query/1 with expired OTP", %{organization: org} do
      user = unconfirmed_user_fixture(%{email: "expired_otp@example.com"}, org)
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")

      expired_inserted_at =
        DateTime.utc_now()
        |> DateTime.add(-(@otp_validity_in_minutes + 1), :minute)
        |> DateTime.truncate(:second)

      expired_token_struct = %{user_token_struct | inserted_at: expired_inserted_at}
      Repo.insert!(expired_token_struct)

      {:ok, query} = UserToken.verify_otp_token_query(otp_string)
      assert Repo.one(query) == nil
    end

    test "verify_otp_token_query/1 with invalid OTP string", _context do
      {:ok, query} = UserToken.verify_otp_token_query("000000")
      assert Repo.one(query) == nil
    end

    test "verify_otp_token_query/1 with OTP for a different context", %{organization: org} do
      user = unconfirmed_user_fixture(%{email: "wrong_context_otp@example.com"}, org)
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")
      Repo.insert!(%{user_token_struct | context: "some_other_context"})

      {:ok, query} = UserToken.verify_otp_token_query(otp_string)
      assert Repo.one(query) == nil
    end
  end

  describe "Accounts.deliver_otp_login_instructions/1" do
    setup %{organization: org} do
      user = unconfirmed_user_fixture(%{email: "otp_delivery_user@example.com"}, org)
      {:ok, user: user}
    end

    test "inserts token and initiates OTP code delivery", %{user: user} do
      {:ok, _email_struct} = Accounts.deliver_otp_login_instructions(user)

      hashed_otp_token_record = Repo.get_by(UserToken, user_id: user.id, context: "login_otp")
      assert hashed_otp_token_record
      assert hashed_otp_token_record.sent_to == user.email
    end
  end

  describe "Accounts.verify_and_log_in_user_by_otp/2" do
    test "with valid OTP for unconfirmed user, confirms user, logs in, and deletes token", %{
      organization: org
    } do
      unconfirmed_user = unconfirmed_user_fixture(%{email: "unconf_verify_otp@example.com"}, org)
      assert is_nil(unconfirmed_user.confirmed_at)

      {otp_string, token_to_insert} = UserToken.build_otp_token(unconfirmed_user, "login_otp")
      inserted_token = Repo.insert!(token_to_insert)

      {:ok, logged_in_user} =
        Accounts.verify_and_log_in_user_by_otp(unconfirmed_user.email, otp_string)

      assert logged_in_user.id == unconfirmed_user.id
      assert Repo.get!(User, logged_in_user.id).confirmed_at != nil
      assert Repo.get(UserToken, inserted_token.id) == nil
    end

    test "with valid OTP for confirmed user, logs in, and deletes token", %{organization: org} do
      confirmed_user = user_fixture(%{email: "conf_verify_otp@example.com"}, org)
      assert confirmed_user.confirmed_at != nil

      {otp_string, token_to_insert} = UserToken.build_otp_token(confirmed_user, "login_otp")
      inserted_token = Repo.insert!(token_to_insert)

      {:ok, logged_in_user} =
        Accounts.verify_and_log_in_user_by_otp(confirmed_user.email, otp_string)

      assert logged_in_user.id == confirmed_user.id
      assert Repo.get(UserToken, inserted_token.id) == nil
    end

    test "with invalid (wrong) OTP returns error and does not delete token", %{organization: org} do
      user = user_fixture(%{email: "invalid_code_verify_otp@example.com"}, org)
      {_correct_otp, token_to_insert} = UserToken.build_otp_token(user, "login_otp")
      inserted_token = Repo.insert!(token_to_insert)

      {:error, reason} = Accounts.verify_and_log_in_user_by_otp(user.email, "000000")
      assert reason == :invalid_or_expired_otp
      assert Repo.get(UserToken, inserted_token.id) != nil
    end

    test "with expired OTP returns error", %{organization: org} do
      user = user_fixture(%{email: "expired_verify_otp@example.com"}, org)
      {otp_string, token_to_insert} = UserToken.build_otp_token(user, "login_otp")

      expired_inserted_at =
        DateTime.utc_now()
        |> DateTime.add(-(@otp_validity_in_minutes + 1), :minute)
        |> DateTime.truncate(:second)

      Repo.insert!(%{token_to_insert | inserted_at: expired_inserted_at})

      {:error, reason} = Accounts.verify_and_log_in_user_by_otp(user.email, otp_string)
      assert reason == :invalid_or_expired_otp
    end

    test "with OTP for a different user (but valid OTP string) returns error for the given email",
         %{organization: org} do
      user1 = user_fixture(%{email: "user1_verify_otp@example.com"}, org)
      user2 = user_fixture(%{email: "user2_verify_otp@example.com"}, org)

      {otp_string_for_user2, token_for_user2} = UserToken.build_otp_token(user2, "login_otp")
      Repo.insert!(token_for_user2)

      {:error, reason} = Accounts.verify_and_log_in_user_by_otp(user1.email, otp_string_for_user2)
      assert reason == :invalid_or_expired_otp
    end

    test "with non-existent user email returns error", _context do
      {:error, reason} =
        Accounts.verify_and_log_in_user_by_otp("nonexistent@example.com", "123456")

      assert reason == :not_found
    end

    test "with already used OTP returns error (token deleted)", %{organization: org} do
      user = user_fixture(%{email: "used_otp_verify@example.com"}, org)
      {otp_string, token_to_insert} = UserToken.build_otp_token(user, "login_otp")
      Repo.insert!(token_to_insert)

      {:ok, _logged_in_user} = Accounts.verify_and_log_in_user_by_otp(user.email, otp_string)

      {:error, reason} = Accounts.verify_and_log_in_user_by_otp(user.email, otp_string)
      assert reason == :invalid_or_expired_otp
    end
  end
end
