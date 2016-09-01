ExUnit.start [trace: "--trace" in System.argv, timeout: 120_000]

{:ok, files} = File.ls("./test/support")

for file <- files,
  Path.extname(file) in [".ex", ".exs"]
do
  Code.require_file "support/#{file}", __DIR__
end
