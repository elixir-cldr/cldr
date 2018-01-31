defmodule Cldr.Number.Ordinal do
  @moduledoc """
  Implements ordinal plural rules for numbers.
  """

  use Cldr.Number.PluralRule, :ordinal
  alias Cldr.LanguageTag

  @type operand :: integer()

  # Generate the functions to process plural rules
  @spec do_plural_rule(
          LanguageTag.t(),
          number,
          operand,
          operand,
          operand,
          operand,
          [integer(), ...] | integer()
        ) :: :zero | :one | :two | :few | :many | :other

  # Function body is the AST of the function which needs to be injected
  # into the function definition.
  for locale_name <- @known_locale_names do
    function_body =
      @rules
      |> Map.get(locale_name)
      |> rules_to_condition_statement(__MODULE__)

    defp do_plural_rule(%LanguageTag{cldr_locale_name: unquote(locale_name)}, n, i, v, w, f, t) do
      # silence unused variable warnings
      _ = {n, i, v, w, f, t}
      unquote(function_body)
    end
  end

  # If we get here then it means that the locale doesn't have a plural rule,
  # but the language might
  defp do_plural_rule(%LanguageTag{} = language_tag, n, i, v, w, f, t) do
    if language_tag.language == language_tag.cldr_locale_name do
      {
        :error,
        {
          Cldr.UnknownPluralRules,
          "No #{@module_name} plural rules available for #{inspect(language_tag)}"
        }
      }
    else
      language_tag = Map.put(language_tag, :cldr_locale_name, language_tag.language)
      do_plural_rule(language_tag, n, i, v, w, f, t)
    end
  end
end
