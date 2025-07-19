defmodule CMS.Repo.Migrations.CreatePrayerRequests do
  use Ecto.Migration

  def change do
    create table(:prayer_requests) do
      add :body, :text, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false
      add :organization_id, references(:organizations, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:prayer_requests, [:user_id])
    create index(:prayer_requests, [:organization_id])
  end
end
