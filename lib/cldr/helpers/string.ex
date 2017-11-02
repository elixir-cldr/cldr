defmodule Cldr.String do
  @moduledoc """
  Functions that operate on a `String.t` that are not provided
  in the standard lib.
  """

  @doc """
  This is the code of Macro.underscore with the following modifications
  which will be submitted as a PR when its clear it working appropriately

  The change is to cater for strings in the format:

    This_That

  which in Macro.underscore get formatted as

    this__that (note the double underscore)

  when we actually want

    that_that

  """

  # Don't underscore territory_codes
  @territory_codes ["IT", "SG", "MR", "MA", "NE", "NC", "PY", "MK", "CG", "TZ", "LB", "KN", "MT", "TW", "SK", "VU",
                    "BR", "BN", "LA", "BA", "PS", "BJ", "VC", "ID", "BE", "LY", "VN", "PW", "KW", "SN", "MH", "TM",
                    "TF", "TA", "BT", "NF", "RW", "LK", "RU", "IL", "CR", "CZ", "SL", "CL", "EH", "AF", "TL", "PR",
                    "DJ", "WF", "MZ", "KI", "VG", "HR", "GN", "CN", "NO", "GB", "NL", "BZ", "MP", "PE", "BM", "BI",
                    "MV", "IO", "TJ", "JM", "GQ", "DO", "CO", "BV", "KR", "MY", "KP", "YT", "ML", "ET", "IC", "PF",
                    "BS", "PN", "PK", "CW", "LS", "JP", "SC", "TR", "PT", "MD", "GM", "FR", "MU", "BH", "DE", "SX",
                    "GF", "LU", "TH", "AT", "GE", "CC", "UA", "KH", "AS", "AD", "ES", "NA", "GY", "CU", "UM", "BF",
                    "TO", "MQ", "BO", "IE", "SV", "LV", "GP", "KE", "IN", "PG", "AQ", "AR", "TK", "SH", "CM", "CA",
                    "QA", "MO", "DG", "GS", "BQ", "RS", "GT", "ST", "DM", "CP", "SS", "SR", "KZ", "EA", "GI", "ZW",
                    "EG", "IQ", "IM", "MM", "VI", "GD", "RO", "IR", "HM", "WS", "UZ", "AM", "TV", "EC", "KG", "SE",
                    "FK", "GU", "ZZ", "MN", "GR", "MC", "LR", "MW", "MG", "SI", "DK", "TT", "CV", "SD", "FM", "BW",
                    "EE", "SM", "XK", "JO", "GW", "FO", "HU", "BB", "MX", "RE", "KM", "OM", "TD", "SJ", "LC", "US",
                    "AC", "SB", "GH", "BG", "HT", "PH", "VE", "AW", "PA", "CF", "CH", "CY", "ME", "AZ", "LI", "MF",
                    "AE", "YE", "CD", "IS", "NR", "ZA", "GG", "BD", "SY", "AG", "PL", "CK", "CX", "GA", "TN", "MS",
                    "HN", "BL", "LT", "JE", "NZ", "FJ", "AU", "SZ", "AI", "AL", "NU", "UG", "AX", "NP", "NI", "NG",
                    "SA", "KY", "ZM", "GL", "TC", "SO", "HK", "VA", "CI", "FI", "AO", "ER", "UY", "DZ", "PM", "TG",
                    "BY"]
  for code <- @territory_codes do
    def underscore(unquote(code)), do: unquote(code)
  end

  def underscore(atom) when is_atom(atom) do
    "Elixir." <> rest = Atom.to_string(atom)
    underscore(rest)
  end
  def underscore(atom) when is_atom(atom) do
    "Elixir." <> rest = Atom.to_string(atom)
    underscore(rest)
  end
  def underscore(<<h, t::binary>>) do
    <<to_lower_char(h)>> <> do_underscore(t, h)
  end
  def underscore("") do
    ""
  end

  # h is upper case, next char is not uppercase, or a _ or .  => and prev != _
  defp do_underscore(<<h, t, rest::binary>>, prev)
      when (h >= ?A and h <= ?Z) and not (t >= ?A and t <= ?Z) and t != ?. and t != ?_ and prev != ?_ do
    <<?_, to_lower_char(h), t>> <> do_underscore(rest, t)
  end

  # h is uppercase, previous was not uppercase or _
  defp do_underscore(<<h, t::binary>>, prev)
      when (h >= ?A and h <= ?Z) and not (prev >= ?A and prev <= ?Z) and prev != ?_ do
    <<?_, to_lower_char(h)>> <> do_underscore(t, h)
  end

  # h is .
  defp do_underscore(<<?., t::binary>>, _) do
    <<?/>> <> underscore(t)
  end

  # Any other char
  defp do_underscore(<<h, t::binary>>, _) do
    <<to_lower_char(h)>> <> do_underscore(t, h)
  end
  defp do_underscore(<<>>, _) do
    <<>>
  end

  def to_upper_char(char) when char >= ?a and char <= ?z, do: char - 32
  def to_upper_char(char), do: char

  def to_lower_char(char) when char >= ?A and char <= ?Z, do: char + 32
  def to_lower_char(char), do: char
end
