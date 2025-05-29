defmodule CMS.Liturgies.SharedContent do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope

  @types [:text, :song, :passage]

  schema "shared_contents" do
    field :body, :string

    field :title, :string
    field :type, Ecto.Enum, values: @types, null: false

    belongs_to :organization, CMS.Accounts.Organization

    timestamps(type: :utc_datetime)
  end

  def types, do: @types

  def changeset(:text, block, attrs, %Scope{} = scope) do
    block
    |> cast(attrs, [:title, :body])
    |> put_change(:type, :text)
    |> put_change(:organization_id, scope.organization.id)
  end

  def changeset(:song, block, attrs, %Scope{} = scope) do
    block
    |> cast(attrs, [:title, :body])
    |> put_change(:type, :song)
    |> put_change(:organization_id, scope.organization.id)
  end

  def changeset(:passage, block, attrs, %Scope{} = scope) do
    block
    |> cast(attrs, [:title])
    |> put_change(:type, :passage)
    |> put_change(:organization_id, scope.organization.id)
  end
end
