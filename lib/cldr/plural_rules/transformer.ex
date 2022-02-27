defmodule Cldr.Number.PluralRule.Transformer do
  @moduledoc false

  # Transformations on the parse tree returned from parsing plural rules.
  #
  # The transformations is primarily to convert the parse tree into an AST
  # representing a `cond` statement that implements the rule.

  @doc """
  Converts a map representing a set of plural rules and converts it
  to an `cond` statement.

  `rules` is a map of the locale specific branch of the plurals.json
  file from CLDR.  It is then tokenized, parsed and the resulting ast
  converted to a `cond` statement.
  """
  def rules_to_condition_statement(rules, module) do
    branches =
      Enum.map(rules, fn {category, definition} ->
        {new_ast, _} = set_operand_module(definition[:rule], module)
        rule_to_cond_branch(new_ast, category)
      end)

    {:cond, [], [[do: move_true_branch_to_end(branches)]]}
  end

  # We can't assume the order of branches and we need the
  # `true` branch at the end since it will always match
  # and hence potentially shadow other branches
  defp move_true_branch_to_end(branches) do
    Enum.sort(branches, fn {:->, [], [[ast], _category]}, _other_branch ->
      not (ast == true)
    end)
  end

  # Walk the AST and replace the variable context to that of the calling
  # module
  defp set_operand_module(ast, _module) do
    Macro.prewalk(ast, [], fn expr, acc ->
      new_expr =
        case expr do
          {var, [], Elixir} ->
            {var, [], Cldr.Number.PluralRule}

          # {var, [], module}
          {:mod, _context, [operand, value]} ->
            {:mod, [context: Elixir, import: Elixir.Cldr.Math], [operand, value]}

          {:within, _context, [operand, range]} ->
            {:within, [context: Elixir, import: Elixir.Cldr.Math], [operand, range]}

          _ ->
            expr
        end

      {new_expr, acc}
    end)
  end

  # Transform the rule AST into a branch of a `cond` statement
  defp rule_to_cond_branch(nil, category) do
    {:->, [], [[true], category]}
  end

  defp rule_to_cond_branch(rule_ast, category) do
    {:->, [], [[rule_ast], category]}
  end
end
