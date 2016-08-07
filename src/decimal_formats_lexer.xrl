% Tokenizes CLDR decimal formats which are described at
% http://unicode.org/reports/tr35/tr35-numbers.html#Number_Format_Patterns
Definitions.

Number                 = ([@#,]*)?([0-9]+)?(\.[0-9]+([#,]+)?)
Whitespace              = [\s\n\t]

Rules.

% {Equals}                : {token,{equals,TokenLine,TokenChars}}.
{Whitespace}+           : skip_token.

Erlang code.
