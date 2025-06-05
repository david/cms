defmodule CMS.Repo.Migrations.MoveTextBodiesToBlocks do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      add :body, :text
    end

    execute """
    UPDATE blocks
    SET body = shared_contents.body
    FROM shared_contents
    WHERE blocks.shared_content_id IS NOT NULL
      AND blocks.shared_content_id = shared_contents.id
    """
  end
end
