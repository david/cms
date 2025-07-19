defmodule CMS.LiturgiesTest do
  use CMS.DataCase, async: true

  import CMS.AccountsFixtures
  import CMS.LiturgiesFixtures

  alias CMS.Liturgies

  @moduletag :liturgies

  describe "update_liturgy/3" do
    test "broadcasts a message to the liturgy's public topic" do
      user = user_fixture(%{}, organization_fixture())
      scope = CMS.Accounts.Scope.for_user(user, user.organization)
      liturgy = liturgy_fixture(scope)
      Phoenix.PubSub.subscribe(CMS.PubSub, "liturgy:#{liturgy.id}")

      {:ok, updated_liturgy} =
        Liturgies.update_liturgy(scope, liturgy, %{"service_on" => ~D[2025-05-01]})

      assert updated_liturgy.service_on == ~D[2025-05-01]

      updated_id = updated_liturgy.id

      assert_receive {:updated, %{id: ^updated_id}}, 500, "Expected broadcast on public topic"
    end
  end
end
