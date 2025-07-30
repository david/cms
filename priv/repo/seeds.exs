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
alias CMS.Accounts.Group
alias CMS.Accounts.Organization
alias CMS.Accounts.User
alias CMS.Liturgies.Liturgy
alias CMS.Prayers.PrayerRequest
alias CMS.Repo
alias CMS.Songs.Song

org =
  Repo.get_by(Organization, name: "Default Organization") ||
    Repo.insert!(%Organization{
      name: "Default Organization",
      hostname: "localhost"
    })

elders_group =
  Repo.get_by(Group, name: "Elders", organization_id: org.id) ||
    Repo.insert!(%Group{
      name: "Elders",
      description: "The elders of the church.",
      organization_id: org.id
    })

deacons_group =
  Repo.get_by(Group, name: "Deacons", organization_id: org.id) ||
    Repo.insert!(%Group{
      name: "Deacons",
      description: "The deacons of the church.",
      organization_id: org.id
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

elders_group = Repo.preload(elders_group, :users)

Ecto.Changeset.change(elders_group, %{})
|> Ecto.Changeset.put_assoc(:users, [admin_user])
|> Repo.update!()

smith_family =
  Repo.get_by(Family, designation: "The Smiths", organization_id: org.id) ||
    Repo.insert!(%Family{designation: "The Smiths", organization: org})

smith_user =
  Repo.get_by(User, email: "smith@example.com") ||
    Repo.insert!(%User{
      email: "smith@example.com",
      family_id: smith_family.id,
      name: "John Smith",
      role: :member,
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      organization_id: org.id
    })

deacons_group = Repo.preload(deacons_group, :users)

Ecto.Changeset.change(deacons_group, %{})
|> Ecto.Changeset.put_assoc(:users, [smith_user])
|> Repo.update!()

jones_family =
  Repo.get_by(Family, designation: "The Joneses", organization_id: org.id) ||
    Repo.insert!(%Family{designation: "The Joneses", organization: org})

jones_user =
  Repo.get_by(User, email: "jones@example.com") ||
    Repo.insert!(%User{
      email: "jones@example.com",
      family_id: jones_family.id,
      name: "Mary Jones",
      role: :member,
      confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second),
      organization_id: org.id
    })

unconfirmed_family_1 =
  Repo.get_by(Family, designation: "The Unconfirmeds", organization_id: org.id) ||
    Repo.insert!(%Family{designation: "The Unconfirmeds", organization: org})

Repo.get_by(User, email: "unconfirmed1@example.com") ||
  Repo.insert!(%User{
    email: "unconfirmed1@example.com",
    family_id: unconfirmed_family_1.id,
    name: "Unconfirmed User 1",
    role: :member,
    organization_id: org.id
  })

unconfirmed_family_2 =
  Repo.get_by(Family, designation: "The Newcomers", organization_id: org.id) ||
    Repo.insert!(%Family{designation: "The Newcomers", organization: org})

Repo.get_by(User, email: "unconfirmed2@example.com") ||
  Repo.insert!(%User{
    email: "unconfirmed2@example.com",
    family_id: unconfirmed_family_2.id,
    name: "Unconfirmed User 2",
    role: :member,
    organization_id: org.id
  })

Repo.get_by(PrayerRequest, user_id: smith_user.id) ||
  Repo.insert!(%PrayerRequest{
    body: "Please pray for my upcoming job interview.",
    user_id: smith_user.id,
    organization_id: org.id
  })

Repo.get_by(PrayerRequest, user_id: jones_user.id) ||
  Repo.insert!(%PrayerRequest{
    body: "Please pray for my grandmother's health.",
    user_id: jones_user.id,
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
