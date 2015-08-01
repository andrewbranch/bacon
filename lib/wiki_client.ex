defmodule Bacon.WikiClient do
  alias HTTPotion.AsyncChunk
  alias HTTPotion.AsyncEnd
  use HTTPotion.Base
  require Logger
  
  def get_backlinks(article, pid) do
    aggregator = spawn aggregate_response(pid)
    %{id: id} = get article, [stream_to: aggregator]
    # Logger.debug "sending request id #{id |> to_string} to aggregator..."
    send aggregator, {:start, id}
    id
  end
  
  def process_url(article) do
    "https://en.wikipedia.org/w/api.php?action=query&list=backlinks&format=json&bllimit=500&bltitle=" <> article
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
  
  defp extract_backlinks(body) do
    process_response_body(body)["query"]["backlinks"]
  end
  
  defp aggregate_response(pid, request_id \\ nil, chunks \\ nil) do
    fn ->
      receive do
        {:start, id} ->
          aggregate_response(pid, id, "").()
        %AsyncChunk{id: ^request_id, chunk: chunk} ->
          aggregate_response(pid, request_id, chunks <> chunk).()
        %AsyncEnd{id: ^request_id} ->
          send pid, %{id: request_id, backlinks: extract_backlinks(chunks)}
      end
    end
  end
end