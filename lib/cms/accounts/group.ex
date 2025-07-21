defmodule CMS.Accounts.Group do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope

  schema "groups" do
    field :name, :string
    field :description, :string

    belongs_to :organization, CMS.Accounts.Organization
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
