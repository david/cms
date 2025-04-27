defmodule CMS.Repo.Migrations.CreateSongs do
  use Ecto.Migration

  def change do
    create table(:songs) do
      add :title, :string, null: false
      add :body, :string, null: false
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:songs, [:organization_id])
    create index(:songs, [:user_id])
  end
end
