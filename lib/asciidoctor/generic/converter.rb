require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"

module Asciidoctor
  module Generic

    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter
      XML_ROOT_TAG = "generic-standard".freeze
      XML_NAMESPACE = "https://www.metanorma.org/ns/generic".freeze

      register_for "generic"

      def xml_root_tag
        configuration.xml_root_tag || XML_ROOT_TAG
      end

      def xml_namespace
        configuration.document_namespace || XML_NAMESPACE
      end

       def baselocation(loc)
        return nil if loc.nil?
        File.expand_path(File.join(File.dirname(
          self.class::_file || __FILE__), "..", "..", "..", loc))
      end

      def default_publisher
        configuration.organization_name_long
      end

      def org_abbrev
        if !configuration.organization_name_long.empty? &&
            !configuration.organization_name_short.empty? &&
            configuration.organization_name_long !=
            configuration.organization_name_short
          { configuration.organization_name_long =>
            configuration.organization_name_short }
        else
          super
        end
      end

      def relaton_relations
        Array(configuration.relations) || []
      end

      def metadata_committee(node, xml)
        return unless node.attr("committee")
        xml.editorialgroup do |a|
          a.committee node.attr("committee"),
            **attr_code(type: node.attr("committee-type"))
          i = 2
          while node.attr("committee_#{i}") do
            a.committee node.attr("committee_#{i}"),
              **attr_code(type: node.attr("committee-type_#{i}"))
            i += 1
          end
        end
      end

      def metadata_status(node, xml)
        xml.status do |s|
          s.stage ( node.attr("status") || node.attr("docstage") ||
                   configuration.default_stage || "published" )
          x = node.attr("substage") and s.substage x
          x = node.attr("iteration") and s.iteration x
        end
      end

      def docidentifier_cleanup(xmldoc)
        template = configuration.docid_template ||
          "{{ organization_name_short }} {{ docnumeric }}"
        docid = xmldoc.at("//bibdata/docidentifier")
        id = boilerplate_isodoc(xmldoc).populate_template(template, nil)
        id.empty? and docid.remove or docid.children = id
      end

      def metadata_id(node, xml)
        xml.docidentifier **{ type:
                              configuration.organization_name_short } do |i|
          i << "DUMMY"
        end
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def metadata_ext(node, ext)
        super
        if configuration.metadata_extensions.is_a? Hash
          metadata_ext_hash(node, ext, configuration.metadata_extensions)
        else
          Array(configuration.metadata_extensions).each do |e|
            a = node.attr(e) and ext.send e, a
          end
        end
      end

      EXT_STRUCT = %w(_output _attribute _list).freeze

      def metadata_ext_hash(node, ext, hash)
        hash.each do |k, v|
          next if EXT_STRUCT.include?(k) || !v&.is_a?(Hash) && !node.attr(k)
          if v&.is_a?(Hash) && v["_list"]
            csv_split(node.attr(k)).each do |val|
              metadata_ext_hash1(k, val, ext, v, node)
            end
          else
            metadata_ext_hash1(k, node.attr(k), ext, v, node)
          end
        end
      end

      def metadata_ext_hash1(key, value, ext, hash, node)
        return if hash&.is_a?(Hash) && hash["_attribute"]
        is_hash = hash&.is_a?(Hash) &&
            !hash.keys.reject { |n| EXT_STRUCT.include?(n) }.empty?
        return if !is_hash && (value.nil? || value.empty?)
        name = hash&.is_a?(Hash) ? (hash["_output"] || key) : key
        ext.send name, **attr_code(metadata_ext_attrs(hash, node)) do |e|
            is_hash ? metadata_ext_hash(node, e, hash) : (e << value)
        end
      end

      def metadata_ext_attrs(hash, node)
        return {} unless hash.is_a?(Hash)
        ret = {}
        hash.each do |k, v|
          next unless v.is_a?(Hash) && v["_attribute"]
          ret[(v["_output"] || k).to_sym] = node.attr(k)
        end
        ret
      end

      def doctype(node)
        d = super
        configuration.doctypes or return d == "article" ? "standard" : d
        type = configuration.default_doctype ||
          Array(configuration.doctypes).dig(0) || "standard"
        unless Array(configuration.doctypes).include? d
          @log.add("Document Attributes", nil,
                   "#{d} is not a legal document type: reverting to '#{type}'")
          d = type
        end
        d
      end

      def read_config_file(path_to_config_file)
        Metanorma::Generic.configuration.
          set_default_values_from_yaml_file(path_to_config_file)
      end

      def sectiontype_streamline(ret)
        if configuration.termsdefs_titles.map(&:downcase).include? (ret)
          "terms and definitions"
        elsif configuration.symbols_titles.map(&:downcase).include? (ret)
          "symbols and abbreviated terms"
        elsif configuration.normref_titles.map(&:downcase).include? (ret)
          "normative references"
        elsif configuration.bibliography_titles.map(&:downcase).include? (ret)
          "bibliography"
        else
          ret
        end
      end

      def document(node)
        read_config_file(node.attr("customize")) if node.attr("customize")
        super
      end

      def outputs(node, ret)
        File.open(@filename + ".xml", "w:UTF-8") { |f| f.write(ret) }
        presentation_xml_converter(node)&.convert(@filename + ".xml")
        html_converter(node)&.convert(@filename + ".presentation.xml", 
                                      nil, false, "#{@filename}.html")
        doc_converter(node)&.convert(@filename + ".presentation.xml", 
                                     nil, false, "#{@filename}.doc")
        pdf_converter(node)&.convert(@filename + ".presentation.xml", 
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
        stages = configuration&.stage_abbreviations&.keys || return
        stages.empty? and return
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        stages.include? stage or
          @log.add("Document Attributes", nil, "#{stage} is not a recognised status")
      end

      def committee_validate(xmldoc)
        committees = Array(configuration&.committees) || return
        committees.empty? and return
        xmldoc.xpath("//bibdata/ext/editorialgroup/committee").each do |c|
          committees.include? c.text or
            @log.add("Document Attributes", nil, "#{c.text} is not a recognised committee")
        end
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def blank_method(*args); end

      def html_converter(node)
        IsoDoc::Generic::HtmlConvert.new(html_extract_attributes(node))
      end

      def presentation_xml_converter(node)
        IsoDoc::Generic::PresentationXMLConvert.new(html_extract_attributes(node))
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
        conv = super
        Metanorma::Generic::Configuration::CONFIG_ATTRS.each do |a|
          conv.i18n.set(a, configuration.send(a))
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
    end
  end
end
