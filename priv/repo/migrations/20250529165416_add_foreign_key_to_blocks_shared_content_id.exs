defmodule CMS.Repo.Migrations.AddForeignKeyToBlocksSharedContentId do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      modify :shared_content_id, references(:shared_contents, on_delete: :nothing)
    end
  end
end
