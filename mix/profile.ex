defmodule Cldr.Profile do
  import ExProf.Macro

  @doc "analyze with profile macro"
  def do_analyze do
    profile do
      Cldr.Number.to_string 12345.6789
    end
  end

  @doc "get analysis records and sum them up"
  def run do
    records = do_analyze()
    total_percent = Enum.reduce(records, 0.0, &(&1.percent + &2))
    IO.inspect "total = #{total_percent}"
  end
end
