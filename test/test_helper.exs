ExUnit.start [trace: "--trace" in System.argv, timeout: 120_000]

test_dirs = ["support", "math", "number", "plural_rules"]

for dir <- test_dirs do
  files = File.ls!("./test/#{dir}")
  for file <- files do
    if Path.extname(file) in [".ex", ".exs"] do
      Code.require_file "#{dir}/#{file}", __DIR__
    end
  end
end
