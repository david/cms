defmodule CMS.PrayersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `CMS.Prayers` context.
  """

  import CMS.AccountsFixtures

  @doc """
  Generate a prayer_request.
  """
  def prayer_request_fixture(attrs \\ %{}) do
    org = attrs[:organization] || organization_fixture()
    user = attrs[:user] || user_fixture(%{}, org)
    scope = user_scope_fixture(user)

    attrs =
      Enum.into(attrs, %{
        body: "some body",
        visibility: :private
      })

    {:ok, prayer_request} = CMS.Prayers.create_prayer_request(scope, attrs)

    CMS.Repo.preload(prayer_request, [:user])
  end
end
