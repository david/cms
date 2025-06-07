defmodule CMS.LiturgiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CMS.Liturgies` context.
  """

  alias CMS.Liturgies.Block
  alias CMS.Repo

  def liturgy_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      "service_on" => ~D[2025-04-26],
      "liturgy_blocks" => [
        %{
          "title" => "Opening Prayer",
          "body" => "O God, our help in ages past...",
          "type" => "text"
        },
        %{
          "title" => "Amazing Grace",
          "body" => "Amazing grace, how sweet the sound...",
          "type" => "song"
        },
        %{
          "title" => "John 3:16",
          "body" => "For God so loved the world...",
          "type" => "passage"
        }
      ],
      "liturgy_blocks_sort" => ["new-text", "new-song", "new-passage"],
      "blocks_drop" => []
    })
  end

  @doc """
  Generate a liturgy.
  """
  def liturgy_fixture(scope, attrs \\ %{}) do
    attrs = liturgy_attrs(attrs)

    {:ok, liturgy} = CMS.Liturgies.create_liturgy(scope, attrs)

    liturgy
  end

  def block_fixture(attrs \\ %{}, scope) do
    {:ok, block} =
      %Block{organization_id: scope.organization.id}
      |> Ecto.Changeset.change(attrs)
      |> Repo.insert()

    block
  end
end
