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
    |> cast(attrs, [:block_id, :position])
    |> merge(Block.changeset(liturgy_block, attrs, user_scope))
    |> put_change(:organization_id, user_scope.organization.id)
  end

  @doc false
  def copy_changeset(%{block_id: block_id, position: position}, user_scope) do
    attrs = %{
      block_id: block_id,
      organization_id: user_scope.organization.id,
      position: position
    }

    cast(%__MODULE__{}, attrs, [:block_id, :organization_id, :position])
  end
end
