defmodule CMS.Accounts.Scope do
  @moduledoc """
  Defines the scope of the caller to be used throughout the app.

  The `CMS.Accounts.Scope` allows public interfaces to receive
  information about the caller, such as if the call is initiated from an
  end-user, and if so, which user. Additionally, such a scope can carry fields
  such as "super user" or other privileges for use as authorization, or to
  ensure specific code paths can only be access for a given scope.

  It is useful for logging as well as for scoping pubsub subscriptions and
  broadcasts when a caller subscribes to an interface or performs a particular
  action.

  Feel free to extend the fields on this struct to fit the needs of
  growing application requirements.
  """

  alias CMS.Accounts.{User, Organization}

  defstruct user: nil, organization: nil, groups: []

  @doc """
  Creates a scope for the given user.

  Expects the user struct to have the `:organization` association preloaded.
  Returns nil if no user is given.
  """
  def for_user(%User{} = user, %Organization{} = organization, groups \\ []) do
    true = user.organization_id == organization.id

    %__MODULE__{user: user, organization: organization, groups: groups}
  end
end
