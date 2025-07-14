defmodule CMS.Liturgies.BlockTest do
  use CMS.DataCase, async: true

  alias CMS.Liturgies.Block

  import Ecto.Changeset
  import CMS.AccountsFixtures

  setup do
    %{scope: user_scope_fixture()}
  end

  describe "changeset for a text block" do
    test "for a new text block", %{scope: scope} do
      attrs = %{"title" => "Test Title", "body" => "Test Body"}
      liturgy_attrs = %{"blocks_sort" => ["new-text"]}

      changeset = Block.changeset(%Block{}, attrs, 0, liturgy_attrs, scope)

      assert changeset.valid?
      assert get_field(changeset, :title) == "Test Title"
      assert get_field(changeset, :body) == "Test Body"
      assert get_field(changeset, :type) == :text
      assert get_field(changeset, :position) == 0
      assert get_field(changeset, :organization_id) == scope.organization.id
    end
  end

  describe "changeset for a song block" do
    test "for a new song block", %{scope: scope} do
      attrs = %{"title" => "Test Title", "body" => "Test Body"}
      liturgy_attrs = %{"blocks_sort" => ["new-song"]}

      changeset = Block.changeset(%Block{}, attrs, 0, liturgy_attrs, scope)

      assert changeset.valid?
      assert get_field(changeset, :title) == "Test Title"
      assert get_field(changeset, :body) == "Test Body"
      assert get_field(changeset, :type) == :song
      assert get_field(changeset, :position) == 0
      assert get_field(changeset, :organization_id) == scope.organization.id
    end
  end

  describe "changeset for a passage block" do
    test "for a new passage block", %{scope: scope} do
      attrs = %{"title" => "Test Title", "body" => "Test Body"}
      liturgy_attrs = %{"blocks_sort" => ["new-passage"]}

      changeset = Block.changeset(%Block{}, attrs, 0, liturgy_attrs, scope)

      assert changeset.valid?
      assert get_field(changeset, :title) == "Test Title"
      assert get_field(changeset, :body) == "Test Body"
      assert get_field(changeset, :type) == :passage
      assert get_field(changeset, :position) == 0
      assert get_field(changeset, :organization_id) == scope.organization.id
    end
  end
end
