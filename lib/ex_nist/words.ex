defmodule ExNist.Words do
  @moduledoc false
  def words do
    File.stream!("static/words.txt")
    |> Enum.map(fn word -> word |> String.trim() |> String.downcase() end)
  end
end
