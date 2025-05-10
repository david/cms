defmodule CMS.Bibles do
  import Ecto.Query, warn: false

  alias CMS.Repo
  alias CMS.Bibles.Bible
  alias CMS.Bibles.Passage
  alias CMS.Bibles.Verse
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

  defp get_verses(
         {:ok, {book_usfm, start_chapter, start_verse}, {_end_book_usfm, end_chapter, end_verse}},
         bible
       ) do
    start_chapter..end_chapter
    |> Enum.to_list()
    |> ensure_persisted_chapters(book_usfm, bible)
    |> get_cached_verses(book_usfm)
    |> filter_verses_by_reference_range(start_chapter, start_verse, end_chapter, end_verse)
    |> Enum.to_list()
  end

  defp ensure_persisted_chapters(required_chapters, book_usfm, bible) do
    cached_chapter_numbers = get_cached_chapter_numbers(book_usfm, required_chapters)
    chapters_to_fetch = required_chapters -- cached_chapter_numbers

    chapters_to_fetch
    |> Enum.flat_map(&YouVersion.get_chapter(&1, book_usfm, bible))
    |> create_verses()

    required_chapters
  end

  defp get_cached_chapter_numbers(book_usfm, chapter_numbers) do
    from(v in Verse,
      where: v.book_usfm == ^book_usfm and v.chapter in ^chapter_numbers,
      select: v.chapter,
      distinct: true
    )
    |> Repo.all()
  end

  defp filter_verses_by_reference_range(
         verses,
         start_chapter,
         start_verse,
         end_chapter,
         end_verse
       ) do
    verses
    |> Stream.drop_while(fn verse ->
      verse.chapter == start_chapter && verse.verse_number < start_verse
    end)
    |> Stream.take_while(fn verse ->
      verse.chapter < end_chapter or verse.verse_number <= end_verse
    end)
    |> Enum.to_list()
  end

  defp get_cached_verses(chapter_numbers, book_usfm) when is_list(chapter_numbers) do
    Verse
    |> where([v], v.book_usfm == ^book_usfm and v.chapter in ^chapter_numbers)
    |> order_by([v], asc: v.chapter, asc: v.verse_number)
    |> Repo.all()
  end

  defp create_verses(verses) do
    changesets = Enum.map(verses, &Verse.changeset/1)

    Repo.transaction(fn ->
      for c <- changesets do
        {:ok, verse} =
          Repo.insert(c,
            on_conflict: :nothing,
            conflict_target: [:book_usfm, :chapter, :verse_number]
          )

        verse
      end
    end)
  end
end
