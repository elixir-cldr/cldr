defmodule Cldr.Rfc5646.Helpers do
  @moduledoc false

  @doc false
  def combine_attributes_and_keywords([{:attributes, attributes}, %{} = keywords]) do
    Map.put(keywords, :attributes, attributes)
  end

  def combine_attributes_and_keywords([%{} = other]) do
    other
  end

  @doc false
  def collapse_extension(args) do
    type = args[:type]

    attributes =
      args
      |> Keyword.delete(:type)
      |> Keyword.values()

    %{type => attributes}
  end

  # Transform keywords to a map. Note that not
  # all keywords have a parameter so we set the
  # param to nil in those cases.
  @doc false
  def collapse_keywords(list) do
    list
    |> combine_multiple_types
    |> do_collapse_keywords
    |> Map.new()
  end

  @doc false
  def combine_multiple_types([{:type, type_1}, {:type, type_2} | rest]) when is_list(type_1) do
    combine_multiple_types([{:type, type_1 ++ [type_2]} | rest])
  end

  def combine_multiple_types([{:type, type_1}, {:type, type_2} | rest]) do
    combine_multiple_types([{:type, [type_1, type_2]} | rest])
  end

  def combine_multiple_types([other | rest]) do
    [other | combine_multiple_types(rest)]
  end

  def combine_multiple_types([]) do
    []
  end

  @doc false
  def do_collapse_keywords([{:key, key}, {:type, type} | rest]) do
    [{key, type} | do_collapse_keywords(rest)]
  end

  def do_collapse_keywords([{:key, key}, {:key, _key2} = other | rest]) do
    [{key, nil} | do_collapse_keywords([other | rest])]
  end

  def do_collapse_keywords([{:key, key}]) do
    [{key, nil}]
  end

  def do_collapse_keywords([]) do
    []
  end

  def flatten(_rest, args, context, _line, _offset) when is_list(args) do
    {List.flatten(args), context}
  end

  # This is just to keep dialyzer quiet
  def flatten(_rest, _args, _context, _line, _offset) do
    {:error, "Can't flatten a non-list"}
  end

  def collapse_extensions(args) do
    extensions =
      args
      |> Enum.filter(fn
        {x, _y} -> x == :extension
        _ -> false
      end)
      |> Keyword.values()
      |> Cldr.Map.merge_map_list()

    args
    |> Enum.reject(fn
      {x, _y} -> x == :extension
      _ -> false
    end)
    |> Keyword.put(:extensions, extensions)
  end
end
