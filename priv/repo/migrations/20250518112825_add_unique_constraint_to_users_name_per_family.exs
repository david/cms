defmodule CMS.Repo.Migrations.AddUniqueConstraintToUsersNamePerFamily do
  use Ecto.Migration

  def change do
    create unique_index(:users, [:family_id, :name], name: :users_family_id_name_index)
  end
end
