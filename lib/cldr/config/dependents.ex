defmodule Cldr.Config.Dependents do
  @moduledoc false

  @doc """
  Returns a list of apps that depend on ex_cldr

  """
  @provider_modules [
    {Cldr.Number.Backend, :define_number_modules, []},
    {Cldr.Currency.Backend, :define_currency_module, []},
    {Cldr.DateTime.Backend, :define_date_time_modules, []},
    {Cldr.List.Backend, :define_list_module, []},
    {Cldr.Unit.Backend, :define_unit_module, []},
    {Cldr.Territory.Backend, :define_territory_module, []},
    {Cldr.Language.Backend, :define_language_module, []}
  ]

  def cldr_provider_modules do
    @provider_modules
  end

end
