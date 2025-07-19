defmodule CMS.Prayers.PrayerRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "prayer_requests" do
    field :body, :string
    belongs_to :user, CMS.Accounts.User
    belongs_to :organization, CMS.Accounts.Organization

    timestamps()
  end

  @doc false
  def changeset(prayer_request, attrs) do
    prayer_request
    |> cast(attrs, [:body])
    |> validate_required([:body])
  end
end
