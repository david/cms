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

      _song_z = song_fixture(%{organization_id: user.organization_id, title: "Song Z for Org 1"})
      _song_a = song_fixture(%{organization_id: user.organization_id, title: "Song A for Org 1"})

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
end
