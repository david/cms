defmodule CMS.Repo.Migrations.AddHostnameToOrganizations do
  use Ecto.Migration

  def change do
    alter table(:organizations) do
      add :hostname, :string, null: false, default: "localhost"
    end

    create unique_index(:organizations, [:hostname])

    alter table(:organizations) do
      modify :hostname, :string, null: false, default: nil
    end
  end
end
