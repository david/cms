defmodule Cms.Repo.Migrations.CreateFamiliesAndMigrateUsersFamilyDesignation do
  use Ecto.Migration

  def up do
    create table(:families) do
      add :designation, :string, null: false
      add :address, :text
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:families, [:organization_id, :designation])

    execute """
    INSERT INTO families (id, designation, organization_id, inserted_at, updated_at)
    SELECT id, CONCAT(family_designation, ' ', id::varchar), organization_id, now(), now()
    FROM users
    """

    execute """
    SELECT setval('families_id_seq', max(id), true)
    FROM families
    """

    alter table(:users) do
      add :family_id, references(:families, on_delete: :delete_all)
    end

    execute "UPDATE users SET family_id = id"

    alter table(:users) do
      modify :family_id, references(:families, on_delete: :delete_all),
        from: references(:families, on_delete: :delete_all),
        null: false

      remove :family_designation
    end

    create index(:users, [:family_id])
  end

  def down do
    alter table(:users) do
      add :family_designation, :string
    end

    execute """
    UPDATE users SET family_designation = families.designation
    FROM families
    WHERE users.family_id = families.id
    """

    alter table(:users) do
      modify :family_designation, :string, null: false
      remove :family_id
    end

    drop table(:families)
  end
end
