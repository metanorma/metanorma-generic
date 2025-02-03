require "asciidoctor"
require "metanorma/standoc/converter"
require "fileutils"
require_relative "front"
require "metanorma"
require "pathname"

module Metanorma
  module Generic
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "generic-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/generic".freeze

      register_for "generic"

      #def xml_root_tag
        #configuration.xml_root_tag || XML_ROOT_TAG
      #end
#
      #def xml_namespace
        #configuration.document_namespace || XML_NAMESPACE
      #end

      def baselocation(loc)
        loc.nil? and return nil
        return loc
      end

      def docidentifier_cleanup(xmldoc)
        b = boilerplate_isodoc(xmldoc) or return
        template = configuration.docid_template ||
          "{{ organization_name_short }} {{ docnumeric }}"
        docid = xmldoc.at("//bibdata/docidentifier")
        docid&.text&.empty? or return
        id = b.populate_template(template, nil)
        (id.empty? and docid.remove) or docid.children = id
      end

      def doctype(node)
        d = super
        node.attr("doctype") == "article" and d = "article"
        a = configuration.default_doctype and @default_doctype = a
        unless configuration.doctypes
          d == "article" and return @default_doctype
          return d
        end
        type = @default_doctype || configuration.doctypes.keys[0]
        if !configuration.doctypes.key?(d)
          (node.attr("doctype") && node.attr("doctype") != "article") and # factory default
            @log.add("Document Attributes", nil,
                     "#{d} is not a legal document type: reverting to '#{type}'")
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

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        baselocation(configuration.validate_rng_file) ||
                        File.join(File.dirname(__FILE__), "generic.rng"))
      end

      def content_validate(doc)
        super
        bibdata_validate(doc.root)
      end

      def bibdata_validate(doc)
        stage_validate(doc)
        committee_validate(doc)
      end

      def stage_validate(xmldoc)
        stages = configuration.stage_abbreviations&.keys || return
        stages.empty? and return
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        stages.include? stage or
          @log.add("Document Attributes", nil,
                   "#{stage} is not a recognised status")
      end

      def committee_validate(xmldoc)
        committees = Array(configuration&.committees) || return
        committees.empty? and return
        xmldoc.xpath("//bibdata/ext/editorialgroup/committee").each do |c|
          committees.include? c.text or
            @log.add("Document Attributes", nil,
                     "#{c.text} is not a recognised committee")
        end
      end

      def sections_cleanup(xml)
        super
        xml.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def blank_method(*args); end

      def html_converter(node)
        IsoDoc::Generic::HtmlConvert.new(html_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Generic::PresentationXMLConvert
          .new(html_extract_attributes(node)
          .merge(output_formats: ::Metanorma::Generic::Processor.new.output_formats))
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

      def boilerplate_isodoc(xmldoc)
        conv = super or return nil
        Metanorma::Generic::Configuration::CONFIG_ATTRS.each do |a|
          conv.meta.set(a, configuration.send(a))
        end
        conv
      end

      def boilerplate_file(xmldoc)
        f = configuration.boilerplate
        f.nil? and return super
        f.is_a? String and return baselocation(f)
        f.is_a? Hash and f[@lang] and return baselocation(f[@lang])
        super
      end

      def cleanup(xmldoc)
        super
        empty_metadata_cleanup(xmldoc)
        xmldoc
      end

      def empty_metadata_cleanup(xmldoc)
        xmldoc.xpath("//bibdata/ext//*").each do |x|
          x.remove if x.children.empty?
        end
      end
    end
  end
end
