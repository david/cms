defmodule CMS.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset

  alias CMS.Accounts.{Family, Group, Organization, Scope, User, UserToken, UserNotifier}
  alias CMS.Repo

  def list_groups(%Scope{organization: %Organization{id: org_id}}) do
    from(g in Group,
      where: g.organization_id == ^org_id,
      order_by: [asc: g.name]
    )
    |> Repo.all()
  end

  def create_group(%Scope{} = scope, attrs) do
    %Group{}
    |> Group.changeset(attrs, scope)
    |> Repo.insert()
  end

  def change_group(group, attrs, scope) do
    Group.changeset(group, attrs, scope)
  end

  ## Database getters

  @doc """
  Gets a user by email.

  ## Examples

      iex> get_user_by_email("foo@example.com")
      %User{}

      iex> get_user_by_email("unknown@example.com")
      nil

  """
  def get_user_by_email(email) when is_binary(email) do
    Repo.get_by(User, email: email)
  end

  def get_user(%Scope{organization: %{id: org_id}}, id) do
    Repo.get_by(User, id: id, organization_id: org_id)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(%Scope{organization: %{id: org_id}}, id),
    do:
      from(u in User,
        join: f in assoc(u, :family),
        select: %{u | family_designation: f.designation},
        preload: [family: f],
        where: [organization_id: ^org_id]
      )
      |> Repo.get(id)

  @doc """
  Gets the single organization presumed to exist in the system.

  Raises `Ecto.NoResultsError` if no organization is found.
  This function assumes a single-organization setup.
  """
  def get_organization_by_hostname!(hostname) when is_binary(hostname) do
    Repo.get_by!(Organization, hostname: hostname)
  end

  @doc """
  Lists all users within the given scope's organization.
  Accepts a `Scope` struct.
  """
  def list_users(%Scope{organization: %Organization{id: org_id}})
      when not is_nil(org_id) do
    from(u in User,
      where: u.organization_id == ^org_id,
      preload: [:family],
      order_by: [asc: u.name]
    )
    |> Repo.all()
  end

  def create_family(scope, attrs) do
    %Family{}
    |> Family.changeset(attrs, scope)
    |> Repo.insert()
  end

  def list_families(%Scope{organization: %Organization{id: org_id}}) do
    from(f in Family,
      where: f.organization_id == ^org_id,
      order_by: [asc: f.designation]
    )
    |> Repo.all()
  end

  def update_family(scope, family, attrs) do
    family
    |> Family.changeset(attrs, scope)
    |> Repo.update()
  end

  ## User registration and invitation

  @doc """
  Registers a user.

  ## Examples

      iex> register_user(%{field: value})
      {:ok, %User{}}

      iex> register_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_user(attrs, organization) do
    %User{}
    |> User.email_changeset(attrs, organization)
    |> Repo.insert()
  end

  def import_user(scope, attrs) do
    %User{}
    |> User.import_changeset(attrs, scope)
    # TODO: we should set whatever fields we can update when there is a conflict
    |> Repo.insert(on_conflict: :nothing)
  end

  @doc """
  Invites a new user based on the provided scope (for organization) and delivers login instructions.

  Requires an email in attrs. Creates a user record associated with the scope's organization.
  A `magic_link_url_fun` that takes an encoded token and returns a URL must be provided.

  ## Examples

      iex> invite_user(scope, %{email: "new@example.com"}, &url_fun/1)
      {:ok, %User{}}

      iex> invite_user(scope, %{email: "invalid"}, &url_fun/1)
      {:error, %Ecto.Changeset{}}
  """
  def invite_user(
        %Scope{organization: %Organization{id: current_org_id}} = scope,
        attrs \\ %{},
        magic_link_url_fun
      )
      when is_function(magic_link_url_fun, 1) do
    changeset = User.invitation_changeset(%User{}, attrs, scope)

    family_attrs = %{
      designation: Changeset.get_change(changeset, :family_designation),
      address: Changeset.get_change(changeset, :family_address)
    }

    {:ok, family} =
      case Changeset.get_change(changeset, :family_id) do
        nil ->
          %Family{}
          |> Family.changeset(family_attrs, scope)
          |> Repo.insert()

        family_id when is_integer(family_id) ->
          fam = %Family{} = Repo.get_by!(Family, id: family_id, organization_id: current_org_id)

          fam
          |> Family.changeset(family_attrs, scope)
          |> Repo.update()
      end

    with {:ok, %User{} = user} <-
           %User{}
           |> User.invitation_changeset(Map.merge(attrs, %{"family_id" => family.id}), scope)
           |> Repo.insert() do
      {encoded_token, user_token} = UserToken.build_email_token(user, "login")

      Repo.insert!(user_token)
      UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))

      {:ok, user}
    end
  end

  ## Settings

  @doc """
  Checks whether the user is in sudo mode.

  The user is in sudo mode when the last authentication was done no further
  than 20 minutes ago. The limit can be given as second argument in minutes.
  """
  def sudo_mode?(user, minutes \\ -20)

  def sudo_mode?(%User{authenticated_at: ts}, minutes) when is_struct(ts, DateTime) do
    DateTime.after?(ts, DateTime.utc_now() |> DateTime.add(minutes, :minute))
  end

  def sudo_mode?(_user, _minutes), do: false

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the user email.

  See `CMS.Accounts.User.email_changeset/3` for a list of supported options.

  ## Examples

      iex> change_user_email(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user_email(user, attrs \\ %{}, opts \\ []) do
    User.email_changeset(user, attrs, user.organization, opts)
  end

  def update_user(scope, user, attrs) do
    user
    |> User.update_changeset(attrs, scope)
    |> Repo.update()
  end

  @doc """
  Updates the user email using the given token.

  If the token matches, the user email is updated and the token is deleted.
  """
  def update_user_email(user, token) do
    context = "change:#{user.email}"

    with {:ok, query} <- UserToken.verify_change_email_token_query(token, context),
         %UserToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(user_email_multi(user, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp user_email_multi(user, email, context) do
    changeset = User.email_changeset(user, %{email: email}, user.organization)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, changeset)
    |> Ecto.Multi.delete_all(:tokens, UserToken.by_user_and_contexts_query(user, [context]))
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_user_session_token(user) do
    {token, user_token} = UserToken.build_session_token(user)
    Repo.insert!(user_token)
    token
  end

  @doc """
  Gets the user with the given signed token.

  If the token is valid `{user, token_inserted_at}` is returned, otherwise `nil` is returned.
  """
  def get_user_by_session_token(token) do
    {:ok, query} = UserToken.verify_session_token_query(token)

    case Repo.one(query) do
      {user, token_inserted_at} -> {Repo.preload(user, :organization), token_inserted_at}
      _ -> nil
    end
  end

  @doc """
  Gets the user with the given magic link token.
  """
  def get_user_by_magic_link_token(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         {user, _token_record} <- Repo.one(query) do
      user
    else
      _ -> nil
    end
  end

  @doc """
  Logs the user in by magic link.

  There are three cases to consider:

  1. The user has already confirmed their email. They are logged in
     and the magic link is expired.

  2. The user has not confirmed their email and no password is set.
     In this case, the user gets confirmed, logged in, and all tokens -
     including session ones - are expired. In theory, no other tokens
     exist but we delete all of them for best security practices.

  3. The user has not confirmed their email but a password is set.
     This cannot happen in the default implementation but may be the
     source of security pitfalls. See the "Mixing magic link and password registration" section of
     `mix help phx.gen.auth`.
  """
  def login_user_by_magic_link(token) do
    with {:ok, query} <- UserToken.verify_magic_link_token_query(token),
         result <- Repo.one(query) do
      case result do
        {%User{confirmed_at: nil} = u, _token_record} ->
          {:ok, user, expired_tokens} =
            u
            |> User.confirm_changeset()
            |> update_user_and_delete_all_tokens()

          {:ok, Repo.preload(user, [:organization]), expired_tokens}

        {user, token_record} ->
          # User already confirmed, just delete this magic link token
          Repo.delete!(token_record)
          {:ok, Repo.preload(user, [:organization]), []}

        nil ->
          {:error, :not_found}
      end
    else
      _error ->
        {:error, :not_found}
    end
  end

  @doc ~S"""
  Delivers the update email instructions to the given user.

  ## Examples

      iex> deliver_user_update_email_instructions(user, current_email, &url(~p"/users/settings/confirm-email/#{&1}"))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_user_update_email_instructions(%User{} = user, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "change:#{current_email}")

    Repo.insert!(user_token)
    UserNotifier.deliver_update_email_instructions(user, update_email_url_fun.(encoded_token))
  end

  @doc ~S"""
  Delivers the magic link login instructions to the given user.
  This function is used for the standard magic link flow (e.g., for user invitations).
  """
  def deliver_login_instructions(%User{} = user, magic_link_url_fun)
      when is_function(magic_link_url_fun, 1) do
    {encoded_token, user_token} = UserToken.build_email_token(user, "login")
    Repo.insert!(user_token)
    UserNotifier.deliver_login_instructions(user, magic_link_url_fun.(encoded_token))
  end

  @doc ~S"""
  Delivers OTP login instructions to the given user.
  The user will receive an email with the OTP code.
  """
  def deliver_otp_login_instructions(%User{} = user) do
    {otp_string, user_token_struct} = UserToken.build_otp_token(user, "login_otp")
    Repo.insert!(user_token_struct)
    UserNotifier.deliver_otp_code_instructions(user, otp_string)
  end

  @doc """
  Verifies an OTP code submitted by a user and logs them in.
  Returns `{:ok, user}` on success, `{:error, reason}` on failure.
  Reasons can be `:not_found` (user email not found),
  `:invalid_or_expired_otp`, or `:confirmation_failed`.
  """
  def verify_and_log_in_user_by_otp(email, submitted_otp_code)
      when is_binary(email) and is_binary(submitted_otp_code) do
    case get_user_by_email(email) do
      nil ->
        {:error, :not_found}

      user_from_email ->
        with {:ok, query_from_otp_verification} <-
               UserToken.verify_otp_token_query(submitted_otp_code),
             token_verification_result <- Repo.one(query_from_otp_verification) do
          case token_verification_result do
            {user_associated_with_otp, token_record} ->
              if user_associated_with_otp.id == user_from_email.id do
                Repo.delete!(token_record)

                if is_nil(user_associated_with_otp.confirmed_at) do
                  case User.confirm_changeset(user_associated_with_otp) |> Repo.update() do
                    {:ok, confirmed_user} ->
                      {:ok, Repo.preload(confirmed_user, [:organization])}

                    {:error, _changeset} ->
                      {:error, :confirmation_failed}
                  end
                else
                  {:ok, Repo.preload(user_associated_with_otp, [:organization])}
                end
              else
                {:error, :invalid_or_expired_otp}
              end

            nil ->
              {:error, :invalid_or_expired_otp}
          end
        else
          _error_or_unmatched_step ->
            {:error, :invalid_or_expired_otp}
        end
    end
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_user_session_token(token) do
    Repo.delete_all(UserToken.by_token_and_context_query(token, "session"))
    :ok
  end

  ## Token helper

  defp update_user_and_delete_all_tokens(changeset) do
    %{data: %User{} = user} = changeset

    with {:ok, %{user: user, tokens_to_expire: expired_tokens}} <-
           Ecto.Multi.new()
           |> Ecto.Multi.update(:user, changeset)
           |> Ecto.Multi.all(:tokens_to_expire, UserToken.by_user_and_contexts_query(user, :all))
           |> Ecto.Multi.delete_all(:tokens, fn %{tokens_to_expire: tokens_to_expire} ->
             UserToken.delete_all_query(tokens_to_expire)
           end)
           |> Repo.transaction() do
      {:ok, user, expired_tokens}
    end
  end

  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end
end
