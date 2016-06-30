defmodule Cldr.Currency do
  defstruct [:code, :name, :one, :many, :symbol, :narrow_symbol, :minor_units, :number]
  alias Cldr.Currency

  @moduledoc """
  *Implements CLDR currency format functions*
  
  Note that the actual data used is the json version of cldr, not the LDML version described in the standard.  
  Conversion is done using the Unicode Consortiums [ldml2json](http://cldr.unicode.org/tools) tool.
  """
  @spec locale_path(binary) :: String.t
  def locale_path(locale) when is_binary(locale) do
    Path.join(Cldr.locale_dir(), "/#{locale}/currencies.json")
  end
  
  @iso4217_path   Path.join(Cldr.data_dir, "iso4217/list_one.xml")
  @iso4217_data   Xml.parse(@iso4217_path)
  @resource       @iso4217_path
  
  IO.puts "Generating currencies for locales #{inspect Cldr.known_locales}"
  IO.puts "Default locale is #{inspect Cldr.default_locale}"
  
  @spec find(String.t, String.t) :: %Cldr.Currency{}
  def find(currency, locale \\ Cldr.default_locale)
  def find(currency, locale) when is_binary(currency),
    do: do_find(String.upcase(currency), locale)
  def find(currency, locale) when is_atom(currency),
    do: find(Atom.to_string(currency), locale)
  
  {:ok, currencies} = 
    Path.join(Cldr.locale_dir(), "/#{Cldr.default_locale()}/currencies.json") 
    |> File.read! 
    |> Poison.decode
  @currencies currencies["main"][Cldr.default_locale()]["numbers"]["currencies"] 
    |> Enum.map(fn {code, _currency} -> code end)
  
  def known_currencies do
    @currencies
  end

  def known_currency?(currency) when is_binary(currency) do
    upcase_currency = String.upcase(currency)
    !!Enum.find(known_currencies, &(&1 == upcase_currency))
  end
  def known_currency?(currency) when is_atom(currency) do
    known_currency?(Atom.to_string(currency))
  end
    
  @spec do_find(String.t, String.t) :: %Cldr.Currency{}
  Enum.each Cldr.known_locales, fn locale ->
    {:ok, currencies} = 
      Path.join(Cldr.locale_dir(), "/#{locale}/currencies.json") 
      |> File.read! 
      |> Poison.decode
      
    currencies = currencies["main"][locale]["numbers"]["currencies"]
    Enum.each currencies, fn {code, currency} ->
      iso_currency = Xml.first(@iso4217_data, "//CcyNtry[Ccy='#{code}']") 
      currency_number = iso_currency |> Xml.first("//CcyNbr") |> Xml.text
      currency_number =
        if is_nil(currency_number), 
          do: nil,
          else: String.to_integer(currency_number)
        
      minor_units = iso_currency |> Xml.first("//CcyMnrUnts") |> Xml.text
      minor_units = 
        if minor_units == "N.A." || is_nil(minor_units),
          do: 0, 
          else: String.to_integer(minor_units)
        
      defp do_find(unquote(code), unquote(locale)) do
        %Currency{
          code: unquote(code),
          name: unquote(currency["displayName"]), 
          one:  unquote(currency["displayName-count-one"]),
          many: unquote(currency["displayName-count-other"]),
          symbol: unquote(currency["symbol"]),
          narrow_symbol: unquote(currency["symbol-alt-narrow"]),
          minor_units:   unquote(minor_units),
          number: unquote(currency_number)
        }
      end
    end
  end
  
  defp do_find(any, locale) when is_binary(any) do
    raise ArgumentError, message: "Currency #{inspect any} is not known in locale #{inspect locale}"
  end

end