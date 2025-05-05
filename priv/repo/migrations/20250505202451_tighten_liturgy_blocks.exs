defmodule CMS.Repo.Migrations.TightenLiturgyBlocks do
  use Ecto.Migration

  def change do
    alter table(:liturgies_blocks) do
      lref = references(:liturgies, on_delete: :delete_all)
      bref = references(:blocks, on_delete: :delete_all)

      modify :liturgy_id, lref, from: lref, null: false
      modify :block_id, bref, from: bref, null: false
    end
  end
end
