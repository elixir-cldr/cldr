defmodule Cldr.TestHelpers do
  def with_no_default_backend(fun) do
    current_default = Application.get_env(:ex_cldr, :default_backend)
    Application.put_env(:ex_cldr, :default_backend, nil)

    try do
      fun.()
    after
      Application.put_env(:ex_cldr, :default_backend, current_default)
    end
  end
end
