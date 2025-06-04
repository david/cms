defmodule CMS.AccountsOtpTest do
  use CMS.DataCase, async: true

  alias CMS.Accounts
  alias CMS.Accounts.User
  alias CMS.Accounts.UserToken
  alias CMS.Repo
  # Import the fixtures module
  import CMS.AccountsFixtures

  @hash_algorithm :sha256
  @otp_validity_in_minutes 5

  describe "UserToken OTP functions" do
    test "build_otp_token/2 generates a valid OTP and UserToken struct" do
      user = unconfirmed_user_fixture(%{email: "otp_builder@example.com"})
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")

      assert Regex.match?(~r/^\d{6}$/, otp_string)
      assert user_token_struct.context == "login_otp"
      assert user_token_struct.user_id == user.id
      assert user_token_struct.sent_to == user.email

      expected_hash = :crypto.hash(@hash_algorithm, otp_string)
      assert user_token_struct.token == expected_hash
    end

    test "verify_otp_token_query/1 with valid, unexpired OTP" do
      user = unconfirmed_user_fixture(%{email: "valid_otp@example.com"})
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")
      Repo.insert!(user_token_struct)

      {:ok, query} = UserToken.verify_otp_token_query(otp_string)
      {queried_user, _token_record} = Repo.one(query)

      assert queried_user.id == user.id
    end

    test "verify_otp_token_query/1 with expired OTP" do
      user = unconfirmed_user_fixture(%{email: "expired_otp@example.com"})
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

    test "verify_otp_token_query/1 with invalid OTP string" do
      {:ok, query} = UserToken.verify_otp_token_query("000000")
      assert Repo.one(query) == nil
    end

    test "verify_otp_token_query/1 with OTP for a different context" do
      user = unconfirmed_user_fixture(%{email: "wrong_context_otp@example.com"})
      {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")
      Repo.insert!(%{user_token_struct | context: "some_other_context"})

      {:ok, query} = UserToken.verify_otp_token_query(otp_string)
      assert Repo.one(query) == nil
    end
  end

  describe "Accounts OTP delivery and retrieval" do
    setup do
      user = unconfirmed_user_fixture(%{email: "accounts_otp_user@example.com"})
      {:ok, user: user}
    end

    test "deliver_otp_login_instructions/2 inserts token and initiates delivery", %{user: user} do
      otp_url_fun = fn otp -> "http://localhost/login/#{otp}" end

      Accounts.deliver_otp_login_instructions(user, otp_url_fun)

      hashed_otp_token_record = Repo.get_by(UserToken, user_id: user.id, context: "login_otp")
      assert hashed_otp_token_record
      assert hashed_otp_token_record.sent_to == user.email
    end

    test "get_user_by_otp_url_token/1 returns user for valid OTP", %{user: user} do
      {otp_string, token_struct} = UserToken.build_otp_token(user, "login_otp")
      Repo.insert!(token_struct)

      retrieved_user = Accounts.get_user_by_otp_url_token(otp_string)
      assert retrieved_user.id == user.id
    end

    test "get_user_by_otp_url_token/1 returns nil for invalid/expired OTP", %{user: _user} do
      assert Accounts.get_user_by_otp_url_token("000000") == nil
    end
  end

  describe "Accounts.login_user_by_otp_url/1" do
    test "with valid OTP for unconfirmed user, confirms and logs in" do
      unconfirmed_user = unconfirmed_user_fixture(%{email: "unconf_otp_login@example.com"})
      assert is_nil(unconfirmed_user.confirmed_at)

      {otp_string, token_struct_to_insert} =
        UserToken.build_otp_token(unconfirmed_user, "login_otp")

      inserted_token = Repo.insert!(token_struct_to_insert)
      original_token_id = inserted_token.id

      {:ok, logged_in_user, []} = Accounts.login_user_by_otp_url(otp_string)

      assert logged_in_user.id == unconfirmed_user.id
      assert Repo.get!(User, logged_in_user.id).confirmed_at != nil
      assert Repo.get(UserToken, original_token_id) == nil
    end

    test "with valid OTP for confirmed user, logs in" do
      confirmed_user = user_fixture(%{email: "conf_otp_login@example.com"})
      assert confirmed_user.confirmed_at != nil

      {otp_string, token_struct_to_insert} =
        UserToken.build_otp_token(confirmed_user, "login_otp")

      inserted_token = Repo.insert!(token_struct_to_insert)
      original_token_id = inserted_token.id

      {:ok, logged_in_user, []} = Accounts.login_user_by_otp_url(otp_string)

      assert logged_in_user.id == confirmed_user.id
      assert Repo.get(UserToken, original_token_id) == nil
    end

    test "with invalid OTP returns error" do
      user = unconfirmed_user_fixture(%{email: "invalid_otp_login_user@example.com"})
      {:error, reason} = Accounts.login_user_by_otp_url("000000")
      assert reason == :invalid_otp_or_expired

      {_otp_string, token_struct_to_insert} = UserToken.build_otp_token(user, "login_otp")
      inserted_token = Repo.insert!(token_struct_to_insert)
      {:error, reason_other} = Accounts.login_user_by_otp_url("111111")
      assert reason_other == :invalid_otp_or_expired
      assert Repo.get(UserToken, inserted_token.id) != nil
    end

    test "with expired OTP returns error" do
      user = unconfirmed_user_fixture(%{email: "expired_otp_login_user_2@example.com"})
      {otp_string, token_struct_to_insert} = UserToken.build_otp_token(user, "login_otp")

      expired_inserted_at =
        DateTime.utc_now()
        |> DateTime.add(-(@otp_validity_in_minutes + 1), :minute)
        |> DateTime.truncate(:second)

      Repo.insert!(%{token_struct_to_insert | inserted_at: expired_inserted_at})

      {:error, reason} = Accounts.login_user_by_otp_url(otp_string)
      assert reason == :invalid_otp_or_expired
    end

    test "with already used OTP returns error" do
      user = unconfirmed_user_fixture(%{email: "used_otp_login_user@example.com"})
      {otp_string, token_struct_to_insert} = UserToken.build_otp_token(user, "login_otp")
      inserted_token = Repo.insert!(token_struct_to_insert)
      original_token_id = inserted_token.id

      {:ok, _, _} = Accounts.login_user_by_otp_url(otp_string)
      assert Repo.get(UserToken, original_token_id) == nil

      {:error, reason} = Accounts.login_user_by_otp_url(otp_string)
      assert reason == :invalid_otp_or_expired
    end
  end
end
