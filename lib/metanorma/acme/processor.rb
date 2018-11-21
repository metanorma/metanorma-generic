require "metanorma/processor"

module Metanorma
  module Acme
    class Processor < Metanorma::Processor

      def initialize
        @short = :acme
        @input_format = :asciidoc
        @asciidoctor_backend = :acme
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::Acme #{Metanorma::Acme::VERSION}"
      end

      def input_to_isodoc(file, filename)
        Metanorma::Input::Asciidoc.new.process(file, filename, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Acme::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Acme::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Acme::PdfConvert.new(options).convert(outname, isodoc_node)
        else
          super
        end
      end
    end
  end
end
