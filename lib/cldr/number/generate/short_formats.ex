defmodule Cldr.Number.Generate.ShortFormats do
  @moduledoc """
  Generates a set of functions to process the various
  :short and :long formats for numbers.
  """
  defmacro __using__(_options \\ []) do
    def_short_formats()
  end

  defp def_short_formats do
    # Number.Format.formats_for("en").decimal_short \
    # |> Enum.group_by(fn {k, v} -> List.first(String.split(k,"-")) end) \
    # |> Enum.map(fn {k, v} ->
    #     vv =  Enum.map(v, fn {a, b} ->
    #       nk = String.split(a, "-") |> Enum.reverse |> List.first |> String.to_atom
    #       nv = b
    #       {nk, nv}
    #     end)
    #     {k, vv}
    #   end)
  end
end
