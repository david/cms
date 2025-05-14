defmodule CMS.Repo.Migrations.AddUniqueIndexToLiturgiesOrganizationServiceOn do
  use Ecto.Migration

  def change do
    create unique_index(:liturgies, [:organization_id, :service_on])
  end
end
