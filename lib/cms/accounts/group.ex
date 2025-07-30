defmodule CMS.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope

  schema "groups" do
    field :name, :string
    field :description, :string

    belongs_to :organization, CMS.Accounts.Organization

    many_to_many :users, CMS.Accounts.User, join_through: "groups_users"

    timestamps()
  end

  @doc false
  def changeset(group, attrs, %Scope{organization: org}) do
    group
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> put_assoc(:organization, org)
  end
end
