# http://icu-project.org/apiref/icu4c/classRuleBasedNumberFormat.html
defmodule Cldr.Numbers.Ordinal do
  use Cldr.Numbers.PluralRules, :cardinal
  
  # Generate the functions to process plural rules
  @spec do_category(binary, number, number, number, number, number, number) 
    :: :one | :two | :few | :many | :other

  Enum.each @configured_locales, fn (locale) ->
    function_body = @rules[locale] |> rules_to_condition_statement(__MODULE__)
    function = quote do
      defp do_category(unquote(locale), n, i, v, w, f, t), do: unquote(function_body)
    end
    if System.get_env("DEBUG"), do: IO.puts Macro.to_string(function)
    Code.eval_quoted(function, [], __ENV__)
  end
end
