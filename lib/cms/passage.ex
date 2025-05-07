defmodule CMS.Bibles.Passage do
  @single_chapter_regex ~r/^(?<book>\w+)\s+(?<chapter>\d+)$/
  @single_verse_regex ~r/^(?<book>\w+)\s+(?<chapter>\d+):(?<verse>\d+)$/
  @multi_verse_regex ~r/^(?<book>\w+)\s+(?<chapter>\d+):(?<verse>\d+)-(?<end_verse>\d+)$/
  @multi_chapter_regex ~r/^(?<book>\w+)\s+(?<chapter>\d+):(?<verse>\d+)-(?<end_chapter>\d+):(?<end_verse>\d+)$/

  def parse(ref, %{usfm_index: usfm_index}) do
    ref = normalize_reference(ref)

    parse_multi_chapter(ref, usfm_index) ||
      parse_multi_verse(ref, usfm_index) ||
      parse_single_verse(ref, usfm_index) ||
      parse_single_chapter(ref, usfm_index) ||
      {:error, ref}
  end

  defp normalize_reference(ref),
    do:
      ref
      |> String.trim()
      |> String.downcase()
      |> String.normalize(:nfd)
      |> String.replace(~r/\s+/u, " ")
      |> String.replace(~r/[^A-z0-9:\s-]/u, "")

  defp parse_multi_chapter(expr, usfm_index) do
    case Regex.named_captures(@multi_chapter_regex, expr) do
      %{
        "book" => book,
        "chapter" => chapter,
        "verse" => verse,
        "end_chapter" => end_chapter,
        "end_verse" => end_verse
      } ->
        with verse_start when not is_nil(verse_start) <-
               normalize(book, chapter, verse, usfm_index),
             verse_end when not is_nil(verse_end) <-
               normalize(book, end_chapter, end_verse, usfm_index) do
          {:ok, verse_start, verse_end}
        end

      _ ->
        nil
    end
  end

  defp parse_multi_verse(expr, usfm_index) do
    case Regex.named_captures(@multi_verse_regex, expr) do
      %{
        "book" => book,
        "chapter" => chapter,
        "verse" => verse,
        "end_verse" => end_verse
      } ->
        with verse_start when not is_nil(verse_start) <-
               normalize(book, chapter, verse, usfm_index),
             verse_end when not is_nil(verse_end) <-
               normalize(book, chapter, end_verse, usfm_index) do
          {:ok, verse_start, verse_end}
        end

      _ ->
        nil
    end
  end

  defp parse_single_verse(expr, usfm_index) do
    case Regex.named_captures(@single_verse_regex, expr) do
      %{
        "book" => book,
        "chapter" => chapter,
        "verse" => verse
      } ->
        with verse_start when not is_nil(verse_start) <-
               normalize(book, chapter, verse, usfm_index) do
          {:ok, verse_start, verse_start}
        end

      _ ->
        nil
    end
  end

  defp parse_single_chapter(expr, usfm_index) do
    case Regex.named_captures(@single_chapter_regex, expr) do
      %{
        "book" => book,
        "chapter" => chapter
      } ->
        with {book, chapter, 1} <- normalize(book, chapter, "1", usfm_index) do
          {:ok, {book, chapter, 1}, {book, chapter, 9999}}
        end

      _ ->
        nil
    end
  end

  defp normalize(book, chapter, verse, usfm_index) do
    with book when not is_nil(book) <- usfm_index[book],
         {chapter, _} <- Integer.parse(chapter),
         {verse, _} <- Integer.parse(verse) do
      {book, chapter, verse}
    end
  end
end
