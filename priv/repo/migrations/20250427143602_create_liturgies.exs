defmodule CMS.Repo.Migrations.CreateLiturgies do
  use Ecto.Migration

  def change do
    create table(:liturgies) do
      add :blocks, :jsonb, null: false
      add :service_on, :date
      add :organization_id, references(:organizations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:liturgies, [:organization_id])
  end
end
