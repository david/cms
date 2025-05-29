defmodule CMS.Repo.Migrations.RenameBlocksToSharedContents do
  use Ecto.Migration

  def change do
    rename table(:blocks), to: table(:shared_contents)
  end
end
