defmodule CMS.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string
    field :hostname, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :hostname])
    |> validate_required([:name, :hostname])
    |> unique_constraint(:hostname)
  end
end
