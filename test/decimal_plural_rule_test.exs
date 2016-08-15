defmodule Decimal.PluralRule.Test do
  use ExUnit.Case
  @moduletag :slow
  @sample_types [:decimal]
  @modules      [Cldr.Number.Cardinal, Cldr.Number.Ordinal]

  Enum.each @modules, fn (module) ->
    Enum.each module.configured_locales, fn (locale) ->
      Enum.each module.plural_rules_for(locale), fn {category, rule} ->
        Enum.each @sample_types, fn (sample_type) ->
          Enum.each rule[sample_type] || [], fn
          :ellipsis ->
            true
          {:.., _context, [from, to]} ->
            test "#{inspect module}: Validate range #{inspect from}..#{inspect to} is in plural category #{inspect category} for locale #{inspect locale}" do
              assert unquote(module).plural_rule(unquote(Macro.escape(from)), unquote(locale)) == unquote(category)
              assert unquote(module).plural_rule(unquote(Macro.escape(to)), unquote(locale)) == unquote(category)
            end
          int ->
            test "#{inspect module}: Validate number #{inspect int} is in plural category #{inspect category} for locale #{inspect locale}" do
              assert unquote(module).plural_rule(unquote(Macro.escape(int)), unquote(locale)) == unquote(category)
            end
          end
        end
      end
    end
  end 
end
