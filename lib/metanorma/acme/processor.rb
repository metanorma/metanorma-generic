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

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Acme::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Acme::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Acme::PdfConvert.new(options).convert(outname, isodoc_node)
=begin
          require 'tempfile'
          outname_html = outname + ".html"
          IsoDoc::Acme::HtmlConvert.new(options).convert(outname_html, isodoc_node)
          puts outname_html
          system "cat #{outname_html}"
          Metanorma::Output::Pdf.new.convert(outname_html, outname)
=end
        else
          super
        end
      end
    end
  end
end
