defmodule Integer.PluralRule.Test do
  use ExUnit.Case

  @moduletag :slow
  @sample_types [:integer]
  @modules [Cldr.Number.Cardinal, Cldr.Number.Ordinal]

  for module <- @modules,
      locale_name <- module.known_locale_names,
      {category, rule} <- module.plural_rules_for(locale_name),
      sample_type <- @sample_types,
      one_rule <- rule[sample_type] || [] do
    locale = Cldr.Locale.new!(locale_name)

    case one_rule do
      :ellipsis ->
        true

      {:.., _context, [from, to]} ->
        Enum.each(from..to, fn int ->
          test "#{inspect(module)}: Validate number #{inspect(int)} in range #{inspect(from)}..#{
                 inspect(to)
               } is in plural category #{inspect(category)} for locale #{inspect(locale_name)}" do
            assert unquote(module).plural_rule(unquote(int), unquote(Macro.escape(locale))) ==
                     unquote(category)
          end
        end)

      int ->
        test "#{inspect(module)}: Validate number #{inspect(int)} is in plural category #{
               inspect(category)
             } for locale #{inspect(locale_name)}" do
          assert unquote(module).plural_rule(unquote(int), unquote(Macro.escape(locale))) ==
                   unquote(category)
        end
    end
  end
end
