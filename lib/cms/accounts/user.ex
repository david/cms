defmodule CMS.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.{Organization, Scope}

  schema "users" do
    field :name, :string
    field :email, :string
    field :phone_number, :string
    field :birth_date, :date
    field :confirmed_at, :utc_datetime
    field :authenticated_at, :utc_datetime, virtual: true

    field :family_designation, :string, virtual: true
    field :family_address, :string, virtual: true

    belongs_to :organization, CMS.Accounts.Organization
    belongs_to :family, CMS.Accounts.Family

    field :role, Ecto.Enum, values: [:admin, :member]

    timestamps(type: :utc_datetime)
  end

  @doc """
  A user changeset for registering or changing the email.

  It requires the email to change otherwise an error is added.

  ## Options

    * `:validate_email` - Set to false if you don\'t want to validate the
      uniqueness of the email, useful when displaying live validations.
      Defaults to `true`.
  """
  def email_changeset(user, attrs, organization, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> put_change(:organization_id, organization.id)
  end

  defp validate_email(changeset, opts) do
    validate_email = Keyword.get(opts, :validate_email, true)
    changeset = validate_email_for_invitation(changeset, validate_email)

    if(validate_email, do: validate_email_changed(changeset), else: changeset)
  end

  defp validate_email_for_invitation(changeset, ensure_uniqueness \\ true) do
    changeset =
      changeset
      |> validate_required([:email])
      |> validate_format(:email, ~r/^[^@,;\s]+@[^@,;\s]+$/,
        message: "must have the @ sign and no spaces"
      )
      |> validate_length(:email, max: 160)

    if ensure_uniqueness do
      changeset
      |> unsafe_validate_unique(:email, CMS.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  defp validate_email_changed(changeset) do
    if get_field(changeset, :email) && get_change(changeset, :email) == nil do
      add_error(changeset, :email, "did not change")
    else
      changeset
    end
  end

  def import_changeset(user, attrs, %Scope{organization: %Organization{id: org_id}}) do
    user
    |> cast(attrs, [:birth_date, :family_id, :name])
    # TODO: need to validate birth date, email, name, phone number
    |> assoc_constraint(:family)
    |> put_change(:organization_id, org_id)
  end

  @doc """
  A changeset for inviting a new user.
  It requires an email and name, and associates the user with the given organization.
  It also expects family_id to be set prior to calling Accounts.invite_user.
  """
  def invitation_changeset(user, attrs, scope) do
    user
    |> cast(attrs, [
      :name,
      :email,
      :phone_number,
      :family_id,
      :family_designation,
      :family_address,
      :birth_date
    ])
    |> validate_required([:name, :email, :family_designation, :family_id])
    |> validate_email_for_invitation()
    |> put_change(:organization_id, scope.organization.id)
    |> assoc_constraint(:family)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(user) do
    now = DateTime.utc_now(:second)
    change(user, confirmed_at: now)
  end
end
