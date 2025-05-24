defmodule CMS.Accounts.Import do
  alias CMS.Accounts
  alias NimbleCSV.RFC4180, as: CSV

  def import_users_file(scope, path) do
    # TODO: use Ecto.Multi

    loaded_families =
      scope |> Accounts.list_families() |> Enum.map(&{&1.designation, &1}) |> Map.new()

    entries =
      path
      |> File.stream!()
      |> CSV.parse_stream(headers: true)
      |> Stream.map(fn [family_designation, family_address, name, birth_date | _] ->
        %{
          birth_date: Timex.parse!(:binary.copy(birth_date), "{YYYY}/{0M}/{0D}"),
          family_address: :binary.copy(family_address),
          family_designation: :binary.copy(family_designation),
          name: :binary.copy(name)
        }
      end)
      |> Enum.to_list()

    entries
    |> Enum.group_by(& &1.family_designation)
    |> Enum.map(fn {family_designation, users} ->
      {
        family_designation,
        %{
          address:
            users
            |> Enum.filter(&(&1.family_address |> String.trim() != ""))
            |> List.first()
            |> then(&Map.get(&1 || %{}, :family_address)),
          designation: family_designation
        }
      }
    end)
    |> Enum.each(fn {designation, %{address: address}} ->
      case loaded_families[designation] do
        nil ->
          Accounts.create_family(scope, %{designation: designation, address: address})

        family ->
          Accounts.update_family(scope, family, %{address: family.address || address})
      end
    end)

    loaded_families =
      scope |> Accounts.list_families() |> Enum.map(&{&1.designation, &1}) |> Map.new()

    for e <- entries do
      Accounts.import_user(
        scope,
        Map.put(e, :family_id, loaded_families[e.family_designation].id)
      )
    end
  end
end
