defmodule CMS.Liturgies.Block do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Organization
  alias CMS.Bibles
  alias CMS.Songs
  alias CMS.Songs.Song
  alias CMS.Liturgies.Liturgy

  defmodule Types do
    def types, do: [:text, :song, :passage]
  end

  schema "blocks" do
    field :position, :integer

    field :title, :string
    field :subtitle, :string
    field :body, :string
    field :type, Ecto.Enum, values: Types.types()

    field :resolved_body, :string, virtual: true

    belongs_to :liturgy, Liturgy
    belongs_to :song, Song, on_replace: :nilify
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(block, attrs, index, liturgy_attrs, user_scope) do
    type = get_type(block, attrs, liturgy_attrs, index)

    block
    |> cast(attrs, [:song_id, :position, :body, :subtitle, :title, :type])
    |> put_change(:type, type)
    |> put_change(:organization_id, user_scope.organization.id)
    |> put_change(:position, index)
    |> normalize_block(type, attrs, user_scope)
  end

  defp get_type(block, attrs, liturgy_attrs, index) do
    block
    |> cast(attrs, [:type])
    |> get_field(:type) ||
      case Enum.at(liturgy_attrs["blocks_sort"], index) do
        "new-text" -> :text
        "new-song" -> :song
        "new-passage" -> :passage
      end
  end

  defp normalize_block(changeset, :text, _attrs, _scope), do: changeset

  defp normalize_block(changeset, :passage, %{"title" => title}, _user_scope) do
    put_change(changeset, :resolved_body, Bibles.get_verses(title))
  end

  defp normalize_block(
         %{data: %{song_id: song_id}} = changeset,
         :song,
         _attrs,
         _user_scope
       )
       when not is_nil(song_id),
       do: changeset

  defp normalize_block(changeset, :song, %{"title" => title}, user_scope) do
    song = Songs.suggest(user_scope, title)

    cond do
      song ->
        changeset
        |> put_change(:body, song.body)
        |> put_assoc(:song, song)

      get_field(changeset, :body) ->
        put_assoc(
          changeset,
          :song,
          %Song{
            body: get_field(changeset, :body),
            title: title,
            organization_id: user_scope.organization.id
          }
        )

      true ->
        changeset
    end
  end

  defp normalize_block(changeset, _type, _attrs, _user_scope), do: changeset

  def make_template(%{type: :text, title: title, subtitle: subtitle}) do
    %__MODULE__{
      type: :text,
      title: title,
      subtitle: subtitle
    }
  end

  def make_template(%{type: type, subtitle: subtitle}) do
    %__MODULE__{
      type: type,
      subtitle: subtitle
    }
  end
end
