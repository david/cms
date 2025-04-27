defmodule CMS.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :string, null: false
      timestamps(type: :utc_datetime)
    end

    execute """
    INSERT INTO organizations (name, inserted_at, updated_at) VALUES ('Default', NOW(), NOW())
    """

    ref = references(:organizations, type: :id, on_delete: :delete_all)

    alter table(:users) do
      add :organization_id, ref
    end

    create index(:users, [:organization_id])

    execute """
      UPDATE users
      SET organization_id = organizations.id
      FROM (SELECT id FROM organizations LIMIT 1) organizations
    """

    alter table(:users) do
      modify(:organization_id, ref, from: ref)
    end
  end
end
