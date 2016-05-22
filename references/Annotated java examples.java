0001:        /* http://www.1java2c.com/Open-Source/Java-Document/Internationalization-Localization/icu4j/com/ibm/icu/dev/demo/rbnf/RbnfSampleRuleSets.java.htm#ordinal

0002:         *******************************************************************************
0003:         * Copyright (C) 1996-2004, International Business Machines Corporation and    *
0004:         * others. All Rights Reserved.                                                *
0005:         *******************************************************************************
0006:         */
0007:        package com.ibm.icu.dev.demo.rbnf;
0008:
0009:        import java.util.Locale;
0010:
0011:        /**
0012:         * A collection of example rule sets for use with RuleBasedNumberFormat.
0013:         * These examples are intended to serve both as demonstrations of what can
0014:         * be done with this framework, and as starting points for designing new
0015:         * rule sets.
0016:         *
0017:         * For those that claim to represent number-spellout rules for languages
0018:         * other than U.S. English, we make no claims of either accuracy or
0019:         * completeness.  In fact, we know them to be incomplete, and suspect
0020:         * most have mistakes in them.  If you see something that you know is wrong,
0021:         * please tell us!
0022:         *
0023:         * @author Richard Gillam
0024:         */
0025:        public class RbnfSampleRuleSets {
0026:            /**
0027:             * Puts a copyright in the .class file
0028:             */
0029:            private static final String copyrightNotice = "Copyright \u00a91997-1998 IBM Corp.  All rights reserved.";
0030:
0031:            //========================================================================
0032:            // Spellout rules for various languages
0033:            //
0034:            // The following RuleBasedNumberFormat descriptions show the rules for
0035:            // spelling out numeric values in various languages.  As mentioned
0036:            // before, we cannot vouch for the accuracy or completeness of this
0037:            // data, although we believe it's pretty close.  Basically, this
0038:            // represents one day's worth of Web-surfing.  If you can supply the
0039:            // missing information in any of these rule sets, or if you find errors,
0040:            // or if you can supply spellout rules for languages that aren't shown
0041:            // here, we want to hear from you!
0042:            //========================================================================
0043:
0044:            /**
0045:             * Spellout rules for U.S. English.  This demonstration version of the
0046:             * U.S. English spellout rules has four variants: 1) %simplified is a
0047:             * set of rules showing the simple method of spelling out numbers in
0048:             * English: 289 is formatted as "two hundred eighty-nine".  2) %alt-teens
0049:             * is the same as %simplified, except that values between 1,000 and 9,999
0050:             * whose hundreds place isn't zero are formatted in hundreds.  For example,
0051:             * 1,983 is formatted as "nineteen hundred eighty-three," and 2,183 is
0052:             * formatted as "twenty-one hundred eighty-three," but 2,083 is still
0053:             * formatted as "two thousand eighty-three."  3) %ordinal formats the
0054:             * values as ordinal numbers in English (e.g., 289 is "two hundred eighty-
0055:             * ninth").  4) %default uses a more complicated algorithm to format
0056:             * numbers in a more natural way: 289 is formatted as "two hundred AND
0057:             * eighty-nine" and commas are inserted between the thousands groups for
0058:             * values above 100,000.
0059:             */
0060:            public static final String usEnglish =
0061:            // This rule set shows the normal simple formatting rules for English
0062:            "%simplified:\n"
0063:                    // negative number rule.  This rule is used to format negative
0064:                    // numbers.  The result of formatting the number's absolute
0065:                    // value is placed where the >> is.
0066:                    + "    -x: minus >>;\n"
0067:                    // faction rule.  This rule is used for formatting numbers
0068:                    // with fractional parts.  The result of formatting the
0069:                    // number's integral part is substituted for the <<, and
0070:                    // the result of formatting the number's fractional part
0071:                    // (one digit at a time, e.g., 0.123 is "zero point one two
0072:                    // three") replaces the >>.
0073:                    + "    x.x: << point >>;\n"
0074:                    // the rules for the values from 0 to 19 are simply the
0075:                    // words for those numbers
0076:                    + "    zero; one; two; three; four; five; six; seven; eight; nine;\n"
0077:                    + "    ten; eleven; twelve; thirteen; fourteen; fifteen; sixteen;\n"
0078:                    + "        seventeen; eighteen; nineteen;\n"
0079:                    // beginning at 20, we use the >> to mark the position where
0080:                    // the result of formatting the number's ones digit.  Thus,
0081:                    // we only need a new rule at every multiple of 10.  Text in
0082:                    // backets is omitted if the value being formatted is an
0083:                    // even multiple of 10.
0084:                    + "    20: twenty[->>];\n"
0085:                    + "    30: thirty[->>];\n"
0086:                    + "    40: forty[->>];\n"
0087:                    + "    50: fifty[->>];\n"
0088:                    + "    60: sixty[->>];\n"
0089:                    + "    70: seventy[->>];\n"
0090:                    + "    80: eighty[->>];\n"
0091:                    + "    90: ninety[->>];\n"
0092:                    // beginning at 100, we can use << to mark the position where
0093:                    // the result of formatting the multiple of 100 is to be
0094:                    // inserted.  Notice also that the meaning of >> has shifted:
0095:                    // here, it refers to both the ones place and the tens place.
0096:                    // The meanings of the << and >> tokens depend on the base value
0097:                    // of the rule.  A rule's divisor is (usually) the highest
0098:                    // power of 10 that is less than or equal to the rule's base
0099:                    // value.  The value being formatted is divided by the rule's
0100:                    // divisor, and the integral quotient is used to get the text
0101:                    // for <<, while the remainder is used to produce the text
0102:                    // for >>.  Again, text in brackets is omitted if the value
0103:                    // being formatted is an even multiple of the rule's divisor
0104:                    // (in this case, an even multiple of 100)
0105:                    + "    100: << hundred[ >>];\n"
0106:                    // The rules for the higher numbers work the same way as the
0107:                    // rule for 100: Again, the << and >> tokens depend on the
0108:                    // rule's divisor, which for all these rules is also the rule's
0109:                    // base value.  To group by thousand, we simply don't have any
0110:                    // rules between 1,000 and 1,000,000.
0111:                    + "    1000: << thousand[ >>];\n"
0112:                    + "    1,000,000: << million[ >>];\n"
0113:                    + "    1,000,000,000: << billion[ >>];\n"
0114:                    + "    1,000,000,000,000: << trillion[ >>];\n"
0115:                    // overflow rule.  This rule specifies that values of a
0116:                    // quadrillion or more are shown in numerals rather than words.
0117:                    // The == token means to format (with new rules) the value
0118:                    // being formatted by this rule and place the result where
0119:                    // the == is.  The #,##0 inside the == signs is a
0120:                    // DecimalFormat pattern.  It specifies that the value should
0121:                    // be formatted with a DecimalFormat object, and that it
0122:                    // should be formatted with no decimal places, at least one
0123:                    // digit, and a thousands separator.
0124:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0125:
0126:                    // This rule set formats numbers between 1,000 and 9,999 somewhat
0127:                    // differently: If the hundreds digit is not zero, the first two
0128:                    // digits are treated as a number of hundreds.  For example, 2,197
0129:                    // would come out as "twenty-one hundred ninety-seven."
0130:                    + "%alt-teens:\n"
0131:                    // just use %simplified to format values below 1,000
0132:                    + "    =%simplified=;\n"
0133:                    // values between 1,000 and 9,999 are delegated to %%alt-hundreds
0134:                    // for formatting.  The > after "1000" decreases the exponent
0135:                    // of the rule's radix by one, causing the rule's divisor
0136:                    // to be 100 instead of 1,000.  This causes the first TWO
0137:                    // digits of the number, instead of just the first digit,
0138:                    // to be sent to %%alt-hundreds
0139:                    + "    1000>: <%%alt-hundreds<[ >>];\n"
0140:                    // for values of 10,000 and more, we again just use %simplified
0141:                    + "    10,000: =%simplified=;\n"
0142:                    // This rule set uses some obscure voodoo of the description language
0143:                    // to format the first two digits of a value in the thousands.
0144:                    // The rule at 10 formats the first two digits as a multiple of 1,000
0145:                    // and the rule at 11 formats the first two digits as a multiple of
0146:                    // 100.  This works because of something known as the "rollback rule":
0147:                    // if the rule applicable to the value being formatted has two
0148:                    // substitutions, the value being formatted is an even multiple of
0149:                    // the rule's divisor, and the rule's base value ISN'T an even multiple
0150:                    // if the rule's divisor, then the rule that precedes this one in the
0151:                    // list is used instead.  (The [] notation is implemented internally
0152:                    // using this notation: a rule containing [] is split into two rules,
0153:                    // and the right one is chosen using the rollback rule.) In this case,
0154:                    // it means that if the first two digits are an even multiple of 10,
0155:                    // they're formatted with the 10 rule (containing "thousand"), and if
0156:                    // they're not, they're formatted with the 11 rule (containing
0157:                    // "hundred").  %%empty is a hack to cause the rollback rule to be
0158:                    // invoked: it makes the 11 rule have two substitutions, even though
0159:                    // the second substitution (calling %%empty) doesn't actually do
0160:                    // anything.
0161:                    + "%%alt-hundreds:\n"
0162:                    + "    0: SHOULD NEVER GET HERE!;\n"
0163:                    + "    10: <%simplified< thousand;\n"
0164:                    + "    11: =%simplified= hundred>%%empty>;\n"
0165:                    + "%%empty:\n"
0166:                    + "    0:;"
0167:
0168:                    // this rule set is the same as %simplified, except that it formats
0169:                    // the value as an ordinal number: 234 is formatted as "two hundred
0170:                    // thirty-fourth".  Notice the calls to ^simplified: we have to
0171:                    // call %simplified to avoid getting "second hundred thirty-fourth."
0172:                    + "%ordinal:\n"
0173:                    + "    zeroth; first; second; third; fourth; fifth; sixth; seventh;\n"
0174:                    + "        eighth; ninth;\n"
0175:                    + "    tenth; eleventh; twelfth; thirteenth; fourteenth;\n"
0176:                    + "        fifteenth; sixteenth; seventeenth; eighteenth;\n"
0177:                    + "        nineteenth;\n"
0178:                    + "    twentieth; twenty->>;\n"
0179:                    + "    30: thirtieth; thirty->>;\n"
0180:                    + "    40: fortieth; forty->>;\n"
0181:                    + "    50: fiftieth; fifty->>;\n"
0182:                    + "    60: sixtieth; sixty->>;\n"
0183:                    + "    70: seventieth; seventy->>;\n"
0184:                    + "    80: eightieth; eighty->>;\n"
0185:                    + "    90: ninetieth; ninety->>;\n"
0186:                    + "    100: <%simplified< hundredth; <%simplified< hundred >>;\n"
0187:                    + "    1000: <%simplified< thousandth; <%simplified< thousand >>;\n"
0188:                    + "    1,000,000: <%simplified< millionth; <%simplified< million >>;\n"
0189:                    + "    1,000,000,000: <%simplified< billionth;\n"
0190:                    + "        <%simplified< billion >>;\n"
0191:                    + "    1,000,000,000,000: <%simplified< trillionth;\n"
0192:                    + "        <%simplified< trillion >>;\n"
0193:                    + "    1,000,000,000,000,000: =#,##0=;"
0194:
0195:                    // %default is a more elaborate form of %simplified;  It is basically
0196:                    // the same, except that it introduces "and" before the ones digit
0197:                    // when appropriate (basically, between the tens and ones digits) and
0198:                    // separates the thousands groups with commas in values over 100,000.
0199:                    + "%default:\n"
0200:                    // negative-number and fraction rules.  These are the same
0201:                    // as those for %simplified, but ave to be stated here too
0202:                    // because this is an entry point
0203:                    + "    -x: minus >>;\n"
0204:                    + "    x.x: << point >>;\n"
0205:                    // just use %simplified for values below 100
0206:                    + "    =%simplified=;\n"
0207:                    // for values from 100 to 9,999 use %%and to decide whether or
0208:                    // not to interpose the "and"
0209:                    + "    100: << hundred[ >%%and>];\n"
0210:                    + "    1000: << thousand[ >%%and>];\n"
0211:                    // for values of 100,000 and up, use %%commas to interpose the
0212:                    // commas in the right places (and also to interpose the "and")
0213:                    + "    100,000>>: << thousand[>%%commas>];\n"
0214:                    + "    1,000,000: << million[>%%commas>];\n"
0215:                    + "    1,000,000,000: << billion[>%%commas>];\n"
0216:                    + "    1,000,000,000,000: << trillion[>%%commas>];\n"
0217:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0218:                    // if the value passed to this rule set is greater than 100, don't
0219:                    // add the "and"; if it's less than 100, add "and" before the last
0220:                    // digits
0221:                    + "%%and:\n" + "    and =%default=;\n"
0222:                    + "    100: =%default=;\n"
0223:                    // this rule set is used to place the commas
0224:                    + "%%commas:\n"
0225:                    // for values below 100, add "and" (the apostrophe at the
0226:                    // beginning is ignored, but causes the space that follows it
0227:                    // to be significant: this is necessary because the rules
0228:                    // calling %%commas don't put a space before it)
0229:                    + "    ' and =%default=;\n"
0230:                    // put a comma after the thousands (or whatever preceded the
0231:                    // hundreds)
0232:                    + "    100: , =%default=;\n"
0233:                    // put a comma after the millions (or whatever precedes the
0234:                    // thousands)
0235:                    + "    1000: , <%default< thousand, >%default>;\n"
0236:                    // and so on...
0237:                    + "    1,000,000: , =%default=;"
0238:                    // %%lenient-parse isn't really a set of number formatting rules;
0239:                    // it's a set of collation rules.  Lenient-parse mode uses a Collator
0240:                    // object to compare fragments of the text being parsed to the text
0241:                    // in the rules, allowing more leeway in the matching text.  This set
0242:                    // of rules tells the formatter to ignore commas when parsing (it
0243:                    // already ignores spaces, which is why we refer to the space; it also
0244:                    // ignores hyphens, making "twenty one" and "twenty-one" parse
0245:                    // identically)
0246:                    + "%%lenient-parse:\n" + "    & ' ' , ',' ;\n";
0247:
0248:            /**
0249:             * Spellout rules for U.K. English.  U.K. English has one significant
0250:             * difference from U.S. English: the names for values of 1,000,000,000
0251:             * and higher.  In American English, each successive "-illion" is 1,000
0252:             * times greater than the preceding one: 1,000,000,000 is "one billion"
0253:             * and 1,000,000,000,000 is "one trillion."  In British English, each
0254:             * successive "-illion" is one million times greater than the one before:
0255:             * "one billion" is 1,000,000,000,000 (or what Americans would call a
0256:             * "trillion"), and "one trillion" is 1,000,000,000,000,000,000.
0257:             * 1,000,000,000 in British English is "one thousand million."  (This
0258:             * value is sometimes called a "milliard," but this word seems to have
0259:             * fallen into disuse.)
0260:             */
0261:            public static final String ukEnglish = "%simplified:\n"
0262:                    + "    -x: minus >>;\n"
0263:                    + "    x.x: << point >>;\n"
0264:                    + "    zero; one; two; three; four; five; six; seven; eight; nine;\n"
0265:                    + "    ten; eleven; twelve; thirteen; fourteen; fifteen; sixteen;\n"
0266:                    + "        seventeen; eighteen; nineteen;\n"
0267:                    + "    20: twenty[->>];\n"
0268:                    + "    30: thirty[->>];\n"
0269:                    + "    40: forty[->>];\n"
0270:                    + "    50: fifty[->>];\n"
0271:                    + "    60: sixty[->>];\n"
0272:                    + "    70: seventy[->>];\n"
0273:                    + "    80: eighty[->>];\n"
0274:                    + "    90: ninety[->>];\n"
0275:                    + "    100: << hundred[ >>];\n"
0276:                    + "    1000: << thousand[ >>];\n"
0277:                    + "    1,000,000: << million[ >>];\n"
0278:                    + "    1,000,000,000,000: << billion[ >>];\n"
0279:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0280:                    + "%alt-teens:\n"
0281:                    + "    =%simplified=;\n"
0282:                    + "    1000>: <%%alt-hundreds<[ >>];\n"
0283:                    + "    10,000: =%simplified=;\n"
0284:                    + "    1,000,000: << million[ >%simplified>];\n"
0285:                    + "    1,000,000,000,000: << billion[ >%simplified>];\n"
0286:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0287:                    + "%%alt-hundreds:\n"
0288:                    + "    0: SHOULD NEVER GET HERE!;\n"
0289:                    + "    10: <%simplified< thousand;\n"
0290:                    + "    11: =%simplified= hundred>%%empty>;\n"
0291:                    + "%%empty:\n"
0292:                    + "    0:;"
0293:                    + "%ordinal:\n"
0294:                    + "    zeroth; first; second; third; fourth; fifth; sixth; seventh;\n"
0295:                    + "        eighth; ninth;\n"
0296:                    + "    tenth; eleventh; twelfth; thirteenth; fourteenth;\n"
0297:                    + "        fifteenth; sixteenth; seventeenth; eighteenth;\n"
0298:                    + "        nineteenth;\n"
0299:                    + "    twentieth; twenty->>;\n"
0300:                    + "    30: thirtieth; thirty->>;\n"
0301:                    + "    40: fortieth; forty->>;\n"
0302:                    + "    50: fiftieth; fifty->>;\n"
0303:                    + "    60: sixtieth; sixty->>;\n"
0304:                    + "    70: seventieth; seventy->>;\n"
0305:                    + "    80: eightieth; eighty->>;\n"
0306:                    + "    90: ninetieth; ninety->>;\n"
0307:                    + "    100: <%simplified< hundredth; <%simplified< hundred >>;\n"
0308:                    + "    1000: <%simplified< thousandth; <%simplified< thousand >>;\n"
0309:                    + "    1,000,000: <%simplified< millionth; <%simplified< million >>;\n"
0310:                    + "    1,000,000,000,000: <%simplified< billionth;\n"
0311:                    + "        <%simplified< billion >>;\n"
0312:                    + "    1,000,000,000,000,000: =#,##0=;" + "%default:\n"
0313:                    + "    -x: minus >>;\n" + "    x.x: << point >>;\n"
0314:                    + "    =%simplified=;\n"
0315:                    + "    100: << hundred[ >%%and>];\n"
0316:                    + "    1000: << thousand[ >%%and>];\n"
0317:                    + "    100,000>>: << thousand[>%%commas>];\n"
0318:                    + "    1,000,000: << million[>%%commas>];\n"
0319:                    + "    1,000,000,000,000: << billion[>%%commas>];\n"
0320:                    + "    1,000,000,000,000,000: =#,##0=;\n" + "%%and:\n"
0321:                    + "    and =%default=;\n" + "    100: =%default=;\n"
0322:                    + "%%commas:\n" + "    ' and =%default=;\n"
0323:                    + "    100: , =%default=;\n"
0324:                    + "    1000: , <%default< thousand, >%default>;\n"
0325:                    + "    1,000,000: , =%default=;" + "%%lenient-parse:\n"
0326:                    + "    & ' ' , ',' ;\n";
0327:            // Could someone please correct me if I'm wrong about "milliard" falling
0328:            // into disuse, or have missed any other details of how large numbers
0329:            // are rendered.  Also, could someone please provide me with information
0330:            // on which other English-speaking countries use which system?  Right now,
0331:            // I'm assuming that the U.S. system is used in Canada and that all the
0332:            // other English-speaking countries follow the British system.  Can
0333:            // someone out there confirm this?
0334:
0335:            /**
0336:             * Spellout rules for Spanish.  The Spanish rules are quite similar to
0337:             * the English rules, but there are some important differences:
0338:             * First, we have to provide separate rules for most of the twenties
0339:             * because the ones digit frequently picks up an accent mark that it
0340:             * doesn't have when standing alone.  Second, each multiple of 100 has
0341:             * to be specified separately because the multiplier on 100 very often
0342:             * changes form in the contraction: 500 is "quinientos," not
0343:             * "cincocientos."  In addition, the word for 100 is "cien" when
0344:             * standing alone, but changes to "ciento" when followed by more digits.
0345:             * There also some other differences.
0346:             */
0347:            public static final String spanish =
0348:            // negative-number and fraction rules
0349:            "-x: menos >>;\n"
0350:                    + "x.x: << punto >>;\n"
0351:                    // words for values from 0 to 19
0352:                    + "cero; uno; dos; tres; cuatro; cinco; seis; siete; ocho; nueve;\n"
0353:                    + "diez; once; doce; trece; catorce; quince; diecis\u00e9is;\n"
0354:                    + "    diecisiete; dieciocho; diecinueve;\n"
0355:                    // words for values from 20 to 29 (necessary because the ones digit
0356:                    // often picks up an accent mark it doesn't have when standing alone)
0357:                    + "veinte; veintiuno; veintid\u00f3s; veintitr\u00e9s; veinticuatro;\n"
0358:                    + "    veinticinco; veintis\u00e9is; veintisiete; veintiocho;\n"
0359:                    + "    veintinueve;\n"
0360:                    // words for multiples of 10 (notice that the tens digit is separated
0361:                    // from the ones digit by the word "y".)
0362:                    + "30: treinta[ y >>];\n"
0363:                    + "40: cuarenta[ y >>];\n"
0364:                    + "50: cincuenta[ y >>];\n"
0365:                    + "60: sesenta[ y >>];\n"
0366:                    + "70: setenta[ y >>];\n"
0367:                    + "80: ochenta[ y >>];\n"
0368:                    + "90: noventa[ y >>];\n"
0369:                    // 100 by itself is "cien," but 100 followed by something is "cineto"
0370:                    + "100: cien;\n"
0371:                    + "101: ciento >>;\n"
0372:                    // words for multiples of 100 (must be stated because they're
0373:                    // rarely simple concatenations)
0374:                    + "200: doscientos[ >>];\n" + "300: trescientos[ >>];\n"
0375:                    + "400: cuatrocientos[ >>];\n" + "500: quinientos[ >>];\n"
0376:                    + "600: seiscientos[ >>];\n" + "700: setecientos[ >>];\n"
0377:                    + "800: ochocientos[ >>];\n"
0378:                    + "900: novecientos[ >>];\n"
0379:                    // for 1,000, the multiplier on "mil" is omitted: 2,000 is "dos mil,"
0380:                    // but 1,000 is just "mil."
0381:                    + "1000: mil[ >>];\n" + "2000: << mil[ >>];\n"
0382:                    // 1,000,000 is "un millon," not "uno millon"
0383:                    + "1,000,000: un mill\u00f3n[ >>];\n"
0384:                    + "2,000,000: << mill\u00f3n[ >>];\n"
0385:                    // overflow rule
0386:                    + "1,000,000,000: =#,##0= (incomplete data);";
0387:            // The Spanish rules are incomplete.  I'm missing information on negative
0388:            // numbers and numbers with fractional parts.  I also don't have
0389:            // information on numbers higher than the millions
0390:
0391:            /**
0392:             * Spellout rules for French.  French adds some interesting quirks of its
0393:             * own: 1) The word "et" is interposed between the tens and ones digits,
0394:             * but only if the ones digit if 1: 20 is "vingt," and 2 is "vingt-deux,"
0395:             * but 21 is "vingt-et-un."  2)  There are no words for 70, 80, or 90.
0396:             * "quatre-vingts" ("four twenties") is used for 80, and values proceed
0397:             * by score from 60 to 99 (e.g., 73 is "soixante-treize" ["sixty-thirteen"]).
0398:             * Numbers from 1,100 to 1,199 are rendered as hundreds rather than
0399:             * thousands: 1,100 is "onze cents" ("eleven hundred"), rather than
0400:             * "mille cent" ("one thousand one hundred")
0401:             */
0402:            public static final String french =
0403:            // the main rule set
0404:            "%main:\n"
0405:                    // negative-number and fraction rules
0406:                    + "    -x: moins >>;\n"
0407:                    + "    x.x: << virgule >>;\n"
0408:                    // words for numbers from 0 to 10
0409:                    + "    z\u00e9ro; un; deux; trois; quatre; cinq; six; sept; huit; neuf;\n"
0410:                    + "    dix; onze; douze; treize; quatorze; quinze; seize;\n"
0411:                    + "        dix-sept; dix-huit; dix-neuf;\n"
0412:                    // ords for the multiples of 10: %%alt-ones inserts "et"
0413:                    // when needed
0414:                    + "    20: vingt[->%%alt-ones>];\n"
0415:                    + "    30: trente[->%%alt-ones>];\n"
0416:                    + "    40: quarante[->%%alt-ones>];\n"
0417:                    + "    50: cinquante[->%%alt-ones>];\n"
0418:                    // rule for 60.  The /20 causes this rule's multiplier to be
0419:                    // 20 rather than 10, allowinhg us to recurse for all values
0420:                    // from 60 to 79...
0421:                    + "    60/20: soixante[->%%alt-ones>];\n"
0422:                    // ...except for 71, which must be special-cased
0423:                    + "    71: soixante et onze;\n"
0424:                    // at 72, we have to repeat the rule for 60 to get us to 79
0425:                    + "    72/20: soixante->%%alt-ones>;\n"
0426:                    // at 80, we state a new rule with the phrase for 80.  Since
0427:                    // it changes form when there's a ones digit, we need a second
0428:                    // rule at 81.  This rule also includes "/20," allowing it to
0429:                    // be used correctly for all values up to 99
0430:                    + "    80: quatre-vingts; 81/20: quatre-vingt->>;\n"
0431:                    // "cent" becomes plural when preceded by a multiplier, and
0432:                    // the multiplier is omitted from the singular form
0433:                    + "    100: cent[ >>];\n"
0434:                    + "    200: << cents[ >>];\n"
0435:                    + "    1000: mille[ >>];\n"
0436:                    // values from 1,100 to 1,199 are rendered as "onze cents..."
0437:                    // instead of "mille cent..."  The > after "1000" decreases
0438:                    // the rule's exponent, causing its multiplier to be 100 instead
0439:                    // of 1,000.  This prevents us from getting "onze cents cent
0440:                    // vingt-deux" ("eleven hundred one hundred twenty-two").
0441:                    + "    1100>: onze cents[ >>];\n"
0442:                    // at 1,200, we go back to formating in thousands, so we
0443:                    // repeat the rule for 1,000
0444:                    + "    1200: mille >>;\n"
0445:                    // at 2,000, the multiplier is added
0446:                    + "    2000: << mille[ >>];\n"
0447:                    + "    1,000,000: << million[ >>];\n"
0448:                    + "    1,000,000,000: << milliarde[ >>];\n"
0449:                    + "    1,000,000,000,000: << billion[ >>];\n"
0450:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0451:                    // %%alt-ones is used to insert "et" when the ones digit is 1
0452:                    + "%%alt-ones:\n" + "    ; et-un; =%main=;";
0453:
0454:            /**
0455:             * Spellout rules for Swiss French.  Swiss French differs from French French
0456:             * in that it does have words for 70, 80, and 90.  This rule set shows them,
0457:             * and is simpler as a result.
0458:             */
0459:            public static final String swissFrench = "%main:\n"
0460:                    + "    -x: moins >>;\n"
0461:                    + "    x.x: << virgule >>;\n"
0462:                    + "    z\u00e9ro; un; deux; trois; quatre; cinq; six; sept; huit; neuf;\n"
0463:                    + "    dix; onze; douze; treize; quatorze; quinze; seize;\n"
0464:                    + "        dix-sept; dix-huit; dix-neuf;\n"
0465:                    + "    20: vingt[->%%alt-ones>];\n"
0466:                    + "    30: trente[->%%alt-ones>];\n"
0467:                    + "    40: quarante[->%%alt-ones>];\n"
0468:                    + "    50: cinquante[->%%alt-ones>];\n"
0469:                    + "    60: soixante[->%%alt-ones>];\n"
0470:                    // notice new words for 70, 80, and 90
0471:                    + "    70: septante[->%%alt-ones>];\n"
0472:                    + "    80: octante[->%%alt-ones>];\n"
0473:                    + "    90: nonante[->%%alt-ones>];\n"
0474:                    + "    100: cent[ >>];\n" + "    200: << cents[ >>];\n"
0475:                    + "    1000: mille[ >>];\n"
0476:                    + "    1100>: onze cents[ >>];\n" + "    1200: mille >>;\n"
0477:                    + "    2000: << mille[ >>];\n"
0478:                    + "    1,000,000: << million[ >>];\n"
0479:                    + "    1,000,000,000: << milliarde[ >>];\n"
0480:                    + "    1,000,000,000,000: << billion[ >>];\n"
0481:                    + "    1,000,000,000,000,000: =#,##0=;\n" + "%%alt-ones:\n"
0482:                    + "    ; et-un; =%main=;";
0483:            // I'm not 100% sure about Swiss French.  Is
0484:            // this correct?  Is "onze cents" commonly used for 1,100 in both France
0485:            // and Switzerland?  Can someone fill me in on the rules for the other
0486:            // French-speaking countries?  I've heard conflicting opinions on which
0487:            // version is used in Canada, and I understand there's an alternate set
0488:            // of words for 70, 80, and 90 that is used somewhere, but I don't know
0489:            // what those words are or where they're used.
0490:
0491:            /**
0492:             * Spellout rules for German.  German also adds some interesting
0493:             * characteristics.  For values below 1,000,000, numbers are customarily
0494:             * written out as a single word.  And the ones digit PRECEDES the tens
0495:             * digit (e.g., 23 is "dreiundzwanzig," not "zwanzigunddrei").
0496:             */
0497:            public static final String german =
0498:            // 1 is "eins" when by itself, but turns into "ein" in most
0499:            // combinations
0500:            "%alt-ones:\n"
0501:                    + "    null; eins; =%%main=;\n"
0502:                    + "%%main:\n"
0503:                    // words for numbers from 0 to 12.  Notice that the values
0504:                    // from 13 to 19 can derived algorithmically, unlike in most
0505:                    // other languages
0506:                    + "    null; ein; zwei; drei; vier; f\u00fcnf; sechs; sieben; acht; neun;\n"
0507:                    + "    zehn; elf; zw\u00f6lf; >>zehn;\n"
0508:                    // rules for the multiples of 10.  Notice that the ones digit
0509:                    // goes on the front
0510:                    + "    20: [>>und]zwanzig;\n"
0511:                    + "    30: [>>und]drei\u00dfig;\n"
0512:                    + "    40: [>>und]vierzig;\n"
0513:                    + "    50: [>>und]f\u00fcnfzig;\n"
0514:                    + "    60: [>>und]sechzig;\n" + "    70: [>>und]siebzig;\n"
0515:                    + "    80: [>>und]achtzig;\n" + "    90: [>>und]neunzig;\n"
0516:                    + "    100: hundert[>%alt-ones>];\n"
0517:                    + "    200: <<hundert[>%alt-ones>];\n"
0518:                    + "    1000: tausend[>%alt-ones>];\n"
0519:                    + "    2000: <<tausend[>%alt-ones>];\n"
0520:                    + "    1,000,000: eine Million[ >%alt-ones>];\n"
0521:                    + "    2,000,000: << Millionen[ >%alt-ones>];\n"
0522:                    + "    1,000,000,000: eine Milliarde[ >%alt-ones>];\n"
0523:                    + "    2,000,000,000: << Milliarden[ >%alt-ones>];\n"
0524:                    + "    1,000,000,000,000: eine Billion[ >%alt-ones>];\n"
0525:                    + "    2,000,000,000,000: << Billionen[ >%alt-ones>];\n"
0526:                    + "    1,000,000,000,000,000: =#,##0=;";
0527:            // again, I'm not 100% sure of these rules.  I think both "hundert" and
0528:            // "einhundert" are correct or 100, but I'm not sure which is preferable
0529:            // in situations where this framework is likely to be used.  Also, is it
0530:            // really true that numbers are run together into compound words all the
0531:            // time?  And again, I'm missing information on negative numbers and
0532:            // decimals.
0533:
0534:            /**
0535:             * Spellout rules for Italian.  Like German, most Italian numbers are
0536:             * written as single words.  What makes these rules complicated is the rule
0537:             * that says that when a word ending in a vowel and a word beginning with
0538:             * a vowel are combined into a compound, the vowel is dropped from the
0539:             * end of the first word: 180 is "centottanta," not "centoottanta."
0540:             * The complexity of this rule set is to produce this behavior.
0541:             */
0542:            public static final String italian =
0543:            // main rule set.  Follows the patterns of the preceding rule sets,
0544:            // except that the final vowel is omitted from words ending in
0545:            // vowels when they are followed by another word; instead, we have
0546:            // separate rule sets that are identical to this one, except that
0547:            // all the words that don't begin with a vowel have a vowel tacked
0548:            // onto them at the front.  A word ending in a vowel calls a
0549:            // substitution that will supply that vowel, unless that vowel is to
0550:            // be elided.
0551:            "%main:\n"
0552:                    + "    -x: meno >>;\n"
0553:                    + "    x.x: << virgola >>;\n"
0554:                    + "    zero; uno; due; tre; quattro; cinque; sei; sette; otto;\n"
0555:                    + "        nove;\n"
0556:                    + "    dieci; undici; dodici; tredici; quattordici; quindici; sedici;\n"
0557:                    + "        diciasette; diciotto; diciannove;\n"
0558:                    + "    20: venti; vent>%%with-i>;\n"
0559:                    + "    30: trenta; trent>%%with-i>;\n"
0560:                    + "    40: quaranta; quarant>%%with-a>;\n"
0561:                    + "    50: cinquanta; cinquant>%%with-a>;\n"
0562:                    + "    60: sessanta; sessant>%%with-a>;\n"
0563:                    + "    70: settanta; settant>%%with-a>;\n"
0564:                    + "    80: ottanta; ottant>%%with-a>;\n"
0565:                    + "    90: novanta; novant>%%with-a>;\n"
0566:                    + "    100: cento; cent[>%%with-o>];\n"
0567:                    + "    200: <<cento; <<cent[>%%with-o>];\n"
0568:                    + "    1000: mille; mill[>%%with-i>];\n"
0569:                    + "    2000: <<mila; <<mil[>%%with-a>];\n"
0570:                    + "    100,000>>: <<mila[ >>];\n"
0571:                    + "    1,000,000: =#,##0= (incomplete data);\n"
0572:                    + "%%with-a:\n"
0573:                    + "    azero; uno; adue; atre; aquattro; acinque; asei; asette; otto;\n"
0574:                    + "        anove;\n"
0575:                    + "    adieci; undici; adodici; atredici; aquattordici; aquindici; asedici;\n"
0576:                    + "        adiciasette; adiciotto; adiciannove;\n"
0577:                    + "    20: aventi; avent>%%with-i>;\n"
0578:                    + "    30: atrenta; atrent>%%with-i>;\n"
0579:                    + "    40: aquaranta; aquarant>%%with-a>;\n"
0580:                    + "    50: acinquanta; acinquant>%%with-a>;\n"
0581:                    + "    60: asessanta; asessant>%%with-a>;\n"
0582:                    + "    70: asettanta; asettant>%%with-a>;\n"
0583:                    + "    80: ottanta; ottant>%%with-a>;\n"
0584:                    + "    90: anovanta; anovant>%%with-a>;\n"
0585:                    + "    100: acento; acent[>%%with-o>];\n"
0586:                    + "    200: <%%with-a<cento; <%%with-a<cent[>%%with-o>];\n"
0587:                    + "    1000: amille; amill[>%%with-i>];\n"
0588:                    + "    2000: <%%with-a<mila; <%%with-a<mil[>%%with-a>];\n"
0589:                    + "    100,000: =%main=;\n"
0590:                    + "%%with-i:\n"
0591:                    + "    izero; uno; idue; itre; iquattro; icinque; isei; isette; otto;\n"
0592:                    + "        inove;\n"
0593:                    + "    idieci; undici; idodici; itredici; iquattordici; iquindici; isedici;\n"
0594:                    + "        idiciasette; idiciotto; idiciannove;\n"
0595:                    + "    20: iventi; ivent>%%with-i>;\n"
0596:                    + "    30: itrenta; itrent>%%with-i>;\n"
0597:                    + "    40: iquaranta; iquarant>%%with-a>;\n"
0598:                    + "    50: icinquanta; icinquant>%%with-a>;\n"
0599:                    + "    60: isessanta; isessant>%%with-a>;\n"
0600:                    + "    70: isettanta; isettant>%%with-a>;\n"
0601:                    + "    80: ottanta; ottant>%%with-a>;\n"
0602:                    + "    90: inovanta; inovant>%%with-a>;\n"
0603:                    + "    100: icento; icent[>%%with-o>];\n"
0604:                    + "    200: <%%with-i<cento; <%%with-i<cent[>%%with-o>];\n"
0605:                    + "    1000: imille; imill[>%%with-i>];\n"
0606:                    + "    2000: <%%with-i<mila; <%%with-i<mil[>%%with-a>];\n"
0607:                    + "    100,000: =%main=;\n"
0608:                    + "%%with-o:\n"
0609:                    + "    ozero; uno; odue; otre; oquattro; ocinque; osei; osette; otto;\n"
0610:                    + "        onove;\n"
0611:                    + "    odieci; undici; ododici; otredici; oquattordici; oquindici; osedici;\n"
0612:                    + "        odiciasette; odiciotto; odiciannove;\n"
0613:                    + "    20: oventi; ovent>%%with-i>;\n"
0614:                    + "    30: otrenta; otrent>%%with-i>;\n"
0615:                    + "    40: oquaranta; oquarant>%%with-a>;\n"
0616:                    + "    50: ocinquanta; ocinquant>%%with-a>;\n"
0617:                    + "    60: osessanta; osessant>%%with-a>;\n"
0618:                    + "    70: osettanta; osettant>%%with-a>;\n"
0619:                    + "    80: ottanta; ottant>%%with-a>;\n"
0620:                    + "    90: onovanta; onovant>%%with-a>;\n"
0621:                    + "    100: ocento; ocent[>%%with-o>];\n"
0622:                    + "    200: <%%with-o<cento; <%%with-o<cent[>%%with-o>];\n"
0623:                    + "    1000: omille; omill[>%%with-i>];\n"
0624:                    + "    2000: <%%with-o<mila; <%%with-o<mil[>%%with-a>];\n"
0625:                    + "    100,000: =%main=;\n";
0626:            // Can someone confirm that I did the vowel-eliding thing right?  I'm
0627:            // not 100% sure I'm doing it in all the right places, or completely
0628:            // correctly.  Also, I don't have information for negatives and decimals,
0629:            // and I lack words fror values from 1,000,000 on up.
0630:
0631:            /**
0632:             * Spellout rules for Swedish.
0633:             */
0634:            public static final String swedish = "noll; ett; tv\u00e5; tre; fyra; fem; sex; sjo; \u00e5tta; nio;\n"
0635:                    + "tio; elva; tolv; tretton; fjorton; femton; sexton; sjutton; arton; nitton;\n"
0636:                    + "20: tjugo[>>];\n"
0637:                    + "30: trettio[>>];\n"
0638:                    + "40: fyrtio[>>];\n"
0639:                    + "50: femtio[>>];\n"
0640:                    + "60: sextio[>>];\n"
0641:                    + "70: sjuttio[>>];\n"
0642:                    + "80: \u00e5ttio[>>];\n"
0643:                    + "90: nittio[>>];\n"
0644:                    + "100: hundra[>>];\n"
0645:                    + "200: <<hundra[>>];\n"
0646:                    + "1000: tusen[ >>];\n"
0647:                    + "2000: << tusen[ >>];\n"
0648:                    + "1,000,000: en miljon[ >>];\n"
0649:                    + "2,000,000: << miljon[ >>];\n"
0650:                    + "1,000,000,000: en miljard[ >>];\n"
0651:                    + "2,000,000,000: << miljard[ >>];\n"
0652:                    + "1,000,000,000,000: en biljon[ >>];\n"
0653:                    + "2,000,000,000,000: << biljon[ >>];\n"
0654:                    + "1,000,000,000,000,000: =#,##0=";
0655:            // can someone supply me with information on negatives and decimals?
0656:
0657:            /**
0658:             * Spellout rules for Dutch.  Notice that in Dutch, as in German,
0659:             * the ones digit precedes the tens digit.
0660:             */
0661:            public static final String dutch = " -x: min >>;\n"
0662:                    + "x.x: << komma >>;\n"
0663:                    + "(zero?); een; twee; drie; vier; vijf; zes; zeven; acht; negen;\n"
0664:                    + "tien; elf; twaalf; dertien; veertien; vijftien; zestien;\n"
0665:                    + "zeventien; achtien; negentien;\n"
0666:                    + "20: [>> en ]twintig;\n" + "30: [>> en ]dertig;\n"
0667:                    + "40: [>> en ]veertig;\n" + "50: [>> en ]vijftig;\n"
0668:                    + "60: [>> en ]zestig;\n" + "70: [>> en ]zeventig;\n"
0669:                    + "80: [>> en ]tachtig;\n" + "90: [>> en ]negentig;\n"
0670:                    + "100: << honderd[ >>];\n" + "1000: << duizend[ >>];\n"
0671:                    + "1,000,000: << miljoen[ >>];\n"
0672:                    + "1,000,000,000: << biljoen[ >>];\n"
0673:                    + "1,000,000,000,000: =#,##0=";
0674:
0675:            /**
0676:             * Spellout rules for Japanese.  In Japanese, there really isn't any
0677:             * distinction between a number written out in digits and a number
0678:             * written out in words: the ideographic characters are both digits
0679:             * and words.  This rule set provides two variants:  %traditional
0680:             * uses the traditional CJK numerals (which are also used in China
0681:             * and Korea).  %financial uses alternate ideographs for many numbers
0682:             * that are harder to alter than the traditional numerals (one could
0683:             * fairly easily change a one to
0684:             * a three just by adding two strokes, for example).  This is also done in
0685:             * the other countries using Chinese idographs, but different ideographs
0686:             * are used in those places.
0687:             */
0688:            public static final String japanese = "%financial:\n"
0689:                    + "    \u96f6; \u58f1; \u5f10; \u53c2; \u56db; \u4f0d; \u516d; \u4e03; \u516b; \u4e5d;\n"
0690:                    + "    \u62fe[>>];\n"
0691:                    + "    20: <<\u62fe[>>];\n"
0692:                    + "    100: <<\u767e[>>];\n"
0693:                    + "    1000: <<\u5343[>>];\n"
0694:                    + "    10,000: <<\u4e07[>>];\n"
0695:                    + "    100,000,000: <<\u5104[>>];\n"
0696:                    + "    1,000,000,000,000: <<\u5146[>>];\n"
0697:                    + "    10,000,000,000,000,000: =#,##0=;\n"
0698:                    + "%traditional:\n"
0699:                    + "    \u96f6; \u4e00; \u4e8c; \u4e09; \u56db; \u4e94; \u516d; \u4e03; \u516b; \u4e5d;\n"
0700:                    + "    \u5341[>>];\n" + "    20: <<\u5341[>>];\n"
0701:                    + "    100: <<\u767e[>>];\n" + "    1000: <<\u5343[>>];\n"
0702:                    + "    10,000: <<\u4e07[>>];\n"
0703:                    + "    100,000,000: <<\u5104[>>];\n"
0704:                    + "    1,000,000,000,000: <<\u5146[>>];\n"
0705:                    + "    10,000,000,000,000,000: =#,##0=;";
0706:            // Can someone supply me with the right fraud-proof ideographs for
0707:            // Simplified and Traditional Chinese, and for Korean?  Can someone
0708:            // supply me with information on negatives and decimals?
0709:
0710:            /**
0711:             * Spellout rules for Greek.  Again in Greek we have to supply the words
0712:             * for the multiples of 100 because they can't be derived algorithmically.
0713:             * Also, the tens dgit changes form when followed by a ones digit: an
0714:             * accent mark disappears from the tens digit and moves to the ones digit.
0715:             * Therefore, instead of using the [] notation, we actually have to use
0716:             * two separate rules for each multiple of 10 to show the two forms of
0717:             * the word.
0718:             */
0719:            public static final String greek = "zero (incomplete data); \u03ad\u03bd\u03b1; \u03b4\u03cd\u03bf; \u03b4\u03c1\u03af\u03b1; "
0720:                    + "\u03c4\u03ad\u03c3\u03c3\u03b5\u03c1\u03b1; \u03c0\u03ad\u03bd\u03c4\u03b5; "
0721:                    + "\u03ad\u03be\u03b9; \u03b5\u03c0\u03c4\u03ac; \u03bf\u03ba\u03c4\u03ce; "
0722:                    + "\u03b5\u03bd\u03bd\u03ad\u03b1;\n"
0723:                    + "10: \u03b4\u03ad\u03ba\u03b1; "
0724:                    + "\u03ad\u03bd\u03b4\u03b5\u03ba\u03b1; \u03b4\u03ce\u03b4\u03b5\u03ba\u03b1; "
0725:                    + "\u03b4\u03b5\u03ba\u03b1>>;\n"
0726:                    + "20: \u03b5\u03af\u03ba\u03bf\u03c3\u03b9; \u03b5\u03b9\u03ba\u03bf\u03c3\u03b9>>;\n"
0727:                    + "30: \u03c4\u03c1\u03b9\u03ac\u03bd\u03c4\u03b1; \u03c4\u03c1\u03b9\u03b1\u03bd\u03c4\u03b1>>;\n"
0728:                    + "40: \u03c3\u03b1\u03c1\u03ac\u03bd\u03c4\u03b1; \u03c3\u03b1\u03c1\u03b1\u03bd\u03c4\u03b1>>;\n"
0729:                    + "50: \u03c0\u03b5\u03bd\u03ae\u03bd\u03c4\u03b1; \u03c0\u03b5\u03bd\u03b7\u03bd\u03c4\u03b1>>;\n"
0730:                    + "60: \u03b5\u03be\u03ae\u03bd\u03c4\u03b1; \u03b5\u03be\u03b7\u03bd\u03c4\u03b1>>;\n"
0731:                    + "70: \u03b5\u03b2\u03b4\u03bf\u03bc\u03ae\u03bd\u03c4\u03b1; "
0732:                    + "\u03b5\u03b2\u03b4\u03bf\u03bc\u03b7\u03bd\u03c4\u03b1>>;\n"
0733:                    + "80: \u03bf\u03b3\u03b4\u03cc\u03bd\u03c4\u03b1; \u03bf\u03b3\u03b4\u03bf\u03bd\u03c4\u03b1>>;\n"
0734:                    + "90: \u03b5\u03bd\u03bd\u03b5\u03bd\u03ae\u03bd\u03c4\u03b1; "
0735:                    + "\u03b5\u03bd\u03bd\u03b5\u03bd\u03b7\u03bd\u03c4\u03b1>>;\n"
0736:                    + "100: \u03b5\u03ba\u03b1\u03c4\u03cc[\u03bd >>];\n"
0737:                    + "200: \u03b4\u03b9\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0738:                    + "300: \u03c4\u03c1\u03b9\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0739:                    + "400: \u03c4\u03b5\u03c4\u03c1\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0740:                    + "500: \u03c0\u03b5\u03bd\u03c4\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0741:                    + "600: \u03b5\u03be\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0742:                    + "700: \u03b5\u03c0\u03c4\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0743:                    + "800: \u03bf\u03ba\u03c4\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0744:                    + "900: \u03b5\u03bd\u03bd\u03b9\u03b1\u03ba\u03cc\u03c3\u03b9\u03b1[ >>];\n"
0745:                    + "1000: \u03c7\u03af\u03bb\u03b9\u03b1[ >>];\n"
0746:                    + "2000: << \u03c7\u03af\u03bb\u03b9\u03b1[ >>];\n"
0747:                    + "1,000,000: << \u03b5\u03ba\u03b1\u03c4\u03bf\u03bc\u03bc\u03b9\u03cc\u03c1\u03b9\u03bf[ >>];\n"
0748:                    + "1,000,000,000: << \u03b4\u03b9\u03c3\u03b5\u03ba\u03b1\u03c4\u03bf\u03bc\u03bc\u03b9\u03cc\u03c1\u03b9\u03bf[ >>];\n"
0749:                    + "1,000,000,000,000: =#,##0=";
0750:            // Can someone supply me with information on negatives and decimals?
0751:            // I'm also missing the word for zero.  Can someone clue me in?
0752:
0753:            /**
0754:             * Spellout rules for Russian.
0755:             */
0756:            public static final String russian = "\u043d\u043e\u043b\u044c; \u043e\u0434\u0438\u043d; \u0434\u0432\u0430; \u0442\u0440\u0438; "
0757:                    + "\u0447\u0435\u0442\u044b\u0440\u0435; \u043f\u044f\u0442; \u0448\u0435\u0441\u0442; "
0758:                    + "\u0441\u0435\u043c\u044c; \u0432\u043e\u0441\u0435\u043c\u044c; \u0434\u0435\u0432\u044f\u0442;\n"
0759:                    + "10: \u0434\u0435\u0441\u044f\u0442; "
0760:                    + "\u043e\u0434\u0438\u043d\u043d\u0430\u0434\u0446\u0430\u0442\u044c;\n"
0761:                    + "\u0434\u0432\u0435\u043d\u043d\u0430\u0434\u0446\u0430\u0442\u044c; "
0762:                    + "\u0442\u0440\u0438\u043d\u0430\u0434\u0446\u0430\u0442\u044c; "
0763:                    + "\u0447\u0435\u0442\u044b\u0440\u043d\u0430\u0434\u0446\u0430\u0442\u044c;\n"
0764:                    + "15: \u043f\u044f\u0442\u043d\u0430\u0434\u0446\u0430\u0442\u044c; "
0765:                    + "\u0448\u0435\u0441\u0442\u043d\u0430\u0434\u0446\u0430\u0442\u044c; "
0766:                    + "\u0441\u0435\u043c\u043d\u0430\u0434\u0446\u0430\u0442\u044c; "
0767:                    + "\u0432\u043e\u0441\u0435\u043c\u043d\u0430\u0434\u0446\u0430\u0442\u044c; "
0768:                    + "\u0434\u0435\u0432\u044f\u0442\u043d\u0430\u0434\u0446\u0430\u0442\u044c;\n"
0769:                    + "20: \u0434\u0432\u0430\u0434\u0446\u0430\u0442\u044c[ >>];\n"
0770:                    + "30: \u0442\u0440\u043b\u0434\u0446\u0430\u0442\u044c[ >>];\n"
0771:                    + "40: \u0441\u043e\u0440\u043e\u043a[ >>];\n"
0772:                    + "50: \u043f\u044f\u0442\u044c\u0434\u0435\u0441\u044f\u0442[ >>];\n"
0773:                    + "60: \u0448\u0435\u0441\u0442\u044c\u0434\u0435\u0441\u044f\u0442[ >>];\n"
0774:                    + "70: \u0441\u0435\u043c\u044c\u0434\u0435\u0441\u044f\u0442[ >>];\n"
0775:                    + "80: \u0432\u043e\u0441\u0435\u043c\u044c\u0434\u0435\u0441\u044f\u0442[ >>];\n"
0776:                    + "90: \u0434\u0435\u0432\u044f\u043d\u043e\u0441\u0442\u043e[ >>];\n"
0777:                    + "100: \u0441\u0442\u043e[ >>];\n"
0778:                    + "200: << \u0441\u0442\u043e[ >>];\n"
0779:                    + "1000: \u0442\u044b\u0441\u044f\u0447\u0430[ >>];\n"
0780:                    + "2000: << \u0442\u044b\u0441\u044f\u0447\u0430[ >>];\n"
0781:                    + "1,000,000: \u043c\u0438\u043b\u043b\u0438\u043e\u043d[ >>];\n"
0782:                    + "2,000,000: << \u043c\u0438\u043b\u043b\u0438\u043e\u043d[ >>];\n"
0783:                    + "1,000,000,000: =#,##0=;";
0784:            // Can someone supply me with information on negatives and decimals?
0785:            // How about words for billions and trillions?
0786:
0787:            /**
0788:             * Spellout rules for Hebrew.  Hebrew actually has inflected forms for
0789:             * most of the lower-order numbers.  The masculine forms are shown
0790:             * here.
0791:             */
0792:            public static final String hebrew = "zero (incomplete data); \u05d0\u05d4\u05d3; \u05e9\u05d2\u05d9\u05d9\u05dd; \u05e9\u05dc\u05d5\u05e9\u05d4;\n"
0793:                    + "4: \u05d0\u05d3\u05d1\u05e6\u05d4; \u05d7\u05d2\u05d5\u05d9\u05e9\u05d4; \u05e9\u05e9\u05d4;\n"
0794:                    + "7: \u05e9\u05d1\u05e6\u05d4; \u05e9\u05de\u05d5\u05d2\u05d4; \u05ea\u05e9\u05e6\u05d4;\n"
0795:                    + "10: \u05e6\u05e9\u05d3\u05d4[ >>];\n"
0796:                    + "20: \u05e6\u05e9\u05d3\u05d9\u05dd[ >>];\n"
0797:                    + "30: \u05e9\u05dc\u05d5\u05e9\u05d9\u05dd[ >>];\n"
0798:                    + "40: \u05d0\u05d3\u05d1\u05e6\u05d9\u05dd[ >>];\n"
0799:                    + "50: \u05d7\u05de\u05d9\u05e9\u05d9\u05dd[ >>];\n"
0800:                    + "60: \u05e9\u05e9\u05d9\u05dd[ >>];\n"
0801:                    + "70: \u05e9\u05d1\u05e6\u05d9\u05dd[ >>];\n"
0802:                    + "80: \u05e9\u05de\u05d5\u05d2\u05d9\u05dd[ >>];\n"
0803:                    + "90: \u05ea\u05e9\u05e6\u05d9\u05dd[ >>];\n"
0804:                    + "100: \u05de\u05d0\u05d4[ >>];\n"
0805:                    + "200: << \u05de\u05d0\u05d4[ >>];\n"
0806:                    + "1000: \u05d0\u05dc\u05e3[ >>];\n"
0807:                    + "2000: << \u05d0\u05dc\u05e3[ >>];\n"
0808:                    + "1,000,000: =#,##0= (incomplete data);";
0809:            // This data is woefully incomplete.  Can someone fill me in on the
0810:            // various inflected forms of the numbers, which seem to be necessary
0811:            // to do Hebrew correctly?  Can somone supply me with data for values
0812:            // from 1,000,000 on up?  What about the word for zero?  What about
0813:            // information on negatives and decimals?
0814:
0815:            //========================================================================
0816:            // Simple examples
0817:            //========================================================================
0818:
0819:            /**
0820:             * This rule set adds an English ordinal abbreviation to the end of a
0821:             * number.  For example, 2 is formatted as "2nd".  Parsing doesn't work with
0822:             * this rule set.  To parse, use DecimalFormat on the numeral.
0823:             */
0824:            public static final String ordinal =
0825:            // this rule set formats the numeral and calls %%abbrev to
0826:            // supply the abbreviation
0827:            "%main:\n" + "    =#,##0==%%abbrev=;\n"
0828:            // this rule set supplies the abbreviation
0829:                    + "%%abbrev:\n"
0830:                    // the abbreviations.  Everything from 4 to 19 ends in "th"
0831:                    + "    th; st; nd; rd; th;\n"
0832:                    // at 20, we begin repeating the cycle every 10 (13 is "13th",
0833:                    // but 23 and 33 are "23rd" and "33rd")  We do this by
0834:                    // ignoring all bug the ones digit in selecting the abbreviation
0835:                    + "    20: >>;\n"
0836:                    // at 100, we repeat the whole cycle by considering only the
0837:                    // tens and ones digits in picking an abbreviation
0838:                    + "    100: >>;\n";
0839:
0840:            /**
0841:             * This is a simple message-formatting example.  Normally one would
0842:             * use ChoiceFormat and MessageFormat to do something this simple,
0843:             * but this shows it could be done with RuleBasedNumberFormat too.
0844:             * A message-formatting example that might work better with
0845:             * RuleBasedNumberFormat appears later.
0846:             */
0847:            public static final String message1 =
0848:            // this rule surrounds whatever the other rules produce with the
0849:            // rest of the sentence
0850:            "x.0: The search found <<.;\n"
0851:                    // use words for values below 10 (and change to "file" for 1)
0852:                    + "no files; one file; two files; three files; four files; five files;\n"
0853:                    + "    six files; seven files; eight files; nine files;\n"
0854:                    // use numerals for values higher than 10
0855:                    + "=#,##0= files;";
0856:
0857:            //========================================================================
0858:            // Fraction handling
0859:            //
0860:            // The next few examples show how RuleBasedNumberFormat can be used for
0861:            // more flexible handling of fractions
0862:            //========================================================================
0863:
0864:            /**
0865:             * This example formats a number in one of the two styles often used
0866:             * on checks.  %dollars-and-hundredths formats cents as hundredths of
0867:             * a dollar (23.40 comes out as "twenty-three and 40/100 dollars").
0868:             * %dollars-and-cents formats in dollars and cents (23.40 comes out as
0869:             * "twenty-three dollars and forty cents")
0870:             */
0871:            public static final String dollarsAndCents =
0872:            // this rule set formats numbers as dollars and cents
0873:            "%dollars-and-cents:\n"
0874:                    // if the value is 1 or more, put "xx dollars and yy cents".
0875:                    // the "and y cents" part is suppressed if the value is an
0876:                    // even number of dollars
0877:                    + "    x.0: << [and >%%cents>];\n"
0878:                    // if the value is between 0 and 1, put "xx cents"
0879:                    + "    0.x: >%%cents>;\n"
0880:                    // these three rules take care of the singular and plural
0881:                    // forms of "dollar" and use %%main to format the number
0882:                    + "    0: zero dollars; one dollar; =%%main= dollars;\n"
0883:                    // these are the regular U.S. English number spellout rules
0884:                    + "%%main:\n"
0885:                    + "    zero; one; two; three; four; five; six; seven; eight; nine;\n"
0886:                    + "    ten; eleven; twelve; thirteen; fourteen; fifteen; sixteen;\n"
0887:                    + "        seventeen; eighteen; nineteen;\n"
0888:                    + "    20: twenty[->>];\n" + "    30: thirty[->>];\n"
0889:                    + "    40: forty[->>];\n" + "    50: fifty[->>];\n"
0890:                    + "    60: sixty[->>];\n" + "    70: seventy[->>];\n"
0891:                    + "    80: eighty[->>];\n" + "    90: ninety[->>];\n"
0892:                    + "    100: << hundred[ >>];\n"
0893:                    + "    1000: << thousand[ >>];\n"
0894:                    + "    1,000,000: << million[ >>];\n"
0895:                    + "    1,000,000,000: << billion[ >>];\n"
0896:                    + "    1,000,000,000,000: << trillion[ >>];\n"
0897:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0898:                    // this rule takes care of the fractional part of the value.  It
0899:                    // multiplies the fractional part of the number being formatted by
0900:                    // 100, formats it with %%main, and then addes the word "cent" or
0901:                    // "cents" to the end.  (The text in brackets is omitted if the
0902:                    // numerator of the fraction is 1.)
0903:                    + "%%cents:\n" + "    100: <%%main< cent[s];\n"
0904:
0905:                    // this rule set formats numbers as dollars and hundredths of dollars
0906:                    + "%dollars-and-hundredths:\n"
0907:                    // this rule takes care of the general shell of the output
0908:                    // string.  We always show the cents, even when there aren't
0909:                    // any.  Because of this, the word is always "dollars"--
0910:                    // we don't have to worry about the singular form.  We use
0911:                    // %%main to format the number of dollars and %%hundredths to
0912:                    // format the number of cents
0913:                    + "    x.0: <%%main< and >%%hundredths>/100 dollars;\n"
0914:                    // this rule set formats the cents for %dollars-and-hundredths.
0915:                    // It multiplies the fractional part of the number by 100 and formats
0916:                    // the result using a DecimalFormat ("00" tells the DecimalFormat to
0917:                    // always use two digits, even for numbers under 10)
0918:                    + "%%hundredths:\n" + "    100: <00<;\n";
0919:
0920:            /**
0921:             * This rule set shows the fractional part of the number as a fraction
0922:             * with a power of 10 as the denominator.  Some languages don't spell
0923:             * out the fractional part of a number as "point one two three," but
0924:             * always render it as a fraction.  If we still want to treat the fractional
0925:             * part of the number as a decimal, then the fraction's denominator
0926:             * is always a power of 10.  This example does that: 23.125 is formatted
0927:             * as "twenty-three and one hundred twenty-five thousandths" (as opposed
0928:             * to "twenty-three point one two five" or "twenty-three and one eighth").
0929:             */
0930:            public static final String decimalAsFraction =
0931:            // the regular U.S. English spellout rules, with one difference
0932:            "%main:\n"
0933:                    + "    -x: minus >>;\n"
0934:                    // the difference.  This rule uses %%frac to show the fractional
0935:                    // part of the number.  Text in brackets is omitted when the
0936:                    // value is between 0 and 1 (causing 0.3 to come out as "three
0937:                    // tenths" instead of "zero and three tenths").
0938:                    + "    x.x: [<< and ]>%%frac>;\n"
0939:                    + "    zero; one; two; three; four; five; six; seven; eight; nine;\n"
0940:                    + "    ten; eleven; twelve; thirteen; fourteen; fifteen; sixteen;\n"
0941:                    + "        seventeen; eighteen; nineteen;\n"
0942:                    + "    twenty[->>];\n"
0943:                    + "    30: thirty[->>];\n"
0944:                    + "    40: forty[->>];\n"
0945:                    + "    50: fifty[->>];\n"
0946:                    + "    60: sixty[->>];\n"
0947:                    + "    70: seventy[->>];\n"
0948:                    + "    80: eighty[->>];\n"
0949:                    + "    90: ninety[->>];\n"
0950:                    + "    100: << hundred[ >>];\n"
0951:                    + "    1000: << thousand[ >>];\n"
0952:                    + "    1,000,000: << million[ >>];\n"
0953:                    + "    1,000,000,000: << billion[ >>];\n"
0954:                    + "    1,000,000,000,000: << trillion[ >>];\n"
0955:                    + "    1,000,000,000,000,000: =#,##0=;\n"
0956:                    // the rule set that formats the fractional part of the number.
0957:                    // The rule that is used is the one that, when its baase value is
0958:                    // multiplied by the fractional part of the number being formatted,
0959:                    // produces the result closest to zero.  Thus, the base values are
0960:                    // prospective denominators of the fraction.  The << marks the place
0961:                    // where the numerator of the fraction (the result of multiplying the
0962:                    // fractional part of the number by the rule's base value) is
0963:                    // placed.  Text in brackets is omitted when the numerator is 1, giving
0964:                    // us the singular and plural forms of the words.
0965:                    // [In languages where the singular and plural are completely different
0966:                    // words, the rule can just be stated twice: the second time with
0967:                    // the plural form.]
0968:                    + "%%frac:\n" + "    10: << tenth[s];\n"
0969:                    + "    100: << hundredth[s];\n"
0970:                    + "    1000: << thousandth[s];\n"
0971:                    + "    10,000: << ten-thousandth[s];\n"
0972:                    + "    100,000: << hundred-thousandth[s];\n"
0973:                    + "    1,000,000: << millionth[s];";
0974:
0975:            /**
0976:             * Number with closest fraction.  This example formats a value using
0977:             * numerals, but shows the fractional part as a ratio (fraction) rather
0978:             * than a decimal.  The fraction always has a denominator between 2 and 10.
0979:             */
0980:            public static final String closestFraction = "%main:\n"
0981:                    // this rule formats the number if it's 1 or more.  It formats
0982:                    // the integral part using a DecimalFormat ("#,##0" puts
0983:                    // thousands separators in the right places) and the fractional
0984:                    // part using %%frac.  If there is no fractional part, it
0985:                    // just shows the integral part.
0986:                    + "    x.0: <#,##0<[ >%%frac>];\n"
0987:                    // this rule formats the number if it's between 0 and 1.  It
0988:                    // shows only the fractional part (0.5 shows up as "1/2," not
0989:                    // "0 1/2")
0990:                    + "    0.x: >%%frac>;\n"
0991:                    // the fraction rule set.  This works the same way as the one in the
0992:                    // preceding example: We multiply the fractional part of the number
0993:                    // being formatted by each rule's base value and use the rule that
0994:                    // produces the result closest to 0 (or the first rule that produces 0).
0995:                    // Since we only provide rules for the numbers from 2 to 10, we know
0996:                    // we'll get a fraction with a denominator between 2 and 10.
0997:                    // "<0<" causes the numerator of the fraction to be formatted
0998:                    // using numerals
0999:                    + "%%frac:\n" + "    2: 1/2;\n" + "    3: <0</3;\n"
1000:                    + "    4: <0</4;\n" + "    5: <0</5;\n" + "    6: <0</6;\n"
1001:                    + "    7: <0</7;\n" + "    8: <0</8;\n" + "    9: <0</9;\n"
1002:                    + "    10: <0</10;\n";
1003:
1004:            /**
1005:             * American stock-price formatting.  Non-integral stock prices are still
1006:             * generally shown in eighths or sixteenths of dollars instead of dollars
1007:             * and cents.  This example formats stock prices in this way if possible,
1008:             * and in dollars and cents if not.
1009:             */
1010:            public static final String stock = "%main:\n"
1011:                    // this rule formats the integral part of the number in numerals
1012:                    // and (if necessary) the fractional part using %%frac1
1013:                    + "    x.0: <#,##0<[>%%frac1>];\n"
1014:                    // this rule is used for values between 0 and 1 and omits the
1015:                    // integral part
1016:                    + "    0.x: >%%frac2>;\n"
1017:                    // this rule set is used to format the fractional part of the number when
1018:                    // there's an integral part before it (again, we try all denominators
1019:                    // and use the "best" one)
1020:                    + "%%frac1:\n"
1021:                    // for even multiples of 1/4, format the fraction using the
1022:                    // typographer's fractions
1023:                    + "    4: <%%quarters<;\n"
1024:                    // format the value as a number of eighths, sixteenths, or
1025:                    // thirty-seconds, whichever produces the most accurate value.
1026:                    // The apostrophe at the front of these rules is ignored, but
1027:                    // it makes the space that follows it significant.  This puts a
1028:                    // space between the value's integral and fractional parts so
1029:                    // you can read it
1030:                    + "    8: ' <0</8;\n"
1031:                    + "    16: ' <0</16;\n"
1032:                    + "    32: ' <0</32;\n"
1033:                    // if we can't reasonably format the number in powers of 2,
1034:                    // then show it as dollars and cents
1035:                    + "    100: .<00<;\n"
1036:                    // this rule set is used when the fractional part of the value stands
1037:                    // alone
1038:                    + "%%frac2:\n"
1039:                    + "    4: <%%quarters<;\n"
1040:                    // for fractions that we can't show using typographer's fractions,
1041:                    // we don't have to put a space before the fraction
1042:                    + "    8: <0</8;\n"
1043:                    + "    16: <0</16;\n"
1044:                    + "    32: <0</32;\n"
1045:                    // but dollars and cents look better with a leading 0
1046:                    + "    100: 0.<00<;\n"
1047:                    // this rule set formats 1/4, 1/2, and 3/4 using typographer's fractions
1048:                    + "%%quarters:\n"
1049:                    + "    ; \u00bc; \u00bd; \u00be;\n"
1050:                    // there are the lenient-parse rules.  These allow the user to type
1051:                    // "1/4," "1/2," and "3/4" instead of their typographical counterparts
1052:                    // and still have them be understood by the formatter
1053:                    + "%%lenient-parse:\n" + "    & '1/4' , \u00bc\n"
1054:                    + "    & '1/2' , \u00bd\n" + "    & '3/4' , \u00be\n;";
1055:
1056:            //========================================================================
1057:            // Changing dimensions
1058:            //
1059:            // The next few examples demonstrate using a RuleBasedNumberFormat to
1060:            // change the units a value is denominated in depending on its magnitude
1061:            //========================================================================
1062:
1063:            /**
1064:             * The example shows large numbers the way they often appear is nwespapers:
1065:             * 1,200,000 is formatted as "1.2 million".
1066:             */
1067:            public static final String abbEnglish = "=#,##0=;\n"
1068:                    // this is fairly self-explanatory, but note that the << substitution
1069:                    // can show the fractional part of the substitution value if the user
1070:                    // wants it
1071:                    + "1,000,000: <##0.###< million;\n"
1072:                    + "1,000,000,000: <##0.###< billion;\n"
1073:                    + "1,000,000,000,000: <##0.###< trillion;\n";
1074:
1075:            /**
1076:             * This example takes a number of meters and formats it in whatever unit
1077:             * will produce a number with from one to three digits before the decimal
1078:             * point.  For example, 230,000 is formatted as "230 km".
1079:             */
1080:            public static final String units = "%main:\n"
1081:                    // for values between 0 and 1, delegate to %%small
1082:                    + "    0.x: >%%small>;\n"
1083:                    // otherwise, show between 3 and 6 significant digits of the value
1084:                    // along with the most appropriate unit
1085:                    + "    0: =##0.###= m;\n"
1086:                    + "    1,000: <##0.###< km;\n"
1087:                    + "    1,000,000: <##0.###< Mm;\n"
1088:                    + "    1,000,000,000: <##0.###< Gm;\n"
1089:                    + "    1,000,000,000,000: <#,##0.###< Tm;\n"
1090:                    // %%small formats the number when it's less then 1.  It multiplies the
1091:                    // value by one billion, and then uses %%small2 to actually do the
1092:                    // formatting.
1093:                    + "%%small:\n"
1094:                    + "    1,000,000,000,000: <%%small2<;\n"
1095:                    // this rule set actually formats small values.  %%small passes this
1096:                    // rule set a number of picometers, and it takes care of scaling up as
1097:                    // appropriate in exactly the same way %main does (we can't normally
1098:                    // handle fractional values this way: here, we're concerned about
1099:                    // magnitude; most of the time, we're concerned about precsion)
1100:                    + "%%small2:\n" + "    0: =##0= pm;\n"
1101:                    + "    1,000: <##0.###< nm;\n"
1102:                    + "    1,000,000: <##0.###< \u00b5m;\n"
1103:                    + "    1,000,000,000: <##0.###< mm;\n";
1104:
1105:            /**
1106:             * A more complicated message-formatting example.  Here, in addition to
1107:             * handling the singular and plural versions of the word, the value is
1108:             * denominated in bytes, kilobytes, or megabytes depending on its magnitude.
1109:             * Also notice that it correctly treats a kilobyte as 1,024 bytes (not 1,000),
1110:             * and a megabyte as 1,024 kilobytes (not 1,000).
1111:             */
1112:            public static final String message2 =
1113:            // this rule supplies the shell of the sentence
1114:            "x.0: There << free space on the disk.;\n"
1115:                    // handle singular and plural forms of "byte" (and format 0 as
1116:                    // "There is no free space...")
1117:                    + "0: is no;\n"
1118:                    + "is one byte of;\n"
1119:                    + "are =0= bytes of;\n"
1120:                    // for values above 1,024, format the number in K (since "K" is usually
1121:                    // promounced "K" regardless of whether it's singular or plural, we
1122:                    // don't worry about the plural form).  The "/1024" here causes us to
1123:                    // treat a K as 1,024 bytes rather than 1,000 bytes.
1124:                    + "1024/1024: is <0<K of;\n"
1125:                    // for values about 1,048,576, format the number in Mb.  Since "Mb" is
1126:                    // usually promounced "meg" in singular and "megs" in plural, we do have
1127:                    // both singular and plural forms.  Again, notice we treat a megabyte
1128:                    // as 1,024 kilobytes.
1129:                    + "1,048,576/1024: is 1 Mb of;\n"
1130:                    + "2,097,152/1024: are <0< Mb of;";
1131:
1132:            //========================================================================
1133:            // Alternate radices
1134:            //========================================================================
1135:
1136:            /**
1137:             * This example formats a number in dozens and gross.  This is intended to
1138:             * demonstrate how this rule set can be used to format numbers in systems
1139:             * other than base 10.  The "/12" after the rules' base values controls this.
1140:             * Also notice that the base doesn't have to be consistent throughout the
1141:             * whole rule set: we go back to base 10 for values over 1,000.
1142:             */
1143:            public static final String dozens =
1144:            // words for numbers...
1145:            "zero; one; two; three; four; five; six;\n"
1146:                    + "seven; eight; nine; ten; eleven;\n"
1147:                    // format values over 12 in dozens
1148:                    + "12/12: << dozen[ and >>];\n"
1149:                    // format values over 144 in gross
1150:                    + "144/12: << gross[, >>];\n"
1151:                    // format values over 1,000 in thousands
1152:                    + "1000: << thousand[, >>];\n"
1153:                    // overflow rule.  Format values over 10,000 in numerals
1154:                    + "10,000: =#,##0=;\n";
1155:
1156:            //========================================================================
1157:            // Major and minor units
1158:            //
1159:            // These examples show how a single value can be divided up into major
1160:            // and minor units that don't relate to each other by a factor of 10.
1161:            //========================================================================
1162:
1163:            /**
1164:             * This example formats a number of seconds in sexagesimal notation
1165:             * (i.e., hours, minutes, and seconds).  %with-words formats it with
1166:             * words (3740 is "1 hour, 2 minutes, 20 seconds") and %in-numerals
1167:             * formats it entirely in numerals (3740 is "1:02:20").
1168:             */
1169:            public static final String durationInSeconds =
1170:            // main rule set for formatting with words
1171:            "%with-words:\n"
1172:                    // take care of singular and plural forms of "second"
1173:                    + "    0 seconds; 1 second; =0= seconds;\n"
1174:                    // use %%min to format values greater than 60 seconds
1175:                    + "    60/60: <%%min<[, >>];\n"
1176:                    // use %%hr to format values greater than 3,600 seconds
1177:                    // (the ">>>" below causes us to see the number of minutes
1178:                    // when when there are zero minutes)
1179:                    + "    3600/60: <%%hr<[, >>>];\n"
1180:                    // this rule set takes care of the singular and plural forms
1181:                    // of "minute"
1182:                    + "%%min:\n"
1183:                    + "    0 minutes; 1 minute; =0= minutes;\n"
1184:                    // this rule set takes care of the singular and plural forms
1185:                    // of "hour"
1186:                    + "%%hr:\n"
1187:                    + "    0 hours; 1 hour; =0= hours;\n"
1188:
1189:                    // main rule set for formatting in numerals
1190:                    + "%in-numerals:\n"
1191:                    // values below 60 seconds are shown with "sec."
1192:                    + "    =0= sec.;\n"
1193:                    // higher values are shown with colons: %%min-sec is used for
1194:                    // values below 3,600 seconds...
1195:                    + "    60: =%%min-sec=;\n"
1196:                    // ...and %%hr-min-sec is used for values of 3,600 seconds
1197:                    // and above
1198:                    + "    3600: =%%hr-min-sec=;\n"
1199:                    // this rule causes values of less than 10 minutes to show without
1200:                    // a leading zero
1201:                    + "%%min-sec:\n"
1202:                    + "    0: :=00=;\n"
1203:                    + "    60/60: <0<>>;\n"
1204:                    // this rule set is used for values of 3,600 or more.  Minutes are always
1205:                    // shown, and always shown with two digits
1206:                    + "%%hr-min-sec:\n" + "    0: :=00=;\n"
1207:                    + "    60/60: <00<>>;\n" + "    3600/60: <#,##0<:>>>;\n"
1208:                    // the lenient-parse rules allow several different characters to be used
1209:                    // as delimiters between hours, minutes, and seconds
1210:                    + "%%lenient-parse:\n" + "    & : = . = ' ' = -;\n";
1211:
1212:            /**
1213:             * This example formats a number of hours in sexagesimal notation (i.e.,
1214:             * hours, minutes, and seconds).  %with-words formats the value using
1215:             * words for the units, and %in-numerals formats the value using only
1216:             * numerals.
1217:             */
1218:            public static final String durationInHours =
1219:            // main entry point for formatting with words
1220:            "%with-words:\n"
1221:                    // this rule omits minutes and seconds when the value is
1222:                    // an even number of hours
1223:                    + "    x.0: <<[, >%%min-sec>];\n"
1224:                    // these rules take care of the singular and plural forms
1225:                    // of hours
1226:                    + "    0 hours; 1 hour; =#,##0= hours;\n"
1227:                    // this rule set takes the fractional part of the number and multiplies
1228:                    // it by 3,600 (turning it into a number of seconds).  Then it delegates
1229:                    // to %%min-sec-implementation to format the resulting value
1230:                    + "%%min-sec:\n"
1231:                    + "    3600: =%%min-sec-implementation=;\n"
1232:                    // this rule set formats the seconds as either seconds or minutes and
1233:                    // seconds, and takes care of the singular and plural forms of
1234:                    // "minute" and "second"
1235:                    + "%%min-sec-implementation:\n"
1236:                    + "    0 seconds; 1 second; =0= seconds;\n"
1237:                    + "    60/60: 1 minute[, >>];\n"
1238:                    + "    120/60: <0< minutes[, >>];\n"
1239:
1240:                    // main entry point for formatting in numerals
1241:                    + "%in-numerals:\n"
1242:                    // show minutes even for even numbers of hours
1243:                    + "    x.0: <#,##0<:00;\n"
1244:                    // delegate to %%min-sec2 to format minutes and seconds
1245:                    + "    x.x: <#,##0<:>%%min-sec2>;\n"
1246:                    // this rule set formats minutes when there is an even number of
1247:                    // minutes, and delegates to %%min-sec2-implementation when there
1248:                    // are seconds
1249:                    + "%%min-sec2:\n"
1250:                    + "    60: <00<;\n"
1251:                    + "    3600: <%%min-sec2-implementation<;\n"
1252:                    // these two rule sets are used to format the minutes and seconds
1253:                    + "%%min-sec2-implementation:\n"
1254:                    // if there are fewer than 60 seconds, show the minutes anyway
1255:                    + "    0: 00:=00=;\n"
1256:                    // if there are minutes, format them too, and always use 2 digits
1257:                    // for both minutes and seconds
1258:                    + "    60: =%%min-sec3=;\n" + "%%min-sec3:\n"
1259:                    + "    0: :=00=;\n" + "    60/60: <00<>>;\n"
1260:                    // the lenient-parse rules allow the user to use any of several
1261:                    // characters as delimiters between hours, minutes, and seconds
1262:                    + "%%lenient-parse:\n" + "    & : = . = ' ' = -;\n";
1263:
1264:            /**
1265:             * This rule set formats a number of pounds as pounds, shillings, and
1266:             * pence in the old English system of currency.
1267:             */
1268:            public static final String poundsShillingsAndPence =
1269:            // for values of 1 or more, format the integral part with a pound
1270:            // sign in front, and show shillings and pence if necessary
1271:            "%main:\n"
1272:                    + "    x.0: \u00a3<#,##0<[ >%%shillings-and-pence>];\n"
1273:                    // for values between 0 and 1, omit the number of pounds
1274:                    + "    0.x: >%%pence-alone>;\n"
1275:                    // this rule set is used to show shillings and pence.  It multiplies
1276:                    // the fractional part of the number by 240 (the number of pence in a
1277:                    // pound) and uses %%shillings-and-pence-implementation to format
1278:                    // the result
1279:                    + "%%shillings-and-pence:\n"
1280:                    + "    240: <%%shillings-and-pence-implementation<;\n"
1281:                    // this rule set is used to show shillings and pence when there are
1282:                    // no pounds.  It also multiplies the value by 240, and then it uses
1283:                    // %%pence-alone-implementation to format the result.
1284:                    + "%%pence-alone:\n"
1285:                    + "    240: <%%pence-alone-implementation<;\n"
1286:                    // this rule set formats a number of pence when we know we also
1287:                    // have pounds.  We always show shillings (with a 0 if necessary),
1288:                    // but only show pence if the value isn't an even number of shillings
1289:                    + "%%shillings-and-pence-implementation:\n"
1290:                    + "    0/; 0/=0=;\n"
1291:                    + "    12/12: <0</[>0>];\n"
1292:                    // this rule set formats a number of pence when we know there are
1293:                    // no pounds.  Values less than a shilling are shown with "d." (the
1294:                    // abbreviation for pence), and values greater than a shilling are
1295:                    // shown with a shilling bar (and without pence when the value is
1296:                    // an even number of shillings)
1297:                    + "%%pence-alone-implementation:\n" + "    =0= d.;\n"
1298:                    + "    12/12: <0</[>0>];\n";
1299:
1300:            //========================================================================
1301:            // Alternate numeration systems
1302:            //
1303:            // These examples show how RuleBasedNumberFormat can be used to format
1304:            // numbers using non-positional numeration systems.
1305:            //========================================================================
1306:
1307:            /**
1308:             * Arabic digits.  This example formats numbers in Arabic numerals.
1309:             * Normally, you'd do this with DecimalFormat, but this shows that
1310:             * RuleBasedNumberFormat can handle it too.
1311:             */
1312:            public static final String arabicNumerals = "0; 1; 2; 3; 4; 5; 6; 7; 8; 9;\n"
1313:                    + "10: <<>>;\n"
1314:                    + "100: <<>>>;\n"
1315:                    + "1000: <<,>>>;\n"
1316:                    + "1,000,000: <<,>>>;\n"
1317:                    + "1,000,000,000: <<,>>>;\n"
1318:                    + "1,000,000,000,000: <<,>>>;\n"
1319:                    + "1,000,000,000,000,000: =#,##0=;\n"
1320:                    + "-x: ->>;\n"
1321:                    + "x.x: <<.>>;";
1322:
1323:            /**
1324:             * Words for digits.  Follows the same pattern as the Arabic-numerals
1325:             * example above, but uses words for the various digits (e.g., 123 comes
1326:             * out as "one two three").
1327:             */
1328:            public static final String wordsForDigits = "-x: minus >>;\n"
1329:                    + "x.x: << point >>;\n"
1330:                    + "zero; one; two; three; four; five; six;\n"
1331:                    + "    seven; eight; nine;\n" + "10: << >>;\n"
1332:                    + "100: << >>>;\n" + "1000: <<, >>>;\n"
1333:                    + "1,000,000: <<, >>>;\n" + "1,000,000,000: <<, >>>;\n"
1334:                    + "1,000,000,000,000: <<, >>>;\n"
1335:                    + "1,000,000,000,000,000: =#,##0=;\n";
1336:
1337:            /**
1338:             * This example formats numbers using Chinese characters in the Arabic
1339:             * place-value method.  This was used historically in China for a while.
1340:             */
1341:            public static final String chinesePlaceValue = "\u3007; \u4e00; \u4e8c; \u4e09; \u56db; \u4e94; \u516d; \u4e03; \u516b; \u4e5d;\n"
1342:                    + "10: <<>>;\n"
1343:                    + "100: <<>>>;\n"
1344:                    + "1000: <<>>>;\n"
1345:                    + "1,000,000: <<>>>;\n"
1346:                    + "1,000,000,000: <<>>>;\n"
1347:                    + "1,000,000,000,000: <<>>>;\n"
1348:                    + "1,000,000,000,000,000: =#,##0=;\n";
1349:
1350:            /**
1351:             * Roman numerals.  This example has two variants: %modern shows how large
1352:             * numbers are usually handled today; %historical ses the older symbols for
1353:             * thousands.
1354:             */
1355:            public static final String romanNumerals = "%historical:\n"
1356:                    + "    =%modern=;\n"
1357:                    // in early Roman numerals, 1,000 was shown with a circle
1358:                    // bisected by a vertical line.  Additional thousands were
1359:                    // shown by adding more concentric circles, and fives were
1360:                    // shown by cutting the symbol for next-higher power of 10
1361:                    // in half (the letter D for 500 evolved from this).
1362:                    // We could go beyond 40,000, but Unicode doesn't encode
1363:                    // the symbols for higher numbers/
1364:                    + "    1000: \u2180[>>]; 2000: \u2180\u2180[>>]; 3000: \u2180\u2180\u2180[>>]; 4000: \u2180\u2181[>>];\n"
1365:                    + "    5000: \u2181[>>]; 6000: \u2181\u2180[>>]; 7000: \u2181\u2180\u2180[>>];\n"
1366:                    + "    8000: \u2181\u2180\u2180\u2180[>>]; 9000: \u2180\u2182[>>];\n"
1367:                    + "    10,000: \u2182[>>]; 20,000: \u2182\u2182[>>]; 30,000: \u2182\u2182\u2182[>>];\n"
1368:                    + "    40,000: =#,##0=;\n"
1369:                    + "%modern:\n"
1370:                    + "    ; I; II; III; IV; V; VI; VII; VIII; IX;\n"
1371:                    + "    10: X[>>]; 20: XX[>>]; 30: XXX[>>]; 40: XL[>>]; 50: L[>>];\n"
1372:                    + "    60: LX[>>]; 70: LXX[>>]; 80: LXXX[>>]; 90: XC[>>];\n"
1373:                    + "    100: C[>>]; 200: CC[>>]; 300: CCC[>>]; 400: CD[>>]; 500: D[>>];\n"
1374:                    + "    600: DC[>>]; 700: DCC[>>]; 800: DCCC[>>]; 900: CM[>>];\n"
1375:                    // in modern Roman numerals, high numbers are generally shown
1376:                    // by placing a bar over the letters for the lower numbers:
1377:                    // the bar multiplied a letter's value by 1,000
1378:                    + "    1000: M[>>]; 2000: MM[>>]; 3000: MMM[>>]; 4000: MV\u0306[>>];\n"
1379:                    + "    5000: V\u0306[>>]; 6000: V\u0306M[>>]; 7000: V\u0306MM[>>];\n"
1380:                    + "    8000: V\u0306MMM[>>]; 9000: MX\u0306[>>];\n"
1381:                    + "    10,000: X\u0306[>>]; 20,000: X\u0306X\u0306[>>]; 30,000: X\u0306X\u0306X\u0306[>>];\n"
1382:                    + "    40,000: X\u0306L\u0306[>>]; 50,000: L\u0306[>>]; 60,000: L\u0306X\u0306[>>];\n"
1383:                    + "    70,000: L\u0306X\u0306X\u0306[>>]; 80,000: L\u0306X\u0306X\u0306X\u0306[>>];\n"
1384:                    + "    90,000: X\u0306C\u0306[>>];\n"
1385:                    + "    100,000: C\u0306[>>]; 200,000: C\u0306C\u0306[>>]; 300,000: C\u0306C\u0306[>>];\n"
1386:                    + "    400,000: C\u0306D\u0306[>>]; 500,000: D\u0306[>>]; 600,000: D\u0306C\u0306[>>];\n"
1387:                    + "    700,000: D\u0306C\u0306C\u0306[>>]; 800,000: D\u0306C\u0306C\u0306C\u0306[>>];\n"
1388:                    + "    900,000: =#,##0=;\n";
1389:
1390:            /**
1391:             * Hebrew alphabetic numerals.  Before adoption of Arabic numerals, Hebrew speakers
1392:             * used the letter of their alphabet as numerals.  The first nine letters of
1393:             * the alphabet repesented the values from 1 to 9, the second nine letters the
1394:             * multiples of 10, and the remaining letters the multiples of 100.  Since they
1395:             * ran out of letters at 400, the remaining multiples of 100 were represented
1396:             * using combinations of the existing letters for the hundreds.  Numbers were
1397:             * distinguished from words in a number of different ways: the way shown here
1398:             * uses a single mark after a number consisting of one letter, and a double
1399:             * mark between the last two letters of a number consisting of two or more
1400:             * letters.  Two dots over a letter multiplied its value by 1,000.  Also, since
1401:             * the letter for 10 is the first letter of God's name and the letters for 5 and 6
1402:             * are letters in God's name, which wasn't supposed to be written or spoken, 15 and
1403:             * 16 were usually written as 9 + 6 and 9 + 7 instead of 10 + 5 and 10 + 6.
1404:             */
1405:            public static final String hebrewAlphabetic =
1406:            // letters for the ones
1407:            "%%ones:\n"
1408:                    + "    (no zero); \u05d0; \u05d1; \u05d2; \u05d3; \u05d4; \u05d5; \u05d6; \u05d7; \u05d8;\n"
1409:                    // letters for the tens
1410:                    + "%%tens:\n"
1411:                    + "    ; \u05d9; \u05db; \u05dc; \u05de; \u05e0; \u05e1; \u05e2; \u05e4; \u05e6;\n"
1412:                    // letters for the first four hundreds
1413:                    + "%%hundreds:\n"
1414:                    + "    ; \u05e7; \u05e8; \u05e9; \u05ea;\n"
1415:                    // this rule set is used to write the combination of the tens and ones digits
1416:                    // when we know that no other digits precede them: they put the numeral marks
1417:                    // in the right place and properly handle 15 and 16 (I'm using the mathematical
1418:                    // prime characters for the numeral marks because my Unicode font doesn't
1419:                    // include the real Hebrew characters, which look just like the prime marks)
1420:                    + "%%tens-and-ones:\n"
1421:                    // for values less than 10, just use %%ones and put the numeral mark
1422:                    // afterward
1423:                    + "    =%%ones=\u2032;\n"
1424:                    // put the numeral mark at the end for 10, but in the middle for
1425:                    // 11 through 14
1426:                    + "    10: <%%tens<\u2032; <%%tens<\u2033>%%ones>;\n"
1427:                    // special-case 15 and 16
1428:                    + "    15: \u05d8\u2033\u05d5; 16: \u05d8\u2033\u05d6;\n"
1429:                    // go back to the normal method at 17
1430:                    + "    17: <%%tens<\u2033>%%ones>;\n"
1431:                    // repeat the rules for 10 and 11 to cover the values from 20 to 99
1432:                    + "    20: <%%tens<\u2032; <%%tens<\u2033>%%ones>;\n"
1433:                    // this rule set is used to format numbers below 1,000.  It relies on
1434:                    // %%tens-and-ones to format the tens and ones places, and adds logic
1435:                    // to handle the high hundreds and the numeral marks when there is no
1436:                    // tens digit.  Notice how the rules are paired: all of these pairs of
1437:                    // rules take advantage of the rollback rule: if the value (between 100
1438:                    // and 499) is an even multiple of 100, the rule for 100 is used; otherwise,
1439:                    // the rule for 101 (the following rule) is used.  The first rule in each
1440:                    // pair (the one for the even multiple) places the numeral mark in a different
1441:                    // spot than the second rule in each pair (which knows there are more digits
1442:                    // and relies on the rule supplying them to also supply the numeral mark).
1443:                    // The call to %%null in line 10 is there simply to invoke the rollback
1444:                    // rule.
1445:                    + "%%low-order:\n"
1446:                    // this rule is only called when there are other characters before.
1447:                    // It places the numeral mark before the last digit
1448:                    + "    \u2033=%%ones=;\n"
1449:                    // the rule for 10 places the numeral mark before the 10 character
1450:                    // (because we know it's the last character); the rule for 11 relies
1451:                    // on %%tens-and-ones to place the numeral mark
1452:                    + "    10: \u2033<%%tens<; =%%tens-and-ones=>%%null>;\n"
1453:                    // the rule for 100 places the numeral mark before the 100 character
1454:                    // (we know it's the last character); the rule for 101 recurses to
1455:                    // fill in the remaining digits and the numeral mark
1456:                    + "    100: <%%hundreds<\u2032; <%%hundreds<>>;\n"
1457:                    // special-case the hundreds from 500 to 900 because they consist of
1458:                    // more than one character
1459:                    + "    500: \u05ea\u2033\u05e7; \u05ea\u05e7>>;\n"
1460:                    + "    600: \u05ea\u2033\u05e8; \u05ea\u05e8>>;\n"
1461:                    + "    700: \u05ea\u2033\u05e9; \u05ea\u05e9>>;\n"
1462:                    + "    800: \u05ea\u2033\u05ea; \u05ea\u05ea>>;\n"
1463:                    + "    900: \u05ea\u05ea\u2033\u05e7; \u05ea\u05ea\u05e7>>;\n"
1464:                    // this rule set is used to format values of 1,000 or more.  Here, we don't
1465:                    // worry about the numeral mark, and we add two dots (the Unicode combining
1466:                    // diaeresis character) to ever letter
1467:                    + "%%high-order:\n"
1468:                    // put the ones digit, followed by the diaeresis
1469:                    + "    =%%ones=\u0308;\n"
1470:                    // the tens can be handled with recursion
1471:                    + "    10: <%%tens<\u0308[>>];\n"
1472:                    // still have to special-case 15 and 16
1473:                    + "    15: \u05d8\u0308\u05d5\u0308; 16: \u05d8\u003078\u05d6\u0308;\n"
1474:                    // back to the regular rules at 17
1475:                    + "    17: <%%tens<\u0308[>>];\n"
1476:                    // the hundreds with the dots added (and without worrying about
1477:                    // placing the numeral mark)
1478:                    + "    100: <%%hundreds<\u0308[>>];\n"
1479:                    + "    500: \u05ea\u0308\u05e7\u0308[>>];\n"
1480:                    + "    600: \u05ea\u0308\u05e8\u0308[>>];\n"
1481:                    + "    700: \u05ea\u0308\u05e9\u0308[>>];\n"
1482:                    + "    800: \u05ea\u0308\u05ea\u0308[>>];\n"
1483:                    + "    900: \u05ea\u0308\u05ea\u0308\u05e7\u0308[>>];\n"
1484:                    // this rule set doesn't do anything; it's used by some other rules to
1485:                    // invoke the rollback rule
1486:                    + " %%null:\n" + "    ;\n"
1487:                    // the main rule set.
1488:                    + "%main:\n"
1489:                    // for values below 10, just output the letter and the numeral mark
1490:                    + "    =%%ones=\u2032;\n"
1491:                    // for values from 10 to 99, use %%tens-and-ones to do the formatting
1492:                    + "    10: =%%tens-and-ones=;\n"
1493:                    // for values from 100 to 999, use %%low-order to do the formatting
1494:                    + "    100: =%%low-order=;\n"
1495:                    // for values of 1,000 and over, use %%high-order to do the formatting
1496:                    + "    1000: <%%high-order<[>%%low-order>];\n";
1497:
1498:            /**
1499:             * Greek alphabetic numerals.  The Greeks, before adopting the Arabic numerals,
1500:             * also used the letters of their alphabet as numerals.  There are three now-
1501:             * obsolete Greek letters that are used as numerals; many fonts don't have them.
1502:             * Large numbers were handled many different ways; the way shown here divides
1503:             * large numbers into groups of four letters (factors of 10,000), and separates
1504:             * the groups with the capital letter mu (for myriad).  Capital letters are used
1505:             * for values below 10,000; small letters for higher numbers (to make the capital
1506:             * mu stand out).
1507:             */
1508:            public static final String greekAlphabetic =
1509:            // this rule set is used for formatting numbers below 10,000.  It uses
1510:            // capital letters.
1511:            "%%low-order:\n"
1512:                    + "    (no zero); \u0391; \u0392; \u0393; \u0394; \u0395; \u03dc; \u0396; \u0397; \u0398;\n"
1513:                    + "    10: \u0399[>>]; 20: \u039a[>>]; 30: \u039b[>>]; 40: \u039c[>>]; 50: \u039d[>>];\n"
1514:                    + "    60: \u039e[>>]; 70: \u039f[>>]; 80: \u03a0[>>]; 90: \u03de[>>];\n"
1515:                    + "    100: \u03a1[>>]; 200: \u03a3[>>]; 300: \u03a4[>>]; 400: \u03a5[>>];\n"
1516:                    + "    500: \u03a6[>>]; 600: \u03a7[>>]; 700: \u03a8[>>]; 800: \u03a9[>>];\n"
1517:                    + "    900: \u03e0[>>];\n"
1518:                    // the thousands are represented by the same numbers as the ones, but
1519:                    // with a comma-like mark added to their left shoulder
1520:                    + "    1000: \u0391\u0313[>>]; 2000: \u0392\u0313[>>]; 3000: \u0393\u0313[>>];\n"
1521:                    + "    4000: \u0394\u0313[>>]; 5000: \u0395\u0313[>>]; 6000: \u03dc\u0313[>>];\n"
1522:                    + "    7000: \u0396\u0313[>>]; 8000: \u0397\u0313[>>]; 9000: \u0398\u0313[>>];\n"
1523:                    // this rule set is the same as above, but uses lowercase letters.  It is used
1524:                    // for formatting the groups in numbers above 10,000.
1525:                    + "%%high-order:\n"
1526:                    + "    (no zero); \u03b1; \u03b2; \u03b3; \u03b4; \u03b5; \u03dc; \u03b6; \u03b7; \u03b8;\n"
1527:                    + "    10: \u03b9[>>]; 20: \u03ba[>>]; 30: \u03bb[>>]; 40: \u03bc[>>]; 50: \u03bd[>>];\n"
1528:                    + "    60: \u03be[>>]; 70: \u03bf[>>]; 80: \u03c0[>>]; 90: \u03de[>>];\n"
1529:                    + "    100: \u03c1[>>]; 200: \u03c3[>>]; 300: \u03c4[>>]; 400: \u03c5[>>];\n"
1530:                    + "    500: \u03c6[>>]; 600: \u03c7[>>]; 700: \u03c8[>>]; 800: \u03c9[>>];\n"
1531:                    + "    900: \u03c0[>>];\n"
1532:                    + "    1000: \u03b1\u0313[>>]; 2000: \u03b2\u0313[>>]; 3000: \u03b3\u0313[>>];\n"
1533:                    + "    4000: \u03b4\u0313[>>]; 5000: \u03b5\u0313[>>]; 6000: \u03dc\u0313[>>];\n"
1534:                    + "    7000: \u03b6\u0313[>>]; 8000: \u03b7\u0313[>>]; 9000: \u03b8\u0313[>>];\n"
1535:                    // the main rule set
1536:                    + "%main:\n"
1537:                    // for values below 10,000, just use %%low-order
1538:                    + "    =%%low-order=;\n"
1539:                    // for values above 10,000, split into two groups of four digits
1540:                    // and format each with %%high-order (putting an M in betwen)
1541:                    + "    10,000: <%%high-order<\u039c>%%high-order>;\n"
1542:                    // for values above 100,000,000, add another group onto the front
1543:                    // and another M
1544:                    + "    100,000,000: <%%high-order<\u039c>>\n";
1545:
1546:            /**
1547:             * A list of all the sample rule sets, used by the demo program.
1548:             */
1549:            public static final String[] sampleRuleSets = { usEnglish,
1550:                    ukEnglish, spanish, french, swissFrench, german, italian,
1551:                    swedish, dutch, japanese, greek, russian, hebrew, ordinal,
1552:                    message1, dollarsAndCents, decimalAsFraction,
1553:                    closestFraction, stock, abbEnglish, units, message2,
1554:                    dozens, durationInSeconds, durationInHours,
1555:                    poundsShillingsAndPence, arabicNumerals, wordsForDigits,
1556:                    chinesePlaceValue, romanNumerals, hebrewAlphabetic,
1557:                    greekAlphabetic };
1558:
1559:            /**
1560:             * The displayable names for all the sample rule sets, in the same order as
1561:             * the preceding array.
1562:             */
1563:            public static final String[] sampleRuleSetNames = { "English (US)",
1564:                    "English (UK)", "Spanish", "French (France)",
1565:                    "French (Switzerland)", "German", "Italian", "Swedish",
1566:                    "Dutch", "Japanese", "Greek", "Russian", "Hebrew",
1567:                    "English ordinal abbreviations",
1568:                    "Simple message formatting", "Dollars and cents",
1569:                    "Decimals as fractions", "Closest fraction",
1570:                    "Stock prices", "Abbreviated US English",
1571:                    "Changing dimensions", "Complex message formatting",
1572:                    "Dozens", "Duration (value in seconds)",
1573:                    "Duration (value in hours)",
1574:                    "Pounds, shillings, and pence", "Arabic numerals",
1575:                    "Words for digits", "Chinese place-value notation",
1576:                    "Roman numerals", "Hebrew ahlphabetic numerals",
1577:                    "Greek alphabetic numerals" };
1578:
1579:            /**
1580:             * The base locale for each of the sample rule sets.  The locale is used to
1581:             * determine DecimalFormat behavior, lenient-parse behavior, and text-display
1582:             * selection (we have a hack in here to allow display of non-Latin scripts).
1583:             * Null means the locale setting is irrelevant and the default can be used.
1584:             */
1585:            public static final Locale[] sampleRuleSetLocales = { Locale.US,
1586:                    Locale.UK, new Locale("es", "", ""), Locale.FRANCE,
1587:                    new Locale("fr", "CH", ""), Locale.GERMAN, Locale.ITALIAN,
1588:                    new Locale("sv", "", ""), new Locale("nl", "", ""),
1589:                    Locale.JAPANESE, new Locale("el", "", ""),
1590:                    new Locale("ru", "", ""), new Locale("iw", "", ""),
1591:                    Locale.ENGLISH, Locale.ENGLISH, Locale.US, Locale.ENGLISH,
1592:                    null, null, Locale.ENGLISH, null, Locale.ENGLISH,
1593:                    Locale.ENGLISH, null, null, Locale.UK, null,
1594:                    Locale.ENGLISH, new Locale("zh", "", ""), null,
1595:                    new Locale("iw", "", ""), new Locale("el", "", ""), null };
1596:
1597:            public static final String[] sampleRuleSetCommentary = {
1598:                    "This demonstration version of the "
1599:                            + "U.S. English spellout rules has four variants: 1) %simplified is a "
1600:                            + "set of rules showing the simple method of spelling out numbers in "
1601:                            + "English: 289 is formatted as \"two hundred eighty-nine\".  2) %alt-teens "
1602:                            + "is the same as %simplified, except that values between 1,000 and 9,999 "
1603:                            + "whose hundreds place isn't zero are formatted in hundreds.  For example, "
1604:                            + "1,983 is formatted as \"nineteen hundred eighty-three,\" and 2,183 is "
1605:                            + "formatted as \"twenty-one hundred eighty-three,\" but 2,083 is still "
1606:                            + "formatted as \"two thousand eighty-three.\"  3) %ordinal formats the "
1607:                            + "values as ordinal numbers in English (e.g., 289 is \"two hundred eighty-"
1608:                            + "ninth\").  4) %default uses a more complicated algorithm to format "
1609:                            + "numbers in a more natural way: 289 is formatted as \"two hundred AND "
1610:                            + "eighty-nine\" and commas are inserted between the thousands groups for "
1611:                            + "values above 100,000.",
1612:
1613:                    "U.K. English has one significant "
1614:                            + "difference from U.S. English: the names for values of 1,000,000,000 "
1615:                            + "and higher.  In American English, each successive \"-illion\" is 1,000 "
1616:                            + "times greater than the preceding one: 1,000,000,000 is \"one billion\" "
1617:                            + "and 1,000,000,000,000 is \"one trillion.\"  In British English, each "
1618:                            + "successive \"-illion\" is one million times greater than the one before: "
1619:                            + "\"one billion\" is 1,000,000,000,000 (or what Americans would call a "
1620:                            + "\"trillion\"), and \"one trillion\" is 1,000,000,000,000,000,000.  "
1621:                            + "1,000,000,000 in British English is \"one thousand million.\"  (This "
1622:                            + "value is sometimes called a \"milliard,\" but this word seems to have "
1623:                            + "fallen into disuse.)",
1624:
1625:                    "The Spanish rules are quite similar to "
1626:                            + "the English rules, but there are some important differences: "
1627:                            + "First, we have to provide separate rules for most of the twenties "
1628:                            + "because the ones digit frequently picks up an accent mark that it "
1629:                            + "doesn't have when standing alone.  Second, each multiple of 100 has "
1630:                            + "to be specified separately because the multiplier on 100 very often "
1631:                            + "changes form in the contraction: 500 is \"quinientos,\" not "
1632:                            + "\"cincocientos.\"  In addition, the word for 100 is \"cien\" when "
1633:                            + "standing alone, but changes to \"ciento\" when followed by more digits.  "
1634:                            + "There also some other differences.",
1635:
1636:                    "French adds some interesting quirks of its "
1637:                            + "own: 1) The word \"et\" is interposed between the tens and ones digits, "
1638:                            + "but only if the ones digit if 1: 20 is \"vingt,\" and 2 is \"vingt-deux,\" "
1639:                            + "but 21 is \"vingt-et-un.\"  2)  There are no words for 70, 80, or 90.  "
1640:                            + "\"quatre-vingts\" (\"four twenties\") is used for 80, and values proceed "
1641:                            + "by score from 60 to 99 (e.g., 73 is \"soixante-treize\" [\"sixty-thirteen\"]).  "
1642:                            + "Numbers from 1,100 to 1,199 are rendered as hundreds rather than "
1643:                            + "thousands: 1,100 is \"onze cents\" (\"eleven hundred\"), rather than "
1644:                            + "\"mille cent\" (\"one thousand one hundred\")",
1645:
1646:                    "Swiss French differs from French French "
1647:                            + "in that it does have words for 70, 80, and 90.  This rule set shows them, "
1648:                            + "and is simpler as a result.",
1649:
1650:                    "German also adds some interesting "
1651:                            + "characteristics.  For values below 1,000,000, numbers are customarily "
1652:                            + "written out as a single word.  And the ones digit PRECEDES the tens "
1653:                            + "digit (e.g., 23 is \"dreiundzwanzig,\" not \"zwanzigunddrei\").",
1654:
1655:                    "Like German, most Italian numbers are "
1656:                            + "written as single words.  What makes these rules complicated is the rule "
1657:                            + "that says that when a word ending in a vowel and a word beginning with "
1658:                            + "a vowel are combined into a compound, the vowel is dropped from the "
1659:                            + "end of the first word: 180 is \"centottanta,\" not \"centoottanta.\"  "
1660:                            + "The complexity of this rule set is to produce this behavior.",
1661:
1662:                    "Spellout rules for Swedish.",
1663:
1664:                    "Spellout rules for Dutch.  Notice that in Dutch, as in German,"
1665:                            + "the ones digit precedes the tens digit.",
1666:
1667:                    "In Japanese, there really isn't any "
1668:                            + "distinction between a number written out in digits and a number "
1669:                            + "written out in words: the ideographic characters are both digits "
1670:                            + "and words.  This rule set provides two variants:  %traditional "
1671:                            + "uses the traditional CJK numerals (which are also used in China "
1672:                            + "and Korea).  %financial uses alternate ideographs for many numbers "
1673:                            + "that are harder to alter than the traditional numerals (one could "
1674:                            + "fairly easily change a one to "
1675:                            + "a three just by adding two strokes, for example).  This is also done in "
1676:                            + "the other countries using Chinese idographs, but different ideographs "
1677:                            + "are used in those places.",
1678:
1679:                    "Again in Greek we have to supply the words "
1680:                            + "for the multiples of 100 because they can't be derived algorithmically.  "
1681:                            + "Also, the tens dgit changes form when followed by a ones digit: an "
1682:                            + "accent mark disappears from the tens digit and moves to the ones digit.  "
1683:                            + "Therefore, instead of using the [] notation, we actually have to use "
1684:                            + "two separate rules for each multiple of 10 to show the two forms of "
1685:                            + "the word.",
1686:
1687:                    "Spellout rules for Russian.",
1688:
1689:                    "Spellout rules for Hebrew.  Hebrew actually has inflected forms for "
1690:                            + "most of the lower-order numbers.  The masculine forms are shown "
1691:                            + "here.",
1692:
1693:                    "This rule set adds an English ordinal abbreviation to the end of a "
1694:                            + "number.  For example, 2 is formatted as \"2nd\".  Parsing doesn't work with "
1695:                            + "this rule set.  To parse, use DecimalFormat on the numeral.",
1696:
1697:                    "This is a simple message-formatting example.  Normally one would "
1698:                            + "use ChoiceFormat and MessageFormat to do something this simple, "
1699:                            + "but this shows it could be done with RuleBasedNumberFormat too.  "
1700:                            + "A message-formatting example that might work better with "
1701:                            + "RuleBasedNumberFormat appears later.",
1702:
1703:                    "The next few examples demonstrate fraction handling.  "
1704:                            + "This example formats a number in one of the two styles often used "
1705:                            + "on checks.  %dollars-and-hundredths formats cents as hundredths of "
1706:                            + "a dollar (23.40 comes out as \"twenty-three and 40/100 dollars\").  "
1707:                            + "%dollars-and-cents formats in dollars and cents (23.40 comes out as "
1708:                            + "\"twenty-three dollars and forty cents\")",
1709:
1710:                    "This rule set shows the fractional part of the number as a fraction "
1711:                            + "with a power of 10 as the denominator.  Some languages don't spell "
1712:                            + "out the fractional part of a number as \"point one two three,\" but "
1713:                            + "always render it as a fraction.  If we still want to treat the fractional "
1714:                            + "part of the number as a decimal, then the fraction's denominator "
1715:                            + "is always a power of 10.  This example does that: 23.125 is formatted "
1716:                            + "as \"twenty-three and one hundred twenty-five thousandths\" (as opposed "
1717:                            + "to \"twenty-three point one two five\" or \"twenty-three and one eighth\").",
1718:
1719:                    "Number with closest fraction.  This example formats a value using "
1720:                            + "numerals, but shows the fractional part as a ratio (fraction) rather "
1721:                            + "than a decimal.  The fraction always has a denominator between 2 and 10.",
1722:
1723:                    "American stock-price formatting.  Non-integral stock prices are still "
1724:                            + "generally shown in eighths or sixteenths of dollars instead of dollars "
1725:                            + "and cents.  This example formats stock prices in this way if possible, "
1726:                            + "and in dollars and cents if not.",
1727:
1728:                    "The next few examples demonstrate using a RuleBasedNumberFormat to "
1729:                            + "change the units a value is denominated in depending on its magnitude.  "
1730:                            + "The example shows large numbers the way they often appear is nwespapers: "
1731:                            + "1,200,000 is formatted as \"1.2 million\".",
1732:
1733:                    "This example takes a number of meters and formats it in whatever unit "
1734:                            + "will produce a number with from one to three digits before the decimal "
1735:                            + "point.  For example, 230,000 is formatted as \"230 km\".",
1736:
1737:                    "A more complicated message-formatting example.  Here, in addition to "
1738:                            + "handling the singular and plural versions of the word, the value is "
1739:                            + "denominated in bytes, kilobytes, or megabytes depending on its magnitude.  "
1740:                            + "Also notice that it correctly treats a kilobyte as 1,024 bytes (not 1,000), "
1741:                            + "and a megabyte as 1,024 kilobytes (not 1,000).",
1742:
1743:                    "This example formats a number in dozens and gross.  This is intended to "
1744:                            + "demonstrate how this rule set can be used to format numbers in systems "
1745:                            + "other than base 10.  The \"/12\" after the rules' base values controls this.  "
1746:                            + "Also notice that the base doesn't have to be consistent throughout the "
1747:                            + "whole rule set: we go back to base 10 for values over 1,000.",
1748:
1749:                    "The next few examples show how a single value can be divided up into major "
1750:                            + "and minor units that don't relate to each other by a factor of 10.  "
1751:                            + "This example formats a number of seconds in sexagesimal notation "
1752:                            + "(i.e., hours, minutes, and seconds).  %with-words formats it with "
1753:                            + "words (3740 is \"1 hour, 2 minutes, 20 seconds\") and %in-numerals "
1754:                            + "formats it entirely in numerals (3740 is \"1:02:20\").",
1755:
1756:                    "This example formats a number of hours in sexagesimal notation (i.e., "
1757:                            + "hours, minutes, and seconds).  %with-words formats the value using "
1758:                            + "words for the units, and %in-numerals formats the value using only "
1759:                            + "numerals.",
1760:
1761:                    "This rule set formats a number of pounds as pounds, shillings, and "
1762:                            + "pence in the old English system of currency.",
1763:
1764:                    "These examples show how RuleBasedNumberFormat can be used to format "
1765:                            + "numbers using non-positional numeration systems.  "
1766:                            + "This example formats numbers in Arabic numerals.  "
1767:                            + "Normally, you'd do this with DecimalFormat, but this shows that "
1768:                            + "RuleBasedNumberFormat can handle it too.",
1769:
1770:                    "This example follows the same pattern as the Arabic-numerals "
1771:                            + "example, but uses words for the various digits (e.g., 123 comes "
1772:                            + "out as \"one two three\").",
1773:
1774:                    "This example formats numbers using Chinese characters in the Arabic "
1775:                            + "place-value method.  This was used historically in China for a while.",
1776:
1777:                    "Roman numerals.  This example has two variants: %modern shows how large "
1778:                            + "numbers are usually handled today; %historical ses the older symbols for "
1779:                            + "thousands.  Not all of the characters are displayable with most fonts.",
1780:
1781:                    "Hebrew alphabetic numerals.  Before adoption of Arabic numerals, Hebrew speakers "
1782:                            + "used the letter of their alphabet as numerals.  The first nine letters of "
1783:                            + "the alphabet repesented the values from 1 to 9, the second nine letters the "
1784:                            + "multiples of 10, and the remaining letters the multiples of 100.  Since they "
1785:                            + "ran out of letters at 400, the remaining multiples of 100 were represented "
1786:                            + "using combinations of the existing letters for the hundreds.  Numbers were "
1787:                            + "distinguished from words in a number of different ways: the way shown here "
1788:                            + "uses a single mark after a number consisting of one letter, and a double "
1789:                            + "mark between the last two letters of a number consisting of two or more "
1790:                            + "letters.  Two dots over a letter multiplied its value by 1,000.  Also, since "
1791:                            + "the letter for 10 is the first letter of God's name and the letters for 5 and 6 "
1792:                            + "are letters in God's name, which wasn't supposed to be written or spoken, 15 and "
1793:                            + "16 were usually written as 9 + 6 and 9 + 7 instead of 10 + 5 and 10 + 6.",
1794:
1795:                    "Greek alphabetic numerals.  The Greeks, before adopting the Arabic numerals, "
1796:                            + "also used the letters of their alphabet as numerals.  There are three now-"
1797:                            + "obsolete Greek letters that are used as numerals; many fonts don't have them.  "
1798:                            + "Large numbers were handled many different ways; the way shown here divides "
1799:                            + "large numbers into groups of four letters (factors of 10,000), and separates "
1800:                            + "the groups with the capital letter mu (for myriad).  Capital letters are used "
1801:                            + "for values below 10,000; small letters for higher numbers (to make the capital "
1802:                            + "mu stand out).",
1803:
1804:                    "This is a custom (user-defined) rule set." };
1805:        }
