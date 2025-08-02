defmodule CMS.Prayers.PrayerRequestTest do
  use CMS.DataCase

  alias CMS.Prayers.PrayerRequest
  import CMS.AccountsFixtures
  import CMS.PrayersFixtures

  setup do
    org = organization_fixture()
    user = user_fixture(%{}, org)
    group = group_fixture(%{users: [user]}, org)
    scope = user_scope_fixture(user)

    prayer_request =
      prayer_request_fixture(
        user: user,
        created_by: user,
        organization: org,
        group: group,
        visibility: :group
      )

    {:ok, %{user: user, scope: scope, org: org, prayer_request: prayer_request}}
  end

  test "changeset sets group_id to nil when visibility changes from :group to :private", %{
    prayer_request: prayer_request,
    scope: scope
  } do
    changeset = PrayerRequest.changeset(prayer_request, %{visibility: :private}, scope)

    assert changeset.valid?
    assert get_change(changeset, :visibility) == :private
    assert get_change(changeset, :group_id) == nil
  end

  test "changeset sets group_id to nil when visibility changes from :group to :organization", %{
    prayer_request: prayer_request,
    scope: scope
  } do
    changeset = PrayerRequest.changeset(prayer_request, %{visibility: :organization}, scope)

    assert changeset.valid?
    assert get_change(changeset, :visibility) == :organization
    assert get_change(changeset, :group_id) == nil
  end
end
