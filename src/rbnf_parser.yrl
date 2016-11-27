Nonterminals quotient_rule modulo_rule invoke_rule

Terminals rule_cardinal_start rule_ordinal_start format_call
          rule_name conditional_start conditional_end modulo_call
          quotient_call rule_call rule_end plural_rules right_paren
          left_paren dollar comma literal others

Rootsymbol rbnf_rule.

quotient_rule     ->  quotient_call rule quotient_rule.
modulo_rule       ->  modulo_call rule modulo_rule.
invoke_rule       ->  equal rule equal.

rule              ->  rule_name.
rule              ->  format_call.


literal_list      ->  literal literal_list : append('$1', '$2').
literal_list      ->  literal : '$1'.

Erlang code.

% Append list items.  Consolidate literals if possible into
% a single list element.
append([{literal, Literal1}], [{literal, Literal2} | Rest]) ->
  [{literal, list_to_binary([Literal1, Literal2])}] ++ Rest;
append(A, B) when is_list(A) and is_list(B) ->
  A ++ B.

% Return a token value
unwrap({_,_,V}) when is_list(V) -> unicode:characters_to_binary(V);
unwrap({_,_,V}) -> V.
