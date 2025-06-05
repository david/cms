defmodule CMS.Liturgies.Songs do
  @moduledoc """
  The Songs context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Liturgies.Song

  def suggest(%Scope{organization: %{id: org_id}}, title) do
    Song
    |> from(
      select: [:body, :id, :title],
      where: [organization_id: ^org_id, title: ^title]
    )
    |> Repo.one()
  end
end
