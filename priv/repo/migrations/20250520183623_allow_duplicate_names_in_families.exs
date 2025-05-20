defmodule CMS.Repo.Migrations.AllowDuplicateNamesInFamilies do
  use Ecto.Migration

  def change do
    drop unique_index(:users, [:family_id, :name], name: :users_family_id_name_index)
    create unique_index(:users, [:family_id, :name, :birth_date])
  end
end
