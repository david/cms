defmodule CMS.LiturgiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CMS.Liturgies` context.
  """

  def liturgy_attrs(attrs \\ %{}) do
    Enum.into(attrs, %{
      "service_on" => ~D[2025-04-26],
      "blocks" => [
        %{
          "title" => "Text Block",
          "type" => :text
        }
      ],
      "blocks_sort" => [0],
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
end
