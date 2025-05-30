defmodule CMS.Liturgies.Block do
  use Ecto.Schema
  import Ecto.Changeset

  alias CMS.Accounts.Organization
  alias CMS.Accounts.Scope
  alias CMS.Bibles
  alias CMS.Liturgies.SharedContent
  alias CMS.Liturgies.SharedContents
  alias CMS.Liturgies.Liturgy

  schema "blocks" do
    field :position, :integer

    field :title, :string
    field :subtitle, :string
    field :body, :string, virtual: true
    field :type, Ecto.Enum, values: SharedContent.types()

    belongs_to :liturgy, Liturgy
    belongs_to :shared_content, SharedContent, on_replace: :nilify
    belongs_to :organization, Organization

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(block, attrs, index, liturgy_attrs, user_scope) do
    block
    |> cast(attrs, [:shared_content_id, :position, :body, :subtitle, :title, :type])
    |> put_block(attrs, index, liturgy_attrs, user_scope)
    |> put_change(:organization_id, user_scope.organization.id)
  end

  defp put_block(changeset, attrs, index, liturgy_attrs, user_scope) do
    type =
      get_field(changeset, :type) ||
        case Enum.at(liturgy_attrs["blocks_sort"], index) do
          "new-text" -> :text
          "new-song" -> :song
          "new-passage" -> :passage
        end

    changeset
    |> build_shared_content(type, attrs, user_scope)
    |> merge(SharedContent.changeset(type, changeset.data, attrs, user_scope))
    |> put_change(:position, index)
  end

  defp build_shared_content(
         %{data: %{shared_content_id: shared_content_id}} = changeset,
         _type,
         _attrs,
         _user_scope
       )
       when not is_nil(shared_content_id),
       do: changeset

  defp build_shared_content(changeset, :passage, %{"title" => title}, user_scope) do
    put_change(changeset, :body, Bibles.get_verses(title))
  end

  defp build_shared_content(changeset, type, %{"title" => title}, user_scope) do
    shared_content = SharedContents.suggest_shared_content(user_scope, type, title)

    cond do
      shared_content ->
        changeset
        |> put_change(:body, shared_content.body)
        |> put_assoc(:shared_content, shared_content)

      get_field(changeset, :body) ->
        put_assoc(
          changeset,
          :shared_content,
          %SharedContent{
            body: get_field(changeset, :body),
            title: title,
            type: type,
            organization_id: user_scope.organization.id
          }
        )

      true ->
        changeset
    end
  end

  defp build_shared_content(changeset, _type, _attrs, _user_scope), do: changeset

  @doc false
  def copy_changeset(
        %{
          shared_content_id: shared_content_id,
          shared_content: %{type: :song},
          position: position
        },
        %Scope{
          organization: %{id: org_id}
        }
      ) do
    attrs = %{
      shared_content_id: shared_content_id,
      organization_id: org_id,
      position: position
    }

    cast(%__MODULE__{}, attrs, [:shared_content_id, :organization_id, :position])
  end

  def copy_changeset(%{position: position, shared_content: shared_content}, %Scope{
        organization: %{id: org_id}
      }) do
    attrs = %{
      organization_id: org_id,
      position: position
    }

    %__MODULE__{}
    |> cast(attrs, [:organization_id, :position])
    |> put_assoc(
      :shared_content,
      shared_content
      |> Map.take([:type, :title, :subtitle, :body])
      |> Map.put(:organization_id, org_id)
    )
  end
end
