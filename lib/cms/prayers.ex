defmodule CMS.Prayers do
  @moduledoc """
  The Prayers context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Prayers.PrayerRequest

  def list_prayer_requests(%Scope{} = scope) do
    from(p in PrayerRequest,
      where: p.organization_id == ^scope.organization.id,
      preload: [:user]
    )
    |> Repo.all()
  end
end
