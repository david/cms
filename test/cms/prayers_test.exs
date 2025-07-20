defmodule CMS.PrayersTest do
  use CMS.DataCase

  alias CMS.Prayers

  describe "prayer_requests" do
    alias CMS.Prayers.PrayerRequest

    import CMS.AccountsFixtures
    import CMS.PrayersFixtures

    @invalid_attrs %{body: nil}

    setup do
      org = organization_fixture()
      user = user_fixture(%{}, org)
      scope = user_scope_fixture(user)

      {:ok, %{user: user, scope: scope}}
    end

    test "list_prayer_requests/1 returns all prayer_requests for a user's organization", %{
      scope: scope,
      user: user
    } do
      prayer_request = prayer_request_fixture(%{user: user})

      # create a prayer request in another organization
      prayer_request_fixture(%{organization: organization_fixture()})

      assert Prayers.list_prayer_requests(scope) == [prayer_request]
    end

    test "create_prayer_request/2 with valid data creates a prayer_request", %{
      scope: scope,
      user: user
    } do
      valid_attrs = %{body: "some body"}

      assert {:ok, %PrayerRequest{} = prayer_request} =
               Prayers.create_prayer_request(scope, valid_attrs)

      assert prayer_request.body == "some body"
      assert prayer_request.user_id == user.id
      assert prayer_request.organization_id == user.organization_id
    end

    test "create_prayer_request/2 with invalid data returns error changeset", %{scope: scope} do
      assert {:error, %Ecto.Changeset{}} =
               Prayers.create_prayer_request(scope, @invalid_attrs)
    end
  end
end
