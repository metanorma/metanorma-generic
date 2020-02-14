require "isodoc"

module IsoDoc
  module Acme

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        default_logo_path = File.expand_path(File.join(here, "html", "logo.jpg"))
        set(:logo, ::IsoDoc::Acme::BaseConvert.baselocation(configuration.logo_path) || default_logo_path)
      end

      def configuration
        Metanorma::Acme.configuration
      end

      def author(isoxml, _out)
        super
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def stage_abbr(status)
        return super unless configuration.stage_abbreviations
        Hash(configuration.stage_abbreviations).dig(status)
      end

      def unpublished(status)
        stages = configuration&.published_stages || ["published"]
        !(Array(stages).map { |m| m.downcase }.include? status.downcase)
      end
    end
  end
end
