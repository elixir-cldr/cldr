ExUnit.start [trace: "--trace" in System.argv, timeout: 120_000]

{:ok, files} = File.ls("./test/support")

Enum.each files, fn(file) ->
  Code.require_file "support/#{file}", __DIR__
end