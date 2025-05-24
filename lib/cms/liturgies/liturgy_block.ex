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
  def changeset(liturgy_block, attrs, user_scope) do
    liturgy_block
    |> cast(attrs, [:block_id, :position])
    |> merge(Block.changeset(liturgy_block, attrs, user_scope))
    |> normalize_block(user_scope)
    |> put_change(:organization_id, user_scope.organization.id)
  end

  defp normalize_block(%Ecto.Changeset{changes: %{title: nil}} = changeset, _scope), do: changeset

  defp normalize_block(
         %Ecto.Changeset{changes: %{title: title}, data: %{type: type}} = changeset,
         scope
       )
       when type in [:passage, :song] do
    if Regex.match?(~r/^\s*$/, title) do
      changeset
    else
      scope
      |> Blocks.suggest_block(type, title)
      |> change_copy(changeset, scope)
    end
  end

  defp normalize_block(changeset, scope),
    do: changeset |> cast_assoc(:block, with: &Block.changeset(&1, &2, scope))

  defp change_copy(nil, changeset, _scope),
    do:
      changeset
      |> put_change(:block_id, nil)
      |> put_change(:body, nil)
      |> put_change(:type, nil)
      |> cast_assoc(:block, nil)

  defp change_copy(%{id: nil, body: body, title: title, type: :song = type}, changeset, scope),
    do:
      changeset
      |> put_change(:body, body)
      |> put_change(:type, type)
      |> put_assoc(:block, %Block{type: type, title: title, body: body})
      |> cast_assoc(:block, with: &Block.song_changeset(&1, &2, scope))

  defp change_copy(%{id: nil, body: body, title: title, type: :passage = type}, changeset, scope),
    do:
      changeset
      |> put_change(:body, body)
      |> put_change(:type, type)
      |> put_assoc(:block, %Block{type: type, title: title})
      |> cast_assoc(:block, with: &Block.passage_changeset(&1, &2, scope))

  defp change_copy(%{id: id, body: body, type: type} = block, changeset, _scope),
    do:
      changeset
      |> put_change(:block_id, id)
      |> put_change(:body, body)
      |> put_change(:type, type)
      |> put_assoc(:block, block)

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
