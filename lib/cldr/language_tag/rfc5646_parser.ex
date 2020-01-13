# Generated from lib/cldr/language_tag/rfc5646_parser.ex.exs, do not edit.
# Generated at 2020-01-13 20:30:59Z.

defmodule Cldr.Rfc5646.Parser do
  @moduledoc false

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

  # language-tag  = langtag             ; normal language tags
  #               / privateuse          ; private use tag
  #               / grandfathered       ; grandfathered tags

  @doc """
  Parses the given `binary` as language_tag.

  Returns `{:ok, [token], rest, context, position, byte_offset}` or
  `{:error, reason, rest, context, line, byte_offset}` where `position`
  describes the location of the language_tag (start position) as `{line, column_on_line}`.

  ## Options

    * `:line` - the initial line, defaults to 1
    * `:byte_offset` - the initial byte offset, defaults to 0
    * `:context` - the initial context value. It will be converted
      to a map

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
    line = Keyword.get(opts, :line, 1)
    offset = Keyword.get(opts, :byte_offset, 0)
    context = Map.new(Keyword.get(opts, :context, []))

    case(language_tag__0(binary, [], [], context, {line, offset}, offset)) do
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
    language_tag__62(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__42(rest, acc, stack, context, line, offset) do
    language_tag__43(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__43(rest, acc, stack, context, line, offset) do
    language_tag__44(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__44(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) do
    language_tag__45(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__44(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    language_tag__38(rest, acc, stack, context, line, offset)
  end

  defp language_tag__45(rest, acc, stack, context, line, offset) do
    language_tag__47(rest, acc, [1 | stack], context, line, offset)
  end

  defp language_tag__47(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) do
    language_tag__48(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__47(rest, acc, stack, context, line, offset) do
    language_tag__46(rest, acc, stack, context, line, offset)
  end

  defp language_tag__46(rest, acc, [_ | stack], context, line, offset) do
    language_tag__49(rest, acc, stack, context, line, offset)
  end

  defp language_tag__48(rest, acc, [1 | stack], context, line, offset) do
    language_tag__49(rest, acc, stack, context, line, offset)
  end

  defp language_tag__48(rest, acc, [count | stack], context, line, offset) do
    language_tag__47(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__49(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__50(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__50(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__51(
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

  defp language_tag__51(rest, acc, stack, context, line, offset) do
    language_tag__55(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__53(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__52(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__54(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__53(rest, [], stack, context, line, offset)
  end

  defp language_tag__55(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__56(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__55(rest, acc, stack, context, line, offset) do
    language_tag__54(rest, acc, stack, context, line, offset)
  end

  defp language_tag__56(
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
    language_tag__57(
      rest,
      [script: <<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__56(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, x5::integer,
           x6::integer, x7::integer, x8::integer, x9::integer, x10::integer, x11::integer,
           x12::integer, x13::integer, x14::integer, x15::integer, rest::binary>>,
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
              ((x10 >= 97 and x10 <= 122) or (x10 >= 65 and x10 <= 90)) and x11 === 45 and
              ((x12 >= 97 and x12 <= 122) or (x12 >= 65 and x12 <= 90)) and
              ((x13 >= 97 and x13 <= 122) or (x13 >= 65 and x13 <= 90)) and
              ((x14 >= 97 and x14 <= 122) or (x14 >= 65 and x14 <= 90)) and
              ((x15 >= 97 and x15 <= 122) or (x15 >= 65 and x15 <= 90)) do
    language_tag__57(
      rest,
      [
        script: <<x12::integer, x13::integer, x14::integer, x15::integer>>,
        language_subtags: [
          <<x0::integer, x1::integer, x2::integer>>,
          <<x4::integer, x5::integer, x6::integer>>,
          <<x8::integer, x9::integer, x10::integer>>
        ]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 16
    )
  end

  defp language_tag__56(
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
              ((x10 >= 97 and x10 <= 122) or (x10 >= 65 and x10 <= 90)) and
              ((x11 >= 97 and x11 <= 122) or (x11 >= 65 and x11 <= 90)) do
    language_tag__57(
      rest,
      [
        script: <<x8::integer, x9::integer, x10::integer, x11::integer>>,
        language_subtags: [
          <<x0::integer, x1::integer, x2::integer>>,
          <<x4::integer, x5::integer, x6::integer>>
        ]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 12
    )
  end

  defp language_tag__56(
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
              ((x6 >= 97 and x6 <= 122) or (x6 >= 65 and x6 <= 90)) and
              ((x7 >= 97 and x7 <= 122) or (x7 >= 65 and x7 <= 90)) do
    language_tag__57(
      rest,
      [
        script: <<x4::integer, x5::integer, x6::integer, x7::integer>>,
        language_subtags: [<<x0::integer, x1::integer, x2::integer>>]
      ] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 8
    )
  end

  defp language_tag__56(
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
    language_tag__57(
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

  defp language_tag__56(
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
    language_tag__57(
      rest,
      [<<x4::integer, x5::integer, x6::integer>>, <<x0::integer, x1::integer, x2::integer>>] ++
        acc,
      stack,
      context,
      comb__line,
      comb__offset + 7
    )
  end

  defp language_tag__56(
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
    language_tag__57(
      rest,
      [language_subtags: [<<x0::integer, x1::integer, x2::integer>>]] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__56(rest, acc, stack, context, line, offset) do
    language_tag__54(rest, acc, stack, context, line, offset)
  end

  defp language_tag__57(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__52(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__52(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__41(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__58(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__42(rest, [], stack, context, line, offset)
  end

  defp language_tag__59(
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
    language_tag__60(
      rest,
      [language: <<x0::integer, x1::integer, x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__59(rest, acc, stack, context, line, offset) do
    language_tag__58(rest, acc, stack, context, line, offset)
  end

  defp language_tag__60(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__41(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__61(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__59(rest, [], stack, context, line, offset)
  end

  defp language_tag__62(rest, acc, stack, context, line, offset) do
    language_tag__63(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__63(rest, acc, stack, context, line, offset) do
    language_tag__64(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__64(
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
    language_tag__65(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__64(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__61(rest, acc, stack, context, line, offset)
  end

  defp language_tag__65(rest, acc, stack, context, line, offset) do
    language_tag__67(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__67(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) do
    language_tag__68(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__67(rest, acc, stack, context, line, offset) do
    language_tag__66(rest, acc, stack, context, line, offset)
  end

  defp language_tag__66(rest, acc, [_ | stack], context, line, offset) do
    language_tag__69(rest, acc, stack, context, line, offset)
  end

  defp language_tag__68(rest, acc, [1 | stack], context, line, offset) do
    language_tag__69(rest, acc, stack, context, line, offset)
  end

  defp language_tag__68(rest, acc, [count | stack], context, line, offset) do
    language_tag__67(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__69(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__70(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__70(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__71(
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

  defp language_tag__71(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__41(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__41(
         <<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 and ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90)) and
              ((x4 >= 97 and x4 <= 122) or (x4 >= 65 and x4 <= 90)) do
    language_tag__72(
      rest,
      [script: <<x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__41(<<rest::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__72(rest, [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp language_tag__72(rest, acc, stack, context, line, offset) do
    language_tag__74(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__74(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__75(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__74(rest, acc, stack, context, line, offset) do
    language_tag__73(rest, acc, stack, context, line, offset)
  end

  defp language_tag__75(rest, acc, stack, context, line, offset) do
    language_tag__76(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__76(rest, acc, stack, context, line, offset) do
    language_tag__81(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__78(
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
    language_tag__79(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__78(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__73(rest, acc, stack, context, line, offset)
  end

  defp language_tag__79(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__77(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__80(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__78(rest, [], stack, context, line, offset)
  end

  defp language_tag__81(rest, acc, stack, context, line, offset) do
    language_tag__82(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__82(
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
    language_tag__83(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__82(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__80(rest, acc, stack, context, line, offset)
  end

  defp language_tag__83(rest, acc, stack, context, line, offset) do
    language_tag__85(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__85(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__86(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__85(rest, acc, stack, context, line, offset) do
    language_tag__84(rest, acc, stack, context, line, offset)
  end

  defp language_tag__84(rest, acc, [_ | stack], context, line, offset) do
    language_tag__87(rest, acc, stack, context, line, offset)
  end

  defp language_tag__86(rest, acc, [1 | stack], context, line, offset) do
    language_tag__87(rest, acc, stack, context, line, offset)
  end

  defp language_tag__86(rest, acc, [count | stack], context, line, offset) do
    language_tag__85(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__87(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__88(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__88(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__77(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__77(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__89(
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

  defp language_tag__73(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__90(rest, acc, stack, context, line, offset)
  end

  defp language_tag__89(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__74(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__90(rest, acc, stack, context, line, offset) do
    language_tag__94(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__92(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__91(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__93(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__92(rest, [], stack, context, line, offset)
  end

  defp language_tag__94(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__95(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__94(rest, acc, stack, context, line, offset) do
    language_tag__93(rest, acc, stack, context, line, offset)
  end

  defp language_tag__95(rest, acc, stack, context, line, offset) do
    language_tag__96(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__96(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90)) do
    language_tag__97(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__96(
         <<x0::integer, x1::integer, x2::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 >= 48 and x0 <= 57 and (x1 >= 48 and x1 <= 57) and (x2 >= 48 and x2 <= 57) do
    language_tag__97(
      rest,
      [x2 - 48 + (x1 - 48) * 10 + (x0 - 48) * 100] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__96(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__93(rest, acc, stack, context, line, offset)
  end

  defp language_tag__97(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__98(
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

  defp language_tag__98(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__91(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__91(rest, acc, stack, context, line, offset) do
    language_tag__100(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__100(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__101(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__100(rest, acc, stack, context, line, offset) do
    language_tag__99(rest, acc, stack, context, line, offset)
  end

  defp language_tag__101(rest, acc, stack, context, line, offset) do
    language_tag__102(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__102(rest, acc, stack, context, line, offset) do
    language_tag__107(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__104(
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
    language_tag__105(
      rest,
      [Enum.join([<<x0::integer>>, <<x1::integer, x2::integer, x3::integer>>])] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__104(rest, _acc, stack, context, line, offset) do
    [_, _, acc | stack] = stack
    language_tag__99(rest, acc, stack, context, line, offset)
  end

  defp language_tag__105(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__103(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__106(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__104(rest, [], stack, context, line, offset)
  end

  defp language_tag__107(rest, acc, stack, context, line, offset) do
    language_tag__108(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__108(
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
    language_tag__109(
      rest,
      [<<x0::integer, x1::integer, x2::integer, x3::integer, x4::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 5
    )
  end

  defp language_tag__108(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__106(rest, acc, stack, context, line, offset)
  end

  defp language_tag__109(rest, acc, stack, context, line, offset) do
    language_tag__111(rest, acc, [3 | stack], context, line, offset)
  end

  defp language_tag__111(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__112(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__111(rest, acc, stack, context, line, offset) do
    language_tag__110(rest, acc, stack, context, line, offset)
  end

  defp language_tag__110(rest, acc, [_ | stack], context, line, offset) do
    language_tag__113(rest, acc, stack, context, line, offset)
  end

  defp language_tag__112(rest, acc, [1 | stack], context, line, offset) do
    language_tag__113(rest, acc, stack, context, line, offset)
  end

  defp language_tag__112(rest, acc, [count | stack], context, line, offset) do
    language_tag__111(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__113(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__114(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__114(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__103(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__103(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__115(
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

  defp language_tag__99(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__116(rest, acc, stack, context, line, offset)
  end

  defp language_tag__115(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__100(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__116(rest, acc, stack, context, line, offset) do
    language_tag__118(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__118(rest, acc, stack, context, line, offset) do
    language_tag__119(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__119(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__120(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__119(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__117(rest, acc, stack, context, line, offset)
  end

  defp language_tag__120(rest, acc, stack, context, line, offset) do
    language_tag__219(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__122(rest, acc, stack, context, line, offset) do
    language_tag__123(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__123(rest, acc, stack, context, line, offset) do
    language_tag__124(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__124(
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
    language_tag__125(
      rest,
      [type: <<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp language_tag__124(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, acc | stack] = stack
    language_tag__117(rest, acc, stack, context, line, offset)
  end

  defp language_tag__125(rest, acc, stack, context, line, offset) do
    language_tag__126(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__126(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__127(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__126(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, acc | stack] = stack
    language_tag__117(rest, acc, stack, context, line, offset)
  end

  defp language_tag__127(rest, acc, stack, context, line, offset) do
    language_tag__128(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__128(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) do
    language_tag__129(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__128(rest, _acc, stack, context, line, offset) do
    [_, _, _, _, _, _, acc | stack] = stack
    language_tag__117(rest, acc, stack, context, line, offset)
  end

  defp language_tag__129(rest, acc, stack, context, line, offset) do
    language_tag__131(rest, acc, [6 | stack], context, line, offset)
  end

  defp language_tag__131(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__132(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__131(rest, acc, stack, context, line, offset) do
    language_tag__130(rest, acc, stack, context, line, offset)
  end

  defp language_tag__130(rest, acc, [_ | stack], context, line, offset) do
    language_tag__133(rest, acc, stack, context, line, offset)
  end

  defp language_tag__132(rest, acc, [1 | stack], context, line, offset) do
    language_tag__133(rest, acc, stack, context, line, offset)
  end

  defp language_tag__132(rest, acc, [count | stack], context, line, offset) do
    language_tag__131(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__133(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__134(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__134(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__135(
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

  defp language_tag__135(rest, acc, stack, context, line, offset) do
    language_tag__137(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__137(rest, acc, stack, context, line, offset) do
    language_tag__138(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__138(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__139(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__138(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__136(rest, acc, stack, context, line, offset)
  end

  defp language_tag__139(rest, acc, stack, context, line, offset) do
    language_tag__140(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__140(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when ((x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57)) and
              ((x1 >= 97 and x1 <= 122) or (x1 >= 65 and x1 <= 90) or (x1 >= 48 and x1 <= 57)) do
    language_tag__141(
      rest,
      [<<x0::integer, x1::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 2
    )
  end

  defp language_tag__140(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__136(rest, acc, stack, context, line, offset)
  end

  defp language_tag__141(rest, acc, stack, context, line, offset) do
    language_tag__143(rest, acc, [6 | stack], context, line, offset)
  end

  defp language_tag__143(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__144(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__143(rest, acc, stack, context, line, offset) do
    language_tag__142(rest, acc, stack, context, line, offset)
  end

  defp language_tag__142(rest, acc, [_ | stack], context, line, offset) do
    language_tag__145(rest, acc, stack, context, line, offset)
  end

  defp language_tag__144(rest, acc, [1 | stack], context, line, offset) do
    language_tag__145(rest, acc, stack, context, line, offset)
  end

  defp language_tag__144(rest, acc, [count | stack], context, line, offset) do
    language_tag__143(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__145(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__146(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__146(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__147(
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

  defp language_tag__136(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__148(rest, acc, stack, context, line, offset)
  end

  defp language_tag__147(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__137(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__148(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__149(
      rest,
      [collapse_extension(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__149(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__150(
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

  defp language_tag__150(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__121(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__151(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__122(rest, [], stack, context, line, offset)
  end

  defp language_tag__152(rest, acc, stack, context, line, offset) do
    language_tag__153(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__153(rest, acc, stack, context, line, offset) do
    language_tag__154(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__154(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 116 or x0 === 84) and x1 === 45 and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__155(
      rest,
      [key: <<x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__154(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__151(rest, acc, stack, context, line, offset)
  end

  defp language_tag__155(rest, acc, stack, context, line, offset) do
    language_tag__159(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__157(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__156(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__158(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__157(rest, [], stack, context, line, offset)
  end

  defp language_tag__159(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__160(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__159(rest, acc, stack, context, line, offset) do
    language_tag__158(rest, acc, stack, context, line, offset)
  end

  defp language_tag__160(rest, acc, stack, context, line, offset) do
    language_tag__161(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__161(rest, acc, stack, context, line, offset) do
    language_tag__162(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__162(
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
    language_tag__163(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__162(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__158(rest, acc, stack, context, line, offset)
  end

  defp language_tag__163(rest, acc, stack, context, line, offset) do
    language_tag__165(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__165(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__166(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__165(rest, acc, stack, context, line, offset) do
    language_tag__164(rest, acc, stack, context, line, offset)
  end

  defp language_tag__164(rest, acc, [_ | stack], context, line, offset) do
    language_tag__167(rest, acc, stack, context, line, offset)
  end

  defp language_tag__166(rest, acc, [1 | stack], context, line, offset) do
    language_tag__167(rest, acc, stack, context, line, offset)
  end

  defp language_tag__166(rest, acc, [count | stack], context, line, offset) do
    language_tag__165(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__167(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__168(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__168(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__169(
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

  defp language_tag__169(rest, acc, stack, context, line, offset) do
    language_tag__171(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__171(rest, acc, stack, context, line, offset) do
    language_tag__172(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__172(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__173(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__172(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__170(rest, acc, stack, context, line, offset)
  end

  defp language_tag__173(rest, acc, stack, context, line, offset) do
    language_tag__174(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__174(
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
    language_tag__175(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__174(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__170(rest, acc, stack, context, line, offset)
  end

  defp language_tag__175(rest, acc, stack, context, line, offset) do
    language_tag__177(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__177(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__178(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__177(rest, acc, stack, context, line, offset) do
    language_tag__176(rest, acc, stack, context, line, offset)
  end

  defp language_tag__176(rest, acc, [_ | stack], context, line, offset) do
    language_tag__179(rest, acc, stack, context, line, offset)
  end

  defp language_tag__178(rest, acc, [1 | stack], context, line, offset) do
    language_tag__179(rest, acc, stack, context, line, offset)
  end

  defp language_tag__178(rest, acc, [count | stack], context, line, offset) do
    language_tag__177(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__179(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__180(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__180(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__181(
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

  defp language_tag__170(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__182(rest, acc, stack, context, line, offset)
  end

  defp language_tag__181(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__171(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__182(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__156(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__156(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__183(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__183(rest, acc, stack, context, line, offset) do
    language_tag__185(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__185(rest, acc, stack, context, line, offset) do
    language_tag__186(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__186(
         <<x0::integer, x1::integer, x2::integer, x3::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 116 or x0 === 84) and x1 === 45 and
              ((x2 >= 97 and x2 <= 122) or (x2 >= 65 and x2 <= 90) or (x2 >= 48 and x2 <= 57)) and
              ((x3 >= 97 and x3 <= 122) or (x3 >= 65 and x3 <= 90) or (x3 >= 48 and x3 <= 57)) do
    language_tag__187(
      rest,
      [key: <<x2::integer, x3::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 4
    )
  end

  defp language_tag__186(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__184(rest, acc, stack, context, line, offset)
  end

  defp language_tag__187(rest, acc, stack, context, line, offset) do
    language_tag__191(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__189(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__188(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__190(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__189(rest, [], stack, context, line, offset)
  end

  defp language_tag__191(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__192(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__191(rest, acc, stack, context, line, offset) do
    language_tag__190(rest, acc, stack, context, line, offset)
  end

  defp language_tag__192(rest, acc, stack, context, line, offset) do
    language_tag__193(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__193(rest, acc, stack, context, line, offset) do
    language_tag__194(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__194(
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
    language_tag__195(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__194(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__190(rest, acc, stack, context, line, offset)
  end

  defp language_tag__195(rest, acc, stack, context, line, offset) do
    language_tag__197(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__197(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__198(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__197(rest, acc, stack, context, line, offset) do
    language_tag__196(rest, acc, stack, context, line, offset)
  end

  defp language_tag__196(rest, acc, [_ | stack], context, line, offset) do
    language_tag__199(rest, acc, stack, context, line, offset)
  end

  defp language_tag__198(rest, acc, [1 | stack], context, line, offset) do
    language_tag__199(rest, acc, stack, context, line, offset)
  end

  defp language_tag__198(rest, acc, [count | stack], context, line, offset) do
    language_tag__197(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__199(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__200(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__200(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__201(
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

  defp language_tag__201(rest, acc, stack, context, line, offset) do
    language_tag__203(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__203(rest, acc, stack, context, line, offset) do
    language_tag__204(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__204(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__205(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__204(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__202(rest, acc, stack, context, line, offset)
  end

  defp language_tag__205(rest, acc, stack, context, line, offset) do
    language_tag__206(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__206(
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
    language_tag__207(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__206(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__202(rest, acc, stack, context, line, offset)
  end

  defp language_tag__207(rest, acc, stack, context, line, offset) do
    language_tag__209(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__209(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__210(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__209(rest, acc, stack, context, line, offset) do
    language_tag__208(rest, acc, stack, context, line, offset)
  end

  defp language_tag__208(rest, acc, [_ | stack], context, line, offset) do
    language_tag__211(rest, acc, stack, context, line, offset)
  end

  defp language_tag__210(rest, acc, [1 | stack], context, line, offset) do
    language_tag__211(rest, acc, stack, context, line, offset)
  end

  defp language_tag__210(rest, acc, [count | stack], context, line, offset) do
    language_tag__209(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__211(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__212(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__212(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__213(
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

  defp language_tag__202(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__214(rest, acc, stack, context, line, offset)
  end

  defp language_tag__213(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__203(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__214(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__188(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__188(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__215(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__184(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__216(rest, acc, stack, context, line, offset)
  end

  defp language_tag__215(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__185(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__216(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__217(
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

  defp language_tag__217(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__121(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__218(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__152(rest, [], stack, context, line, offset)
  end

  defp language_tag__219(rest, acc, stack, context, line, offset) do
    language_tag__220(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__220(rest, acc, stack, context, line, offset) do
    language_tag__221(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__221(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 117 or x0 === 85 do
    language_tag__222(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__221(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__218(rest, acc, stack, context, line, offset)
  end

  defp language_tag__222(rest, acc, stack, context, line, offset) do
    language_tag__259(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__224(rest, acc, stack, context, line, offset) do
    language_tag__225(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__225(rest, acc, stack, context, line, offset) do
    language_tag__227(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__227(
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
    language_tag__228(
      rest,
      [key: <<x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__227(rest, acc, stack, context, line, offset) do
    language_tag__226(rest, acc, stack, context, line, offset)
  end

  defp language_tag__228(rest, acc, stack, context, line, offset) do
    language_tag__232(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__230(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__229(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__231(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__230(rest, [], stack, context, line, offset)
  end

  defp language_tag__232(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__233(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__232(rest, acc, stack, context, line, offset) do
    language_tag__231(rest, acc, stack, context, line, offset)
  end

  defp language_tag__233(rest, acc, stack, context, line, offset) do
    language_tag__234(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__234(rest, acc, stack, context, line, offset) do
    language_tag__235(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__235(
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
    language_tag__236(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__235(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__231(rest, acc, stack, context, line, offset)
  end

  defp language_tag__236(rest, acc, stack, context, line, offset) do
    language_tag__238(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__238(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__239(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__238(rest, acc, stack, context, line, offset) do
    language_tag__237(rest, acc, stack, context, line, offset)
  end

  defp language_tag__237(rest, acc, [_ | stack], context, line, offset) do
    language_tag__240(rest, acc, stack, context, line, offset)
  end

  defp language_tag__239(rest, acc, [1 | stack], context, line, offset) do
    language_tag__240(rest, acc, stack, context, line, offset)
  end

  defp language_tag__239(rest, acc, [count | stack], context, line, offset) do
    language_tag__238(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__240(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__241(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__241(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__242(
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

  defp language_tag__242(rest, acc, stack, context, line, offset) do
    language_tag__244(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__244(rest, acc, stack, context, line, offset) do
    language_tag__245(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__245(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__246(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__245(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__243(rest, acc, stack, context, line, offset)
  end

  defp language_tag__246(rest, acc, stack, context, line, offset) do
    language_tag__247(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__247(
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
    language_tag__248(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__247(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__243(rest, acc, stack, context, line, offset)
  end

  defp language_tag__248(rest, acc, stack, context, line, offset) do
    language_tag__250(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__250(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__251(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__250(rest, acc, stack, context, line, offset) do
    language_tag__249(rest, acc, stack, context, line, offset)
  end

  defp language_tag__249(rest, acc, [_ | stack], context, line, offset) do
    language_tag__252(rest, acc, stack, context, line, offset)
  end

  defp language_tag__251(rest, acc, [1 | stack], context, line, offset) do
    language_tag__252(rest, acc, stack, context, line, offset)
  end

  defp language_tag__251(rest, acc, [count | stack], context, line, offset) do
    language_tag__250(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__252(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__253(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__253(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__254(
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

  defp language_tag__243(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__255(rest, acc, stack, context, line, offset)
  end

  defp language_tag__254(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__244(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__255(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__229(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__226(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__256(rest, acc, stack, context, line, offset)
  end

  defp language_tag__229(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__227(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__256(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__257(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__257(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__223(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__258(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__224(rest, [], stack, context, line, offset)
  end

  defp language_tag__259(rest, acc, stack, context, line, offset) do
    language_tag__260(rest, [], [acc | stack], context, line, offset)
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

  defp language_tag__260(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__258(rest, acc, stack, context, line, offset)
  end

  defp language_tag__261(rest, acc, stack, context, line, offset) do
    language_tag__262(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__262(
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
    language_tag__263(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__262(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__258(rest, acc, stack, context, line, offset)
  end

  defp language_tag__263(rest, acc, stack, context, line, offset) do
    language_tag__265(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__265(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__266(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__265(rest, acc, stack, context, line, offset) do
    language_tag__264(rest, acc, stack, context, line, offset)
  end

  defp language_tag__264(rest, acc, [_ | stack], context, line, offset) do
    language_tag__267(rest, acc, stack, context, line, offset)
  end

  defp language_tag__266(rest, acc, [1 | stack], context, line, offset) do
    language_tag__267(rest, acc, stack, context, line, offset)
  end

  defp language_tag__266(rest, acc, [count | stack], context, line, offset) do
    language_tag__265(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__267(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__268(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__268(rest, acc, stack, context, line, offset) do
    language_tag__270(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__270(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__271(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__270(rest, acc, stack, context, line, offset) do
    language_tag__269(rest, acc, stack, context, line, offset)
  end

  defp language_tag__271(rest, acc, stack, context, line, offset) do
    language_tag__272(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__272(
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
    language_tag__273(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__272(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__269(rest, acc, stack, context, line, offset)
  end

  defp language_tag__273(rest, acc, stack, context, line, offset) do
    language_tag__275(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__275(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__276(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__275(rest, acc, stack, context, line, offset) do
    language_tag__274(rest, acc, stack, context, line, offset)
  end

  defp language_tag__274(rest, acc, [_ | stack], context, line, offset) do
    language_tag__277(rest, acc, stack, context, line, offset)
  end

  defp language_tag__276(rest, acc, [1 | stack], context, line, offset) do
    language_tag__277(rest, acc, stack, context, line, offset)
  end

  defp language_tag__276(rest, acc, [count | stack], context, line, offset) do
    language_tag__275(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__277(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__278(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__269(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__279(rest, acc, stack, context, line, offset)
  end

  defp language_tag__278(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__270(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__279(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__280(
      rest,
      [attributes: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__280(rest, acc, stack, context, line, offset) do
    language_tag__281(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__281(rest, acc, stack, context, line, offset) do
    language_tag__283(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__283(
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
    language_tag__284(
      rest,
      [key: <<x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__283(rest, acc, stack, context, line, offset) do
    language_tag__282(rest, acc, stack, context, line, offset)
  end

  defp language_tag__284(rest, acc, stack, context, line, offset) do
    language_tag__288(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__286(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__285(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__287(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__286(rest, [], stack, context, line, offset)
  end

  defp language_tag__288(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__289(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__288(rest, acc, stack, context, line, offset) do
    language_tag__287(rest, acc, stack, context, line, offset)
  end

  defp language_tag__289(rest, acc, stack, context, line, offset) do
    language_tag__290(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__290(rest, acc, stack, context, line, offset) do
    language_tag__291(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__291(
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
    language_tag__292(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__291(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__287(rest, acc, stack, context, line, offset)
  end

  defp language_tag__292(rest, acc, stack, context, line, offset) do
    language_tag__294(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__294(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__295(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__294(rest, acc, stack, context, line, offset) do
    language_tag__293(rest, acc, stack, context, line, offset)
  end

  defp language_tag__293(rest, acc, [_ | stack], context, line, offset) do
    language_tag__296(rest, acc, stack, context, line, offset)
  end

  defp language_tag__295(rest, acc, [1 | stack], context, line, offset) do
    language_tag__296(rest, acc, stack, context, line, offset)
  end

  defp language_tag__295(rest, acc, [count | stack], context, line, offset) do
    language_tag__294(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__296(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__297(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__297(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__298(
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

  defp language_tag__298(rest, acc, stack, context, line, offset) do
    language_tag__300(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__300(rest, acc, stack, context, line, offset) do
    language_tag__301(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__301(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__302(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__301(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__299(rest, acc, stack, context, line, offset)
  end

  defp language_tag__302(rest, acc, stack, context, line, offset) do
    language_tag__303(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__303(
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
    language_tag__304(
      rest,
      [<<x0::integer, x1::integer, x2::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 3
    )
  end

  defp language_tag__303(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__299(rest, acc, stack, context, line, offset)
  end

  defp language_tag__304(rest, acc, stack, context, line, offset) do
    language_tag__306(rest, acc, [5 | stack], context, line, offset)
  end

  defp language_tag__306(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__307(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__306(rest, acc, stack, context, line, offset) do
    language_tag__305(rest, acc, stack, context, line, offset)
  end

  defp language_tag__305(rest, acc, [_ | stack], context, line, offset) do
    language_tag__308(rest, acc, stack, context, line, offset)
  end

  defp language_tag__307(rest, acc, [1 | stack], context, line, offset) do
    language_tag__308(rest, acc, stack, context, line, offset)
  end

  defp language_tag__307(rest, acc, [count | stack], context, line, offset) do
    language_tag__306(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__308(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__309(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__309(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__310(
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

  defp language_tag__299(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__311(rest, acc, stack, context, line, offset)
  end

  defp language_tag__310(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__300(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__311(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__285(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__282(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__312(rest, acc, stack, context, line, offset)
  end

  defp language_tag__285(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__283(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__312(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__313(
      rest,
      [collapse_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__313(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__223(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__223(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__314(
      rest,
      [combine_attributes_and_keywords(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__314(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__315(
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

  defp language_tag__315(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__121(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__121(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__316(
      rest,
      [collapse_extensions(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__117(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__317(rest, acc, stack, context, line, offset)
  end

  defp language_tag__316(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__118(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__317(rest, acc, stack, context, line, offset) do
    language_tag__321(
      rest,
      [],
      [{rest, context, line, offset}, acc | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__319(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__318(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__320(_, _, [{rest, context, line, offset} | _] = stack, _, _, _) do
    language_tag__319(rest, [], stack, context, line, offset)
  end

  defp language_tag__321(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__322(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__321(rest, acc, stack, context, line, offset) do
    language_tag__320(rest, acc, stack, context, line, offset)
  end

  defp language_tag__322(rest, acc, stack, context, line, offset) do
    language_tag__323(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__323(
         <<x0::integer, x1::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 === 120 or x0 === 88) and x1 === 45 do
    language_tag__324(rest, [] ++ acc, stack, context, comb__line, comb__offset + 2)
  end

  defp language_tag__323(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__320(rest, acc, stack, context, line, offset)
  end

  defp language_tag__324(rest, acc, stack, context, line, offset) do
    language_tag__325(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__325(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__326(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp language_tag__325(rest, _acc, stack, context, line, offset) do
    [_, acc | stack] = stack
    language_tag__320(rest, acc, stack, context, line, offset)
  end

  defp language_tag__326(rest, acc, stack, context, line, offset) do
    language_tag__328(rest, acc, [7 | stack], context, line, offset)
  end

  defp language_tag__328(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__329(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__328(rest, acc, stack, context, line, offset) do
    language_tag__327(rest, acc, stack, context, line, offset)
  end

  defp language_tag__327(rest, acc, [_ | stack], context, line, offset) do
    language_tag__330(rest, acc, stack, context, line, offset)
  end

  defp language_tag__329(rest, acc, [1 | stack], context, line, offset) do
    language_tag__330(rest, acc, stack, context, line, offset)
  end

  defp language_tag__329(rest, acc, [count | stack], context, line, offset) do
    language_tag__328(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__330(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__331(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__331(rest, acc, stack, context, line, offset) do
    language_tag__333(
      rest,
      [],
      [{rest, acc, context, line, offset} | stack],
      context,
      line,
      offset
    )
  end

  defp language_tag__333(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when x0 === 45 do
    language_tag__334(rest, [] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__333(rest, acc, stack, context, line, offset) do
    language_tag__332(rest, acc, stack, context, line, offset)
  end

  defp language_tag__334(rest, acc, stack, context, line, offset) do
    language_tag__335(rest, [], [acc | stack], context, line, offset)
  end

  defp language_tag__335(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__336(
      rest,
      [<<x0::integer>>] ++ acc,
      stack,
      context,
      comb__line,
      comb__offset + 1
    )
  end

  defp language_tag__335(rest, _acc, stack, context, line, offset) do
    [acc | stack] = stack
    language_tag__332(rest, acc, stack, context, line, offset)
  end

  defp language_tag__336(rest, acc, stack, context, line, offset) do
    language_tag__338(rest, acc, [7 | stack], context, line, offset)
  end

  defp language_tag__338(
         <<x0::integer, rest::binary>>,
         acc,
         stack,
         context,
         comb__line,
         comb__offset
       )
       when (x0 >= 97 and x0 <= 122) or (x0 >= 65 and x0 <= 90) or (x0 >= 48 and x0 <= 57) do
    language_tag__339(rest, [x0] ++ acc, stack, context, comb__line, comb__offset + 1)
  end

  defp language_tag__338(rest, acc, stack, context, line, offset) do
    language_tag__337(rest, acc, stack, context, line, offset)
  end

  defp language_tag__337(rest, acc, [_ | stack], context, line, offset) do
    language_tag__340(rest, acc, stack, context, line, offset)
  end

  defp language_tag__339(rest, acc, [1 | stack], context, line, offset) do
    language_tag__340(rest, acc, stack, context, line, offset)
  end

  defp language_tag__339(rest, acc, [count | stack], context, line, offset) do
    language_tag__338(rest, acc, [count - 1 | stack], context, line, offset)
  end

  defp language_tag__340(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__341(
      rest,
      [List.to_string(:lists.reverse(user_acc))] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__332(_, _, [{rest, acc, context, line, offset} | stack], _, _, _) do
    language_tag__342(rest, acc, stack, context, line, offset)
  end

  defp language_tag__341(
         inner_rest,
         inner_acc,
         [{rest, acc, context, line, offset} | stack],
         inner_context,
         inner_line,
         inner_offset
       ) do
    _ = {rest, acc, context, line, offset}

    language_tag__333(
      inner_rest,
      [],
      [{inner_rest, inner_acc ++ acc, inner_context, inner_line, inner_offset} | stack],
      inner_context,
      inner_line,
      inner_offset
    )
  end

  defp language_tag__342(rest, user_acc, [acc | stack], context, line, offset) do
    language_tag__343(
      rest,
      [private_use: :lists.reverse(user_acc)] ++ acc,
      stack,
      context,
      line,
      offset
    )
  end

  defp language_tag__343(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__318(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__318(rest, user_acc, [acc | stack], context, line, offset) do
    case(flatten(rest, user_acc, context, line, offset)) do
      {user_acc, context} when is_list(user_acc) ->
        language_tag__344(rest, user_acc ++ acc, stack, context, line, offset)

      {:error, reason} ->
        {:error, reason, rest, context, line, offset}
    end
  end

  defp language_tag__344(rest, acc, [_, previous_acc | stack], context, line, offset) do
    language_tag__1(rest, acc ++ previous_acc, stack, context, line, offset)
  end

  defp language_tag__1(<<""::binary>>, acc, stack, context, comb__line, comb__offset) do
    language_tag__345("", [] ++ acc, stack, context, comb__line, comb__offset)
  end

  defp language_tag__1(rest, _acc, _stack, context, line, offset) do
    {:error, "expected a BCP47 language tag", rest, context, line, offset}
  end

  defp language_tag__345(rest, acc, _stack, context, line, offset) do
    {:ok, acc, rest, context, line, offset}
  end

  def error_on_remaining("", context, _line, _offset) do
    {[], context}
  end

  def error_on_remaining(_rest, _context, _line, _offset) do
    {:error, "invalid language tag"}
  end
end
