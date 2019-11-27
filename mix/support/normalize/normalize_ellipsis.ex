defmodule Cldr.Normalize.Ellipsis do
  @moduledoc false

  alias Cldr.Substitution

  def normalize(content, locale) do
    content
    |> normalize_ellipsis(locale)
  end

  def normalize_ellipsis(content, _locale) do
    ellipsis =
      content
      |> get_in(["characters", "ellipsis"])
      |> Enum.map(fn {type, data} -> {type, Substitution.parse(data)} end)
      |> Map.new()

    Map.put(content, "ellipsis", ellipsis)
  end
end
