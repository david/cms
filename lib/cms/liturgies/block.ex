defmodule CMS.Liturgies.Block do
  use Ecto.Schema
  import Ecto.Changeset

  @types [:text, :song, :passage]

  schema "blocks" do
    field :body, :string
    field :subtitle, :string
    field :title, :string
    field :type, Ecto.Enum, values: @types, null: false

    belongs_to :organization, CMS.Accounts.Organization

    timestamps(type: :utc_datetime)
  end

  def types, do: @types

  def parse_type(type) when type in [nil, ""], do: {:error, type}
  def parse_type(type) when type in @types, do: {:ok, type}

  def parse_type(type) when is_binary(type) do
    type |> String.to_existing_atom() |> parse_type()
  end

  @doc false
  def changeset(%{type: :text} = block, attrs, scope), do: text_changeset(block, attrs, scope)
  def changeset(block, %{"type" => :text} = attrs, scope), do: text_changeset(block, attrs, scope)

  def changeset(block, %{"type" => "text"} = attrs, scope),
    do: text_changeset(block, Map.put(attrs, "type", :text), scope)

  def changeset(%{type: :song} = block, attrs, scope), do: song_changeset(block, attrs, scope)
  def changeset(block, %{"type" => :song} = attrs, scope), do: song_changeset(block, attrs, scope)

  def changeset(block, %{"type" => "song"} = attrs, scope),
    do: song_changeset(block, Map.put(attrs, "type", :song), scope)

  def changeset(%{type: :passage} = block, attrs, scope),
    do: passage_changeset(block, attrs, scope)

  def changeset(block, %{"type" => :passage} = attrs, scope),
    do: passage_changeset(block, attrs, scope)

  def changeset(block, %{"type" => "passage"} = attrs, scope),
    do: passage_changeset(block, Map.put(attrs, "type", :passage), scope)

  defp text_changeset(block, attrs, scope) do
    block
    |> cast(attrs, [:title, :body, :subtitle])
    |> put_change(:type, :text)
    |> put_change(:organization_id, scope.user.organization_id)
  end

  defp song_changeset(block, attrs, scope) do
    block
    |> cast(attrs, [:title, :body])
    |> put_change(:type, :song)
    |> put_change(:organization_id, scope.user.organization_id)
  end

  defp passage_changeset(block, attrs, scope) do
    block
    |> cast(attrs, [:title, :subtitle])
    |> put_change(:type, :passage)
    |> put_change(:organization_id, scope.user.organization_id)
  end
end
