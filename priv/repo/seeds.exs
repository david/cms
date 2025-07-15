# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CMS.Repo.insert!(%CMS.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CMS.Accounts.Family
alias CMS.Accounts.Organization
alias CMS.Accounts.User
alias CMS.Liturgies.Liturgy
alias CMS.Repo
alias CMS.Songs.Song

org =
  Repo.get_by(Organization, name: "Default Organization") ||
    Repo.insert!(%Organization{
      name: "Default Organization"
    })

family =
  Repo.get_by(Family, designation: "Administrator", organization_id: org.id) ||
    Repo.insert!(%Family{designation: "Administrator", organization: org})

admin_user =
  Repo.get_by(User, email: "admin@example.com") ||
    Repo.insert!(%User{
      email: "admin@example.com",
      family_id: family.id,
      name: "Admin",
      role: :admin,
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      organization_id: org.id
    })

song =
  Repo.get_by(Song, title: "Amazing Grace", organization_id: org.id) ||
    Repo.insert!(%Song{
      title: "Amazing Grace",
      organization_id: org.id,
      body: """
      Amazing grace! How sweet the sound
      That saved a wretch like me!
      I once was lost, but now am found;
      Was blind, but now I see.
      """
    })

scope = %{organization: org, user: admin_user}

liturgy_attrs = %{
  "service_on" => Date.utc_today(),
  "blocks_sort" => ["0", "1", "2"],
  "blocks" => %{
    "0" => %{
      "type" => "text",
      "title" => "Welcome",
      "subtitle" => "Announcements",
      "body" => "Welcome to our service. Please take a moment to greet someone near you."
    },
    "1" => %{
      "type" => "song",
      "title" => "Amazing Grace",
      "song_id" => song.id
    },
    "2" => %{
      "type" => "passage",
      "title" => "João 3:16",
      "subtitle" => "God's Love"
    }
  }
}

if is_nil(Repo.get_by(Liturgy, service_on: Date.utc_today(), organization_id: org.id)) do
  %Liturgy{}
  |> Liturgy.changeset(liturgy_attrs, scope)
  |> Repo.insert!()
end
