defmodule Bacon.WikiClientTest do
  use ExUnit.Case
  require Logger

  test "response body is a string for valid article name" do
    response = Bacon.WikiClient.get("Kevin_Bacon")
    assert response.body |> is_bitstring
  end
  
  test "can make multiple concurrent requests" do
    titles = ["<title>Kevin Bacon", "<title>Portlandia", "<title>List"]
    ["Kevin_Bacon", "Portlandia_(TV_series)", "List_of_fictional_big_cats"]
    |> Enum.map(fn (article) ->
      Bacon.WikiClient.get article, [stream_to: self]
    end)
    |> Enum.map(fn (response) ->
      %HTTPotion.AsyncResponse{id: id} = response
      id
    end)
    |> Enum.with_index
    |> Enum.each fn (tuple) ->
      {id, index} = tuple
      assert_receive %HTTPotion.AsyncChunk{id: ^id, chunk: body}, 5000
      assert body |> String.contains? Enum.at(titles, index)
    end
  end
end
