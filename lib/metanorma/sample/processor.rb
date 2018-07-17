require "metanorma/processor"

module Metanorma
  module Sample
    class Processor < Metanorma::Processor

      def initialize
        @short = :sample
        @input_format = :asciidoc
        @asciidoctor_backend = :sample
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Asciidoctor::Sample #{Asciidoctor::Sample::VERSION}"
      end

      def input_to_isodoc(file)
        Metanorma::Input::Asciidoc.new.process(file, @asciidoctor_backend)
      end

      def output(isodoc_node, outname, format, options={})
        case format
        when :html
          IsoDoc::Sample::HtmlConvert.new(options).convert(outname, isodoc_node)
        when :doc
          IsoDoc::Sample::WordConvert.new(options).convert(outname, isodoc_node)
        when :pdf
          IsoDoc::Sample::PdfConvert.new(options).convert(outname, isodoc_node)
=begin
          require 'tempfile'
          outname_html = outname + ".html"
          IsoDoc::Sample::HtmlConvert.new(options).convert(outname_html, isodoc_node)
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
