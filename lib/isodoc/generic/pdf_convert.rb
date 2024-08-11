require_relative "base_convert"
require "metanorma-generic"
require "isodoc"

module IsoDoc
  module Generic
    class PdfConvert < IsoDoc::XslfoPdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def pdf_stylesheet(docxml)
        configuration.pdf_stylesheet
      end

      include BaseConvert
      include Init
    end
  end
end
