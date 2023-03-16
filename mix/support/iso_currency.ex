defmodule Cldr.IsoCurrency do
  import SweetXml

  @xml_file "iso_currencies.xml"
  @iso_xml File.read!(Path.join(Cldr.Config.download_data_dir(), @xml_file))

  @currencies @iso_xml
              |> xpath(
                ~x"//CcyTbl/CcyNtry"l,
                currency: ~x"./Ccy/text()",
                subunit: ~x"./CcyMnrUnts/text()"
              )
              |> Enum.reject(&is_nil(Map.get(&1, :currency)))
              |> Enum.map(&Map.put(&1, :currency, List.to_atom(Map.get(&1, :currency))))
              |> Enum.map(fn
                %{subunit: 'N.A.'} = currency ->
                  Map.put(currency, :subunit, 0)

                currency ->
                  Map.put(currency, :subunit, List.to_integer(Map.get(currency, :subunit)))
              end)
              |> Enum.map(fn c -> {c.currency, c.subunit} end)
              |> Enum.uniq()

  def currencies do
    @currencies
  end
end
