defmodule CMS.Repo.Migrations.MoveSubtitleFromSharedContentToBlock do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      add :subtitle, :string
    end

    execute("""
      UPDATE blocks b
      SET subtitle = sc.subtitle
      FROM shared_contents sc
      WHERE b.shared_content_id = sc.id;
    """)

    alter table(:shared_contents) do
      remove :subtitle
    end
  end
end
