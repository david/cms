defmodule Cms.Repo.Migrations.AddCreatedByIdToPrayerRequests do
  use Ecto.Migration

  def change do
    alter table(:prayer_requests) do
      add :created_by_id, references(:users, on_delete: :nothing)
    end

    execute("UPDATE prayer_requests SET created_by_id = user_id")

    alter table(:prayer_requests) do
      modify :created_by_id, :bigint, null: false
    end
  end
end
