defmodule Cldr.Number.Ordinal do
  @moduledoc """
  Implements ordinal plural rules for numbers.
  """

  use Cldr.Number.PluralRule, :ordinal

  @type operand :: non_neg_integer

  # Generate the functions to process plural rules
  @spec do_plural_rule(Cldr.locale, number, operand, operand, operand, operand, operand)
    :: :one | :two | :few | :many | :other

  # Function body is the AST of the function which needs to be injected
  # into the function definition.  Using Code.eval_quoted/3 is hacky but
  # I haven't found another way to inject the AST into the function definition.
  Enum.each @configured_locales, fn (locale) ->
    function_body =
      @rules
      |> Map.get(locale)
      |> rules_to_condition_statement(__MODULE__)

    function = quote do
      defp do_plural_rule(unquote(locale), n, i, v, w, f, t), do: unquote(function_body)
    end

    Code.eval_quoted(function, [], __ENV__)
  end
end
