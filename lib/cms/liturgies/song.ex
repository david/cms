defmodule CMS.Liturgies.Song do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope

  schema "songs" do
    field :body, :string

    field :title, :string

    belongs_to :organization, CMS.Accounts.Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(block, attrs, %Scope{} = scope) do
    block
    |> cast(attrs, [:title, :body])
    |> put_change(:organization_id, scope.organization.id)
  end
end
