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
    user =
      if a = attrs[:user] do
        a
      else
        org =
          if o = attrs[:organization] do
            o
          else
            organization_fixture()
          end

        user_fixture(%{}, org)
      end

    scope = user_scope_fixture(user)

    {:ok, prayer_request} =
      CMS.Prayers.create_prayer_request(
        scope,
        Enum.into(attrs, %{
          body: "some body"
        })
      )

    prayer_request
  end
end
