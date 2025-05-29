defmodule CMS.Liturgies.Liturgy do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Liturgies.Block

  schema "liturgies" do
    field :service_on, :date

    belongs_to :organization, CMS.Accounts.Organization

    has_many :blocks, Block, on_replace: :delete
    has_many :shared_contents, through: [:blocks, :shared_content]

    timestamps(type: :utc_datetime)
  end

  def new do
    %__MODULE__{blocks: []}
  end

  def changeset(liturgy, attrs, user_scope) do
    liturgy
    |> cast(attrs, [:service_on])
    |> cast_assoc(:blocks,
      with: &Block.changeset(&1, &2, &3, attrs, user_scope),
      sort_param: :blocks_sort,
      drop_param: :blocks_drop
    )
    |> validate_required([:service_on])
    |> put_change(:organization_id, user_scope.organization.id)
    |> unique_constraint(:service_on,
      message: "A liturgy already exists for this organization on this date."
    )
  end

  def copy_changeset(source, user_scope) do
    attrs = %{
      organization_id: user_scope.organization.id,
      service_on: Date.add(source.service_on, 7)
    }

    %__MODULE__{}
    |> cast(attrs, [:service_on, :organization_id])
    |> put_assoc(
      :blocks,
      Enum.map(source.liturgy_blocks, &Block.copy_changeset(&1, user_scope))
    )
  end
end
