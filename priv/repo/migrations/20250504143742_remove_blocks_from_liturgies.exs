defmodule CMS.Repo.Migrations.RemoveBlocksFromLiturgies do
  use Ecto.Migration

  def change do
    alter table(:liturgies) do
      remove :blocks
    end
  end
end
