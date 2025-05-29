
defmodule CMS.Repo.Migrations.AddTitleToBlocksAndCopyFromSharedContents do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      add :title, :string
    end

    execute("""
      UPDATE blocks AS b
      SET title = sc.title
      FROM shared_contents AS sc
      WHERE b.shared_content_id = sc.id
    """)
  end
end
