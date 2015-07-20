defmodule Bacon.WikiClient do
  use HTTPotion.Base
  require Logger
  
  def process_url(article) do
    "https://en.wikipedia.org/w/api.php?action=query&list=backlinks&format=json&bltitle=" <> article
  end
  
  def process_request_headers(headers) do
    Dict.put headers, :"User-Agent", "andrewbranch-bacon (github.com/andrewbranch/bacon)"
  end
  
  def process_response_body(body) do
    (
      {:ok, data} = body
      |> to_string
      |> Poison.Parser.parse
    )
    |> elem 1
  end
end