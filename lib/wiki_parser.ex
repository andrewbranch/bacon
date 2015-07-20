defmodule Bacon.WikiParser do
  def get_titles(response) do
    response["query"]["backlinks"] |> Enum.map fn (link) ->
      link["title"]
    end
  end
end