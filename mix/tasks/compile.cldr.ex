defmodule Mix.Tasks.Compile.Cldr do
  use Mix.Task

  def run(_args) do
    if configured_locales() != previous_locales() do
      try do
        Mix.Task.run("deps.compile", ["ex_cldr", "--force"])
      after
        create_manifest()
      end
    end
    :ok
  end

  defp configured_locales do
    Cldr.Config.known_locale_names
  end

  @locale_manifest "priv/.cldr_locale_manifest"
  defp previous_locales do
    case File.read(@locale_manifest) do
      {:error, :enoent} ->
        create_manifest()
        previous_locales()
      {:ok, binary} ->
        :erlang.binary_to_term(binary)
    end
  end

  defp create_manifest do
    locales =
      configured_locales()
      |> :erlang.term_to_binary

    File.write!(@locale_manifest, locales)
  end
end