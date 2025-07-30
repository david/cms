defmodule CMS.Prayers.PrayerRequest do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope

  schema "prayer_requests" do
    field :body, :string
    field :visibility, Ecto.Enum, values: [:private, :organization, :group], default: :private
    # The user's name is used by the autocomplete component's text input.
    field :user_name, :string, virtual: true
    belongs_to :user, CMS.Accounts.User
    belongs_to :organization, CMS.Accounts.Organization
    belongs_to :group, CMS.Accounts.Group

    timestamps()
  end

  def changeset(prayer_request, attrs, %Scope{} = scope) do
    prayer_request
    |> cast(attrs, [:body, :visibility, :group_id])
    |> validate_required([:body, :visibility])
    |> put_assoc(:user, scope.user)
    |> put_assoc(:organization, scope.organization)
    |> validate_group(scope)
  end

  defp validate_group(changeset, scope) do
    case get_field(changeset, :visibility) do
      :group ->
        if group_id = get_field(changeset, :group_id) do
          true = group_id in Enum.map(scope.groups, & &1.id)
        end

        validate_required(changeset, :group_id)

      _ ->
        changeset
    end
  end
end
