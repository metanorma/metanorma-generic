require "asciidoctor"
require "asciidoctor/standoc/converter"
require "fileutils"

module Asciidoctor
  module Acme

    # A {Converter} implementation that generates RSD output, and a document
    # schema encapsulation of the document for validation
    #
    class Converter < Standoc::Converter
      register_for "acme"

      def metadata_author(node, xml)
        xml.contributor do |c|
          c.role **{ type: "author" }
          c.organization do |a|
            a.name configuration.organization_name_short
          end
        end
      end

      def metadata_publisher(node, xml)
        xml.contributor do |c|
          c.role **{ type: "publisher" }
          c.organization do |a|
            a.name configuration.organization_name_short
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
        if id.empty? then docid.remove
        else
          docid.children
        end
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
              o.name configuration.organization_name_short
            end
          end
        end
      end

      def metadata_security(node, xml)
        security = node.attr("security") || return
        xml.security security
      end

      def metadata_ext(node, xml)
        super
        metadata_security(node, xml)
      end

      def title_validate(root)
        nil
      end

      def makexml(node)
        root_tag = configuration.xml_root_tag || 'acme-standard'
        result = ["<?xml version='1.0' encoding='UTF-8'?>\n<#{root_tag}>"]
        @draft = node.attributes.has_key?("draft")
        result << noko { |ixml| front node, ixml }
        result << noko { |ixml| middle node, ixml }
        result << "</#{root_tag}>"
        result = textcleanup(result)
        ret1 = cleanup(Nokogiri::XML(result))
        validate(ret1) unless @novalid
        ret1.root.add_namespace(nil, configuration.document_namespace)
        ret1
      end

      def doctype(node)
        d = node.attr("doctype")
        unless %w{policy-and-procedures best-practices supporting-document report legal directives proposal standard}.include? d
          warn "#{d} is not a legal document type: reverting to 'standard'"
          d = "standard"
        end
        d
      end

      def document(node)
        init(node)
        ret1 = makexml(node)
        ret = ret1.to_xml(indent: 2)
        unless node.attr("nodoc") || !node.attr("docfile")
          filename = node.attr("docfile").gsub(/\.adoc/, ".xml").
            gsub(%r{^.*/}, "")
          File.open(filename, "w") { |f| f.write(ret) }
          html_converter(node).convert filename unless node.attr("nodoc")
          word_converter(node).convert filename unless node.attr("nodoc")
          pdf_converter(node).convert filename unless node.attr("nodoc")
        end
        @files_to_delete.each { |f| FileUtils.rm f }
        ret
      end

      def validate(doc)
        content_validate(doc)
        schema_validate(formattedstr_strip(doc.dup),
                        configuration.validate_rng_file ||
                        File.join(File.dirname(__FILE__), "acme.rng"))
      end

      def html_path_acme(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def sections_cleanup(x)
        super
        x.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def style(n, t)
        return
      end

      def html_converter(node)
        IsoDoc::Acme::HtmlConvert.new(html_extract_attributes(node))
      end

      def pdf_converter(node)
        IsoDoc::Acme::PdfConvert.new(html_extract_attributes(node))
      end

      def word_converter(node)
        IsoDoc::Acme::WordConvert.new(doc_extract_attributes(node))
      end

      def configuration
        Metanorma::Acme.configuration
      end

      def boilerplate_isodoc(xmldoc)
        conv = super
        Metanorma::Acme::Configuration::CONFIG_ATTRS.each do |a|
          conv.labels[a] = configuration.send a
        end
        conv
      end
    end
  end
end
