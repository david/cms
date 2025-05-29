defmodule CMS.Liturgies.SharedContents do
  @moduledoc """
  The SharedContents context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Bibles
  alias CMS.Liturgies.SharedContent

  def suggest_shared_content(%Scope{organization: %{id: org_id}}, :song, title) do
    SharedContent
    |> from(
      select: [:body, :id, :title, :type],
      where: [organization_id: ^org_id, type: :song, title: ^title]
    )
    |> Repo.one()
  end

  def suggest_shared_content(_scope, :passage, title) do
    %SharedContent{
      title: title,
      type: :passage,
      body: Bibles.get_verses(title)
    }
  end
end