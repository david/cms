defmodule CMS.Repo.Migrations.RepurposeSharedContents do
  use Ecto.Migration

  def change do
    drop table(:songs)

    rename table(:shared_contents), to: table(:songs)

    execute """
    update blocks
    set shared_content_id = null
    where shared_content_id is not null and type <> 'song'
    """

    execute "delete from songs where type <> 'song'"

    alter table(:songs) do
      remove :type
    end
  end
end
