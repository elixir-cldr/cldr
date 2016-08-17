% Parse CLDR decimal formats which are described at
% http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns

Nonterminals decimal_format positive_format negative_format number_format prefix suffix
  literal_list literal_elem.

Terminals plus minus format currency percent permille literal semicolon pad.

Rootsymbol decimal_format.

decimal_format    ->  positive_format semicolon negative_format : [{positive, '$1'}, {negative, '$3'}].
decimal_format    ->  positive_format : [{positive, '$1'}, {negative, nil}].

positive_format   ->  prefix number_format suffix : '$1' ++ format('$2') ++ '$3'.
positive_format   ->  prefix number_format : '$1' ++ format('$2').
positive_format   ->  number_format suffix : format('$1') ++ '$2'.
positive_format   ->  number_format :  format('$1').

negative_format   ->  prefix number_format suffix : '$1' ++ neg_format('$2') ++ '$3'.
negative_format   ->  prefix number_format : '$1' ++ neg_format('$2').
negative_format   ->  number_format suffix : neg_format('$1') ++ '$2'.
negative_format   ->  number_format :  neg_format('$1').

number_format     ->  format : unwrap('$1').

prefix            ->  literal_list pad : '$1' ++ pad('$2').
prefix            ->  pad literal_list : pad('$1') ++ '$2'.
prefix            ->  literal_list : '$1'.
prefix            ->  pad : pad('$1').

suffix            ->  prefix : '$1'.

literal_list      ->  literal_elem literal_list : append('$1', '$2').
literal_list      ->  literal_elem : '$1'.

literal_elem      ->  currency : [{currency, unwrap('$1')}].
literal_elem      ->  percent :  [{percent, unwrap('$1')}].
literal_elem      ->  permille : [{permille, unwrap('$1')}].
literal_elem      ->  literal :  [{literal, unwrap('$1')}].
literal_elem      ->  plus  : [{plus, "+"}].
literal_elem      ->  minus : [{minus, "-"}].

Erlang code.

% Append list items.  Consolidate literals if possible into
% a single list element.
append([{literal, Literal1}], [{literal, Literal2} | Rest]) ->
  [{literal, list_to_binary([Literal1, Literal2])}] ++ Rest;
append(A, B) when is_list(A) and is_list(B) ->
  A ++ B.
  
format(F) ->
  [{format, F}].
  
% Doesn't matter what the negative format is
% its always the same as the positive one
% with potentially different suffix and prefix
neg_format(_F) ->
  [{format, same_as_positive}].
  
pad(V) ->
  [{pad, unwrap(V)}].
  
% Return a token value
unwrap({_,_,V}) when is_list(V) -> unicode:characters_to_binary(V);
unwrap({_,_,V}) -> V.
  