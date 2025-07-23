defmodule CMS.AccountsTest do
  use CMS.DataCase

  alias CMS.Accounts
  import CMS.AccountsFixtures

  setup do
    org = organization_fixture()
    scope = %CMS.Accounts.Scope{organization: org}
    %{org: org, scope: scope}
  end

  describe "list_groups/1" do
    test "returns only groups from the specified organization", %{org: org1, scope: scope} do
      org2 = organization_fixture()

      group1 = group_fixture(%{name: "Group 1"}, org1)
      _group2 = group_fixture(%{name: "Group 2"}, org2)

      assert [^group1] = Accounts.list_groups(scope)
    end

    test "returns an empty list if the organization has no groups", %{scope: scope} do
      assert [] == Accounts.list_groups(scope)
    end
  end

  describe "create_group/2" do
    test "creates a group with valid attributes", %{org: org, scope: scope} do
      attrs = %{
        "name" => "New Group",
        "description" => "A description"
      }

      assert {:ok, group} = Accounts.create_group(scope, attrs)
      assert group.name == "New Group"
      assert group.description == "A description"
      assert group.organization_id == org.id
    end

    test "returns an error changeset with invalid attributes", %{scope: scope} do
      attrs = %{"name" => ""}

      assert {:error, changeset} = Accounts.create_group(scope, attrs)
      assert changeset.errors[:name] == {"can't be blank", [validation: :required]}
    end
  end

  describe "update_user/3" do
    test "updates user attributes", %{scope: scope, org: org} do
      user = user_fixture(%{}, org) |> CMS.Repo.preload(:family)

      update_attrs = %{
        "email" => "new_email@example.com",
        "name" => user.name,
        "family_id" => user.family_id,
        "family_designation" => user.family.designation
      }

      assert {:ok, updated_user} = Accounts.update_user(scope, user, update_attrs)
      assert updated_user.email == "new_email@example.com"
    end
  end
end
