import Ecto.Query

alias CMS.Repo
alias CMS.Accounts.Organization
alias CMS.Accounts.Scope
alias CMS.Accounts.User
alias CMS.Liturgies.Block
alias CMS.Liturgies.Blocks
alias CMS.Liturgies.Liturgy
alias CMS.Liturgies.LiturgyBlock

IEx.configure(inspect: [charlists: :as_lists, limit: :infinity, structs: true])
