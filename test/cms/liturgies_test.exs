defmodule CMS.LiturgiesTest do
  use CMS.DataCase

  alias CMS.Liturgies

  describe "liturgies" do
    alias CMS.Liturgies.Liturgy

    import CMS.AccountsFixtures, only: [user_scope_fixture: 0]
    import CMS.LiturgiesFixtures

    @invalid_attrs %{"service_on" => nil, "blocks" => []}

    test "list_liturgies/1 returns all scoped liturgies" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)
      other_liturgy = liturgy_fixture(other_scope)
      assert Liturgies.list_liturgies(scope) == [liturgy]
      assert Liturgies.list_liturgies(other_scope) == [other_liturgy]
    end

    test "get_liturgy!/2 returns the liturgy with given id" do
      scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)
      other_scope = user_scope_fixture()
      assert Liturgies.get_liturgy!(scope, liturgy.id) == liturgy
      assert_raise Ecto.NoResultsError, fn -> Liturgies.get_liturgy!(other_scope, liturgy.id) end
    end

    test "create_liturgy/2 with valid data creates a liturgy" do
      valid_attrs = liturgy_attrs()
      scope = user_scope_fixture()

      assert {:ok, %Liturgy{} = liturgy} = Liturgies.create_liturgy(scope, valid_attrs)
      assert liturgy.service_on == ~D[2025-04-26]
      assert liturgy.organization_id == scope.user.organization_id
    end

    test "create_liturgy/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Liturgies.create_liturgy(scope, @invalid_attrs)
    end

    test "create_liturgy/2 with a song creates the song" do
      valid_attrs =
        liturgy_attrs(%{
          "blocks" => [%{"type" => :song, "title" => "Song Block", "body" => "Song Body"}]
        })

      scope = user_scope_fixture()

      assert {:ok, %Liturgy{} = liturgy} = Liturgies.create_liturgy(scope, valid_attrs)

      songs = CMS.Liturgies.list_songs(scope)
      assert length(songs) == 1

      song = List.first(songs)
      block = List.first(liturgy.blocks)

      assert Map.take(block, [:type, :song_id]) == %{type: :song_reference, song_id: song.id}
    end

    test "update_liturgy/3 with valid data updates the liturgy" do
      scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)

      update_attrs = %{
        "service_on" => ~D[2025-04-27],
        "blocks" => [%{"type" => :text, "title" => "Text Block"}]
      }

      assert {:ok, %Liturgy{} = liturgy} = Liturgies.update_liturgy(scope, liturgy, update_attrs)
      assert liturgy.service_on == ~D[2025-04-27]
    end

    test "update_liturgy/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)

      assert_raise MatchError, fn ->
        Liturgies.update_liturgy(other_scope, liturgy, %{})
      end
    end

    test "update_liturgy/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)

      assert {:error, %Ecto.Changeset{}} =
               Liturgies.update_liturgy(scope, liturgy, @invalid_attrs)

      assert liturgy == Liturgies.get_liturgy!(scope, liturgy.id)
    end

    test "delete_liturgy/2 deletes the liturgy" do
      scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)
      assert {:ok, %Liturgy{}} = Liturgies.delete_liturgy(scope, liturgy)
      assert_raise Ecto.NoResultsError, fn -> Liturgies.get_liturgy!(scope, liturgy.id) end
    end

    test "delete_liturgy/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)
      assert_raise MatchError, fn -> Liturgies.delete_liturgy(other_scope, liturgy) end
    end

    test "change_liturgy/2 returns a liturgy changeset" do
      scope = user_scope_fixture()
      liturgy = liturgy_fixture(scope)
      assert %Ecto.Changeset{} = Liturgies.change_liturgy(scope, liturgy)
    end
  end
end
