defmodule CMS.Repo.Migrations.CreateBlocks do
  use Ecto.Migration

  def change do
    create table(:blocks) do
      add :title, :string, null: false
      add :subtitle, :string
      add :body, :text
      add :type, :string, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end

    create table(:liturgies_blocks) do
      add :liturgy_id, references(:liturgies, on_delete: :delete_all)
      add :block_id, references(:blocks, on_delete: :delete_all)
      add :position, :integer, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
