defmodule Bacon.WikiClient do
  use HTTPotion.Base
  
  def process_url(url) do
    "https://en.wikipedia.org/wiki/" <> url
  end
  
  def process_response_body(body) do
    body |> to_string
  end
end