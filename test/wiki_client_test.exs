defmodule Bacon.WikiClientTest do
  use ExUnit.Case

  test "response body is a map for valid article name" do
    response = Bacon.WikiClient.get("Kevin_Bacon")
    assert response.body |> is_map
  end
  
  test "can make multiple concurrent requests" do
    backlinks = ["Apollo 13", "Jello Biafra", "List of fictional dogs"]
    ["Kevin_Bacon", "Portlandia_(TV_series)", "List_of_fictional_big_cats"]
    |> Enum.map(fn (article) ->
      Bacon.WikiClient.get article, [stream_to: self]
    end)
    |> Enum.with_index
    |> Enum.each fn (tuple) ->
      {response = %{id: id}, index} = tuple
      assert_receive %HTTPotion.AsyncChunk{id: ^id, chunk: body}, 5000
      body = Bacon.WikiClient.process_response_body(body)
      assert body["query"]["backlinks"] |> Enum.any? fn (link) ->
        link["title"] == backlinks |> Enum.at index
      end
    end
  end
end
