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
  # into the function definition.
  for locale <- @configured_locales do
    function_body =
      @rules
      |> Map.get(locale)
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
      defp do_plural_rule(unquote(locale), n, i, v, w, f, t), do: unquote(function_body)
    end
    Code.eval_quoted(function, [], __ENV__)
  end
end
