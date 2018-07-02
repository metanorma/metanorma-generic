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
          doc: "doc"
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
        else
          super
        end
      end
    end
  end
end
