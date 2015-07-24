defmodule Bacon.WikiParserTest do
  use ExUnit.Case
  
  test "get_titles pulls a list of article titles from an API response" do
    titles = Bacon.WikiParser.get_titles %{"batchcomplete" => "","continue" => %{"blcontinue" => "0|15308", "continue" => "-||"},"query" => %{"backlinks" => [%{"ns" => 0, "pageid" => 1178,"title" => "Afterlife"},%{"ns" => 0, "pageid" => 1770, "title" => "Apollo 13"},%{"ns" => 0, "pageid" => 4471, "title" => "Billy Bob Thornton"},%{"ns" => 0, "pageid" => 5655, "title" => "Courtney Love"},%{"ns" => 0, "pageid" => 5951, "title" => "Cleveland"},%{"ns" => 0, "pageid" => 8860, "title" => "Dubbing (filmmaking)"},%{"ns" => 0, "pageid" => 9736, "title" => "Empire State Building"},%{"ns" => 0, "pageid" => 9742, "title" => "Erdős number"},%{"ns" => 0, "pageid" => 12431, "title" => "Google Search"},%{"ns" => 0, "pageid" => 12561, "title" => "Gene Hackman"}]},"warnings" => %{"query" => %{"*" => "Formatting of continuation data has changed. To receive raw query-continue data, use the 'rawcontinue' parameter. To silence this warning, pass an empty string for 'continue' in the initial query."}}}
    assert titles |> is_list
    assert titles |> Enum.count == 10
    assert titles |> Enum.at(0) == "Afterlife"
  end
end