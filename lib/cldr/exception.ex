defmodule Cldr.UnknownLocaleError do
  @moduledoc """
  Exception raised when an attempt is made to use a locale not configured
  in `Cldr`.  `Cldr.known_locales/0` returns the locale names known to `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownFormatError do
  @moduledoc """
  Exception raised when an attempt is made to use a locale not configured
  in `Cldr`.  `Cldr.known_locales/0` returns the locale names known to `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.FormatError do
  @moduledoc """
  Exception raised when there is an error in the formatting of a number/list/...
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end