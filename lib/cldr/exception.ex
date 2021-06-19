defmodule Cldr.UnknownLocaleError do
  @moduledoc """
  Exception raised when an attempt is made to use a locale not configured
  in `Cldr`.  `Cldr.known_locale_names/1` returns the locale names known to `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownNumberSystemError do
  @moduledoc """
  Exception raised when an attempt is made to use a number system that is not known
  in `Cldr`.  `Cldr.Number.number_system_names/0` returns the number system names known to `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.NoMatchingLocale do
  @moduledoc """
  Exception raised when no configured locale matches the provided "Accept-Language" header
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownNumberSystemTypeError do
  @moduledoc """
  Exception raised when an attempt is made to use a number system type that is not known
  in `Cldr`.  `Cldr.Number.number_system_types/0` returns the number system types known to `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownFormatError do
  @moduledoc """
  Exception raised when an attempt is made to use a locale that is not configured
  in `Cldr`.  `Cldr.known_locale_names/1` returns the locale names known to `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownUnitError do
  @moduledoc """
  Exception raised when an attempt is made to use a unit that is not known.
  in `Cldr`.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownCalendarError do
  @moduledoc """
  Exception raised when an attempt is made to use a calendar that is not known.
  in `Cldr`.
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

defmodule Cldr.FormatCompileError do
  @moduledoc """
  Exception raised when there is an error in the compiling of a number format.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownCurrencyError do
  @moduledoc """
  Exception raised when there is an invalid currency code.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownTerritoryError do
  @moduledoc """
  Exception raised when there is an invalid territory code.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownOTPAppError do
  @moduledoc """
  Exception raised when the configured OTP app
  is not known
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownPluralRules do
  @moduledoc """
  Exception raised when there are no plural rules for a locale or language.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidDateFormatType do
  @moduledoc """
  Exception raised when there is an invalid date format type.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidTimeFormatType do
  @moduledoc """
  Exception raised when there is an invalid time format type.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidDateTimeFormatType do
  @moduledoc """
  Exception raised when there is an invalid datetime format type.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.Rbnf.NotAvailable do
  @moduledoc """
  Exception raised when there is no RBNF for a locale.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.AcceptLanguageError do
  @moduledoc """
  Exception raised when there no valid language tag
  in an `Accept-Language` header.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.LanguageTag.ParseError do
  @moduledoc """
  Exception raised when a language tag cannot
  be parsed (there is unparsed content).
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.NoDefaultBackendError do
  @moduledoc """
  Exception raised when there is no
  default backend configured
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownMeasurementSystemError do
  @moduledoc """
  Exception raised when the measurement
  system is invalid.
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.UnknownBackendError do
  @moduledoc """
  Exception raised when the backend
  module is unknown or not a backend module
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.AmbiguousTimezoneError do
  @moduledoc """
  Exception raised when the there are more
  than one timezones for a locale
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.NoParentError do
  @moduledoc """
  Exception raised when the there are more
  no parent locale
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidLanguageError do
  @moduledoc """
  Exception raised when a language
  is invalid
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidScriptError do
  @moduledoc """
  Exception raised when a script
  is invalid
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidTerritoryError do
  @moduledoc """
  Exception raised when a territory
  is invalid
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end

defmodule Cldr.InvalidVariantError do
  @moduledoc """
  Exception raised when a language
  variant is invalid
  """
  defexception [:message]

  def exception(message) do
    %__MODULE__{message: message}
  end
end
