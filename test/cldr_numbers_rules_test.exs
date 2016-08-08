defmodule Cldr.Numbers.Rules.Test do
  use ExUnit.Case
  alias Cldr.Number.PluralRules.Compiler

  test "Validate Cardinal CLDR plural rules categories against sample data" do
    validate_cardinal()
  end
  
  test "Validate Ordinal CLDR plural rules categories against sample data" do
    validate_ordinal()
  end
  
  # Run sample tests against all configured locales
  defp validate_cardinal do
    Enum.each Cldr.Number.Cardinal.configured_locales, fn (locale) ->
      rules_for_locale(Cldr.Number.Cardinal, locale) |> validate_rules(Cldr.Number.Cardinal, locale)
    end
  end
  
  defp validate_ordinal do
    Enum.each Cldr.Number.Ordinal.configured_locales, fn (locale) ->
      rules_for_locale(Cldr.Number.Ordinal, locale) |> validate_rules(Cldr.Number.Ordinal, locale)
    end
  end
  
  defp validate_rules(rules, module, locale) do
    Enum.map rules, fn ({category, rule}) ->
      validate_rule(module, locale, category, rule)
    end
  end
  
  defp validate_rule(module, locale, category, rule) do
    validate_integer(module, locale, category, rule[:integer])
    validate_decimal(module, locale, category, rule[:decimal])
  end
  
  defp validate_integer(_module, _locale, _category, nil), do: nil
  defp validate_integer(module, locale, category, samples) do
    Enum.each samples, fn
      :ellipsis ->
        true
      {:.., _context, [from, to]} -> 
        Enum.each from..to, fn (int) ->
          validate(module, locale, int, category)
        end
      int ->
        validate(module, locale, int, category)
    end
  end
  
  defp validate_decimal(_module, _locale, _category, nil), do: nil
  defp validate_decimal(module, locale, category, samples) do
    Enum.each samples, fn
      :ellipsis ->
        true
      {:.., _context, [from, to]}-> 
        validate_decimal_range(module, locale, from, to, category)
      dec ->
        validate(module, locale, dec, category)
    end
  end
  
  defp validate(module, locale, int, expected) do
    got = apply(module, :plural_rule, [int, locale])
    # unless expected == got do
    #   IO.puts "Locale: #{inspect locale} for #{inspect int} should be #{inspect expected} but got #{inspect got}"
    # end
    assert expected == got
  end
  
  # We're validating a range.  But for a decimal the range is infinite.
  # Just validate `from` and `to` for now
  defp validate_decimal_range(module, locale, from, to, expected) do
    got = apply(module, :plural_rule, [from, locale])
    assert expected == got
    # unless expected == got do
    #   IO.puts "Locale: #{inspect locale} for #{inspect from} should be #{inspect expected} but got #{inspect got}"
    # end
    got = apply(module, :plural_rule, [to, locale])
    assert expected == got
    # unless expected == got do
    #   IO.puts "Locale: #{inspect locale} for #{inspect to} should be #{inspect expected} but got #{inspect got}"
    # end
  end
  
  defp rules_for_locale(module, locale) do
    Enum.map apply(module, :plural_rules, [])[locale], fn({"pluralRule-count-" <> category, rule}) ->
      {:ok, definition} = Compiler.parse(rule)
      {String.to_atom(category), definition}
    end
  end
end
