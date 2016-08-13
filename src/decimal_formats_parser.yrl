% Parse CLDR decimal formats which are described at
% http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns

Nonterminals decimal_format positive_format negative_format number_format prefix suffix
  literal_list literal_elem.

Terminals plus minus format currency percent permille literal semicolon pad.

Rootsymbol decimal_format.

decimal_format    ->  positive_format semicolon negative_format : [{positive, '$1'}, {negative, '$3'}].
decimal_format    ->  positive_format : [{positive, '$1'}, {negative, nil}].

positive_format   ->  prefix number_format suffix : '$1' ++ format('$2') ++ '$3'.
positive_format   ->  prefix number_format : '$1' ++ format('$2') ++ suffix(nil).
positive_format   ->  number_format suffix : prefix(nil) ++ format('$1') ++ '$2'.
positive_format   ->  number_format :        prefix(nil) ++ format('$1') ++ suffix(nil).

negative_format   ->  positive_format : '$1'.

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
  [{literal, Literal1 ++ Literal2}] ++ Rest;
append(A, B) when is_list(A) and is_list(B) ->
  A ++ B.
  
format(F) ->
  [{format, F}].
  
pad(V) ->
  [{pad, unwrap(V)}].
  
prefix(V) ->
  [{prefix, V}].

suffix(V) ->
  [{suffix, V}].
  
% Return a token value
unwrap({_,_,V}) -> V.