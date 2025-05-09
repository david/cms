defmodule CMS.YouVersion do
  alias CMS.Bibles.Verse

  def get_chapter(chapter, book, bible),
    do: bible |> fetch_content(book, chapter) |> get_verses(chapter, book)

  defp fetch_content(bible, book, chapter),
    do:
      "https://www.bible.com/bible/#{bible.source_id}/#{book}.#{chapter}.#{bible.source_label}"
      |> Req.get!()
      |> Map.get(:body)

  defp get_verses(content, chapter, book) do
    content
    |> find_elements()
    |> Enum.group_by(&(&1 |> get_attr("data-usfm") |> parse_verse()))
    |> Enum.sort_by(fn {number, _} -> number end)
    |> Enum.map(fn {number, data} ->
      %Verse{body: get_body(data), book: book, chapter: chapter, number: number}
    end)
  end

  defp find_elements(string) do
    {:ok, doc} = Floki.parse_document(string)

    Floki.find(doc, "span[data-usfm]")
  end

  defp get_body(data),
    do:
      data
      |> Enum.map(&get_data/1)
      |> Enum.join(" ")
      |> String.replace(~r/\s+([,.])/u, "\\1")
      |> String.replace(~r/\s{2,}/u, " ")
      |> String.trim()

  defp get_data(data) when is_binary(data), do: data

  defp get_data({_tag, _attrs, data} = elem) do
    class = get_attr(elem, "class")

    cond do
      class =~ ~r/^ChapterContent_label/ ->
        ""

      class =~ ~r/^ChapterContent_note/ ->
        ""

      true ->
        data |> Enum.map(&get_data/1) |> Enum.join(" ")
    end
  end

  defp get_attr({_tag, attrs, _data}, key),
    do: attrs |> Enum.find(fn {k, _v} -> k == key end) |> elem(1)

  defp parse_verse(usfm),
    do: usfm |> String.split(".") |> Enum.at(2) |> Integer.parse() |> elem(0)
end
