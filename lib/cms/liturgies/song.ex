defmodule CMS.Liturgies.Song do
  use Ecto.Schema
  import Ecto.Changeset

  schema "songs" do
    field :title, :string
    field :body, :string

    belongs_to :organization, CMS.Accounts.Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(song, attrs, scope) do
    song
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> put_change(:organization_id, scope.organization.id)
  end
end
