defmodule Cldr.Number.Ordinal do
  @moduledoc """
  Implements ordinal plural rules for numbers.
  """

  use Cldr.Number.PluralRule, :ordinal
  alias Cldr.LanguageTag

  @type operand :: integer()

  # Generate the functions to process plural rules
  @spec do_plural_rule(LanguageTag.t, number, operand, operand, operand, operand,
    [integer(),...] | integer()) :: :zero | :one | :two | :few | :many | :other

  # Function body is the AST of the function which needs to be injected
  # into the function definition.
  for locale_name <- @known_locale_names do
    function_body =
      @rules
      |> Map.get(locale_name)
      |> rules_to_condition_statement(__MODULE__)

    # This is the appropriate way to generate the function we're
    # generating.  However this will generate a lot of warnings
    # about unused parameters since not all generated functions
    # use all parameters.

    # defp do_plural_rule(unquote(locale), n, i, v, w, f, t) do
    #   unquote(Macro.escape(function_body))
    # end

    # So we use this version which is a bit hacky.  But we're only calling
    # Code.eval_quoted during compile time so we'll live with it.
    function = quote do
      defp do_plural_rule(%LanguageTag{language: unquote(locale_name)}, n, i, v, w, f, t),
        do: unquote(function_body)
    end
    Code.eval_quoted(function, [], __ENV__)
  end

  # If we get here then it means that the locale doesn't have a plural rule,
  # but the language might
  defp do_plural_rule(%LanguageTag{} = language_tag, n, i, v, w, f, t) do
    if language_tag.language == language_tag.cldr_locale_name do
      raise Cldr.UnknownPluralRules, "No #{@module_name} plural rules available for #{inspect language_tag}"
    else
      language_tag = Map.put(language_tag, :cldr_locale_name, language_tag.language)
      do_plural_rule(language_tag, n, i, v, w, f, t)
    end
  end
end
