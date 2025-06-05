defmodule CMS.Repo.Migrations.AndRenameSharedContentId do
  use Ecto.Migration

  def change do
    rename table(:blocks), :shared_content_id, to: :song_id
  end
end
