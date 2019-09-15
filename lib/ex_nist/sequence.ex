defmodule ExNist.Sequence do
  @moduledoc """
  Module to generate list of sequences that passwords should not contain

  E.g. "abc", "cba", "123"
  """
  @ascii_start 48
  @ascii_end 90

  @ascii_symbol_start 58
  @ascii_symbol_end 64
  @doc "Returns list of sequences"
  def sequences do
    sequences =
      for char <- @ascii_start..(@ascii_end - 2) do
        sequence = char..@ascii_end

        seq =
          Enum.reduce_while(sequence, [], &build_sequence/2)

        [
          seq |> List.to_string() |> String.downcase(),
          seq |> Enum.reverse() |> List.to_string() |> String.downcase()
        ]
      end

    # these two sequences are not generated so they're added manually
    ["098", "890" | sequences] |> List.flatten() |> Enum.uniq()
  end

  def build_sequence(c, acc) when c >= @ascii_symbol_start and c <= @ascii_symbol_end do
    {:cont, acc}
  end

  def build_sequence(c, acc) when length(acc) <= 2 do
    {:cont, [c | acc]}
  end

  def build_sequence(_c, acc) do {:halt, acc} end

end
