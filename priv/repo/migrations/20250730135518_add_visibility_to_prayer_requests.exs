defmodule CMS.Repo.Migrations.AddVisibilityToPrayerRequests do
  use Ecto.Migration

  def change do
    alter table(:prayer_requests) do
      add :visibility, :string, null: false, default: "private"
      add :group_id, references(:groups, on_delete: :restrict)
    end
  end
end
