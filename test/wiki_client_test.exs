defmodule Bacon.WikiClientTest do
  use ExUnit.Case
  alias Bacon.WikiClient

  test "response body is a map for valid article name" do
    response = WikiClient.get("List_of_fictional_big_cats")
    assert response.body |> is_map
  end
  
  test "can make multiple concurrent requests" do
    expected = ["Jello Biafra", "List of fictional dogs"]
    ["Portlandia_(TV_series)", "List_of_fictional_big_cats"]
    |> Enum.map(fn (article) ->
      WikiClient.get_backlinks article, self
    end)
    |> Enum.with_index
    |> Enum.each fn (tuple) ->
      {id, index} = tuple
      assert_receive %{id: ^id, backlinks: backlinks}, 5000
      assert backlinks |> Enum.any? fn (link) ->
        link["title"] == expected |> Enum.at index
      end
    end
  end
  
  test "continues requests that return continue codes" do
    id = WikiClient.get_backlinks "Kevin_Bacon", self
    assert_receive %{id: ^id, backlinks: backlinks}, 7500
    assert Enum.count(backlinks) > 1000
  end
end
