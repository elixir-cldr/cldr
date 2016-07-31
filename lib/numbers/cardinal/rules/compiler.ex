# http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
defmodule Cldr.Numbers.Cardinal.Rules.Compiler do
  @moduledoc """
  Generate functions from CLDR plural rules that can be used to determine 
  which pularization rule to be used for a given number.
  """
  
  {:ok, json} = Path.join(__DIR__, "/../../../../data/cldr-core/supplemental/plurals.json") 
    |> File.read! 
    |> Poison.decode
  @cardinal_rules json["supplemental"]["plurals-type-cardinal"]
  
  @doc """
  The locales for which cardinal rules are defined
  """
  @cardinal_rules_locales Map.keys(@cardinal_rules) |> Enum.sort
  def known_locales do
    @cardinal_rules_locales
  end
  
  @doc """
  The configured locales for which plural rules are defined
  
  This is the intersection of the Cldr.known_locales and the locales for
  which plural rules are defined.  There are many Cldr locales which
  don't have their own plural rules so this list is the intersection
  of Cldr's configured locales and those that have rules.
  """
  @configured_locales  MapSet.intersection(MapSet.new(@cardinal_rules_locales), MapSet.new(Cldr.known_locales)) 
  |> MapSet.to_list
  |> Enum.sort
  
  def configured_locales do
    @configured_locales
  end
  
  @doc """
  The cardinal plural rules defined in CLDR.
  """
  @spec cardinal_rules :: Map.t
  def cardinal_rules do
    @cardinal_rules
  end
  
  @doc """
  Scan a rule definition
  
  Using a leex lexer, tokenize a rule definition
  """
  def tokenize(definition) when is_binary(definition) do
    String.to_charlist(definition) |> :plural_rules_lexer.string
  end
  
  @doc """
  Parse a rule definition
  
  Using a yexx lexer, parse a rule definition into an Elixir
  AST that can then be `unquoted` into a function definition.
  """
  def parse(tokens) when is_list(tokens) do
    :plural_rules_parser.parse tokens
  end
  
  def parse(definition) when is_binary(definition) do
    {:ok, tokens, _end_line} = tokenize(definition) 
    tokens |> :plural_rules_parser.parse
  end
end