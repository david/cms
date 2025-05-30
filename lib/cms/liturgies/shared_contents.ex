defmodule CMS.Liturgies.SharedContents do
  @moduledoc """
  The SharedContents context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Bibles
  alias CMS.Liturgies.SharedContent

  def suggest_shared_content(%Scope{organization: %{id: org_id}}, type, title) do
    SharedContent
    |> from(
      select: [:body, :id, :title, :type],
      where: [organization_id: ^org_id, type: ^type, title: ^title]
    )
    |> Repo.one()
  end
end

