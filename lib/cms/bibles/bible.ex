defmodule CMS.Bibles.Bible do
  use Ecto.Schema

  schema "bibles" do
    field :name, :string
    field :usfm_index, :string
    field :source_id, :integer
    field :source_label, :string
    field :language, :string

    timestamps()
  end
end
