if Code.ensure_loaded?(NimbleParsec) do
  defmodule Cldr.Rfc5646.Core do
    @moduledoc false

    import NimbleParsec

    def lowercase do
      ascii_string([?a..?z], 1)
    end

    def uppercase do
      ascii_string([?A..?Z], 1)
    end

    def digit do
      ascii_string([?0..?9], 1)
    end

    def digit3 do
      ascii_string([?0..?9], 3)
    end

    def integer3 do
      integer(3)
    end

    def hex_digit do
      ascii_string([?0..?9, ?a..?f, ?A..?F], 1)
    end

    def alpha do
      ascii_string([?a..?z, ?A..?Z], 1)
    end

    def dash do
      ascii_string([?-], 1)
    end

    def alpha_numeric do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], 1)
    end

    def alpha_numeric3 do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], 3)
    end

    def alpha_numeric2 do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], 2)
    end

    def alpha2 do
      ascii_string([?a..?z, ?A..?Z], 2)
    end

    def alpha3 do
      ascii_string([?a..?z, ?A..?Z], 3)
    end

    def alpha4 do
      ascii_string([?a..?z, ?A..?Z], 4)
    end

    def alpha2_3 do
      ascii_string([?a..?z, ?A..?Z], min: 2, max: 3)
    end

    def alpha5_8 do
      ascii_string([?a..?z, ?A..?Z], min: 5, max: 8)
    end

    def alpha_numeric3_8 do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 3, max: 8)
    end

    def alpha_numeric2_8 do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 2, max: 8)
    end

    def alpha_numeric5_8 do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 5, max: 8)
    end

    def alpha_numeric1_8 do
      ascii_string([?a..?z, ?A..?Z, ?0..?9], min: 1, max: 8)
    end
  end
end
