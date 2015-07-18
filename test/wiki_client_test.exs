defmodule Bacon.WikiClientTest do
  use ExUnit.Case

  test "response body is a string for valid article name" do
    response = Bacon.WikiClient.get("Kevin_Bacon")
    assert response.body |> is_bitstring
  end
end
