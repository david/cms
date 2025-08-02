defmodule CMS.Repo.Migrations.RemoveCreatedByFromPrayerRequests do
  use Ecto.Migration

  def change do
    alter table(:prayer_requests) do
      remove :created_by_id
    end
  end
end
