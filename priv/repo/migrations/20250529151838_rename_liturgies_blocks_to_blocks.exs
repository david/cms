defmodule CMS.Repo.Migrations.RenameLiturgiesBlocksToBlocks do
  use Ecto.Migration

  def change do
    rename table(:liturgies_blocks), to: table(:blocks)
  end
end
