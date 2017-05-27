defmodule Cldr.Number.Cardinal do
  @moduledoc """
  Implements cardinal plural rules for numbers.
  """

  use Cldr.Number.PluralRule, :cardinal

  @type operand :: non_neg_integer

  # Generate the functions to process plural rules
  @spec do_plural_rule(Cldr.locale, number, operand, operand, operand, operand, operand)
    :: :one | :two | :few | :many | :other

  Enum.each @configured_locales, fn (locale) ->
    function_body = @rules[locale] |> rules_to_condition_statement(__MODULE__)
    function = quote do
      defp do_plural_rule(unquote(locale), n, i, v, w, f, t), do: unquote(function_body)
    end
    Code.eval_quoted(function, [], __ENV__)
  end
end