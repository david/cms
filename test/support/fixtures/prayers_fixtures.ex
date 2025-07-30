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

    attrs =
      Enum.into(attrs, %{
        body: "some body",
        visibility: :private
      })

    attrs =
      if attrs.visibility == :group do
        group = attrs[:group] || group_fixture(%{users: user}, org)

        Map.put(attrs, :group_id, group.id)
      else
        attrs
      end

    scope = user_scope_fixture(user)

    {:ok, prayer_request} = CMS.Prayers.create_prayer_request(scope, attrs)

    CMS.Repo.preload(prayer_request, [:user])
  end
end
