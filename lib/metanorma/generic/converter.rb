require "asciidoctor"
require "metanorma-standoc"
require "fileutils"
require_relative "front"
require_relative "bibdata_config"
require "metanorma"
require "pathname"

module Metanorma
  module Generic
    class Converter < Standoc::Converter
      register_for "generic"

      def baselocation(loc)
        loc.nil? and return nil
        loc
      end

      def doctype(node)
        d = super
        node.attr("doctype") == "article" and d = "article"
        a = configuration.default_doctype and @default_doctype = a
        configuration.doctypes or
          return d == "article" ? @default_doctype : d
        type = @default_doctype || configuration.doctypes.keys[0]
        if !configuration.doctypes.key?(d)
          node.attr("doctype") && node.attr("doctype") != "article" and # factory default
            @log.add("GENERIC_1", nil, params: [d, type])
          d = type
        end
        d
      end

      def read_config_file(path_to_config_file)
        Metanorma::Generic.configuration
          .set_default_values_from_yaml_file(path_to_config_file)
        # reregister Processor to Metanorma with updated values
        if defined? Metanorma::Registry
          Metanorma::Registry.instance.register(Metanorma::Generic::Processor)
        end
      end

      def sectiontype_streamline(ret)
        if configuration.termsdefs_titles&.map(&:downcase)&.include? ret
          "terms and definitions"
        elsif configuration.symbols_titles&.map(&:downcase)&.include? ret
          "symbols and abbreviated terms"
        elsif configuration.normref_titles&.map(&:downcase)&.include? ret
          "normative references"
        elsif configuration.bibliography_titles&.map(&:downcase)&.include? ret
          "bibliography"
        else
          super
        end
      end

      def document(node)
        if node.attr("customize")
          p = node.attr("customize")
          (Pathname.new p).absolute? or
            p = File.expand_path(File.join(Metanorma::Utils::localdir(node), p))
          read_config_file(p)
        end
        super
      end

      def outputs(node, ret)
        File.open("#{@filename}.xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node)&.convert("#{@filename}.xml")
        html_converter(node)&.convert("#{@filename}.presentation.xml",
                                      nil, false, "#{@filename}.html")
        doc_converter(node)&.convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.doc")
        pdf_converter(node)&.convert("#{@filename}.presentation.xml",
                                     nil, false, "#{@filename}.pdf")
      end

      def blank_method(*args); end

      def html_converter(node)
        IsoDoc::Generic::HtmlConvert.new(html_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Generic::PresentationXMLConvert
          .new(html_extract_attributes(node)
          .merge(output_formats: ::Metanorma::Generic::Processor.new
            .output_formats))
      end

      alias_method :pdf_converter, :html_converter
      alias_method :style, :blank_method
      alias_method :title_validate, :blank_method

      def doc_converter(node)
        IsoDoc::Generic::WordConvert.new(doc_extract_attributes(node))
      end

      def configuration
        Metanorma::Generic.configuration
      end
    end
  end
end

require "metanorma/generic/log"
