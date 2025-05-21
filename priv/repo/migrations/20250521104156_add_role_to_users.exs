defmodule CMS.Repo.Migrations.AddRoleToUsers do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE user_role AS ENUM ('admin', 'member')"

    alter table(:users) do
      add :role, :user_role
    end

    execute "UPDATE users SET role = 'admin'"
  end

  def down do
    alter table(:users) do
      remove :role
    end

    execute "DROP TYPE user_role"
  end
end
