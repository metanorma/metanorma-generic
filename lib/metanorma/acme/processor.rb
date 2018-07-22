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

      def extract_options(file)
        header = file.sub(/\n\n.*$/m, "")
        /\n:htmlstylesheet: (?<htmlstylesheet>[^\n]+)\n/ =~ header
        /\n:htmlcoverpage: (?<htmlcoverpage>[^\n]+)\n/ =~ header
        /\n:htmlintropage: (?<htmlintropage>[^\n]+)\n/ =~ header
        /\n:htmlscripts: (?<htmlscripts>[^\n]+)\n/ =~ header
        /\n:wordstylesheet: (?<wordstylesheet>[^\n]+)\n/ =~ header
        /\n:standardstylesheet: (?<standardstylesheet>[^\n]+)\n/ =~ header
        /\n:header: (?<header>[^\n]+)\n/ =~ header
        /\n:wordcoverpage: (?<wordcoverpage>[^\n]+)\n/ =~ header
        /\n:wordintropage: (?<wordintropage>[^\n]+)\n/ =~ header
        /\n:ulstyle: (?<ulstyle>[^\n]+)\n/ =~ header
        /\n:olstyle: (?<olstyle>[^\n]+)\n/ =~ header
        new_options = {
          htmlstylesheet: defined?(htmlstylesheet) ? htmlstylesheet : nil,
          htmlcoverpage: defined?(htmlcoverpage) ? htmlcoverpage : nil,
          htmlintropage: defined?(htmlintropage) ? htmlintropage : nil,
          htmlscripts: defined?(htmlscripts) ? htmlscripts : nil,
          wordstylesheet: defined?(wordstylesheet) ? wordstylesheet : nil,
          standardstylesheet: defined?(standardstylesheet) ? standardstylesheet : nil,
          header: defined?(header) ? header : nil,
          wordcoverpage: defined?(wordcoverpage) ? wordcoverpage : nil,
          wordintropage: defined?(wordintropage) ? wordintropage : nil,
          ulstyle: defined?(ulstyle) ? ulstyle : nil,
          olstyle: defined?(olstyle) ? olstyle : nil,
        }.reject { |_, val| val.nil? }
        super.merge(new_options)
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
