defmodule Bacon.WikiClient do
  alias HTTPotion.AsyncChunk
  alias HTTPotion.AsyncEnd
  use HTTPotion.Base
  
  def  get_backlinks(article, pid), do: get_backlinks(article, pid, nil, [])
  defp get_backlinks(article, pid, code, backlinks, first_request_id \\ nil) do
    if code, do: article = article <> "&blcontinue=#{code}"
    aggregator = spawn aggregate_response(pid, article, backlinks, first_request_id)
    %{id: id} = get article, [stream_to: aggregator]
    send aggregator, {:start, id}
    id
  end
  
  def process_url(article) do
    "https://en.wikipedia.org/w/api.php?action=query&continue=&list=backlinks&format=json&bllimit=500&bltitle=" <> article
  end
  
  def process_request_headers(headers) do
    Dict.put headers, :"User-Agent", "andrewbranch-bacon (github.com/andrewbranch/bacon)"
  end
  
  def process_response_body(body) do
    (
      {:ok, _data} = body
      |> to_string
      |> Poison.Parser.parse
    )
    |> elem 1
  end
  
  defp extract_backlinks(parsed) do
    parsed["query"]["backlinks"]
  end
  
  defp aggregate_response(pid, article, backlinks \\ [], first_request_id, request_id \\ nil, chunks \\ nil) do
    fn ->
      receive do
        {:start, id} ->
          aggregate_response(pid, article, backlinks, first_request_id || id, id, "").()
        %AsyncChunk{id: ^request_id, chunk: chunk} ->
          aggregate_response(pid, article, backlinks, first_request_id, request_id, chunks <> chunk).()
        %AsyncEnd{id: ^request_id} ->
          body = process_response_body(chunks)
          case body do
            %{"continue" => %{"blcontinue" => code}} ->
              get_backlinks(article, pid, code, backlinks ++ extract_backlinks(body), first_request_id)
            _ ->
              send pid, %{id: first_request_id, backlinks: backlinks ++ extract_backlinks(body)}
          end
      end
    end
  end
end