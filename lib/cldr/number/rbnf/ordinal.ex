defmodule Cldr.Rbnf.Ordinal do
  @moduledoc """
  Functions to implement the ordinal rule-based-number-format rules of CLDR.

  As CLDR notes, the data is incomplete or non-existent for many languages.  It
  is considered complete for English however.
  """
  
  import Kernel, except: [and: 2]
  alias  Cldr.Rbnf
  use    Cldr.Rbnf.Operations

  @ordinal Rbnf.for_all_locales["OrdinalRules"]
  for {locale, _rule_group} <-  @ordinal do
    for {rule_group, %{access: _access, rules: rules}} <- @ordinal[locale] do
      for rule <- rules do
        {:ok, parsed} = Rbnf.Rule.parse(rule.definition)
        range = rule.range

        case rule.base_value do
          "-x" ->
            def unquote(rule_group)(number, unquote(locale))
            when Kernel.and(is_integer(number), number < 0) do
              do_rule(number,
                unquote(locale),
                unquote(rule_group),
                unquote(Macro.escape(rule)),
                unquote(Macro.escape(parsed)))
            end
          "x.x" ->
            :ok
          "0.x" ->
            :ok
          "x.0" ->
            :ok
          "Inf" ->
            :ok
          "NaN" ->
            :ok
          0 when range == :undefined ->
            def unquote(rule_group)(number, unquote(locale))
            when is_integer(number) do
              do_rule(number,
                unquote(locale),
                unquote(rule_group),
                unquote(Macro.escape(rule)),
                unquote(Macro.escape(parsed)))
            end
          _ ->
            def unquote(rule_group)(number, unquote(locale))
            when Kernel.and(is_integer(number),
              Kernel.and(number >= unquote(rule.base_value), number < unquote(rule.range))) do
              do_rule(number,
                unquote(locale),
                unquote(rule_group),
                unquote(Macro.escape(rule)),
                unquote(Macro.escape(parsed)))
            end
        end
      end
    end
  end
end