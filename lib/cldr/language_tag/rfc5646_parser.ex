# Generated from lib/cldr/language_tag/rfc5646_parser.ex.exs, do not edit.
# Generated at 2021-08-20 10:43:22Z.

defmodule Cldr.Rfc5646.Parser do
  @moduledoc """
  Implements parsing for [RFC5646](https://datatracker.ietf.org/doc/html/rfc5646) language
  tags with [BCP47](https://tools.ietf.org/search/bcp47) extensions.

  The primary interface to this module is the function
  `Cldr.LanguageTag.parse/1`.

  """

  alias Cldr.LanguageTag

  import Cldr.Rfc5646.Helpers

  def parse(rule \\ :language_tag, input) when is_atom(rule) and is_binary(input) do
    apply(__MODULE__, rule, [input])
    |> unwrap
  end

  defp unwrap({:ok, acc, "", _, _, _}) when is_list(acc),
    do: {:ok, acc}

  defp unwrap({:error, <<first::binary-size(1), reason::binary>>, rest, _, _, offset}),
    do:
      {:error,
       {LanguageTag.ParseError,
        "#{String.capitalize(first)}#{reason}. Could not parse the remaining #{inspect(rest)} " <>
          "starting at position #{offset + 1}"}}

  @doc """
  Parses the given `binary` as language_tag.

  Returns `{:ok, [token], rest, context, position, byte_offset}` or
  `{:error, reason, rest, context, line, byte_offset}` where `position`
  describes the location of the language_tag (start position) as `{line, column_on_line}`.

  ## Options

    * `:byte_offset` - the byte offset for the whole binary, defaults to 0
    * `:line` - the line and the byte offset into that line, defaults to `{1, byte_offset}`
    * `:context` - the initial context value. It will be converted to a map

  """
  @spec language_tag(binary, keyword) ::
          {:ok, [term], rest, context, line, byte_offset}
          | {:error, reason, rest, context, line, byte_offset}
        when line: {pos_integer, byte_offset},
             byte_offset: pos_integer,
             rest: binary,
             reason: String.t(),
             context: map()
  def language_tag(binary, opts \\ []) when is_binary(binary) do
    context = Map.new(Keyword.get(opts, :context, []))
    byte_offset = Keyword.get(opts, :byte_offset, 0)

    line =
      case(Keyword.get(opts, :line, 1)) do
        {_, _} = line ->
          line

        line ->
          {line, byte_offset}
      end

    case(language_tag__0(binary, [], [], context, line, byte_offset)) do
      {:ok, acc, rest, context, line, offset} ->
        {:ok, :lists.reverse(acc), rest, context, line, offset}

      {:error, _, _, _, _, _} = error ->
        error
    end
  end

  defp language_tag__0(rest, acc, stack, context, line, offset) do
    language_tag__39(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__2(rest, acc, stack, context, line, offset) do
    language_tag__3(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__3(rest, acc, stack, context, line, offset) do
    language_tag__10(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__5(rest, acc, stack, context, line, offset) do
    language_tag__6(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__6(
         <<"art-lojban", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__7(rest, ["art-lojban"] ++ acc, stack, context, comb__line, comb__offset + 10)
  end

  defp language_tag__6(
         <<"cel-gaulish", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__7(rest, ["cel-gaulish"] ++ acc, stack, context, comb__line, comb__offset + 11)
  end

  defp language_tag__6(<<"no-bok", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__7(rest, ["no-bok"] ++ acc, stack, context, comb__line, comb__offset + 6)
  end

  defp language_tag__6(<<"no-nyn", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__7(rest, ["no-nyn"] ++ acc, stack, context, comb__line, comb__offset + 6)
  end

  defp language_tag__6(
         <<"zh-guoyu", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__7(rest, ["zh-guoyu"] ++ acc, stack, context, comb__line, comb__offset + 8)
  end

  defp language_tag__6(
         <<"zh-hakka", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__7(rest, ["zh-hakka"] ++ acc, stack, context, comb__line, comb__offset + 8)
  end

  defp language_tag__6(<<"zh-min", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__7(rest, ["zh-min"] ++ acc, stack, context, comb__line, comb__offset + 6)
  end

  defp language_tag__6(
         <<"zh-min-nan", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__7(rest, ["zh-min-nan"] ++ acc, stack, context, comb__line, comb__offset + 10)
  end

  defp language_tag__6(
         <<"zh-xiang", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__7(rest, ["zh-xiang"] ++ acc, stack, context, comb__line, comb__offset + 8)
  end

  defp language_tag__6(rest, _acc, _stack, context, line, offset) do
    {:error,
     "expected one of the regular language tags in BCP-47 while processing a grandfathered language tag inside a BCP47 language tag",
     rest, context, line, offset}
  end

  defp language_tag__7(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__8(
      rest,
      [
        regular:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__8(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__4(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__9(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__5(rest, [], stack, context, line, offset)
  end

  defp language_tag__10(rest, acc, stack, context, line, offset) do
    language_tag__11(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__11(
         <<"en-GB-oed", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["en-GB-oed"] ++ acc, stack, context, comb__line, comb__offset + 9)
  end

  defp language_tag__11(<<"i-ami", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-ami"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(<<"i-bnn", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-bnn"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(
         <<"i-default", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["i-default"] ++ acc, stack, context, comb__line, comb__offset + 9)
  end

  defp language_tag__11(
         <<"i-enochian", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["i-enochian"] ++ acc, stack, context, comb__line, comb__offset + 10)
  end

  defp language_tag__11(<<"i-hak", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-hak"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(
         <<"i-klingon", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["i-klingon"] ++ acc, stack, context, comb__line, comb__offset + 9)
  end

  defp language_tag__11(<<"i-lux", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-lux"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(
         <<"i-mingo", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["i-mingo"] ++ acc, stack, context, comb__line, comb__offset + 7)
  end

  defp language_tag__11(
         <<"i-navajo", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["i-navajo"] ++ acc, stack, context, comb__line, comb__offset + 8)
  end

  defp language_tag__11(<<"i-pwn", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-pwn"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(<<"i-tao", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-tao"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(<<"i-tay", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-tay"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(<<"i-tsu", rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__12(rest, ["i-tsu"] ++ acc, stack, context, comb__line, comb__offset + 5)
  end

  defp language_tag__11(
         <<"sgn-BE-FR", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["sgn-BE-FR"] ++ acc, stack, context, comb__line, comb__offset + 9)
  end

  defp language_tag__11(
         <<"sgn-BE-NL", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["sgn-BE-NL"] ++ acc, stack, context, comb__line, comb__offset + 9)
  end

  defp language_tag__11(
         <<"sgn-CH-DE", rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       ) do
    language_tag__12(rest, ["sgn-CH-DE"] ++ acc, stack, context, comb__line, comb__offset + 9)
  end

  defp language_tag__11(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__9(rest, acc, stack, context, line, offset)
  end

  defp language_tag__12(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__13(
      rest,
      [
        irregular:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__13(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__4(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__4(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__14(
      rest,
      [grandfathered: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__14(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__15(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__2(rest, [], stack, context, line, offset)
  end

  defp language_tag__16(rest, acc, stack, context, line, offset) do
    language_tag__17(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__17(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 120 or x0 === 88) and x1 === 45 do
    language_tag__18(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp language_tag__17(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__15(rest, acc, stack, context, line, offset)
  end

  defp language_tag__18(rest, acc, stack, context, line, offset) do
    language_tag__19(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__19(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__20(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__19(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__15(rest, acc, stack, context, line, offset)
  end

  defp language_tag__20(rest, acc, stack, context, line, offset) do
    language_tag__22(rest, acc, [7 | stack], context, line, offset)
  end

  defp language_tag__22(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__23(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__22(rest, acc, stack, context, line, offset) do
    language_tag__21(rest, acc, stack, context, line, offset)
  end

  defp language_tag__21(rest, acc, [_ | stack], context, line, offset) do
    language_tag__24(rest, acc, stack, context, line, offset)
  end

  defp language_tag__23(rest, acc, [1 | stack], context, line, offset) do
    language_tag__24(rest, acc, stack, context, line, offset)
  end

  defp language_tag__23(rest, acc, [count | stack], context, line, offset) do
    language_tag__22(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__24(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__25(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__25(rest, acc, stack, context, line, offset) do
    language_tag__27(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__27(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__28(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__27(rest, acc, stack, context, line, offset) do
    language_tag__26(rest, acc, stack, context, line, offset)
  end

  defp language_tag__28(rest, acc, stack, context, line, offset) do
    language_tag__29(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__29(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__30(rest, [<<x0::integer>>] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__29(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__26(rest, acc, stack, context, line, offset)
  end

  defp language_tag__30(rest, acc, stack, context, line, offset) do
    language_tag__32(rest, acc, [7 | stack], context, line, offset)
  end

  defp language_tag__32(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__33(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__32(rest, acc, stack, context, line, offset) do
    language_tag__31(rest, acc, stack, context, line, offset)
  end

  defp language_tag__31(rest, acc, [_ | stack], context, line, offset) do
    language_tag__34(rest, acc, stack, context, line, offset)
  end

  defp language_tag__33(rest, acc, [1 | stack], context, line, offset) do
    language_tag__34(rest, acc, stack, context, line, offset)
  end

  defp language_tag__33(rest, acc, [count | stack], context, line, offset) do
    language_tag__32(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__34(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__35(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__26(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__36(rest, acc, stack, context, line, offset)
  end

  defp language_tag__35(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__27(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__36(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__37(
      rest,
      [private_use: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__37(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__38(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__16(rest, [], stack, context, line, offset)
  end

  defp language_tag__39(rest, acc, stack, context, line, offset) do
    language_tag__40(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__40(rest, acc, stack, context, line, offset) do
    language_tag__41(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__41(rest, acc, stack, context, line, offset) do
    language_tag__42(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__42(rest, acc, stack, context, line, offset) do
    language_tag__180(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__44(rest, acc, stack, context, line, offset) do
    language_tag__45(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__45(rest, acc, stack, context, line, offset) do
    language_tag__46(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__46(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) do
    language_tag__47(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__46(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, _, acc | stack] = stack
    language_tag__38(rest, acc, stack, context, line, offset)
  end

  defp language_tag__47(rest, acc, stack, context, line, offset) do
    language_tag__49(rest, acc, [1 | stack], context, line, offset)
  end

  defp language_tag__49(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) do
    language_tag__50(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__49(rest, acc, stack, context, line, offset) do
    language_tag__48(rest, acc, stack, context, line, offset)
  end

  defp language_tag__48(rest, acc, [_ | stack], context, line, offset) do
    language_tag__51(rest, acc, stack, context, line, offset)
  end

  defp language_tag__50(rest, acc, [1 | stack], context, line, offset) do
    language_tag__51(rest, acc, stack, context, line, offset)
  end

  defp language_tag__50(rest, acc, [count | stack], context, line, offset) do
    language_tag__49(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__51(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__52(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__52(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__53(
      rest,
      [
        language:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__53(rest, acc, stack, context, line, offset) do
    language_tag__57(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__55(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__54(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__56(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__55(rest, [], stack, context, line, offset)
  end

  defp language_tag__57(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__58(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__57(rest, acc, stack, context, line, offset) do
    language_tag__56(rest, acc, stack, context, line, offset)
  end

  defp language_tag__58(rest, acc, stack, context, line, offset) do
    language_tag__59(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__59(rest, acc, stack, context, line, offset) do
    language_tag__61(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__61(rest, acc, stack, context, line, offset) do
    language_tag__66(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__63(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__64(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__63(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__60(rest, acc, stack, context, line, offset)
  end

  defp language_tag__64(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__62(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__65(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__63(rest, [], stack, context, line, offset)
  end

  defp language_tag__66(rest, acc, stack, context, line, offset) do
    language_tag__67(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__67(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__68(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__67(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__65(rest, acc, stack, context, line, offset)
  end

  defp language_tag__68(rest, acc, stack, context, line, offset) do
    language_tag__70(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__70(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__71(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__70(rest, acc, stack, context, line, offset) do
    language_tag__69(rest, acc, stack, context, line, offset)
  end

  defp language_tag__69(rest, acc, [_ | stack], context, line, offset) do
    language_tag__72(rest, acc, stack, context, line, offset)
  end

  defp language_tag__71(rest, acc, [1 | stack], context, line, offset) do
    language_tag__72(rest, acc, stack, context, line, offset)
  end

  defp language_tag__71(rest, acc, [count | stack], context, line, offset) do
    language_tag__70(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__72(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__73(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__73(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__62(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__62(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__74(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__74(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__56(rest, acc, stack, context, line, offset)
  end

  defp language_tag__60(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__75(rest, acc, stack, context, line, offset)
  end

  defp language_tag__75(rest, acc, stack, context, line, offset) do
    language_tag__155(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__77(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) do
    language_tag__78(
      rest,
      [language_subtags: [<<x0::integer, x1::integer, x2::integer>>]] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__77(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__56(rest, acc, stack, context, line, offset)
  end

  defp language_tag__78(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__79(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__77(rest, [], stack, context, line, offset)
  end

  defp language_tag__80(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) do
    language_tag__81(
      rest,
      [<<x4::integer, x5::integer, x6::integer>>, <<x0::integer, x1::integer, x2::integer>>] ++
        acc,
      stack,
      context,
      comb__line,
      comb__offset + 7
    )
  end

  defp language_tag__80(rest, acc, stack, context, line, offset) do
    language_tag__79(rest, acc, stack, context, line, offset)
  end

  defp language_tag__81(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__82(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__80(rest, [], stack, context, line, offset)
  end

  defp language_tag__83(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, x8::integer, x9::integer, x10::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and x7 === 45 and
              ((x8 >= 97 and x8 <= 122) or (x8 >= 65 and x8 <= 90)) and
              ((x9 >= 97 and x9 <= 122) or (x9 >= 65 and x9 <= 90)) and
              ((x10 >= 97 and x10 <= 122) or (x10 >= 65 and x10 <= 90)) do
    language_tag__84(
      rest,
      [
        <<x8::integer, x9::integer, x10::integer>>,
        <<x4::integer, x5::integer, x6::integer>>,
        <<x0::integer, x1::integer, x2::integer>>
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 11
    )
  end

  defp language_tag__83(rest, acc, stack, context, line, offset) do
    language_tag__82(rest, acc, stack, context, line, offset)
  end

  defp language_tag__84(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__85(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__83(rest, [], stack, context, line, offset)
  end

  defp language_tag__86(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 do
    language_tag__87(
      rest,
      [language_subtags: [<<x0::integer, x1::integer, x2::integer>>]] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__86(rest, acc, stack, context, line, offset) do
    language_tag__85(rest, acc, stack, context, line, offset)
  end

  defp language_tag__87(rest, acc, stack, context, line, offset) do
    language_tag__88(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__88(rest, acc, stack, context, line, offset) do
    language_tag__89(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__89(rest, acc, stack, context, line, offset) do
    language_tag__91(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__91(rest, acc, stack, context, line, offset) do
    language_tag__96(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__93(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__94(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__93(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__90(rest, acc, stack, context, line, offset)
  end

  defp language_tag__94(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__92(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__95(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__93(rest, [], stack, context, line, offset)
  end

  defp language_tag__96(rest, acc, stack, context, line, offset) do
    language_tag__97(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__97(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__98(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__97(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__95(rest, acc, stack, context, line, offset)
  end

  defp language_tag__98(rest, acc, stack, context, line, offset) do
    language_tag__100(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__100(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__101(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__100(rest, acc, stack, context, line, offset) do
    language_tag__99(rest, acc, stack, context, line, offset)
  end

  defp language_tag__99(rest, acc, [_ | stack], context, line, offset) do
    language_tag__102(rest, acc, stack, context, line, offset)
  end

  defp language_tag__101(rest, acc, [1 | stack], context, line, offset) do
    language_tag__102(rest, acc, stack, context, line, offset)
  end

  defp language_tag__101(rest, acc, [count | stack], context, line, offset) do
    language_tag__100(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__102(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__103(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__103(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__92(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__92(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__104(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__104(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__85(rest, acc, stack, context, line, offset)
  end

  defp language_tag__90(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__105(rest, acc, stack, context, line, offset)
  end

  defp language_tag__105(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__106(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__105(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__85(rest, acc, stack, context, line, offset)
  end

  defp language_tag__106(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__107(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__107(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__108(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__86(rest, [], stack, context, line, offset)
  end

  defp language_tag__109(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and x7 === 45 do
    language_tag__110(
      rest,
      [
        language_subtags: [
          <<x0::integer, x1::integer, x2::integer>>,
          <<x4::integer, x5::integer, x6::integer>>
        ]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 8
    )
  end

  defp language_tag__109(rest, acc, stack, context, line, offset) do
    language_tag__108(rest, acc, stack, context, line, offset)
  end

  defp language_tag__110(rest, acc, stack, context, line, offset) do
    language_tag__111(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__111(rest, acc, stack, context, line, offset) do
    language_tag__112(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__112(rest, acc, stack, context, line, offset) do
    language_tag__114(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__114(rest, acc, stack, context, line, offset) do
    language_tag__119(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__116(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__117(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__116(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__113(rest, acc, stack, context, line, offset)
  end

  defp language_tag__117(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__115(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__118(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__116(rest, [], stack, context, line, offset)
  end

  defp language_tag__119(rest, acc, stack, context, line, offset) do
    language_tag__120(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__120(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__121(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__120(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__118(rest, acc, stack, context, line, offset)
  end

  defp language_tag__121(rest, acc, stack, context, line, offset) do
    language_tag__123(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__123(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__124(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__123(rest, acc, stack, context, line, offset) do
    language_tag__122(rest, acc, stack, context, line, offset)
  end

  defp language_tag__122(rest, acc, [_ | stack], context, line, offset) do
    language_tag__125(rest, acc, stack, context, line, offset)
  end

  defp language_tag__124(rest, acc, [1 | stack], context, line, offset) do
    language_tag__125(rest, acc, stack, context, line, offset)
  end

  defp language_tag__124(rest, acc, [count | stack], context, line, offset) do
    language_tag__123(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__125(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__126(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__126(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__115(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__115(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__127(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__127(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__108(rest, acc, stack, context, line, offset)
  end

  defp language_tag__113(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__128(rest, acc, stack, context, line, offset)
  end

  defp language_tag__128(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__129(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__128(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__108(rest, acc, stack, context, line, offset)
  end

  defp language_tag__129(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__130(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__130(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__131(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__109(rest, [], stack, context, line, offset)
  end

  defp language_tag__132(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, x8::integer, x9::integer, x10::integer, x11::integer,
           rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and x7 === 45 and
              ((x8 >= 97 and x8 <= 122) or (x8 >= 65 and x8 <= 90)) and
              ((x9 >= 97 and x9 <= 122) or (x9 >= 65 and x9 <= 90)) and
              ((x10 >= 97 and x10 <= 122) or (x10 >= 65 and x10 <= 90)) and x11 === 45 do
    language_tag__133(
      rest,
      [
        language_subtags: [
          <<x0::integer, x1::integer, x2::integer>>,
          <<x4::integer, x5::integer, x6::integer>>,
          <<x8::integer, x9::integer, x10::integer>>
        ]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 12
    )
  end

  defp language_tag__132(rest, acc, stack, context, line, offset) do
    language_tag__131(rest, acc, stack, context, line, offset)
  end

  defp language_tag__133(rest, acc, stack, context, line, offset) do
    language_tag__134(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__134(rest, acc, stack, context, line, offset) do
    language_tag__135(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__135(rest, acc, stack, context, line, offset) do
    language_tag__137(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__137(rest, acc, stack, context, line, offset) do
    language_tag__142(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__139(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__140(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__139(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__136(rest, acc, stack, context, line, offset)
  end

  defp language_tag__140(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__138(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__141(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__139(rest, [], stack, context, line, offset)
  end

  defp language_tag__142(rest, acc, stack, context, line, offset) do
    language_tag__143(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__143(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__144(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__143(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__141(rest, acc, stack, context, line, offset)
  end

  defp language_tag__144(rest, acc, stack, context, line, offset) do
    language_tag__146(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__146(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__147(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__146(rest, acc, stack, context, line, offset) do
    language_tag__145(rest, acc, stack, context, line, offset)
  end

  defp language_tag__145(rest, acc, [_ | stack], context, line, offset) do
    language_tag__148(rest, acc, stack, context, line, offset)
  end

  defp language_tag__147(rest, acc, [1 | stack], context, line, offset) do
    language_tag__148(rest, acc, stack, context, line, offset)
  end

  defp language_tag__147(rest, acc, [count | stack], context, line, offset) do
    language_tag__146(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__148(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__149(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__149(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__138(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__138(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__150(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__150(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__131(rest, acc, stack, context, line, offset)
  end

  defp language_tag__136(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__151(rest, acc, stack, context, line, offset)
  end

  defp language_tag__151(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__152(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__151(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__131(rest, acc, stack, context, line, offset)
  end

  defp language_tag__152(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__153(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__153(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__154(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__132(rest, [], stack, context, line, offset)
  end

  defp language_tag__155(rest, acc, stack, context, line, offset) do
    language_tag__156(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__156(rest, acc, stack, context, line, offset) do
    language_tag__157(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__157(rest, acc, stack, context, line, offset) do
    language_tag__159(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__159(rest, acc, stack, context, line, offset) do
    language_tag__164(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__161(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__162(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__161(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__158(rest, acc, stack, context, line, offset)
  end

  defp language_tag__162(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__160(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__163(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__161(rest, [], stack, context, line, offset)
  end

  defp language_tag__164(rest, acc, stack, context, line, offset) do
    language_tag__165(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__165(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__166(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__165(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__163(rest, acc, stack, context, line, offset)
  end

  defp language_tag__166(rest, acc, stack, context, line, offset) do
    language_tag__168(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__168(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__169(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__168(rest, acc, stack, context, line, offset) do
    language_tag__167(rest, acc, stack, context, line, offset)
  end

  defp language_tag__167(rest, acc, [_ | stack], context, line, offset) do
    language_tag__170(rest, acc, stack, context, line, offset)
  end

  defp language_tag__169(rest, acc, [1 | stack], context, line, offset) do
    language_tag__170(rest, acc, stack, context, line, offset)
  end

  defp language_tag__169(rest, acc, [count | stack], context, line, offset) do
    language_tag__168(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__170(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__171(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__171(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__160(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__160(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__172(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__172(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__154(rest, acc, stack, context, line, offset)
  end

  defp language_tag__158(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__173(rest, acc, stack, context, line, offset)
  end

  defp language_tag__173(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__174(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__173(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__154(rest, acc, stack, context, line, offset)
  end

  defp language_tag__174(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__175(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__175(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__76(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__76(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__54(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__54(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__43(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__176(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__44(rest, [], stack, context, line, offset)
  end

  defp language_tag__177(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__178(
      rest,
      [language: <<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__177(rest, acc, stack, context, line, offset) do
    language_tag__176(rest, acc, stack, context, line, offset)
  end

  defp language_tag__178(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__43(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__179(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__177(rest, [], stack, context, line, offset)
  end

  defp language_tag__180(rest, acc, stack, context, line, offset) do
    language_tag__181(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__181(rest, acc, stack, context, line, offset) do
    language_tag__182(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__182(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) do
    language_tag__183(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__182(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__179(rest, acc, stack, context, line, offset)
  end

  defp language_tag__183(rest, acc, stack, context, line, offset) do
    language_tag__185(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__185(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) do
    language_tag__186(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__185(rest, acc, stack, context, line, offset) do
    language_tag__184(rest, acc, stack, context, line, offset)
  end

  defp language_tag__184(rest, acc, [_ | stack], context, line, offset) do
    language_tag__187(rest, acc, stack, context, line, offset)
  end

  defp language_tag__186(rest, acc, [1 | stack], context, line, offset) do
    language_tag__187(rest, acc, stack, context, line, offset)
  end

  defp language_tag__186(rest, acc, [count | stack], context, line, offset) do
    language_tag__185(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__187(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__188(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__188(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__189(
      rest,
      [
        language:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__189(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__43(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__43(rest, acc, stack, context, line, offset) do
    language_tag__193(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__191(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__190(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__192(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__191(rest, [], stack, context, line, offset)
  end

  defp language_tag__193(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__194(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__193(rest, acc, stack, context, line, offset) do
    language_tag__192(rest, acc, stack, context, line, offset)
  end

  defp language_tag__194(rest, acc, stack, context, line, offset) do
    language_tag__195(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__195(rest, acc, stack, context, line, offset) do
    language_tag__196(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__196(rest, acc, stack, context, line, offset) do
    language_tag__198(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__198(rest, acc, stack, context, line, offset) do
    language_tag__203(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__200(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__201(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__200(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__197(rest, acc, stack, context, line, offset)
  end

  defp language_tag__201(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__199(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__202(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__200(rest, [], stack, context, line, offset)
  end

  defp language_tag__203(rest, acc, stack, context, line, offset) do
    language_tag__204(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__204(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__205(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__204(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__202(rest, acc, stack, context, line, offset)
  end

  defp language_tag__205(rest, acc, stack, context, line, offset) do
    language_tag__207(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__207(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__208(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__207(rest, acc, stack, context, line, offset) do
    language_tag__206(rest, acc, stack, context, line, offset)
  end

  defp language_tag__206(rest, acc, [_ | stack], context, line, offset) do
    language_tag__209(rest, acc, stack, context, line, offset)
  end

  defp language_tag__208(rest, acc, [1 | stack], context, line, offset) do
    language_tag__209(rest, acc, stack, context, line, offset)
  end

  defp language_tag__208(rest, acc, [count | stack], context, line, offset) do
    language_tag__207(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__209(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__210(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__210(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__199(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__199(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__211(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__211(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__192(rest, acc, stack, context, line, offset)
  end

  defp language_tag__197(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__212(rest, acc, stack, context, line, offset)
  end

  defp language_tag__212(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__213(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__212(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__192(rest, acc, stack, context, line, offset)
  end

  defp language_tag__213(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__214(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__214(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__190(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__190(rest, acc, stack, context, line, offset) do
    language_tag__218(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__216(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__215(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__217(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__216(rest, [], stack, context, line, offset)
  end

  defp language_tag__218(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__219(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__218(rest, acc, stack, context, line, offset) do
    language_tag__217(rest, acc, stack, context, line, offset)
  end

  defp language_tag__219(rest, acc, stack, context, line, offset) do
    language_tag__220(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__220(rest, acc, stack, context, line, offset) do
    language_tag__221(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__221(rest, acc, stack, context, line, offset) do
    language_tag__223(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__223(rest, acc, stack, context, line, offset) do
    language_tag__228(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__225(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__226(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__225(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__222(rest, acc, stack, context, line, offset)
  end

  defp language_tag__226(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__224(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__227(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__225(rest, [], stack, context, line, offset)
  end

  defp language_tag__228(rest, acc, stack, context, line, offset) do
    language_tag__229(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__229(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__230(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__229(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__227(rest, acc, stack, context, line, offset)
  end

  defp language_tag__230(rest, acc, stack, context, line, offset) do
    language_tag__232(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__232(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__233(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__232(rest, acc, stack, context, line, offset) do
    language_tag__231(rest, acc, stack, context, line, offset)
  end

  defp language_tag__231(rest, acc, [_ | stack], context, line, offset) do
    language_tag__234(rest, acc, stack, context, line, offset)
  end

  defp language_tag__233(rest, acc, [1 | stack], context, line, offset) do
    language_tag__234(rest, acc, stack, context, line, offset)
  end

  defp language_tag__233(rest, acc, [count | stack], context, line, offset) do
    language_tag__232(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__234(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__235(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__235(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__224(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__224(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__236(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__236(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__217(rest, acc, stack, context, line, offset)
  end

  defp language_tag__222(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__237(rest, acc, stack, context, line, offset)
  end

  defp language_tag__237(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) do
    language_tag__238(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__237(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and (x1 >= 48 and x1 <= 57) and (x2 >= 48 and x2 <= 57) do
    language_tag__238(
      rest,
      [x2 - 48 + (x1 - 48) * 10 + (x0 - 48) * 100] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__237(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__217(rest, acc, stack, context, line, offset)
  end

  defp language_tag__238(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__239(
      rest,
      [
        territory:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__239(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__215(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__215(rest, acc, stack, context, line, offset) do
    language_tag__241(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__241(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__242(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__241(rest, acc, stack, context, line, offset) do
    language_tag__240(rest, acc, stack, context, line, offset)
  end

  defp language_tag__242(rest, acc, stack, context, line, offset) do
    language_tag__243(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__243(rest, acc, stack, context, line, offset) do
    language_tag__248(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__245(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__246(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__245(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__240(rest, acc, stack, context, line, offset)
  end

  defp language_tag__246(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__244(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__247(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__245(rest, [], stack, context, line, offset)
  end

  defp language_tag__248(rest, acc, stack, context, line, offset) do
    language_tag__249(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__249(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__250(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__249(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__247(rest, acc, stack, context, line, offset)
  end

  defp language_tag__250(rest, acc, stack, context, line, offset) do
    language_tag__252(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__252(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__253(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__252(rest, acc, stack, context, line, offset) do
    language_tag__251(rest, acc, stack, context, line, offset)
  end

  defp language_tag__251(rest, acc, [_ | stack], context, line, offset) do
    language_tag__254(rest, acc, stack, context, line, offset)
  end

  defp language_tag__253(rest, acc, [1 | stack], context, line, offset) do
    language_tag__254(rest, acc, stack, context, line, offset)
  end

  defp language_tag__253(rest, acc, [count | stack], context, line, offset) do
    language_tag__252(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__254(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__255(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__255(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__244(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__244(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__256(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__240(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__257(rest, acc, stack, context, line, offset)
  end

  defp language_tag__256(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__241(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__257(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__258(
      rest,
      [collapse_variants(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__258(rest, acc, stack, context, line, offset) do
    language_tag__260(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__260(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__261(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__260(rest, acc, stack, context, line, offset) do
    language_tag__259(rest, acc, stack, context, line, offset)
  end

  defp language_tag__261(rest, acc, stack, context, line, offset) do
    language_tag__555(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__263(rest, acc, stack, context, line, offset) do
    language_tag__264(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__264(rest, acc, stack, context, line, offset) do
    language_tag__265(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__265(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 48 and x0 <= 57) or (x0 >= 97 and x0 <= 115) or (x0 >= 65 and x0 <= 83) or
              (x0 >= 118 and x0 <= 119) or (x0 >= 86 and x0 <= 87) or (x0 >= 121 and x0 <= 122) or
              (x0 >= 89 and x0 <= 90) do
    language_tag__266(
      rest,
      [type: <<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp language_tag__265(rest, _acc, stack, context, line, offset) do
    [_, _, _, acc | stack] = stack
    language_tag__259(rest, acc, stack, context, line, offset)
  end

  defp language_tag__266(rest, acc, stack, context, line, offset) do
    language_tag__267(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__267(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__268(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__267(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    language_tag__259(rest, acc, stack, context, line, offset)
  end

  defp language_tag__268(rest, acc, stack, context, line, offset) do
    language_tag__269(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__269(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) do
    language_tag__270(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__269(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    language_tag__259(rest, acc, stack, context, line, offset)
  end

  defp language_tag__270(rest, acc, stack, context, line, offset) do
    language_tag__272(rest, acc, [6 | stack], context, line, offset)
  end

  defp language_tag__272(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__273(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__272(rest, acc, stack, context, line, offset) do
    language_tag__271(rest, acc, stack, context, line, offset)
  end

  defp language_tag__271(rest, acc, [_ | stack], context, line, offset) do
    language_tag__274(rest, acc, stack, context, line, offset)
  end

  defp language_tag__273(rest, acc, [1 | stack], context, line, offset) do
    language_tag__274(rest, acc, stack, context, line, offset)
  end

  defp language_tag__273(rest, acc, [count | stack], context, line, offset) do
    language_tag__272(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__274(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__275(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__275(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__276(
      rest,
      [
        attribute:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__276(rest, acc, stack, context, line, offset) do
    language_tag__278(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__278(rest, acc, stack, context, line, offset) do
    language_tag__279(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__279(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__280(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__279(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__277(rest, acc, stack, context, line, offset)
  end

  defp language_tag__280(rest, acc, stack, context, line, offset) do
    language_tag__281(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__281(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) do
    language_tag__282(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__281(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__277(rest, acc, stack, context, line, offset)
  end

  defp language_tag__282(rest, acc, stack, context, line, offset) do
    language_tag__284(rest, acc, [6 | stack], context, line, offset)
  end

  defp language_tag__284(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__285(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__284(rest, acc, stack, context, line, offset) do
    language_tag__283(rest, acc, stack, context, line, offset)
  end

  defp language_tag__283(rest, acc, [_ | stack], context, line, offset) do
    language_tag__286(rest, acc, stack, context, line, offset)
  end

  defp language_tag__285(rest, acc, [1 | stack], context, line, offset) do
    language_tag__286(rest, acc, stack, context, line, offset)
  end

  defp language_tag__285(rest, acc, [count | stack], context, line, offset) do
    language_tag__284(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__286(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__287(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__287(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__288(
      rest,
      [
        attribute:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__277(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__289(rest, acc, stack, context, line, offset)
  end

  defp language_tag__288(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__278(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__289(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__290(
      rest,
      [collapse_extension(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__290(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__291(
      rest,
      [
        extension:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__291(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__262(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__292(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__263(rest, [], stack, context, line, offset)
  end

  defp language_tag__293(rest, acc, stack, context, line, offset) do
    language_tag__294(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__294(rest, acc, stack, context, line, offset) do
    language_tag__295(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__295(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 116 or x0 === 84 do
    language_tag__296(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__295(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__292(rest, acc, stack, context, line, offset)
  end

  defp language_tag__296(rest, acc, stack, context, line, offset) do
    language_tag__300(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__298(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__297(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__299(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__298(rest, [], stack, context, line, offset)
  end

  defp language_tag__300(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__301(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__300(rest, acc, stack, context, line, offset) do
    language_tag__299(rest, acc, stack, context, line, offset)
  end

  defp language_tag__301(rest, acc, stack, context, line, offset) do
    language_tag__302(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__302(rest, acc, stack, context, line, offset) do
    language_tag__440(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__304(rest, acc, stack, context, line, offset) do
    language_tag__305(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__305(rest, acc, stack, context, line, offset) do
    language_tag__306(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__306(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) do
    language_tag__307(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__306(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    language_tag__299(rest, acc, stack, context, line, offset)
  end

  defp language_tag__307(rest, acc, stack, context, line, offset) do
    language_tag__309(rest, acc, [1 | stack], context, line, offset)
  end

  defp language_tag__309(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) do
    language_tag__310(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__309(rest, acc, stack, context, line, offset) do
    language_tag__308(rest, acc, stack, context, line, offset)
  end

  defp language_tag__308(rest, acc, [_ | stack], context, line, offset) do
    language_tag__311(rest, acc, stack, context, line, offset)
  end

  defp language_tag__310(rest, acc, [1 | stack], context, line, offset) do
    language_tag__311(rest, acc, stack, context, line, offset)
  end

  defp language_tag__310(rest, acc, [count | stack], context, line, offset) do
    language_tag__309(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__311(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__312(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__312(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__313(
      rest,
      [
        language:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__313(rest, acc, stack, context, line, offset) do
    language_tag__317(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__315(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__314(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__316(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__315(rest, [], stack, context, line, offset)
  end

  defp language_tag__317(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__318(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__317(rest, acc, stack, context, line, offset) do
    language_tag__316(rest, acc, stack, context, line, offset)
  end

  defp language_tag__318(rest, acc, stack, context, line, offset) do
    language_tag__319(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__319(rest, acc, stack, context, line, offset) do
    language_tag__321(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__321(rest, acc, stack, context, line, offset) do
    language_tag__326(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__323(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__324(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__323(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__320(rest, acc, stack, context, line, offset)
  end

  defp language_tag__324(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__322(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__325(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__323(rest, [], stack, context, line, offset)
  end

  defp language_tag__326(rest, acc, stack, context, line, offset) do
    language_tag__327(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__327(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__328(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__327(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__325(rest, acc, stack, context, line, offset)
  end

  defp language_tag__328(rest, acc, stack, context, line, offset) do
    language_tag__330(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__330(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__331(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__330(rest, acc, stack, context, line, offset) do
    language_tag__329(rest, acc, stack, context, line, offset)
  end

  defp language_tag__329(rest, acc, [_ | stack], context, line, offset) do
    language_tag__332(rest, acc, stack, context, line, offset)
  end

  defp language_tag__331(rest, acc, [1 | stack], context, line, offset) do
    language_tag__332(rest, acc, stack, context, line, offset)
  end

  defp language_tag__331(rest, acc, [count | stack], context, line, offset) do
    language_tag__330(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__332(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__333(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__333(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__322(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__322(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__334(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__334(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__316(rest, acc, stack, context, line, offset)
  end

  defp language_tag__320(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__335(rest, acc, stack, context, line, offset)
  end

  defp language_tag__335(rest, acc, stack, context, line, offset) do
    language_tag__415(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__337(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) do
    language_tag__338(
      rest,
      [language_subtags: [<<x0::integer, x1::integer, x2::integer>>]] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__337(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__316(rest, acc, stack, context, line, offset)
  end

  defp language_tag__338(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__339(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__337(rest, [], stack, context, line, offset)
  end

  defp language_tag__340(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) do
    language_tag__341(
      rest,
      [<<x4::integer, x5::integer, x6::integer>>, <<x0::integer, x1::integer, x2::integer>>] ++
        acc,
      stack,
      context,
      comb__line,
      comb__offset + 7
    )
  end

  defp language_tag__340(rest, acc, stack, context, line, offset) do
    language_tag__339(rest, acc, stack, context, line, offset)
  end

  defp language_tag__341(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__342(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__340(rest, [], stack, context, line, offset)
  end

  defp language_tag__343(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, x8::integer, x9::integer, x10::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and x7 === 45 and
              ((x8 >= 97 and x8 <= 122) or (x8 >= 65 and x8 <= 90)) and
              ((x9 >= 97 and x9 <= 122) or (x9 >= 65 and x9 <= 90)) and
              ((x10 >= 97 and x10 <= 122) or (x10 >= 65 and x10 <= 90)) do
    language_tag__344(
      rest,
      [
        <<x8::integer, x9::integer, x10::integer>>,
        <<x4::integer, x5::integer, x6::integer>>,
        <<x0::integer, x1::integer, x2::integer>>
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 11
    )
  end

  defp language_tag__343(rest, acc, stack, context, line, offset) do
    language_tag__342(rest, acc, stack, context, line, offset)
  end

  defp language_tag__344(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__345(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__343(rest, [], stack, context, line, offset)
  end

  defp language_tag__346(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 do
    language_tag__347(
      rest,
      [language_subtags: [<<x0::integer, x1::integer, x2::integer>>]] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__346(rest, acc, stack, context, line, offset) do
    language_tag__345(rest, acc, stack, context, line, offset)
  end

  defp language_tag__347(rest, acc, stack, context, line, offset) do
    language_tag__348(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__348(rest, acc, stack, context, line, offset) do
    language_tag__349(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__349(rest, acc, stack, context, line, offset) do
    language_tag__351(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__351(rest, acc, stack, context, line, offset) do
    language_tag__356(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__353(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__354(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__353(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__350(rest, acc, stack, context, line, offset)
  end

  defp language_tag__354(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__352(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__355(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__353(rest, [], stack, context, line, offset)
  end

  defp language_tag__356(rest, acc, stack, context, line, offset) do
    language_tag__357(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__357(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__358(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__357(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__355(rest, acc, stack, context, line, offset)
  end

  defp language_tag__358(rest, acc, stack, context, line, offset) do
    language_tag__360(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__360(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__361(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__360(rest, acc, stack, context, line, offset) do
    language_tag__359(rest, acc, stack, context, line, offset)
  end

  defp language_tag__359(rest, acc, [_ | stack], context, line, offset) do
    language_tag__362(rest, acc, stack, context, line, offset)
  end

  defp language_tag__361(rest, acc, [1 | stack], context, line, offset) do
    language_tag__362(rest, acc, stack, context, line, offset)
  end

  defp language_tag__361(rest, acc, [count | stack], context, line, offset) do
    language_tag__360(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__362(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__363(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__363(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__352(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__352(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__364(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__364(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__345(rest, acc, stack, context, line, offset)
  end

  defp language_tag__350(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__365(rest, acc, stack, context, line, offset)
  end

  defp language_tag__365(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__366(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__365(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__345(rest, acc, stack, context, line, offset)
  end

  defp language_tag__366(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__367(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__367(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__368(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__346(rest, [], stack, context, line, offset)
  end

  defp language_tag__369(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and x7 === 45 do
    language_tag__370(
      rest,
      [
        language_subtags: [
          <<x0::integer, x1::integer, x2::integer>>,
          <<x4::integer, x5::integer, x6::integer>>
        ]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 8
    )
  end

  defp language_tag__369(rest, acc, stack, context, line, offset) do
    language_tag__368(rest, acc, stack, context, line, offset)
  end

  defp language_tag__370(rest, acc, stack, context, line, offset) do
    language_tag__371(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__371(rest, acc, stack, context, line, offset) do
    language_tag__372(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__372(rest, acc, stack, context, line, offset) do
    language_tag__374(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__374(rest, acc, stack, context, line, offset) do
    language_tag__379(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__376(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__377(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__376(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__373(rest, acc, stack, context, line, offset)
  end

  defp language_tag__377(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__375(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__378(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__376(rest, [], stack, context, line, offset)
  end

  defp language_tag__379(rest, acc, stack, context, line, offset) do
    language_tag__380(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__380(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__381(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__380(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__378(rest, acc, stack, context, line, offset)
  end

  defp language_tag__381(rest, acc, stack, context, line, offset) do
    language_tag__383(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__383(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__384(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__383(rest, acc, stack, context, line, offset) do
    language_tag__382(rest, acc, stack, context, line, offset)
  end

  defp language_tag__382(rest, acc, [_ | stack], context, line, offset) do
    language_tag__385(rest, acc, stack, context, line, offset)
  end

  defp language_tag__384(rest, acc, [1 | stack], context, line, offset) do
    language_tag__385(rest, acc, stack, context, line, offset)
  end

  defp language_tag__384(rest, acc, [count | stack], context, line, offset) do
    language_tag__383(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__385(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__386(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__386(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__375(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__375(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__387(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__387(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__368(rest, acc, stack, context, line, offset)
  end

  defp language_tag__373(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__388(rest, acc, stack, context, line, offset)
  end

  defp language_tag__388(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__389(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__388(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__368(rest, acc, stack, context, line, offset)
  end

  defp language_tag__389(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__390(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__390(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__391(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__369(rest, [], stack, context, line, offset)
  end

  defp language_tag__392(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, x8::integer, x9::integer, x10::integer, x11::integer,
           rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and x3 === 45 and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) and
              ((x5 >= 97 and x5 <= 122) or (x5 >= 65 and x5 <= 90)) and
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and x7 === 45 and
              ((x8 >= 97 and x8 <= 122) or (x8 >= 65 and x8 <= 90)) and
              ((x9 >= 97 and x9 <= 122) or (x9 >= 65 and x9 <= 90)) and
              ((x10 >= 97 and x10 <= 122) or (x10 >= 65 and x10 <= 90)) and x11 === 45 do
    language_tag__393(
      rest,
      [
        language_subtags: [
          <<x0::integer, x1::integer, x2::integer>>,
          <<x4::integer, x5::integer, x6::integer>>,
          <<x8::integer, x9::integer, x10::integer>>
        ]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 12
    )
  end

  defp language_tag__392(rest, acc, stack, context, line, offset) do
    language_tag__391(rest, acc, stack, context, line, offset)
  end

  defp language_tag__393(rest, acc, stack, context, line, offset) do
    language_tag__394(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__394(rest, acc, stack, context, line, offset) do
    language_tag__395(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__395(rest, acc, stack, context, line, offset) do
    language_tag__397(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__397(rest, acc, stack, context, line, offset) do
    language_tag__402(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__399(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__400(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__399(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__396(rest, acc, stack, context, line, offset)
  end

  defp language_tag__400(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__398(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__401(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__399(rest, [], stack, context, line, offset)
  end

  defp language_tag__402(rest, acc, stack, context, line, offset) do
    language_tag__403(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__403(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__404(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__403(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__401(rest, acc, stack, context, line, offset)
  end

  defp language_tag__404(rest, acc, stack, context, line, offset) do
    language_tag__406(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__406(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__407(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__406(rest, acc, stack, context, line, offset) do
    language_tag__405(rest, acc, stack, context, line, offset)
  end

  defp language_tag__405(rest, acc, [_ | stack], context, line, offset) do
    language_tag__408(rest, acc, stack, context, line, offset)
  end

  defp language_tag__407(rest, acc, [1 | stack], context, line, offset) do
    language_tag__408(rest, acc, stack, context, line, offset)
  end

  defp language_tag__407(rest, acc, [count | stack], context, line, offset) do
    language_tag__406(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__408(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__409(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__409(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__398(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__398(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__410(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__410(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__391(rest, acc, stack, context, line, offset)
  end

  defp language_tag__396(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__411(rest, acc, stack, context, line, offset)
  end

  defp language_tag__411(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__412(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__411(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__391(rest, acc, stack, context, line, offset)
  end

  defp language_tag__412(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__413(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__413(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__414(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__392(rest, [], stack, context, line, offset)
  end

  defp language_tag__415(rest, acc, stack, context, line, offset) do
    language_tag__416(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__416(rest, acc, stack, context, line, offset) do
    language_tag__417(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__417(rest, acc, stack, context, line, offset) do
    language_tag__419(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__419(rest, acc, stack, context, line, offset) do
    language_tag__424(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__421(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__422(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__421(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__418(rest, acc, stack, context, line, offset)
  end

  defp language_tag__422(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__420(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__423(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__421(rest, [], stack, context, line, offset)
  end

  defp language_tag__424(rest, acc, stack, context, line, offset) do
    language_tag__425(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__425(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__426(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__425(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__423(rest, acc, stack, context, line, offset)
  end

  defp language_tag__426(rest, acc, stack, context, line, offset) do
    language_tag__428(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__428(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__429(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__428(rest, acc, stack, context, line, offset) do
    language_tag__427(rest, acc, stack, context, line, offset)
  end

  defp language_tag__427(rest, acc, [_ | stack], context, line, offset) do
    language_tag__430(rest, acc, stack, context, line, offset)
  end

  defp language_tag__429(rest, acc, [1 | stack], context, line, offset) do
    language_tag__430(rest, acc, stack, context, line, offset)
  end

  defp language_tag__429(rest, acc, [count | stack], context, line, offset) do
    language_tag__428(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__430(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__431(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__431(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__420(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__420(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__432(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__432(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__414(rest, acc, stack, context, line, offset)
  end

  defp language_tag__418(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__433(rest, acc, stack, context, line, offset)
  end

  defp language_tag__433(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__434(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__433(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__414(rest, acc, stack, context, line, offset)
  end

  defp language_tag__434(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__435(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__435(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__336(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__336(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__314(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__314(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__303(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__436(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__304(rest, [], stack, context, line, offset)
  end

  defp language_tag__437(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__438(
      rest,
      [language: <<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__437(rest, acc, stack, context, line, offset) do
    language_tag__436(rest, acc, stack, context, line, offset)
  end

  defp language_tag__438(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__303(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__439(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__437(rest, [], stack, context, line, offset)
  end

  defp language_tag__440(rest, acc, stack, context, line, offset) do
    language_tag__441(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__441(rest, acc, stack, context, line, offset) do
    language_tag__442(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__442(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) do
    language_tag__443(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__442(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__439(rest, acc, stack, context, line, offset)
  end

  defp language_tag__443(rest, acc, stack, context, line, offset) do
    language_tag__445(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__445(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) do
    language_tag__446(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__445(rest, acc, stack, context, line, offset) do
    language_tag__444(rest, acc, stack, context, line, offset)
  end

  defp language_tag__444(rest, acc, [_ | stack], context, line, offset) do
    language_tag__447(rest, acc, stack, context, line, offset)
  end

  defp language_tag__446(rest, acc, [1 | stack], context, line, offset) do
    language_tag__447(rest, acc, stack, context, line, offset)
  end

  defp language_tag__446(rest, acc, [count | stack], context, line, offset) do
    language_tag__445(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__447(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__448(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__448(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__449(
      rest,
      [
        language:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__449(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__303(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__303(rest, acc, stack, context, line, offset) do
    language_tag__453(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__451(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__450(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__452(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__451(rest, [], stack, context, line, offset)
  end

  defp language_tag__453(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__454(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__453(rest, acc, stack, context, line, offset) do
    language_tag__452(rest, acc, stack, context, line, offset)
  end

  defp language_tag__454(rest, acc, stack, context, line, offset) do
    language_tag__455(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__455(rest, acc, stack, context, line, offset) do
    language_tag__456(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__456(rest, acc, stack, context, line, offset) do
    language_tag__458(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__458(rest, acc, stack, context, line, offset) do
    language_tag__463(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__460(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__461(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__460(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__457(rest, acc, stack, context, line, offset)
  end

  defp language_tag__461(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__459(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__462(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__460(rest, [], stack, context, line, offset)
  end

  defp language_tag__463(rest, acc, stack, context, line, offset) do
    language_tag__464(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__464(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__465(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__464(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__462(rest, acc, stack, context, line, offset)
  end

  defp language_tag__465(rest, acc, stack, context, line, offset) do
    language_tag__467(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__467(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__468(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__467(rest, acc, stack, context, line, offset) do
    language_tag__466(rest, acc, stack, context, line, offset)
  end

  defp language_tag__466(rest, acc, [_ | stack], context, line, offset) do
    language_tag__469(rest, acc, stack, context, line, offset)
  end

  defp language_tag__468(rest, acc, [1 | stack], context, line, offset) do
    language_tag__469(rest, acc, stack, context, line, offset)
  end

  defp language_tag__468(rest, acc, [count | stack], context, line, offset) do
    language_tag__467(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__469(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__470(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__470(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__459(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__459(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__471(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__471(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__452(rest, acc, stack, context, line, offset)
  end

  defp language_tag__457(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__472(rest, acc, stack, context, line, offset)
  end

  defp language_tag__472(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) do
    language_tag__473(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__472(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__452(rest, acc, stack, context, line, offset)
  end

  defp language_tag__473(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__474(
      rest,
      [
        script:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__474(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__450(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__450(rest, acc, stack, context, line, offset) do
    language_tag__478(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__476(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__475(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__477(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__476(rest, [], stack, context, line, offset)
  end

  defp language_tag__478(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__479(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__478(rest, acc, stack, context, line, offset) do
    language_tag__477(rest, acc, stack, context, line, offset)
  end

  defp language_tag__479(rest, acc, stack, context, line, offset) do
    language_tag__480(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__480(rest, acc, stack, context, line, offset) do
    language_tag__481(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__481(rest, acc, stack, context, line, offset) do
    language_tag__483(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__483(rest, acc, stack, context, line, offset) do
    language_tag__488(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__485(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__486(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__485(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__482(rest, acc, stack, context, line, offset)
  end

  defp language_tag__486(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__484(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__487(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__485(rest, [], stack, context, line, offset)
  end

  defp language_tag__488(rest, acc, stack, context, line, offset) do
    language_tag__489(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__489(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__490(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__489(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__487(rest, acc, stack, context, line, offset)
  end

  defp language_tag__490(rest, acc, stack, context, line, offset) do
    language_tag__492(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__492(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__493(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__492(rest, acc, stack, context, line, offset) do
    language_tag__491(rest, acc, stack, context, line, offset)
  end

  defp language_tag__491(rest, acc, [_ | stack], context, line, offset) do
    language_tag__494(rest, acc, stack, context, line, offset)
  end

  defp language_tag__493(rest, acc, [1 | stack], context, line, offset) do
    language_tag__494(rest, acc, stack, context, line, offset)
  end

  defp language_tag__493(rest, acc, [count | stack], context, line, offset) do
    language_tag__492(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__494(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__495(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__495(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__484(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__484(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__496(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__496(_, _, [{rest, _acc, context, line, offset} | stack], _, _, _) do
    [acc | stack] = stack
    language_tag__477(rest, acc, stack, context, line, offset)
  end

  defp language_tag__482(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__497(rest, acc, stack, context, line, offset)
  end

  defp language_tag__497(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) do
    language_tag__498(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__497(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and (x1 >= 48 and x1 <= 57) and (x2 >= 48 and x2 <= 57) do
    language_tag__498(
      rest,
      [x2 - 48 + (x1 - 48) * 10 + (x0 - 48) * 100] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__497(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__477(rest, acc, stack, context, line, offset)
  end

  defp language_tag__498(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__499(
      rest,
      [
        territory:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__499(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__475(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__475(rest, acc, stack, context, line, offset) do
    language_tag__501(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__501(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__502(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__501(rest, acc, stack, context, line, offset) do
    language_tag__500(rest, acc, stack, context, line, offset)
  end

  defp language_tag__502(rest, acc, stack, context, line, offset) do
    language_tag__503(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__503(rest, acc, stack, context, line, offset) do
    language_tag__508(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__505(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__506(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__505(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__500(rest, acc, stack, context, line, offset)
  end

  defp language_tag__506(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__504(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__507(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__505(rest, [], stack, context, line, offset)
  end

  defp language_tag__508(rest, acc, stack, context, line, offset) do
    language_tag__509(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__509(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90) or (x4 >= 48 and x4 <= 57)) do
    language_tag__510(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__509(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__507(rest, acc, stack, context, line, offset)
  end

  defp language_tag__510(rest, acc, stack, context, line, offset) do
    language_tag__512(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__512(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__513(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__512(rest, acc, stack, context, line, offset) do
    language_tag__511(rest, acc, stack, context, line, offset)
  end

  defp language_tag__511(rest, acc, [_ | stack], context, line, offset) do
    language_tag__514(rest, acc, stack, context, line, offset)
  end

  defp language_tag__513(rest, acc, [1 | stack], context, line, offset) do
    language_tag__514(rest, acc, stack, context, line, offset)
  end

  defp language_tag__513(rest, acc, [count | stack], context, line, offset) do
    language_tag__512(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__514(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__515(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__515(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__504(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__504(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__516(
      rest,
      [
        language_variant:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__500(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__517(rest, acc, stack, context, line, offset)
  end

  defp language_tag__516(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__501(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__517(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__518(
      rest,
      [collapse_variants(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__518(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__297(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__297(rest, acc, stack, context, line, offset) do
    language_tag__519(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__519(rest, acc, stack, context, line, offset) do
    language_tag__521(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__521(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__522(
      rest,
      [key: <<x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__521(rest, acc, stack, context, line, offset) do
    language_tag__520(rest, acc, stack, context, line, offset)
  end

  defp language_tag__522(rest, acc, stack, context, line, offset) do
    language_tag__526(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__524(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__523(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__525(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__524(rest, [], stack, context, line, offset)
  end

  defp language_tag__526(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__527(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__526(rest, acc, stack, context, line, offset) do
    language_tag__525(rest, acc, stack, context, line, offset)
  end

  defp language_tag__527(rest, acc, stack, context, line, offset) do
    language_tag__528(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__528(rest, acc, stack, context, line, offset) do
    language_tag__529(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__529(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__530(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__529(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__525(rest, acc, stack, context, line, offset)
  end

  defp language_tag__530(rest, acc, stack, context, line, offset) do
    language_tag__532(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__532(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__533(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__532(rest, acc, stack, context, line, offset) do
    language_tag__531(rest, acc, stack, context, line, offset)
  end

  defp language_tag__531(rest, acc, [_ | stack], context, line, offset) do
    language_tag__534(rest, acc, stack, context, line, offset)
  end

  defp language_tag__533(rest, acc, [1 | stack], context, line, offset) do
    language_tag__534(rest, acc, stack, context, line, offset)
  end

  defp language_tag__533(rest, acc, [count | stack], context, line, offset) do
    language_tag__532(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__534(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__535(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__535(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__536(
      rest,
      [
        type:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__536(rest, acc, stack, context, line, offset) do
    language_tag__538(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__538(rest, acc, stack, context, line, offset) do
    language_tag__539(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__539(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__540(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__539(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__537(rest, acc, stack, context, line, offset)
  end

  defp language_tag__540(rest, acc, stack, context, line, offset) do
    language_tag__541(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__541(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__542(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__541(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__537(rest, acc, stack, context, line, offset)
  end

  defp language_tag__542(rest, acc, stack, context, line, offset) do
    language_tag__544(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__544(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__545(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__544(rest, acc, stack, context, line, offset) do
    language_tag__543(rest, acc, stack, context, line, offset)
  end

  defp language_tag__543(rest, acc, [_ | stack], context, line, offset) do
    language_tag__546(rest, acc, stack, context, line, offset)
  end

  defp language_tag__545(rest, acc, [1 | stack], context, line, offset) do
    language_tag__546(rest, acc, stack, context, line, offset)
  end

  defp language_tag__545(rest, acc, [count | stack], context, line, offset) do
    language_tag__544(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__546(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__547(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__547(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__548(
      rest,
      [
        type:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__537(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__549(rest, acc, stack, context, line, offset)
  end

  defp language_tag__548(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__538(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__549(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__523(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__520(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__550(rest, acc, stack, context, line, offset)
  end

  defp language_tag__523(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__521(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__550(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__551(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__551(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__552(
      rest,
      [merge_langtag_and_transform(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__552(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__553(
      rest,
      [
        transform:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__553(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__262(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__554(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__293(rest, [], stack, context, line, offset)
  end

  defp language_tag__555(rest, acc, stack, context, line, offset) do
    language_tag__556(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__556(rest, acc, stack, context, line, offset) do
    language_tag__557(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__557(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 117 or x0 === 85 do
    language_tag__558(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__557(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__554(rest, acc, stack, context, line, offset)
  end

  defp language_tag__558(rest, acc, stack, context, line, offset) do
    language_tag__595(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__560(rest, acc, stack, context, line, offset) do
    language_tag__561(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__561(rest, acc, stack, context, line, offset) do
    language_tag__563(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__563(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__564(
      rest,
      [key: <<x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__563(rest, acc, stack, context, line, offset) do
    language_tag__562(rest, acc, stack, context, line, offset)
  end

  defp language_tag__564(rest, acc, stack, context, line, offset) do
    language_tag__568(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__566(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__565(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__567(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__566(rest, [], stack, context, line, offset)
  end

  defp language_tag__568(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__569(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__568(rest, acc, stack, context, line, offset) do
    language_tag__567(rest, acc, stack, context, line, offset)
  end

  defp language_tag__569(rest, acc, stack, context, line, offset) do
    language_tag__570(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__570(rest, acc, stack, context, line, offset) do
    language_tag__571(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__571(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__572(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__571(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__567(rest, acc, stack, context, line, offset)
  end

  defp language_tag__572(rest, acc, stack, context, line, offset) do
    language_tag__574(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__574(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__575(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__574(rest, acc, stack, context, line, offset) do
    language_tag__573(rest, acc, stack, context, line, offset)
  end

  defp language_tag__573(rest, acc, [_ | stack], context, line, offset) do
    language_tag__576(rest, acc, stack, context, line, offset)
  end

  defp language_tag__575(rest, acc, [1 | stack], context, line, offset) do
    language_tag__576(rest, acc, stack, context, line, offset)
  end

  defp language_tag__575(rest, acc, [count | stack], context, line, offset) do
    language_tag__574(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__576(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__577(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__577(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__578(
      rest,
      [
        type:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__578(rest, acc, stack, context, line, offset) do
    language_tag__580(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__580(rest, acc, stack, context, line, offset) do
    language_tag__581(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__581(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__582(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__581(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__579(rest, acc, stack, context, line, offset)
  end

  defp language_tag__582(rest, acc, stack, context, line, offset) do
    language_tag__583(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__583(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__584(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__583(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__579(rest, acc, stack, context, line, offset)
  end

  defp language_tag__584(rest, acc, stack, context, line, offset) do
    language_tag__586(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__586(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__587(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__586(rest, acc, stack, context, line, offset) do
    language_tag__585(rest, acc, stack, context, line, offset)
  end

  defp language_tag__585(rest, acc, [_ | stack], context, line, offset) do
    language_tag__588(rest, acc, stack, context, line, offset)
  end

  defp language_tag__587(rest, acc, [1 | stack], context, line, offset) do
    language_tag__588(rest, acc, stack, context, line, offset)
  end

  defp language_tag__587(rest, acc, [count | stack], context, line, offset) do
    language_tag__586(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__588(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__589(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__589(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__590(
      rest,
      [
        type:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__579(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__591(rest, acc, stack, context, line, offset)
  end

  defp language_tag__590(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__580(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__591(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__565(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__562(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__592(rest, acc, stack, context, line, offset)
  end

  defp language_tag__565(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__563(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__592(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__593(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__593(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__559(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__594(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__560(rest, [], stack, context, line, offset)
  end

  defp language_tag__595(rest, acc, stack, context, line, offset) do
    language_tag__596(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__596(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__597(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__596(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__594(rest, acc, stack, context, line, offset)
  end

  defp language_tag__597(rest, acc, stack, context, line, offset) do
    language_tag__598(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__598(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__599(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__598(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__594(rest, acc, stack, context, line, offset)
  end

  defp language_tag__599(rest, acc, stack, context, line, offset) do
    language_tag__601(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__601(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__602(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__601(rest, acc, stack, context, line, offset) do
    language_tag__600(rest, acc, stack, context, line, offset)
  end

  defp language_tag__600(rest, acc, [_ | stack], context, line, offset) do
    language_tag__603(rest, acc, stack, context, line, offset)
  end

  defp language_tag__602(rest, acc, [1 | stack], context, line, offset) do
    language_tag__603(rest, acc, stack, context, line, offset)
  end

  defp language_tag__602(rest, acc, [count | stack], context, line, offset) do
    language_tag__601(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__603(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__604(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__604(rest, acc, stack, context, line, offset) do
    language_tag__606(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__606(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__607(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__606(rest, acc, stack, context, line, offset) do
    language_tag__605(rest, acc, stack, context, line, offset)
  end

  defp language_tag__607(rest, acc, stack, context, line, offset) do
    language_tag__608(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__608(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__609(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__608(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__605(rest, acc, stack, context, line, offset)
  end

  defp language_tag__609(rest, acc, stack, context, line, offset) do
    language_tag__611(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__611(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__612(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__611(rest, acc, stack, context, line, offset) do
    language_tag__610(rest, acc, stack, context, line, offset)
  end

  defp language_tag__610(rest, acc, [_ | stack], context, line, offset) do
    language_tag__613(rest, acc, stack, context, line, offset)
  end

  defp language_tag__612(rest, acc, [1 | stack], context, line, offset) do
    language_tag__613(rest, acc, stack, context, line, offset)
  end

  defp language_tag__612(rest, acc, [count | stack], context, line, offset) do
    language_tag__611(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__613(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__614(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__605(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__615(rest, acc, stack, context, line, offset)
  end

  defp language_tag__614(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__606(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__615(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__616(
      rest,
      [attributes: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__616(rest, acc, stack, context, line, offset) do
    language_tag__617(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__617(rest, acc, stack, context, line, offset) do
    language_tag__619(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__619(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__620(
      rest,
      [key: <<x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__619(rest, acc, stack, context, line, offset) do
    language_tag__618(rest, acc, stack, context, line, offset)
  end

  defp language_tag__620(rest, acc, stack, context, line, offset) do
    language_tag__624(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__622(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__621(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__623(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__622(rest, [], stack, context, line, offset)
  end

  defp language_tag__624(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__625(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__624(rest, acc, stack, context, line, offset) do
    language_tag__623(rest, acc, stack, context, line, offset)
  end

  defp language_tag__625(rest, acc, stack, context, line, offset) do
    language_tag__626(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__626(rest, acc, stack, context, line, offset) do
    language_tag__627(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__627(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__628(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__627(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__623(rest, acc, stack, context, line, offset)
  end

  defp language_tag__628(rest, acc, stack, context, line, offset) do
    language_tag__630(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__630(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__631(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__630(rest, acc, stack, context, line, offset) do
    language_tag__629(rest, acc, stack, context, line, offset)
  end

  defp language_tag__629(rest, acc, [_ | stack], context, line, offset) do
    language_tag__632(rest, acc, stack, context, line, offset)
  end

  defp language_tag__631(rest, acc, [1 | stack], context, line, offset) do
    language_tag__632(rest, acc, stack, context, line, offset)
  end

  defp language_tag__631(rest, acc, [count | stack], context, line, offset) do
    language_tag__630(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__632(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__633(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__633(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__634(
      rest,
      [
        type:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__634(rest, acc, stack, context, line, offset) do
    language_tag__636(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__636(rest, acc, stack, context, line, offset) do
    language_tag__637(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__637(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__638(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__637(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__635(rest, acc, stack, context, line, offset)
  end

  defp language_tag__638(rest, acc, stack, context, line, offset) do
    language_tag__639(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__639(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) do
    language_tag__640(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__639(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__635(rest, acc, stack, context, line, offset)
  end

  defp language_tag__640(rest, acc, stack, context, line, offset) do
    language_tag__642(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__642(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__643(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__642(rest, acc, stack, context, line, offset) do
    language_tag__641(rest, acc, stack, context, line, offset)
  end

  defp language_tag__641(rest, acc, [_ | stack], context, line, offset) do
    language_tag__644(rest, acc, stack, context, line, offset)
  end

  defp language_tag__643(rest, acc, [1 | stack], context, line, offset) do
    language_tag__644(rest, acc, stack, context, line, offset)
  end

  defp language_tag__643(rest, acc, [count | stack], context, line, offset) do
    language_tag__642(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__644(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__645(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__645(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__646(
      rest,
      [
        type:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__635(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__647(rest, acc, stack, context, line, offset)
  end

  defp language_tag__646(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__636(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__647(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__621(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__618(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__648(rest, acc, stack, context, line, offset)
  end

  defp language_tag__621(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__619(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__648(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__649(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__649(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__559(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__559(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__650(
      rest,
      [combine_attributes_and_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__650(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__651(
      rest,
      [
        locale:
          case(:lists.reverse(user_acc)) do
            [one] ->
              one

            many ->
              raise("unwrap_and_tag/3 expected a single token, got: #{inspect(many)}")
          end
      ] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__651(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__262(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__259(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__652(rest, acc, stack, context, line, offset)
  end

  defp language_tag__262(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__260(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__652(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__653(
      rest,
      [collapse_extensions(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__653(rest, acc, stack, context, line, offset) do
    language_tag__657(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__655(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__654(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__656(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__655(rest, [], stack, context, line, offset)
  end

  defp language_tag__657(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__658(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__657(rest, acc, stack, context, line, offset) do
    language_tag__656(rest, acc, stack, context, line, offset)
  end

  defp language_tag__658(rest, acc, stack, context, line, offset) do
    language_tag__659(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__659(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 120 or x0 === 88) and x1 === 45 do
    language_tag__660(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp language_tag__659(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__656(rest, acc, stack, context, line, offset)
  end

  defp language_tag__660(rest, acc, stack, context, line, offset) do
    language_tag__661(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__661(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__662(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp language_tag__661(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__656(rest, acc, stack, context, line, offset)
  end

  defp language_tag__662(rest, acc, stack, context, line, offset) do
    language_tag__664(rest, acc, [7 | stack], context, line, offset)
  end

  defp language_tag__664(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__665(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__664(rest, acc, stack, context, line, offset) do
    language_tag__663(rest, acc, stack, context, line, offset)
  end

  defp language_tag__663(rest, acc, [_ | stack], context, line, offset) do
    language_tag__666(rest, acc, stack, context, line, offset)
  end

  defp language_tag__665(rest, acc, [1 | stack], context, line, offset) do
    language_tag__666(rest, acc, stack, context, line, offset)
  end

  defp language_tag__665(rest, acc, [count | stack], context, line, offset) do
    language_tag__664(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__666(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__667(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__667(rest, acc, stack, context, line, offset) do
    language_tag__669(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__669(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__670(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__669(rest, acc, stack, context, line, offset) do
    language_tag__668(rest, acc, stack, context, line, offset)
  end

  defp language_tag__670(rest, acc, stack, context, line, offset) do
    language_tag__671(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__671(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__672(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp language_tag__671(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__668(rest, acc, stack, context, line, offset)
  end

  defp language_tag__672(rest, acc, stack, context, line, offset) do
    language_tag__674(rest, acc, [7 | stack], context, line, offset)
  end

  defp language_tag__674(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__675(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__674(rest, acc, stack, context, line, offset) do
    language_tag__673(rest, acc, stack, context, line, offset)
  end

  defp language_tag__673(rest, acc, [_ | stack], context, line, offset) do
    language_tag__676(rest, acc, stack, context, line, offset)
  end

  defp language_tag__675(rest, acc, [1 | stack], context, line, offset) do
    language_tag__676(rest, acc, stack, context, line, offset)
  end

  defp language_tag__675(rest, acc, [count | stack], context, line, offset) do
    language_tag__674(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__676(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__677(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__668(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__678(rest, acc, stack, context, line, offset)
  end

  defp language_tag__677(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__669(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__678(rest, user_acc, [acc | stack], context, line, offset) do
    _ = user_acc

    language_tag__679(
      rest,
      [private_use: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__679(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__654(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__654(rest, user_acc, [acc | stack], context, line, offset) do
    case(flatten(rest, user_acc, context, line, offset)) do
      {user_acc, context} when is_list(user_acc) ->
        language_tag__680(rest, user_acc ++ acc, stack, context, line, offset)

      {:error, reason} ->
        {:error, reason, rest, context, line, offset}
    end
  end

  defp language_tag__680(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__1(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__681("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp language_tag__1(rest, _acc, _stack, context, line, offset) do
    {:error, "expected a BCP47 language tag", rest, context, line, offset}
  end

  defp language_tag__681(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  def error_on_remaining("", context, _line, _offset) do
    {[], context}
  end

  def error_on_remaining(_rest, _context, _line, _offset) do
    {:error, "invalid language tag"}
  end
end
