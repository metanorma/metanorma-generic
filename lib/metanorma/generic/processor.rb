require "metanorma/processor"

module Metanorma
  module Generic
    class Processor < Metanorma::Processor
      def configuration
        Metanorma::Generic.configuration
      end

      def initialize
        @short = configuration&.metanorma_name&.to_sym || :generic
        @input_format = :asciidoc
        @asciidoctor_backend = configuration&.metanorma_name&.to_sym || :generic
      end

      def output_formats
        super.merge(
          html: "html",
          doc: "doc",
          pdf: "pdf"
        )
      end

      def version
        "Metanorma::Generic #{Metanorma::Generic::VERSION}"
      end

      def extract_options(file)
        head = file.sub(/\n\n.*$/m, "\n")
        /\n:htmlstylesheet: (?<htmlstylesheet>[^\n]+)\n/ =~ head
        /\n:htmlcoverpage: (?<htmlcoverpage>[^\n]+)\n/ =~ head
        /\n:htmlintropage: (?<htmlintropage>[^\n]+)\n/ =~ head
        /\n:scripts: (?<scripts>[^\n]+)\n/ =~ head
        /\n:wordstylesheet: (?<wordstylesheet>[^\n]+)\n/ =~ head
        /\n:standardstylesheet: (?<standardstylesheet>[^\n]+)\n/ =~ head
        /\n:header: (?<header>[^\n]+)\n/ =~ head
        /\n:wordcoverpage: (?<wordcoverpage>[^\n]+)\n/ =~ head
        /\n:wordintropage: (?<wordintropage>[^\n]+)\n/ =~ head
        /\n:ulstyle: (?<ulstyle>[^\n]+)\n/ =~ head
        /\n:olstyle: (?<olstyle>[^\n]+)\n/ =~ head
        new_options = {
          htmlstylesheet: defined?(htmlstylesheet) ? htmlstylesheet : nil,
          htmlcoverpage: defined?(htmlcoverpage) ? htmlcoverpage : nil,
          htmlintropage: defined?(htmlintropage) ? htmlintropage : nil,
          scripts: defined?(scripts) ? scripts : nil,
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

      def output(isodoc_node, inname, outname, format, options={})
        case format
        when :html
          IsoDoc::Generic::HtmlConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :doc
          IsoDoc::Generic::WordConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :pdf
          IsoDoc::Generic::PdfConvert.new(options).convert(inname, isodoc_node, nil, outname)
        when :presentation
          IsoDoc::Generic::PresentationXMLConvert.new(options).convert(inname, isodoc_node, nil, outname)
        else
          super
        end
      end
    end
  end
end
