defmodule Mix.Tasks.Compile.Cldr do
  @moduledoc false

  use Mix.Task

  @deprecated "The :cldr compiler is deprecated and is no longer required. Please remove it from your `mix.exs`"
  def run(_args) do
    :noop
  end

end
