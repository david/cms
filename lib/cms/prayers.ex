defmodule CMS.Prayers do
  @moduledoc """
  The Prayers context.
  """

  import Ecto.Query, warn: false
  alias CMS.Repo

  alias CMS.Accounts.Scope
  alias CMS.Prayers.PrayerRequest

  @doc """
  Returns the list of prayer_requests for a given user's organization.

  ## Examples

      iex> list_prayer_requests(scope)
      [%PrayerRequest{}, ...]

  """
  def list_prayer_requests(%Scope{} = scope) do
    from(p in PrayerRequest,
      where:
        p.organization_id == ^scope.organization.id and
          (p.visibility == :private and p.user_id == ^scope.user.id),
      order_by: [desc: p.inserted_at],
      preload: [:organization, :user]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single prayer_request.

  Raises `Ecto.NoResultsError` if the Prayer request does not exist.

  ## Examples

      iex> get_prayer_request!(scope, 123)
      %PrayerRequest{}

      iex> get_prayer_request!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_prayer_request!(%Scope{} = scope, id) do
    from(p in PrayerRequest, where: p.organization_id == ^scope.organization.id)
    |> Repo.get!(id)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking prayer_request changes.
  """
  def change_prayer_request(%Scope{} = scope, %PrayerRequest{} = prayer_request, attrs \\ %{}) do
    PrayerRequest.changeset(prayer_request, attrs, scope)
  end

  @doc """
  Creates a prayer_request.

  ## Examples

      iex> create_prayer_request(user, %{field: value})
      {:ok, %PrayerRequest{}}

      iex> create_prayer_request(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_prayer_request(%Scope{} = scope, attrs) do
    %PrayerRequest{}
    |> PrayerRequest.changeset(attrs, scope)
    |> Repo.insert()
  end
end
