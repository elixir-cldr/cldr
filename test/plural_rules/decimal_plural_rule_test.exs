defmodule Decimal.PluralRule.Test do
  use ExUnit.Case, async: true

  @moduletag :slow
  @sample_types [:decimal]
  @modules [TestBackend.Cldr.Number.Cardinal, TestBackend.Cldr.Number.Ordinal]

  for module <- @modules,
      locale_name <- module.known_locale_names() -- [Cldr.Config.root_locale_name()],
      {category, rule} <- module.plural_rules_for(locale_name),
      sample_type <- @sample_types,
      one_rule <- rule[sample_type] || [] do
    locale = Cldr.Locale.new!(locale_name, TestBackend.Cldr)

    case one_rule do
      :ellipsis ->
        true

      {:.., _context, [from, to]} ->
        test "#{inspect(module)}: Validate range #{inspect(from)}..#{inspect(to)} is in plural category #{inspect(category)} for locale #{inspect(locale_name)}" do
          assert unquote(module).plural_rule(
                   unquote(Macro.escape(from)),
                   unquote(Macro.escape(locale))
                 ) == unquote(category)

          assert unquote(module).plural_rule(
                   unquote(Macro.escape(to)),
                   unquote(Macro.escape(locale))
                 ) == unquote(category)
        end

      dec ->
        test "#{inspect(module)}: Validate number #{inspect(dec)} is in plural category #{inspect(category)} for locale #{inspect(locale_name)}" do
          assert unquote(module).plural_rule(
                   unquote(Macro.escape(dec)),
                   unquote(Macro.escape(locale))
                 ) == unquote(category)
        end
    end
  end

  test "Non-integer decimal pluralization" do
    decimal = Decimal.new("1234.50")
    substitutions = %{one: "one", two: "two", other: "other"}
    assert TestBackend.Cldr.Number.Cardinal.pluralize(decimal, :en, substitutions) == "other"
    assert TestBackend.Cldr.Number.Cardinal.pluralize(decimal, "en", substitutions) == "other"
  end
end
