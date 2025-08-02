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

    timestamps()
  end

  def changeset(prayer_request, attrs, %Scope{} = scope) do
    prayer_request
    |> cast(attrs, [:body])
    |> validate_required([:body])
    |> put_assoc(:user, scope.user)
    |> put_assoc(:organization, scope.organization)
  end
end
