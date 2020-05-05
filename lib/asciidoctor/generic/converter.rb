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
        File.expand_path(File.join(File.dirname(self.class::_file || __FILE__), "..", "..", "..", loc))
      end

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name configuration.organization_name_long
          end
        end
        personal_author(node, xml)
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name configuration.organization_name_long
          end
        end
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

      def docidentifier_cleanup(xmldoc)
        template = configuration.docid_template ||
          "{{ organization_name_short }} {{ docnumeric }}"
        docid = xmldoc.at("//bibdata/docidentifier")
        id = boilerplate_isodoc(xmldoc).populate_template(template, nil)
        id.empty? and docid.remove or docid.children = id
      end

      def metadata_id(node, xml)
        xml.docidentifier do |i|
          i << "DUMMY"
        end
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def metadata_copyright(node, xml)
        from = node.attr("copyright-year") || Date.today.year
        xml.copyright do |c|
          c.from from
          c.owner do |owner|
            owner.organization do |o|
              o.name configuration.organization_name_long
            end
          end
        end
      end

      def metadata_ext(node, ext)
        super
        Array(configuration.metadata_extensions).each do |e|
          a = node.attr(e) and ext.send e, a
        end
      end

=begin
      def makexml(node)
        #root_tag = configuration.xml_root_tag || XML_ROOT_TAG
        root_tag = XML_ROOT_TAG
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<#{root_tag}>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</#{root_tag}>"
        result = textcleanup(result)
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1) unless @novalid
        ret1.root.add_namespace(nil, configuration.document_namespace ||
                                XML_NAMESPACE)
        ret1
      end
=end

      def doctype(node)
        d = node.attr("doctype")
        unless %w{policy-and-procedures best-practices supporting-document
          report legal directives proposal standard}.include? d
          @log.add("Document Attributes", nil,
                   "#{d} is not a legal document type: reverting to 'standard'")
          d = "standard"
        end
        d
      end

      def read_config_file(path_to_config_file)
        Metanorma::Generic.configuration.
          set_default_values_from_yaml_file(path_to_config_file)
      end

      def document(node)
        read_config_file(node.attr("customize")) if node.attr("customize")
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          html_converter(node).convert filename unless node.attr("nodoc")
          word_converter(node).convert filename unless node.attr("nodoc")
          pdf_converter(node)&.convert filename unless node.attr("nodoc")
        end
        @log.write(@localdir + @filename + ".err") unless @novalid
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        baselocation(configuration.validate_rng_file) ||
                        File.join(File.dirname(__FILE__), "generic.rng"))
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

      alias_method :pdf_converter, :html_converter
      alias_method :style, :blank_method
      alias_method :title_validate, :blank_method

      def word_converter(node)
        IsoDoc::Generic::WordConvert.new(doc_extract_attributes(node))
      end

      def configuration
        Metanorma::Generic.configuration
      end

      def boilerplate_isodoc(xmldoc)
        conv = super
        Metanorma::Generic::Configuration::CONFIG_ATTRS.each do |a|
          conv.labels[a] = configuration.send a
        end
        conv
      end
    end
  end
end
