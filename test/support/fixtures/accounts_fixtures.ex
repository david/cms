defmodule CMS.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CMS.Accounts` context.
  """

  import Ecto.Query

  alias CMS.Accounts
  alias CMS.Accounts.Scope

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      name: "Test User"
    })
  end

  def unconfirmed_user_fixture(attrs \\ %{}, organization \\ organization_fixture()) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Accounts.register_user(organization)

    CMS.Repo.preload(user, [:organization])
  end

  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        name: "Organization #{System.unique_integer()}"
      })
      |> Accounts.create_organization()

    organization
  end

  def user_fixture(attrs \\ %{}, organization \\ organization_fixture()) do
    user = unconfirmed_user_fixture(attrs, organization)

    token =
      extract_user_token(fn url ->
        Accounts.deliver_login_instructions(user, url)
      end)

    {:ok, user, _expired_tokens} = Accounts.login_user_by_magic_link(token)

    user
  end

  def user_scope_fixture do
    user = user_fixture()

    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    Scope.for_user(user)
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def override_token_authenticated_at(token, authenticated_at) when is_binary(token) do
    CMS.Repo.update_all(
      from(t in Accounts.UserToken,
        where: t.token == ^token
      ),
      set: [authenticated_at: authenticated_at]
    )
  end

  def generate_user_magic_link_token(user) do
    {encoded_token, user_token} = Accounts.UserToken.build_email_token(user, "login")
    CMS.Repo.insert!(user_token)
    {encoded_token, user_token.token}
  end

  def offset_user_token(token, amount_to_add, unit) do
    dt = DateTime.add(DateTime.utc_now(:second), amount_to_add, unit)

    CMS.Repo.update_all(
      from(ut in Accounts.UserToken, where: ut.token == ^token),
      set: [inserted_at: dt, authenticated_at: dt]
    )
  end
end
