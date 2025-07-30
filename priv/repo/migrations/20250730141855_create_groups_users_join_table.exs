defmodule CMS.Repo.Migrations.CreateGroupsUsersJoinTable do
  use Ecto.Migration

  def change do
    create table(:groups_users, primary_key: false) do
      add :group_id, references(:groups, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end

    create index(:groups_users, [:group_id, :user_id], unique: true)
  end
end
