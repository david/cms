defmodule CMS.LiturgiesTest do
  use CMS.DataCase

  alias CMS.Liturgies
  alias CMS.Liturgies.Block
  alias CMS.Repo

  describe "liturgies" do
    alias CMS.Liturgies.Liturgy

    import CMS.AccountsFixtures, only: [user_scope_fixture: 0]
    import CMS.LiturgiesFixtures, only: [liturgy_fixture: 1, block_fixture: 2]

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

    test "create_liturgy/2 creates text blocks" do
      scope = user_scope_fixture()

      assert 0 == Repo.aggregate(Block, :count, :id)

      attrs = %{
        "service_on" => ~D[2025-04-26],
        "liturgy_blocks" => %{
          "0" => %{
            "title" => "New Text Block",
            "type" => "text"
          }
        }
      }

      assert {:ok, %Liturgy{}} = Liturgies.create_liturgy(scope, attrs)
      assert 1 == Repo.aggregate(Block, :count, :id)
    end

    test "create_liturgy/2 always creates the liturgy in the correct organization"
    test "create_liturgy/2 always updates block in the correct organization"

    test "create_liturgy/2 creates song blocks" do
      scope = user_scope_fixture()

      assert 0 == Repo.aggregate(Block, :count, :id)

      attrs = %{
        "service_on" => ~D[2025-04-26],
        "liturgy_blocks" => %{
          "0" => %{
            "title" => "New Song Block",
            "type" => "song"
          }
        }
      }

      assert {:ok, %Liturgy{}} = Liturgies.create_liturgy(scope, attrs)
      assert 1 == Repo.aggregate(Block, :count, :id)
    end

    test "create_liturgy/2 reuses song blocks" do
      scope = user_scope_fixture()
      song_block_1 = block_fixture(%{type: :song, title: "Song Block 1"}, scope)

      song_block_2 =
        block_fixture(%{type: :song, title: "song Block 2", body: "Song Block 2 Body"}, scope)

      assert 2 == Repo.aggregate(Block, :count, :id)

      attrs = %{
        "service_on" => ~D[2025-04-26],
        "liturgy_blocks" => %{
          "0" => %{
            "block_id" => song_block_1.id,
            "title" => song_block_1.title,
            "body" => song_block_1.body,
            "type" => "song"
          },
          "1" => %{
            "block_id" => song_block_2.id,
            "title" => song_block_2.title,
            "body" => "SB2B",
            "type" => "song"
          }
        }
      }

      assert {:ok, %Liturgy{}} = Liturgies.create_liturgy(scope, attrs)
      assert 2 == Repo.aggregate(Block, :count, :id)

      assert "SB2B" == scope |> Liturgies.list_songs() |> List.last() |> Map.get(:body)
    end

    test "creates blocks in the correct order"
    test "validates blocks"
    test "update also creates blocks when required"

    test "create_liturgy/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Liturgies.create_liturgy(scope, @invalid_attrs)
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
