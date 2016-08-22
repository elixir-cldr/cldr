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

Rule_cardinal_start     = \$\(cardinal,
Rule_ordinal_start      = \$\(ordinal,
Rule_cardord_end        = \)\$
Plural_rules            = (zero\{.+\})?(one\{.+\})?(two\{.+\})?(few\{.+\})?(many\{.+\})?(other\{.+\})?

Rule_name               = (%[%a-zA-Z\-]+)
Number_format           = ([0#]([0#,]+)?)(\.([0#]+))?([eE]([-+]?[0#]+))?
Conditional_start       = \[
Conditional_end         = \]
Greater_than            = →
Less_than               = ←
Equals                  = =
Semicolon               = ;
Literal                 = [^→←=\[\]\n\t\$]
Whitespace              = [\s\n\t]

Rules.

% We're using a common lexer for both the rule declaration and its definition.
% This part is for the declarations.
{Plural_rules}            : {token,{plural_rules,TokenLine,TokenChars}}.

% This part is for the definitions.
{Number_format}           : {token,{number_format,TokenLine,TokenChars}}.
{Rule_name}               : {token,{rule_name,TokenLine,TokenChars}}.
{Conditional_start}       : {token,{conditional_start,TokenLine,TokenChars}}.
{Conditional_end}         : {token,{conditional_end,TokenLine,TokenChars}}.
{Greater_than}            : {token,{modulo_call,TokenLine,TokenChars}}.
{Less_than}               : {token,{quotient_call,TokenLine,TokenChars}}.
{Equals}                  : {token,{rule_call,TokenLine,TokenChars}}.
{Semicolon}               : {token,{rule_end,TokenLine,TokenChars}}.
{Rule_cardinal_start}     : {token,{rule_cardinal_start,TokenLine,TokenChars}}.
{Rule_ordinal_start}      : {token,{rule_ordinal_start,TokenLine,TokenChars}}.
{Rule_cardord_end}        : {token,{rule_card_ord_end,TokenLine,TokenChars}}.
{Literal}+                : {token,{literal,TokenLine,TokenChars}}.
{Whitespace}+             : skip_token.

Erlang code.
