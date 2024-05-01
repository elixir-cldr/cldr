defmodule Cldr.Normalize.Layout do
  @moduledoc false

  def normalize(content, locale) do
    content
    |> normalize_layout(locale)
  end

  def normalize_layout(content, _locale) do
    layout =
      content
      |> get_in(["layout", "orientation"])
      |> Cldr.Map.deep_map(fn
        {"character_order", "right-to-left"} -> {"character_order", "rtl"}
        {"character_order", "left-to-right"} -> {"character_order", "ltr"}
        {"line_order", "top-to-bottom"} -> {"line_order", "ttb"}
        {"line_order", "bottom-to-top"} -> {"line_order", "btt"}
        other -> other
      end)
      |> Map.new()

    Map.put(content, "layout", layout)
  end
end
