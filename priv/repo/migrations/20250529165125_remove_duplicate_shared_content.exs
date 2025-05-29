defmodule CMS.Repo.Migrations.RemoveDuplicateSharedContent do
  use Ecto.Migration

  def up do
    execute """
      DELETE FROM shared_contents
      WHERE id IN (
          SELECT id
          FROM (
              SELECT
                  id,
                  ROW_NUMBER() OVER (PARTITION BY title, organization_id, type ORDER BY id) as rn
              FROM shared_contents
          ) AS duplicates
          WHERE rn > 1
      );
    """
  end

  def down do
    # No direct way to reverse this data deletion without a backup
  end
end
