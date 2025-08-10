defmodule CMS.SongsTest do
  use CMS.DataCase, async: true

  alias CMS.Songs
  alias CMS.Accounts.Scope
  import CMS.AccountsFixtures
  import CMS.SongsFixtures

  describe "list_songs/1" do
    test "returns songs for the organization within the given scope, sorted alphabetically by title" do
      user = user_fixture(%{}, organization_fixture())
      scope = Scope.for_user(user, user.organization)

      _song_z = song_fixture(%{title: "Song Z for Org 1"}, scope)
      _song_a = song_fixture(%{title: "Song A for Org 1"}, scope)

      songs_for_scope = Songs.list_songs(scope)

      assert Enum.count(songs_for_scope) == 2
      assert Enum.map(songs_for_scope, & &1.title) == ["Song A for Org 1", "Song Z for Org 1"]
    end

    test "returns an empty list when no songs exist for the organization in scope" do
      user = user_fixture(%{}, organization_fixture())
      scope = Scope.for_user(user, user.organization)

      assert Songs.list_songs(scope) == []
    end
  end

  describe "update_song/3" do
    test "updates a song with valid data" do
      user = user_fixture(%{}, organization_fixture())
      scope = Scope.for_user(user, user.organization)
      song = song_fixture(%{}, scope)

      attrs = %{
        "title" => "New Title",
        "body" => "New Body"
      }

      assert {:ok, updated_song} = Songs.update_song(scope, song, attrs)
      assert updated_song.title == "New Title"
      assert updated_song.body == "New Body"
    end

    test "returns an error changeset when data is invalid" do
      user = user_fixture(%{}, organization_fixture())
      scope = Scope.for_user(user, user.organization)
      song = song_fixture(%{}, scope)

      attrs = %{
        "title" => "",
        "body" => ""
      }

      assert {:error, changeset} = Songs.update_song(scope, song, attrs)
      assert changeset.errors[:title] == {"can't be blank", [validation: :required]}
      assert changeset.errors[:body] == {"can't be blank", [validation: :required]}
    end
  end
end
