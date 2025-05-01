defmodule CMS.Liturgies.Liturgy do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Liturgies.Block
  alias CMS.Liturgies.LiturgyBlock

  schema "liturgies" do
    field :service_on, :date

    belongs_to :organization, CMS.Accounts.Organization

    has_many :liturgy_blocks, LiturgyBlock, on_replace: :delete
    has_many :blocks, through: [:liturgy_blocks, :block]

    timestamps(type: :utc_datetime)
  end

  def new do
    %__MODULE__{liturgy_blocks: []}
  end

  def changeset(liturgy, attrs, user_scope) do
    liturgy
    |> cast(attrs, [:service_on])
    |> cast_assoc(:liturgy_blocks,
      with: &block_changeset(&1, &2, &3, liturgy, attrs, user_scope),
      sort_param: :liturgy_blocks_sort,
      drop_param: :liturgy_blocks_drop
    )
    |> validate_required([:service_on])
    |> put_change(:organization_id, user_scope.organization.id)
  end

  defp block_changeset(lb, lb_attrs, index, liturgy, liturgy_attrs, user_scope) do
    true = safe_block?(liturgy.liturgy_blocks, lb_attrs)

    block_type =
      case {Block.parse_type(lb_attrs["type"]), lb.type} do
        {{:ok, type}, _} ->
          type

        {{:error, t}, nil} when t in [nil, ""] ->
          liturgy_attrs["liturgy_blocks_sort"] |> Enum.at(index) |> block_type()

        {{:error, t}, lb_type} when t in [nil, ""] ->
          lb_type
      end

    block_attrs =
      lb_attrs
      |> Map.take(["title", "subtitle", "body"])
      |> Map.put("type", block_type)
      |> Map.merge(if(Ecto.assoc_loaded?(lb.block), do: %{"id" => lb.block.id}, else: %{}))

    lb_attrs =
      Map.merge(lb_attrs, %{"position" => index, "type" => block_type, "block" => block_attrs})

    LiturgyBlock.changeset(lb, lb_attrs, user_scope)
  end

  defp safe_block?(_, %{}), do: true
  defp safe_block?(_, %{"id" => id}) when id in [nil, ""], do: true

  defp safe_block?(blocks, %{"id" => str}) do
    {block_id, _} = Integer.parse(str)

    Enum.find_value(blocks, false, &(&1.id == block_id))
  end

  defp block_type("new-text"), do: :text
  defp block_type("new-song"), do: :song
  defp block_type("new-passage"), do: :passage
end
