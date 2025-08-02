defmodule CMS.Prayers.PrayerRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope

  schema "prayer_requests" do
    field :body, :string
    # The user's name is used by the autocomplete component's text input.
    field :user_name, :string, virtual: true
    belongs_to :user, CMS.Accounts.User
    belongs_to :organization, CMS.Accounts.Organization
    belongs_to :created_by, CMS.Accounts.User, foreign_key: :created_by_id

    timestamps()
  end

  def changeset(prayer_request, attrs, %Scope{} = scope) do
    prayer_request
    |> cast(attrs, [:body, :user_id])
    |> validate_required([:body])
    |> put_assoc(:created_by, scope.user)
    |> put_assoc(:organization, scope.organization)
    |> assign_user_if_not_present(scope.user)
    |> validate_required([:user_id])
  end

  defp assign_user_if_not_present(changeset, user) do
    if get_field(changeset, :user_id) do
      changeset
    else
      changeset
      # `put_assoc` is used here because we are associating an existing user,
      # not creating or updating one.
      |> put_assoc(:user, user)
      |> put_change(:user_id, user.id)
    end
  end
end
