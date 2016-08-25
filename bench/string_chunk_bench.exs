defmodule String.Chunk.Test do
  use Benchfella

  @string "123456789"

  bench "[3] String version forward" do
    Cldr.Number.String.chunk_string(@string, 3, :forward)
  end

  bench "[2] List version forward" do
    Cldr.Number.String.chunk_string2(@string, 3, :forward)
  end

  bench "[1] List version forward revised" do
    Cldr.Number.String.chunk_string3(@string, 3, :forward)
  end

  bench "[3] String version reverse" do
    Cldr.Number.String.chunk_string(@string, 3, :reverse)
  end

  bench "[2] List version reverse" do
    Cldr.Number.String.chunk_string2(@string, 3, :reverse)
  end

  bench "[1] List version reverse revised" do
    Cldr.Number.String.chunk_string3(@string, 3, :reverse)
  end
end