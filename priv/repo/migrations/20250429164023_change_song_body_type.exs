defmodule CMS.Repo.Migrations.ChangeSongBodyType do
  use Ecto.Migration

  def change do
    alter table(:songs) do
      modify :body, :text
    end
  end
end
