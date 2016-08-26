defmodule String.Chunk.Bench.Test do
  use Benchfella
  Code.require_file("string_chunk.exs", "./bench/scenarios")

  @string "123456789"

  bench "[3] String version forward" do
    String.Chunk.Bench.chunk_string(@string, 3, :forward)
  end

  bench "[2] List version forward" do
    String.Chunk.Bench.chunk_string2(@string, 3, :forward)
  end

  bench "[1] List version forward revised" do
    String.Chunk.Bench.chunk_string3(@string, 3, :forward)
  end

  bench "[3] String version reverse" do
    String.Chunk.Bench.chunk_string(@string, 3, :reverse)
  end

  bench "[2] List version reverse" do
    String.Chunk.Bench.chunk_string2(@string, 3, :reverse)
  end

  bench "[1] List version reverse revised" do
    String.Chunk.Bench.chunk_string3(@string, 3, :reverse)
  end
end