% Lexer for the ICU/CLDR Rule Based Number Formatting rule definitions.
% Step 1 is to read in the json rule set.
% Then for each ruleset, pass each rule to the parser in two parts:
%   First the rule name
%   THen the rule definition
%
% Can be invoked in elixir as:
%
%   iex> :rbnf.string(rule_part_as_a_char_list)
%
% Note the part about being a char_list since thats what Erlang expects.

Definitions.

Rule_minus              = -x
Rule_improper_fraction  = x.x
Rule_proper_fraction    = 0.x
Rule_master_fraction    = x.0
Rule_infinity           = Inf
Rule_nan                = NaN
Rule_numeric            = [0-9\/]+

Rule_cardinal_start     = \$\(cardinal,
Rule_ordinal_start      = \$\(ordinal,
Rule_cardord_end        = \)\$
Plural_rules            = (one\{.+})(two\{.+\})?(few\{.+\})?(other\{.+\})?

Rule_name               = (%[%a-zA-Z\-]+)
Number_format           = (0|#)[0#,]+\.?[0#]+([eE][-+]?[0#]+)?
Conditional_start       = \[
Conditional_end         = \]
Greater_than            = >
Less_than               = <
Equals                  = =
Semicolon               = ;
Colon                   = :
Text                    = [a-zA-Z0-9\s\-\.]

Rules.

% We're using a common parser for both the rule declaration and its definition.
% This part is for the declarations.
{Rule_minus}              : {token,{rule_minus,TokenLine,TokenChars}}.
{Rule_improper_fraction}  : {token,{rule_improper_fraction,TokenLine,TokenChars}}.
{Rule_proper_fraction}    : {token,{rule_proper_fraction,TokenLine,TokenChars}}.
{Rule_master_fraction}    : {token,{rule_master_fraction,TokenLine,TokenChars}}.
{Rule_infinity}           : {token,{rule_infinity,TokenLine,TokenChars}}.
{Rule_nan}                : {token,{rule_nan,TokenLine,TokenChars}}.
{Rule_numeric}            : {token,{rule_numeric,TokenLine,get_range_and_radix(TokenChars)}}.
{Rule_nan}                : {token,{rule_nan,TokenLine,TokenChars}}.
{Plural_rules}            : {token,{plural_rules,TokenLine,TokenChars}}.

% This part is for the definitions.
{Text}+                   : {token,{text,TokenLine,TokenChars}}.
{Rule_name}               : {token,{rule_name,TokenLine,TokenChars}}.
{Number_format}           : {token,{number_format,TokenLine,TokenChars}}.
{Conditional_start}       : {token,{conditional_start,TokenLine,TokenChars}}.       
{Conditional_end}         : {token,{conditional_end,TokenLine,TokenChars}}.
{Greater_than}            : {token,{greater,TokenLine,TokenChars}}.
{Less_than}               : {token,{less,TokenLine,TokenChars}}.
{Equals}                  : {token,{equals,TokenLine,TokenChars}}.
{Semicolon}               : {token,{semicolon,TokenLine,TokenChars}}.
{Rule_cardinal_start}     : {token,{rule_cardinal_start,TokenLine,TokenChars}}.
{Rule_ordinal_start}      : {token,{rule_ordinal_start,TokenLine,TokenChars}}.
{Rule_cardord_end}        : {token,{rule_card_ord_end,TokenLine,TokenChars}}.

Erlang code.

get_range_and_radix(TokenChars) ->
    case string:tokens(TokenChars, "/") of
        [Range | []] ->
            {Ra, _} = string:to_integer(Range),
            Rx = Ra,
            [Ra, Rx];
        [Range | [Radix]] ->
            {Ra, _} = string:to_integer(Range),
            {Rx, _} = string:to_integer(Radix),
            [Ra, Rx]
    end.