defmodule CMS.Liturgies.LiturgyBlock do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Organization
  alias CMS.Accounts.Scope
  alias CMS.Liturgies.Block
  alias CMS.Liturgies.Blocks
  alias CMS.Liturgies.Liturgy

  schema "liturgies_blocks" do
    field :position, :integer

    field :title, :string, virtual: true
    field :subtitle, :string, virtual: true
    field :body, :string, virtual: true
    field :type, Ecto.Enum, values: Block.types(), virtual: true

    belongs_to :liturgy, Liturgy
    belongs_to :block, Block, on_replace: :nilify
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(liturgy_block, attrs, index, liturgy_attrs, user_scope) do
    liturgy_block
    |> cast(attrs, [:block_id, :position, :body, :subtitle, :title, :type])
    |> put_block(attrs, index, liturgy_attrs, user_scope)
    |> put_change(:organization_id, user_scope.organization.id)
  end

  defp put_block(changeset, attrs, index, liturgy_attrs, user_scope) do
    type =
      get_field(changeset, :type) ||
        case Enum.at(liturgy_attrs["liturgy_blocks_sort"], index) do
          "new-text" -> :text
          "new-song" -> :song
          "new-passage" -> :passage
        end

    changeset
    |> build_block(type, attrs, user_scope)
    |> merge(Block.changeset(type, changeset.data, attrs, user_scope))
    |> put_change(:position, index)
  end

  defp build_block(%{data: %{block_id: block_id}} = changeset, _type, _attrs, _user_scope)
       when not is_nil(block_id),
       do: changeset

  defp build_block(changeset, type, %{"title" => title}, user_scope)
       when type in [:song, :passage] do
    block = Blocks.suggest_block(user_scope, type, title)

    if block do
      changeset
      |> put_change(:body, block.body)
      |> put_assoc(:block, block)
    else
      build_block(changeset, )
      put_assoc(
        changeset,
        :block,
        %Block{
          body: get_field(changeset, :body),
          subtitle: get_field(changeset, :subtitle),
          title: title,
          type: type,
          organization_id: user_scope.organization.id
        }
      )
    end
  end

  defp build_block(changeset, %{organization: %{id: org_id}} = user_scope),
    do:
      put_assoc(
        changeset,
        :block,
        %Block{
          body: get_field(changeset, :body),
          subtitle: get_field(changeset, :subtitle),
          title: title,
          type: type,
          organization_id: org_id
        }
      )

  @doc false
  def copy_changeset(%{block_id: block_id, block: %{type: :song}, position: position}, %Scope{
        organization: %{id: org_id}
      }) do
    attrs = %{
      block_id: block_id,
      organization_id: org_id,
      position: position
    }

    cast(%__MODULE__{}, attrs, [:block_id, :organization_id, :position])
  end

  def copy_changeset(%{position: position, block: block}, %Scope{
        organization: %{id: org_id}
      }) do
    attrs = %{
      organization_id: org_id,
      position: position
    }

    %__MODULE__{}
    |> cast(attrs, [:organization_id, :position])
    |> put_assoc(
      :block,
      block |> Map.take([:type, :title, :subtitle, :body]) |> Map.put(:organization_id, org_id)
    )
  end
end
