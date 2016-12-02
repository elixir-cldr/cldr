% Lexer for the ICU/CLDR Rule Based Number Formatting rule definitions.
% Step 1 is to read in the json rule set.
% Then for each ruleset, pass each rule to the parser in two parts:
%   First the rule name
%   THen the rule definition
%
% Can be invoked in elixir as:
%
%   iex> :rbnf.string(rules_set_as_a_char_list)
%

Definitions.

Rule_cardinal_start     = (cardinal)
Rule_ordinal_start      = (ordinal)
Plural_rules            = (zero\{.+\})?(one\{.+\})?(two\{.+\})?(few\{.+\})?(many\{.+\})?(other\{.+\})?

Rule_name               = (%[%a-zA-Z0-9\-]+)
Number_format           = ([0#]([0#,]+)?)(\.([0#]+))?([eE]([-+]?[0#]+))?
Conditional_start       = \[
Conditional_end         = \]
Left_paren              = \(
Right_paren             = \)
Greater_than            = [→>]
Less_than               = [←<]
Equals                  = =
Dollar                  = \$
Semicolon               = ;
Comma                   = ,
Char                    = .

Rules.

% This part is for the definitions.
{Rule_cardinal_start}     : {token,{rule_cardinal_start,TokenLine,TokenChars}}.
{Rule_ordinal_start}      : {token,{rule_ordinal_start,TokenLine,TokenChars}}.
{Number_format}           : {token,{number_format,TokenLine,TokenChars}}.
{Rule_name}               : {token,{rule_name,TokenLine,TokenChars}}.
{Conditional_start}       : {token,{conditional_start,TokenLine,TokenChars}}.
{Conditional_end}         : {token,{conditional_end,TokenLine,TokenChars}}.
{Greater_than}            : {token,{modulo_call,TokenLine,TokenChars}}.
{Less_than}               : {token,{quotient_call,TokenLine,TokenChars}}.
{Equals}                  : {token,{rule_call,TokenLine,TokenChars}}.
{Semicolon}               : {token,{rule_end,TokenLine,TokenChars}}.
{Plural_rules}            : {token,{plural_rules,TokenLine,TokenChars}}.
{Right_paren}             : {token,{right_paren,TokenLine,TokenChars}}.
{Left_paren}              : {token,{left_paren,TokenLine,TokenChars}}.
{Dollar}                  : {token,{dollar,TokenLine,TokenChars}}.
{Comma}                   : {token,{comma,TokenLine,TokenChars}}.
{Char}                    : {token,{char,TokenLine,TokenChars}}.

Erlang code.
