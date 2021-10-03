defmodule Cldr.Validity do
  @moduledoc false

  @doc """
  Normalizes a language tag field.
  """
  @callback normalize(String.t() | atom()) :: String.t() | atom()

  @doc """
  Validates a language tag field
  """
  @callback validate(String.t() | atom()) :: {:ok, term, atom()} | {:error, String.t()}

  defmacro __using__(type) do
    validity_data = Cldr.Config.validity(type)
    Cldr.Validity.generate_validity_checks(validity_data)
  end

  @doc false
  def generate_validity_checks(validity_data) do
    quote bind_quoted: [validity_data: Macro.escape(validity_data)] do
      for {status, codes} <- validity_data do
        {code_ranges, simple_codes} = Cldr.Validity.partition(codes)

        simple_check =
          if length(simple_codes) > 0 do
            defp valid(code) when code in unquote(simple_codes) do
              {:ok, code, unquote(status)}
            end
          end

        range_check =
          for range <- code_ranges, range != [] do
            {base, range_start, range_end} = Cldr.Validity.range_from(range)

            defp valid(unquote(base) <> <<char::utf8>> = code)
                 when char in unquote(range_start)..unquote(range_end) do
              {:ok, code, unquote(status)}
            end
          end
      end

      defp valid(code) do
        {:error, code}
      end
    end
  end

  @doc false
  def partition(list) do
    Enum.reduce(list, {[], []}, fn elem, {ranges, simple} ->
      if String.contains?(elem, "~") do
        {[elem | ranges], simple}
      else
        {ranges, [elem | simple]}
      end
    end)
  end

  @doc false
  def range_from(code_range) do
    [left, range_end] = String.split(code_range, "~")
    {base, range_start} = String.split_at(left, -1)
    <<range_start::utf8>> = range_start
    <<range_end::utf8>> = range_end
    {base, range_start, range_end}
  end

  # Only used for testing
  @doc false
  def all_valid(type) do
    validity_data = Cldr.Config.validity(type)

    for {_status, codes} <- validity_data do
      {code_ranges, simple_codes} = partition(codes)

      range_check =
        for range <- code_ranges, range != [] do
          {base, range_start, range_end} = range_from(range)

          for char <- range_start..range_end do
            base <> <<char::utf8>>
          end
        end

      simple_codes ++ range_check
    end
    |> List.flatten()
  end

  # Returns a list of known data that omits
  # valid (per the spec) but shouldn't be used
  # in general practise

  @omit_status [:deprecated, :reserved, :special, :unknown, :private_use]

  @doc false
  def known(type) do
    validity_data = Cldr.Config.validity(type)

    for {status, codes} <- validity_data, status not in @omit_status do
      {code_ranges, simple_codes} = partition(codes)

      range_check =
        for range <- code_ranges, range != [] do
          {base, range_start, range_end} = range_from(range)

          for char <- range_start..range_end do
            base <> <<char::utf8>>
          end
        end

      simple_codes ++ range_check
    end
    |> List.flatten()
  end
end
