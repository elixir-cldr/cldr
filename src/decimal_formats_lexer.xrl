% Tokenizes CLDR decimal formats which are described at
% http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns
Definitions.

Number                = ([@#,]*)?([0-9]+)?(\.[0-9]+([#,]+)?([Ee][0-9]+)?)?
Percent               = %
Permille              = ‰
Plus                  = \+
Minus                 = \-
Semicolon             = ;
Currency              = ¤+
Pad                   = x.
Quote                 = \'.\'
Literal               = [^@#0-9¤\+\-;%\']+


Rules.

{Number}              : {token,{format,TokenLine,TokenChars}}.
{Percent}             : {token,{percent,TokenLine,TokenChars}}.
{Permille}            : {token,{permille,TokenLine,TokenChars}}.
{Plus}                : {token,{plus,TokenLine,TokenChars}}.
{Minus}               : {token,{minus,TokenLine,TokenChars}}.
{Semicolon}           : {token,{semicolon,TokenLine,TokenChars}}.
{Currency}            : {token,{currency,TokenLine,TokenChars}}.
{Pad}                 : {token,{pad,TokenLine,TokenChars}}.
{Quote}               : {token,{quote,TokenLine,TokenChars}}.
{Literal}             : {token,{literal,TokenLine,TokenChars}}.


Erlang code.
