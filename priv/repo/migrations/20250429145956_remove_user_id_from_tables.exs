defmodule CMS.Repo.Migrations.RemoveUserIdFromTables do
  use Ecto.Migration

  def change do
    alter table(:liturgies) do
      remove :user_id, references(:users, on_delete: :delete_all), null: false
    end

    alter table(:songs) do
      remove :user_id, references(:users, on_delete: :delete_all), null: false
    end
  end
end
