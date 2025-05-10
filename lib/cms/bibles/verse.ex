defmodule CMS.Bibles.Verse do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Bibles.Verse

  schema "bible_verses" do
    field :book_usfm, :string
    field :chapter, :integer
    field :verse_number, :integer
    field :body, :string

    timestamps()
  end

  @doc """
  Builds a changeset by applying attributes to a verse struct.
  Used for creating (with an empty %Verse{}) or updating (with a loaded Verse).
  The `attrs` argument should be a map of parameters to cast.
  """
  def changeset(%Verse{} = verse_struct, attrs \\ %{}) do
    verse_struct
    |> cast(attrs, [:book_usfm, :chapter, :verse_number, :body])
    |> validate_required([:book_usfm, :chapter, :verse_number, :body])
    |> unique_constraint([:book_usfm, :chapter, :verse_number])
  end
end
