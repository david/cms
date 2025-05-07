defmodule CMS.Bibles.Verse do
  use Ecto.Schema

  schema "bibles_verses" do
    field :book, :integer
    field :chapter, :integer
    field :number, :integer
    field :body, :string

    timestamps()
  end
end
