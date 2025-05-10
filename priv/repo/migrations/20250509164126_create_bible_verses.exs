defmodule CMS.Repo.Migrations.CreateBibleVerses do
  use Ecto.Migration

  def change do
    create table(:bible_verses) do
      add :book_usfm, :string, null: false
      add :chapter, :integer, null: false
      add :verse_number, :integer, null: false
      add :body, :text, null: false # Changed from :text

      timestamps()
    end

    create index(:bible_verses, [:book_usfm, :chapter, :verse_number], unique: true, name: :bible_verses_book_chapter_verse_index) # Changed fields and name
  end
end
