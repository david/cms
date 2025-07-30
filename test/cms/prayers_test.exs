defmodule CMS.PrayersTest do
  use CMS.DataCase

  alias CMS.Prayers

  describe "prayer_requests" do
    alias CMS.Prayers.PrayerRequest
    alias CMS.Accounts.User

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

      private_request_user1 =
        prayer_request_fixture(
          user: user1,
          created_by: user1,
          organization: org,
          visibility: :private
        )

      _private_request_user2 =
        prayer_request_fixture(
          user: user2,
          created_by: user2,
          organization: org,
          visibility: :private
        )

      assert [request] = Prayers.list_prayer_requests(scope1)
      assert request.id == private_request_user1.id
    end

    test "list_prayer_requests/1 returns organization-visible prayer requests" do
      org = organization_fixture()
      user1 = user_fixture(%{}, org)
      user2 = user_fixture(%{}, org)
      scope1 = user_scope_fixture(user1)

      organization_request =
        prayer_request_fixture(
          user: user2,
          created_by: user2,
          organization: org,
          visibility: :organization
        )

      assert [request] = Prayers.list_prayer_requests(scope1)
      assert request.id == organization_request.id
    end

    test "list_prayer_requests/1 does not return requests from other organizations" do
      org1 = organization_fixture()
      user1 = user_fixture(%{}, org1)
      scope1 = user_scope_fixture(user1)

      org2 = organization_fixture()
      user2 = user_fixture(%{}, org2)

      _organization_request =
        prayer_request_fixture(
          user: user2,
          created_by: user2,
          organization: org2,
          visibility: :organization
        )

      assert Prayers.list_prayer_requests(scope1) == []
    end

    test "list_prayer_requests/1 returns group-visible prayer requests for members" do
      org = organization_fixture()
      user1 = user_fixture(%{}, org)
      user2 = user_fixture(%{}, org)
      group = group_fixture(%{users: [user1, user2]}, org)
      user1 = Repo.get(User, user1.id) |> Repo.preload([:groups, :organization])
      scope1 = user_scope_fixture(user1)

      group_request =
        prayer_request_fixture(
          user: user2,
          created_by: user2,
          organization: org,
          group: group,
          visibility: :group
        )

      assert [request] = Prayers.list_prayer_requests(scope1)
      assert request.id == group_request.id
    end

    test "list_prayer_requests/1 does not return group-visible requests for non-members" do
      org = organization_fixture()
      user1 = user_fixture(%{}, org)
      user2 = user_fixture(%{}, org)
      group = group_fixture(%{users: [user2]}, org)
      user1 = Repo.get(User, user1.id) |> Repo.preload([:groups, :organization])
      scope1 = user_scope_fixture(user1)

      _group_request =
        prayer_request_fixture(
          user: user2,
          created_by: user2,
          organization: org,
          group: group,
          visibility: :group
        )

      assert Prayers.list_prayer_requests(scope1) == []
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

    test "create_prayer_request/2 with group visibility", %{org: org, user: user} do
      group = group_fixture(%{users: [user]}, org)
      user = Repo.get(User, user.id) |> Repo.preload([:groups, :organization])
      scope = user_scope_fixture(user)
      valid_attrs = %{body: "some body", visibility: :group, group_id: group.id}

      assert {:ok, %PrayerRequest{} = prayer_request} =
               Prayers.create_prayer_request(scope, valid_attrs)

      assert prayer_request.visibility == :group
      assert prayer_request.group_id == group.id
    end

    test "create_prayer_request/2 with invalid group visibility", %{org: org, scope: scope} do
      group = group_fixture(%{}, org)
      invalid_attrs = %{body: "some body", visibility: :group, group_id: group.id}

      assert_raise MatchError, fn ->
        Prayers.create_prayer_request(scope, invalid_attrs)
      end
    end

    test "create_prayer_request/2 with invalid data returns error changeset", %{scope: scope} do
      assert {:error, %Ecto.Changeset{}} =
               Prayers.create_prayer_request(scope, @invalid_attrs)
    end
  end
end
