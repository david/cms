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
alias CMS.Repo

org =
  Repo.get_by(Organization, name: "Default Organization") ||
    Repo.insert!(%Organization{
      name: "Default Organization"
    })

family = Repo.insert!(%Family{designation: "Administrator", organization: org})

Repo.insert!(%User{
  email: "admin@example.com",
  family: family,
  name: "Admin",
  role: :admin,
  confirmed_at: DateTime.utc_now() |> DateTime.truncate(:second),
  organization: org
})
