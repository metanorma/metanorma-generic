require "asciidoctor"
require "metanorma/standoc/converter"
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

=begin
      def docidentifier_cleanup(xmldoc)
        docid = xmldoc.at("//bibdata/docidentifier") or return
        docid.text.empty? or return
        id = docidentifier_from_template(xmldoc) or return
        (id.empty? and docid.remove) or docid.children = id
      end

      def docidentifier_from_template(xmldoc)
        b = boilerplate_isodoc(xmldoc) or return
        template = configuration.docid_template ||
          "{{ agency }} {{ docnumeric }}"
        b.populate_template(template, nil)
      end
=end

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

      def schema_location
        baselocation(configuration.validate_rng_file) ||
          File.join(File.dirname(__FILE__), "generic.rng")
      end

      def schema_file
        configuration.validate_rng_file || "generic.rng"
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
        stage = xmldoc.at("//bibdata/status/stage")&.text
        stages.include? stage or
          @log.add("GENERIC_2", nil, params: [stage])
      end

      def committee_validate(xmldoc)
        committees = Array(configuration&.committees) || return
        committees.empty? and return
        xmldoc.xpath("//bibdata/contributor[role/description = 'committee']/" \
            "organization/subdivision/name").each do |c|
          committees.include? c.text or
            @log.add("GENERIC_3", nil, params: [c.text])
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

      def boilerplate_isodoc(xmldoc)
        conv = super or return nil
        Metanorma::Generic::Configuration::CONFIG_ATTRS.each do |a|
          conv.meta.set(a, configuration.send(a))
        end
        # conv.meta.set(:bibdata, bibdata_hash(xmldoc))
        @isodoc = conv
        @isodoc
      end

      def bibdata_hash(xmldoc)
        b = xmldoc.at("//bibdata") || xmldoc.at("//xmlns:bibdata")
        BibdataConfig.from_xml("<metanorma>#{b.to_xml}</metanorma>")
          .bibdata.to_hash
      end

      def boilerplate_file(xmldoc)
        f = configuration.boilerplate
        f.nil? and return super
        f.is_a? String and return baselocation(f)
        f.is_a? Hash and f[@lang] and return baselocation(f[@lang])
        super
      end

      def published?(status, _xmldoc)
        stages = configuration&.published_stages || ["published"]
        (Array(stages).map(&:downcase).include? status.downcase)
      end
    end
  end
end

require "metanorma/generic/log"
