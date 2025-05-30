defmodule CMS.Repo.Migrations.CleanBlocksAndSharedContent do
  use Ecto.Migration

  def up do
    alter table(:blocks) do
      modify :shared_content_id, references(:shared_contents, on_delete: :nothing),
        from: references(:shared_contents, on_delete: :nothing),
        null: true
    end

    execute """
      UPDATE blocks AS b
      SET shared_content_id = NULL
      FROM shared_contents AS sc
      WHERE b.shared_content_id = sc.id AND sc.body IS NULL;
    """

    execute """
      DELETE FROM shared_contents
      WHERE id NOT IN (SELECT shared_content_id FROM blocks WHERE shared_content_id IS NOT NULL);
    """
  end

  def down do
  end
end
