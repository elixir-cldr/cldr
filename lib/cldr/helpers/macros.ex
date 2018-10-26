defmodule Cldr.Macros do
  @moduledoc false

  defmacro is_false(value) do
    quote do
      is_nil(unquote(value)) or unquote(value) == false
    end
  end

end
