defmodule Cms.Repo.Migrations.AddFamilyDesignationToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :family_designation, :string, null: true
    end

    execute "UPDATE users SET family_designation = 'Unknown'", ""

    alter table(:users) do
      modify :family_designation, :string, null: false
    end
  end
end
