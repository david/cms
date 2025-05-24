defmodule CMS.Liturgies.Blocks do
  @moduledoc """
  The Blocks context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Bibles
  alias CMS.Liturgies.Block

  def suggest_block(%Scope{organization: %{id: org_id}}, :song, title) do
    Block
    |> from(
      select: [:body, :id, :title, :type],
      where: [organization_id: ^org_id, type: :song, title: ^title],
      limit: 1
    )
    |> Repo.one()
  end

  def suggest_block(_scope, :passage, title) do
    %Block{
      title: title,
      type: :passage,
      body: Bibles.get_verses(title)
    }
  end
end
