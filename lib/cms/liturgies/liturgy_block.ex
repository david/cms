defmodule CMS.Liturgies.LiturgyBlock do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Organization
  alias CMS.Liturgies.Block
  alias CMS.Liturgies.Liturgy

  schema "liturgies_blocks" do
    field :position, :integer

    field :title, :string, virtual: true
    field :subtitle, :string, virtual: true
    field :body, :string, virtual: true
    field :type, Ecto.Enum, values: Block.types(), virtual: true

    belongs_to :liturgy, Liturgy
    belongs_to :block, Block
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(liturgy_block, attrs, user_scope) do
    liturgy_block
    |> cast(attrs, [:liturgy_id, :position])
    |> cast_assoc(:block, with: &Block.changeset(&1, &2, user_scope), required: true)
    |> put_change(:organization_id, user_scope.user.organization_id)
  end
end
