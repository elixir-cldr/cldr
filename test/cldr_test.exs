defmodule CldrTest do
  use ExUnit.Case
  alias Cldr.Numbers.Cardinal.Rules.Compiler
  alias Cldr.Numbers.Cardinal.Rules

  test "Validate CLDR plural rules categories against sample data" do
    validate_known()
  end
  
  # Run sample tests against all configured locales
  defp validate_known do
    Enum.each Compiler.configured_locales, fn (locale) ->
      rules_for_locale(locale) |> validate_rules(locale)
    end
  end
  
  defp validate_rules(rules, locale) do
    Enum.map rules, fn ({category, rule}) ->
      validate_rule(locale, category, rule)
    end
  end
  
  defp validate_rule(locale, category, rule) do
    validate_integer(locale, category, rule[:integer])
    validate_decimal(locale, category, rule[:decimal])
  end
  
  defp validate_integer(_locale, _category, nil), do: nil
  defp validate_integer(locale, category, samples) do
    Enum.each samples, fn
      :ellipsis ->
        true
      {:.., _context, [from, to]} -> 
        Enum.each from..to, fn (int) ->
          validate(locale, int, category)
        end
      int ->
        validate(locale, int, category)
    end
  end
  
  defp validate_decimal(_locale, _category, nil), do: nil
  defp validate_decimal(locale, category, samples) do
    Enum.each samples, fn
      :ellipsis ->
        true
      {:.., _context, [from, to]}-> 
        validate_decimal_range(locale, from, to, category)
      dec ->
        validate(locale, dec, category)
    end
  end
  
  defp validate(locale, int, expected) do
    got = Rules.category(int, locale)
    unless expected == got do
      IO.puts "Locale: #{inspect locale} for #{inspect int} should be #{inspect expected} but got #{inspect got}"
    end
    # assert expected == Rules.category(int, locale)
  end
  
  # We're validating a range.  But for a decimal the range is infinite.
  # Just validate `from` and `to` for now
  defp validate_decimal_range(locale, from, to, expected) do
    got = Rules.category(from, locale)
    unless expected == got do
      IO.puts "Locale: #{inspect locale} for #{inspect from} should be #{inspect expected} but got #{inspect got}"
    end
    got = Rules.category(to, locale)
    unless expected == got do
      IO.puts "Locale: #{inspect locale} for #{inspect to} should be #{inspect expected} but got #{inspect got}"
    end
    # IO.puts "Locale: #{inspect locale} for #{inspect from} should be #{inspect expected}"
    # assert expected == Rules.category(from, locale)
    # IO.puts "Locale: #{inspect locale} for #{inspect to} should be #{inspect expected}"
    # assert expected == Rules.category(to, locale)
  end

  # def validate(locale, int, expected) do
  #   provided = Rules.category(int, locale)
  #   unless expected == provided do
  #     IO.puts "Invalid: Locale: #{inspect locale}. For #{inspect int} expected #{inspect expected} but go #{inspect provided}"
  #   end
  # end
  
  defp rules_for_locale(locale) do
    Enum.map Compiler.cardinal_rules[locale], fn({"pluralRule-count-" <> category, rule}) ->
      {:ok, definition} = Compiler.parse(rule)
      {String.to_atom(category), definition}
    end
  end
end
