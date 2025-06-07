defmodule CMS.Songs.Song do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Scope
  alias CMS.Accounts.Organization

  schema "songs" do
    field :body, :string
    field :title, :string

    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  def changeset(song, attrs, %Scope{} = scope) do
    song
    |> cast(attrs, [:title, :body])
    |> put_change(:organization_id, scope.organization.id)
  end
end
