defmodule CMS.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CMS.Accounts` context.
  """

  import Ecto.Query

  alias CMS.Accounts
  alias CMS.Accounts.Family
  alias CMS.Accounts.Group
  alias CMS.Accounts.Scope
  alias CMS.Accounts.User
  alias CMS.Repo

  def group_fixture(attrs \\ %{}, organization) do
    name = "Group #{System.unique_integer()}"

    users = attrs[:users] || []

    changeset =
      %Group{
        name: name,
        organization_id: organization.id
      }
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:users, users)

    {:ok, group} = Repo.insert(changeset)

    group
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      name: "Test User"
    })
  end

  def family_fixture(attrs \\ %{}, organization) do
    {:ok, family} =
      %Family{
        designation: "Test Family #{System.unique_integer()}",
        organization_id: organization.id
      }
      |> Map.merge(attrs)
      |> Repo.insert()

    family
  end

  def unconfirmed_user_fixture(attrs \\ %{}, organization) do
    {:ok, user} =
      %User{}
      |> Map.merge(valid_user_attributes())
      |> Map.merge(attrs)
      |> Map.put(:organization_id, organization.id)
      |> Map.put(:family_id, family_fixture(%{}, organization).id)
      |> Ecto.Changeset.change(%{})
      |> Repo.insert()

    CMS.Repo.preload(user, [:organization])
  end

  def organization_fixture(attrs \\ %{}) do
    uint = System.unique_integer()
    name = "Organization #{uint}"
    hostname = "www#{uint}.example.com"

    {:ok, organization} =
      %{
        name: name,
        hostname: hostname
      }
      |> Map.merge(attrs)
      |> Accounts.create_organization()

    organization
  end

  def user_fixture(attrs, organization) do
    user = unconfirmed_user_fixture(attrs, organization)

    token =
      extract_user_token(fn url ->
        Accounts.deliver_login_instructions(user, url)
      end)

    {:ok, user, _expired_tokens} = Accounts.login_user_by_magic_link(token)

    user
  end

  def admin_fixture(attrs \\ %{}, organization) do
    user_fixture(Map.merge(attrs, %{role: :admin}), organization)
  end

  def user_scope_fixture do
    user = user_fixture(%{}, organization_fixture())

    user_scope_fixture(user)
  end

  def user_scope_fixture(user) do
    user = Repo.preload(user, [:organization, :groups])
    Scope.for_user(user, user.organization, user.groups)
  end

  def admin_scope_fixture(admin) do
    Scope.for_user(admin, admin.organization)
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
