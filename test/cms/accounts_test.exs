defmodule CMS.AccountsTest do
  use CMS.DataCase

  alias CMS.Accounts
  import CMS.AccountsFixtures

  describe "list_groups/1" do
    test "returns only groups from the specified organization" do
      org1 = organization_fixture()
      org2 = organization_fixture()

      group1 = group_fixture(%{name: "Group 1"}, org1)
      _group2 = group_fixture(%{name: "Group 2"}, org2)

      scope = %CMS.Accounts.Scope{organization: org1}

      assert [^group1] = Accounts.list_groups(scope)
    end

    test "returns an empty list if the organization has no groups" do
      org = organization_fixture()
      scope = %CMS.Accounts.Scope{organization: org}

      assert [] == Accounts.list_groups(scope)
    end
  end
end
