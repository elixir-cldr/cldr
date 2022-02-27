% Parse the CLDR Plural Rules definitions and return an Elixir AST
% Rules syntax and semantics are defined in
% http://unicode.org/reports/tr35/tr35-numbers.html#Language_Plural_Rules
%
% condition     = and_condition ('or' and_condition)*
% samples       = ('@integer' sampleList)?
%                 ('@decimal' sampleList)?
% and_condition = relation ('and' relation)*
% relation      = is_relation | in_relation | within_relation
% is_relation   = expr 'is' ('not')? value
% in_relation   = expr (('not')? 'in' | '=' | '!=') range_list
% within_relation = expr ('not')? 'within' range_list
% expr          = operand (('mod' | '%') value)?
% operand       = 'n' | 'i' | 'f' | 't' | 'v' | 'w'
% range_list    = (range | value) (',' range_list)*
% range         = value'..'value
% sampleList    = sampleRange (',' sampleRange)* (',' ('…'|'...'))?
% sampleRange   = decimalValue ('~' decimalValue)?
% value         = digit+
% decimalValue  = value ('.' value)?
% digit         = 0|1|2|3|4|5|6|7|8|9

Nonterminals plural_rule condition and_condition relation is_relation in_relation within_relation
conditional expression range_list range_or_value range value samples sample_list sample_range.

Terminals mod is_op not_op sample operand tilde or_predicate and_predicate range_op
comma decimal integer ellipsis equals in within_op not_equals.

Rootsymbol plural_rule.

Right     100   mod.
Nonassoc  200   equals not_equals.
Left      300   and_predicate.
Left      400   or_predicate.

plural_rule       ->  condition samples : append({rule, '$1'}, '$2').
plural_rule       ->  condition : [{rule, '$1'}].
plural_rule       ->  samples : '$1'.

condition         ->  and_condition or_predicate condition : or_function('$1', '$3').
condition         ->  and_condition : '$1'.

and_condition     ->  relation and_predicate and_condition : and_function('$1', '$3').
and_condition     ->  relation : '$1'.

relation          ->  is_relation : '$1'.
relation          ->  in_relation : '$1'.
relation          ->  within_relation : '$1'.

is_relation       ->  expression is_op value : or_range_list('$1', '$3').
is_relation       ->  expression is_op not_op value : not_function(or_range_list('$1', '$4')).

in_relation       ->  expression not_equals range_list : not_function(or_range_list('$1', '$3')).
in_relation       ->  expression conditional range_list : or_range_list('$1', '$3').
in_relation       ->  expression not_op in range_list : not_function(or_range_list('$1', '$4')).

within_relation   ->  expression within_op range_list : or_range_list('$1', '$3').
within_relation   ->  expression not_op within_op range_list : not_function(or_range_list('$1', '$4')).

conditional       ->  in : 'in'.
conditional       ->  equals : '='.

% TODO It would be good to keep track of the operands used so we only generate those ones
% TODO We need to generate variables for the mod expressions to avoid duplicate calculations too
expression        ->  operand mod value : mod('$1', '$3').
expression        ->  operand : operand('$1').

range_list        ->  range_or_value comma range_list : append('$1', '$3').
range_list        ->  range_or_value : '$1'.

range_or_value    ->  range : '$1'.
range_or_value    ->  value : '$1'.

range             ->  value range_op value : range('$1', '$3').

value             ->  integer : unwrap('$1').
value             ->  decimal : unwrap('$1').

samples           ->  sample sample_list samples : append({unwrap('$1'), '$2'}, '$3').
samples           ->  sample sample_list : [{unwrap('$1'), '$2'}].

sample_list       ->  sample_range comma sample_list : append('$1', '$3').
sample_list       ->  sample_range : ['$1'].

sample_range      ->  value tilde value : range('$1', '$3').
sample_range      ->  value : '$1'.
sample_range      ->  ellipsis : 'ellipsis'.

Erlang code.

-export([kernel_context/0]).

% mod function will calculate the modulo in Java fashion
% for floats and decimals so that mod(4.3, 3) == 1.3
% The function itself is defined in Cldr.Math
mod(Operand, Value) ->
  {'mod', kernel_context(), [operand(Operand), Value]}.

% Return a reference to an operand
operand(Operand) ->
  {atomize(Operand), [], 'Elixir'}.

% 'and' function
and_function(A, B) ->
  {'and', kernel_context(), [A, B]}.

% 'or' function
or_function(A, B) ->
  {'or', kernel_context(), [A, B]}.

% 'not' function
not_function(A) ->
  {'!', kernel_context(), [A]}.

% Range syntax
range(Start, End) ->
  {'..', kernel_context(), [Start, End]}.

% Inclusion forms
% -> for a range. call a helper function `within`
% so we can handle integers and floats/decimals
% separately
conditional(equals, A, B = {'..', _C, [_From, _To]}) ->
  {'within', kernel_context(), [A, B]};

% -> for an expression
% NOTE this will calculate the expression each time which is
% inefficient.  But parser isn't the right place to unwrap that.

% NOTE REMOVED DUE TO DIALYZER ERROR saying this can never match.
% tests still pass without it.
% conditional({'mod', [_C], [{_L}]}, A, B) ->
%  {'==', kernel_context(), [A, B]};

% -> for a value
conditional(equals, A, B) ->
  {'==', kernel_context(), [A, B]}.

% Convert a range list into a postfix 'or' form
% Just two items in the list
or_range_list(Operand, [A, B]) ->
  or_function(conditional(equals, Operand, A),
              conditional(equals, Operand, B));

% Many items in a list
or_range_list(Operand, [A | B]) ->
  or_function(conditional(equals, Operand, A),
              or_range_list(Operand, B));

% When there's only one value
or_range_list(Operand, Value) ->
  conditional(equals, Operand, Value).

% Append to build up a list of ranges or values
append(A, B) when is_list(A) and is_list(B) ->
  A ++ B;

append(A, B) when is_list(A) and not is_list(B)->
  A ++ [B];

append(A, B) when not is_list(A) and is_list(B) ->
  [A] ++ B;

append(A, B) when not is_list(A) and not is_list(B) ->
  [A, B].

% Return a token value
unwrap({_,_,V}) -> V.

% Elixir Kernel Context
kernel_context() ->
  [{context, 'Elixir'}, {import, 'Elixir.Kernel'}].

% Atomize a token value
atomize(Token) ->
  list_to_atom(unwrap(Token)).

