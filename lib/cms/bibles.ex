defmodule CMS.Bibles do
  import Ecto.Query, warn: false

  alias CMS.Bibles.Bible
  alias CMS.Bibles.Passage
  alias CMS.YouVersion

  @bible %Bible{
    language: "pt",
    name: "Almeida Revista e Actualizada",
    source_id: 1608,
    source_label: "ARA",
    usfm_index: %{
      "genesis" => "GEN",
      "exodo" => "EXO",
      "levitico" => "LEV",
      "numeros" => "NUM",
      "deuteronomio" => "DEU",
      "josue" => "JOS",
      "juizes" => "JDG",
      "rute" => "RUT",
      "1samuel" => "1SA",
      "2samuel" => "2SA",
      "1reis" => "1KI",
      "2reis" => "2KI",
      "1cronicas" => "1CH",
      "2cronicas" => "2CH",
      "esdras" => "EZR",
      "neemias" => "NEH",
      "ester" => "EST",
      "jo" => "JOB",
      "salmo" => "PSA",
      "salmos" => "PSA",
      "proverbios" => "PRO",
      "eclesiastes" => "ECC",
      "canticos" => "SNG",
      "isaias" => "ISA",
      "jeremias" => "JER",
      "lamentacoes" => "LAM",
      "ezequiel" => "EZK",
      "daniel" => "DAN",
      "oseias" => "HOS",
      "joel" => "JOL",
      "amos" => "AMO",
      "obadias" => "OBA",
      "jonas" => "JON",
      "miqueias" => "MIC",
      "naum" => "NAM",
      "habacuque" => "HAB",
      "sofonias" => "ZEP",
      "ageu" => "HAG",
      "zacarias" => "ZEC",
      "malaquias" => "MAL",
      "mateus" => "MAT",
      "marcos" => "MRK",
      "lucas" => "LUK",
      "joao" => "JHN",
      "atos" => "ACT",
      "romanos" => "ROM",
      "1corintios" => "1CO",
      "2corintios" => "2CO",
      "galatas" => "GAL",
      "efesios" => "EPH",
      "filipenses" => "PHP",
      "colossenses" => "COL",
      "1tessalonicenses" => "1TH",
      "2tessalonicenses" => "2TH",
      "1timoteo" => "1TI",
      "2timoteo" => "2TI",
      "tito" => "TIT",
      "filemon" => "PHM",
      "filemom" => "PHM",
      "hebreus" => "HEB",
      "tiago" => "JAS",
      "1pedro" => "1PE",
      "2pedro" => "2PE",
      "1joao" => "1JN",
      "2joao" => "2JN",
      "3joao" => "3JN",
      "judas" => "JUD",
      "apocalipse" => "REV"
    }
  }

  def default_bible, do: @bible

  def get_verses(ref) when is_binary(ref), do: ref |> Passage.parse(@bible) |> get_verses(@bible)

  defp get_verses({:error, _}, _bible), do: []

  defp get_verses({:ok, {book, chapter, verse}, {_book, end_chapter, end_verse}}, bible) do
    {first, rest} =
      chapter..end_chapter
      |> Range.to_list()
      |> Enum.map(&YouVersion.get_chapter(&1, book, bible))
      |> List.pop_at(0)

    list =
      case first do
        nil -> []
        fst -> [Enum.drop_while(fst, fn %{number: num} -> num < verse end)] ++ rest
      end

    case List.pop_at(list, -1) do
      {nil, _} ->
        []

      {last, initial} ->
        initial ++ [Enum.take_while(last, fn %{number: num} -> num <= end_verse end)]
    end
    |> List.flatten()
  end
end
