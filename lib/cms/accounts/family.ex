defmodule CMS.Accounts.Family do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.{Organization, Scope}

  schema "families" do
    field :designation, :string
    field :address, :string

    belongs_to :organization, CMS.Accounts.Organization

    timestamps()
  end

  @doc false
  def changeset(family, attrs, %Scope{organization: %Organization{id: org_id}}) do
    family
    |> cast(attrs, [:designation, :address])
    |> validate_required([:designation])
    |> put_change(:organization_id, org_id)
    |> unique_constraint([:organization_id, :designation])
  end
end
