defmodule CMS.Repo.Migrations.AddTypeToBlocks do
  use Ecto.Migration

  def up do
    alter table(:blocks) do
      add :type, :string, null: true
    end

    # Copy type from shared_contents for blocks with a shared_content_id
    execute """
      UPDATE blocks AS b
      SET type = sc.type
      FROM shared_contents AS sc
      WHERE b.shared_content_id = sc.id;
    """

    # Make the type column mandatory
    alter table(:blocks) do
      modify :type, :string, null: false
    end
  end

  def down do
    alter table(:blocks) do
      remove :type
    end
  end
end
