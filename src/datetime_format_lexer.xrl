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

Period_am_pm        = a
Period_noon_mid     = b
Period_flex         = B

Hour_0_11           = K
Hour_1_12           = h
Hour_0_23           = H
Hour_1_24           = k

Minute              = m

Second              = s
FractionalSecond    = S

ShortZone           = z
BasicZone           = Z
GMT_Zone            = O
GenericZone         = v
ZoneID              = V
ISO_ZoneZ           = X
ISO_Zone            = x

Date                = ({1})
Time                = ({0})

Quote               = ''
Quoted              = '[^']+'
Char                = [^a-zA-Z{}']

Rules.

{Era}+                   : {token,{era,TokenLine,count(TokenChars)}}.

{YearNumeric}+           : {token,{year,TokenLine,count(TokenChars)}}.
{YearWeek}+              : {token,{week_aligned_year,TokenLine,count(TokenChars)}}.
{YearExtended}+          : {token,{extended_year,TokenLine,count(TokenChars)}}.
{CyclicYear}+            : {token,{cyclic_year,TokenLine,count(TokenChars)}}.
{RelatedYear}+           : {token,{related_year,TokenLine,count(TokenChars)}}.

{Quarter}+               : {token,{quarter,TokenLine,count(TokenChars)}}.
{StandAloneQuarter}+     : {token,{standalone_quarter,TokenLine,count(TokenChars)}}.

{Time}                   : {token,{time,TokenLine,0}}.
{Date}                   : {token,{date,TokenLine,0}}.

{Month}+                 : {token,{month,TokenLine,count(TokenChars)}}.
{StandAloneMonth}+       : {token,{standalone_month,TokenLine,count(TokenChars)}}.

{WeekOfYear}+            : {token,{week_of_year,TokenLine,count(TokenChars)}}.
{WeekOfMonth}+           : {token,{week_of_month,TokenLine,count(TokenChars)}}.
{DayOfMonth}+            : {token,{day_of_month,TokenLine,count(TokenChars)}}.
{DayOfYear}+             : {token,{day_of_year,TokenLine,count(TokenChars)}}.
{DayOfWeekInMonth}+      : {token,{day_of_week_in_month,TokenLine,count(TokenChars)}}.

{WeekdayName}+           : {token,{day_name,TokenLine,count(TokenChars)}}.
{WeekdayNumber}+         : {token,{day_of_week,TokenLine,count(TokenChars)}}.
{StandAloneDayOfWeek}+   : {token,{standalone_day_of_week,TokenLine,count(TokenChars)}}.

{Period_am_pm}+          : {token,{period_am_pm,TokenLine,count(TokenChars)}}.
{Period_noon_mid}+       : {token,{period_noon_mid,TokenLine,count(TokenChars)}}.
{Period_flex}+           : {token,{period_flex,TokenLine,count(TokenChars)}}.

{Hour_1_12}+             : {token,{hour_1_12,TokenLine,count(TokenChars)}}.
{Hour_0_11}+             : {token,{hour_0_11,TokenLine,count(TokenChars)}}.
{Hour_1_24}+             : {token,{hour_1_24,TokenLine,count(TokenChars)}}.
{Hour_0_23}+             : {token,{hour_0_23,TokenLine,count(TokenChars)}}.

{Minute}+                : {token,{minute,TokenLine,count(TokenChars)}}.
{Second}+                : {token,{second,TokenLine,count(TokenChars)}}.
{FractionalSecond}+      : {token,{fractional_second,TokenLine,count(TokenChars)}}.

{ShortZone}+             : {token,{zone_short,TokenLine,count(TokenChars)}}.
{BasicZone}+             : {token,{zone_basic,TokenLine,count(TokenChars)}}.
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
