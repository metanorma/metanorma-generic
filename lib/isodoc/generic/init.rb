require "isodoc"
require_relative "metadata"
require_relative "xref"
require_relative "i18n"
require_relative "utils"

module IsoDoc
  module Generic
    module Init
      def metadata_init(lang, script, locale, i18n)
        @meta = Metadata.new(lang, script, locale, i18n)
      end

      def xref_init(lang, script, _klass, i18n, options)
        html = HtmlConvert.new(language: lang, script: script)
        @xrefs = Xref.new(lang, script, html, i18n, options)
      end

      def i18n_init(lang, script, locale, i18nyaml = nil)
        f = Metanorma::Generic.configuration.i18nyaml
        f = nil unless f.is_a? String
        @i18n = I18n.new(
          lang, script, locale: locale, i18nyaml: i18nyaml || f || @i18nyaml)
      end

      include Utils
    end
  end
end

