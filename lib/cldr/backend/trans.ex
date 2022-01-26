defmodule Cldr.Trans.Backend do
  @moduledoc false

  def define_locale_backend(config) do
    quote location: :keep, bind_quoted: [config: Macro.escape(config), backend: config.backend] do
      defmodule Trans do
        @moduledoc false
        if Cldr.Config.include_module_docs?(config.generate_docs) do
          @moduledoc """
          Backend module to generate translation schemas
          for user of the [trans](https://hex.pm/packages/trans)
          library.

          WHen defining structured translations for Ecto schemas
          the `Trans` documentation shows the following example

              defmodule MyApp.Article do
                use Ecto.Schema
                use Trans, translates: [:title, :body]

                schema "articles" do
                  field :title, :string
                  field :body, :string
                  embeds_one :translations, Translations, on_replace: :update, primary_key: false do
                    embeds_one :es, MyApp.Article.Translation, on_replace: :update
                    embeds_one :fr, MyApp.Article.Translation, on_replace: :update
                  end
                end
              end

          Using the `translate/3` macro in this module, the following
          will configure structued translations for all locales configured
          in this backend.  An example is:

              defmodule MyApp.Article do
                use Ecto.Schema
                use Trans, translates: [:title, :body]
                use MyApp.Cldr.Trans

                schema "articles" do
                  field :title, :string
                  field :body, :string

                  # The translation module name and the options
                  # may be ommitted - the defaults are those shown
                  translations :translations, Translations, on_replace: :update, primary_key: false
                end
              end

          """
        end

        def __using__(_opts) do
          backend = unquote(backend)

          quote do
            import unquote(backend).Trans
          end
        end

        @doc false
        def default_options do
          [on_replace: :update, primary_key: false]
        end

        defmacro translations(field_name, translation_module \\ Translation, options \\ []) do
          options = Keyword.merge(unquote(backend).Trans.default_options(), options)
          backend = unquote(backend)

          quote do
            embeds_one unquote(field_name), Translations, unquote(options) do
              for locale_name <- unquote(backend).known_locale_names() do
                embeds_one locale_name, unquote(translation_module), on_replace: :update
              end
            end
          end
        end
     end
    end
  end
end
