defmodule Decimal.PluralRule.Test do
  use ExUnit.Case

  @moduletag :slow
  @sample_types [:decimal]
  @modules      [Cldr.Number.Cardinal, Cldr.Number.Ordinal]

  for module           <- @modules,
      locale           <- module.configured_locales,
      {category, rule} <- module.plural_rules_for(locale),
      sample_type      <- @sample_types,
      one_rule         <- (rule[sample_type] || [])
  do
    case one_rule do
      :ellipsis ->
        true
      {:.., _context, [from, to]} ->
        test "#{inspect module}: Validate range #{inspect from}..#{inspect to} is in plural category #{inspect category} for locale #{inspect locale}" do
          assert unquote(module).plural_rule(unquote(Macro.escape(from)), unquote(locale)) == unquote(category)
          assert unquote(module).plural_rule(unquote(Macro.escape(to)), unquote(locale)) == unquote(category)
        end
      dec ->
        test "#{inspect module}: Validate number #{inspect dec} is in plural category #{inspect category} for locale #{inspect locale}" do
          assert unquote(module).plural_rule(unquote(Macro.escape(dec)), unquote(locale)) == unquote(category)
        end
    end
  end
end
