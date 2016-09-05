defmodule Cldr.Number.Generate.DecimalFormats do
  @doc """
  Module to precompile known decimal formats that are then
  wrapped in functions to optimize performance at runtime.
  """

  defmacro __using__(_options \\ []) do
    def_compiled_formats()
  end

  # Compile the known decimal formats extracted from the
  # current configuration of Cldr.  This avoids having to tokenize
  # parse and analyse the format on each invokation.  There
  # are around 600 Cldr defined decimal formats.
  defp def_compiled_formats do
    for format <- Cldr.Number.Format.decimal_format_list() do
      case Cldr.Number.Format.Compiler.decode(format) do
      {:ok, meta} ->
        quote do
          defp to_string(number, unquote(format), options) do
            do_to_string(number, unquote(Macro.escape(meta)), options)
          end
        end
      {:error, message} ->
        raise CompileError, description: message
      end
    end
  end
end
