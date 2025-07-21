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
      where: p.organization_id == ^scope.organization.id,
      order_by: [desc: p.inserted_at],
      # Preload `created_by` to display the name of the user who created the prayer request.
      preload: [:organization, :user, :created_by]
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
  def change_prayer_request(%PrayerRequest{} = prayer_request, attrs \\ %{}) do
    PrayerRequest.changeset(prayer_request, attrs)
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
    |> ensure_user_in_organization(scope)
    |> Repo.insert()
  end

  defp ensure_user_in_organization(changeset, %Scope{} = scope) do
    if user_id = Ecto.Changeset.get_field(changeset, :user_id) do
      user = CMS.Accounts.get_user(scope, user_id)

      if is_nil(user) || user.organization_id != scope.organization.id do
        raise "user #{user_id} is not in organization #{scope.organization.id}"
      end
    end

    changeset
  end
end
