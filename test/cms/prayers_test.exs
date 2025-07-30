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

      {:ok, %{user: user, scope: scope, org: org}}
    end

    test "list_prayer_requests/1 returns only private prayer requests for the current user" do
      org = organization_fixture()
      user1 = user_fixture(%{}, org)
      user2 = user_fixture(%{}, org)
      scope1 = user_scope_fixture(user1)
      _scope2 = user_scope_fixture(user2)

      private_request_user1 = prayer_request_fixture(user: user1, created_by: user1, organization: org, visibility: :private)
      _private_request_user2 = prayer_request_fixture(user: user2, created_by: user2, organization: org, visibility: :private)

      assert [request] = Prayers.list_prayer_requests(scope1)
      assert request.id == private_request_user1.id
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
      assert prayer_request.visibility == :private
    end

    test "create_prayer_request/2 with invalid data returns error changeset", %{scope: scope} do
      assert {:error, %Ecto.Changeset{}} =
               Prayers.create_prayer_request(scope, @invalid_attrs)
    end
  end
end
