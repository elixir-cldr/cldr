Nonterminals quotient_rule modulo_rule invoke_rule cardinal_rule ordinal_rule
          rule literal rbnf_rule rule_part character.

Terminals rule_cardinal_start rule_ordinal_start number_format
          rule_name conditional_start conditional_end modulo_call
          quotient_call rule_call plural_rules right_paren
          left_paren dollar comma char.

Rootsymbol rbnf_rule.

Left      100   rbnf_rule.
Right     400   modulo_call.
Right     500   quotient_call.
Right     600   character.

rbnf_rule         -> rule_part rbnf_rule : ['$1'] ++ '$2'.
rbnf_rule         -> rule_part : ['$1'].

rule_part         -> literal : '$1'.
rule_part         -> quotient_rule : '$1'.
rule_part         -> modulo_rule : '$1'.
rule_part         -> invoke_rule : '$1'.
rule_part         -> cardinal_rule : '$1'.
rule_part         -> ordinal_rule : '$1'.
rule_part         -> conditional_start rbnf_rule conditional_end : {conditional, '$2'}.

quotient_rule     ->  quotient_call rule quotient_call quotient_call : {quotient, '$2'}.
quotient_rule     ->  quotient_call rule quotient_call : {quotient, '$2'}.
quotient_rule     ->  quotient_call quotient_call : {quotient, nil}.

modulo_rule       ->  modulo_call rule modulo_call : {modulo, '$2'}.
modulo_rule       ->  modulo_call modulo_call : {modulo, nil}.

% Note that here we are treating >>> as equivalent to >>
% This is not strictly true since the spec says we should
% ... but bypass the normal rule-selection process and just
% use the rule that precedes this one in this rule list.
modulo_rule       ->  modulo_call modulo_call modulo_call : {modulo, nil}.


invoke_rule       ->  rule_call rule rule_call : {call, '$2'}.

cardinal_rule     ->  dollar left_paren rule_cardinal_start comma
                      plural_rules right_paren dollar : {cardinal, to_map('$5')}.
ordinal_rule      ->  dollar left_paren rule_ordinal_start comma
                      plural_rules right_paren dollar : {ordinal, to_map('$5')}.

rule              ->  rule_name : {rule, normalize_rule_name('$1')}.
rule              ->  number_format : {format, unwrap('$1')}.

literal           ->  character literal : append('$1', '$2').
literal           ->  character : {literal, unwrap('$1')}.

character         ->  char : '$1'.
character         ->  comma : '$1'.
character         ->  number_format : '$1'.

Erlang code.

% Consolidate characters into a binary
append({char, _, _} = Char, {literal, Literal}) ->
  {literal, list_to_binary([unwrap(Char), Literal])};
append({comma, _, _} = Char, {literal, Literal}) ->
  {literal, list_to_binary([unwrap(Char), Literal])};
append({number_format, _, _} = Char, {literal, Literal}) ->
  {literal, list_to_binary([unwrap(Char), Literal])};
append({literal, Literal1}, {literal, Literal2}) ->
  {literal, list_to_binary([Literal2, Literal1])}.

% We will turn rule names into functions later on so
% we normalise the names to a format that is acceptable.
normalize_rule_name({_,_,[$%, $% | Name]}) ->
  erlang:binary_to_atom(unicode:characters_to_binary(underscore(Name)), utf8);
normalize_rule_name({_,_,[$% | Name]}) ->
  erlang:binary_to_atom(unicode:characters_to_binary(underscore(Name)), utf8).

% Return a token value as a binary
unwrap({_,_,V}) when is_list(V) -> unicode:characters_to_binary(V);
unwrap({_,_,V}) -> V.

% Substitute "_" for "-" since we will use these rule names
% as functions later on.
underscore([$-| Rest]) ->
  [$_ | underscore(Rest)];
underscore([]) ->
  [];
underscore([Char | Rest]) ->
  [Char | underscore(Rest)].

% Convert ordinal and cardinal rules into a map
to_map(Plurals) ->
  String = unwrap(Plurals),
  Parts = binary:split(String, [<<"{">>,<<"}">>], [global, trim]),
  Proplist = to_proplist(Parts),
  maps:from_list(Proplist).

% Convert a list into a proplist
to_proplist([K,V | T]) -> [{erlang:binary_to_atom(K, utf8),V} | to_proplist(T)];
to_proplist([]) -> [].