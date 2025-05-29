defmodule CMS.Repo.Migrations.RenameBlockIdToSharedContentIdInLiturgiesBlocks do
  use Ecto.Migration

  def change do
    rename table(:liturgies_blocks), :block_id, to: :shared_content_id
  end
end
