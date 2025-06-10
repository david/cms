defmodule CMS.Liturgies.Block do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Organization
  alias CMS.Bibles
  alias CMS.Songs.Song
  alias CMS.Songs
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
    block
    |> cast(attrs, [:song_id, :position, :body, :subtitle, :title, :type])
    |> put_block(attrs, index, liturgy_attrs, user_scope)
    |> put_change(:organization_id, user_scope.organization.id)
    |> put_change(:position, index)
  end

  defp put_block(changeset, attrs, index, liturgy_attrs, user_scope) do
    type =
      get_field(changeset, :type) ||
        case Enum.at(liturgy_attrs["blocks_sort"], index) do
          "new-text" -> :text
          "new-song" -> :song
          "new-passage" -> :passage
        end

    changeset
    |> build_song(type, attrs, user_scope)
  end

  defp build_song(changeset, :text, _attrs, _scope), do: changeset

  defp build_song(changeset, :passage, %{"title" => title}, _user_scope) do
    put_change(changeset, :body, Bibles.get_verses(title))
  end

  defp build_song(
         %{data: %{song_id: song_id}} = changeset,
         :song,
         _attrs,
         _user_scope
       )
       when not is_nil(song_id),
       do: changeset

  defp build_song(changeset, :song, %{"title" => title}, user_scope) do
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

  defp build_song(changeset, _type, _attrs, _user_scope), do: changeset

  def make_template(%{type: type, subtitle: subtitle}) do
    %__MODULE__{type: type, subtitle: subtitle}
  end
end
