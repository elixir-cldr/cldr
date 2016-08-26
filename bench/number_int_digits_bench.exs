defmodule Number.Int.Digits.Test do
  use Benchfella
  Code.require_file("number_int_digits.exs", "./bench/scenarios")

  @int 1_000_000_000
  @decimal Decimal.new(@int)

  bench "[1] Integer.digits version" do
    Number.Int.Digits.Bench.number_of_integer_digits(@int)
  end

  bench "[1] Decimal Integer.digits version" do
    Number.Int.Digits.Bench.number_of_integer_digits(@decimal)
  end

  bench "[2] floor(log10(number)) + 1" do
    Number.Int.Digits.Bench.number_of_integer_digits2(@int)
  end

  bench "[2] Decimal floor(log10(number)) + 1" do
    Number.Int.Digits.Bench.number_of_integer_digits2(@decimal)
  end

  bench "[3] successive division" do
    Number.Int.Digits.Bench.number_of_integer_digits3(@int)
  end

  bench "[3] Decimal successive division" do
    Number.Int.Digits.Bench.number_of_integer_digits3(@decimal)
  end

  bench "[4] Divide by 10" do
    Number.Int.Digits.Bench.number_of_integer_digits4(@int)
  end

  bench "[4] Decimal Divide by 10" do
    Number.Int.Digits.Bench.number_of_integer_digits4(@decimal)
  end
end
