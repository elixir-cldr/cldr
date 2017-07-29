% Tokenizes CLDR date and time formats which are described at
% http://unicode.org/reports/tr35/tr35-dates.html

Definitions.

Era                 = G

YearNumeric         = y
YearWeek            = Y
YearExtended        = u
CyclicYear          = U
RelatedYear         = r

Quarter             = q
StandAloneQuarter   = Q

Month               = M
StandAloneMonth     = L

WeekOfYear          = w
WeekOfMonth         = W

DayOfMonth          = d
DayOfYear           = D
DayOfWeekInMonth    = F

WeekdayName         = E
WeekdayNumber       = e
StandAloneDayOfWeek = c

Period              = [abB]

Hour12              = [hK]
Hour24              = [Hk]

Minute              = m

Second              = s
FractionalSecond    = S

ShortZone           = z
LongZone            = Z
GMT_Zone            = O
GenericZone         = v
ZoneID              = V
ISO_ZoneZ           = X
ISO_Zone            = x

Quote               = ''
Quoted              = '[^']+'
Char                = [^a-zA-Z']

Rules.

{Era}+                   : {token,{era,TokenLine,count(TokenChars)}}.

{YearNumeric}+           : {token,{year_numeric,TokenLine,count(TokenChars)}}.
{YearWeek}+              : {token,{year_week_relative,TokenLine,count(TokenChars)}}.
{YearExtended}+          : {token,{year_extended,TokenLine,count(TokenChars)}}.
{CyclicYear}+            : {token,{year_cyclic,TokenLine,count(TokenChars)}}.
{RelatedYear}+           : {token,{year_related,TokenLine,count(TokenChars)}}.

{Quarter}+               : {token,{quarter,TokenLine,count(TokenChars)}}.
{StandAloneQuarter}+     : {token,{quarter_standalone,TokenLine,count(TokenChars)}}.

{Month}+                 : {token,{month,TokenLine,count(TokenChars)}}.
{StandAloneMonth}+       : {token,{month_standalone,TokenLine,count(TokenChars)}}.

{WeekOfYear}+            : {token,{week_of_year,TokenLine,count(TokenChars)}}.
{WeekOfMonth}+           : {token,{month_week,TokenLine,count(TokenChars)}}.
{DayOfMonth}+            : {token,{day_of_month,TokenLine,count(TokenChars)}}.
{DayOfYear}+             : {token,{day_of_year,TokenLine,count(TokenChars)}}.
{DayOfWeekInMonth}+      : {token,{day_of_week_in_month,TokenLine,count(TokenChars)}}.

{WeekdayName}+           : {token,{weekday_name,TokenLine,count(TokenChars)}}.
{WeekdayNumber}+         : {token,{weekday_number,TokenLine,count(TokenChars)}}.
{StandAloneDayOfWeek}+   : {token,{standalone_day_of_week,TokenLine,count(TokenChars)}}.
{Period}+                : {token,{period,TokenLine,count(TokenChars)}}.

{Hour12}+                : {token,{hour_12,TokenLine,count(TokenChars)}}.
{Hour24}+                : {token,{hour_24,TokenLine,count(TokenChars)}}.
{Minute}+                : {token,{minute,TokenLine,count(TokenChars)}}.

{Second}+                : {token,{second,TokenLine,count(TokenChars)}}.
{FractionalSecond}+      : {token,{fractional_second,TokenLine,count(TokenChars)}}.

{ShortZone}+             : {token,{zone_short,TokenLine,count(TokenChars)}}.
{LongZone}+              : {token,{zone_long,TokenLine,count(TokenChars)}}.
{GMT_Zone}+              : {token,{zone_gmt,TokenLine,count(TokenChars)}}.
{GenericZone}+           : {token,{zone_generic,TokenLine,count(TokenChars)}}.
{ZoneID}+                : {token,{zone_id,TokenLine,count(TokenChars)}}.
{ISO_ZoneZ}+             : {token,{zone_iso_z,TokenLine,count(TokenChars)}}.
{ISO_Zone}+              : {token,{zone_iso,TokenLine,count(TokenChars)}}.

{Quoted}                 : {token,{literal,TokenLine,'Elixir.List':to_string(unquote(TokenChars))}}.
{Quote}                  : {token,{literal,TokenLine,<<"'">>}}.
{Char}+                  : {token,{literal,TokenLine,'Elixir.List':to_string(TokenChars)}}.

Erlang code.

-import('Elixir.List', [to_string/1]).

count(Chars) -> string:len(Chars).

unquote([_ | Tail]) ->
  [_ | Rev] = lists:reverse(Tail),
  lists:reverse(Rev).
