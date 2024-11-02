require "isodoc"
require "fileutils"

module IsoDoc
  module Generic
    module BaseConvert
      def cleanup(docxml)
        super
        term_cleanup(docxml)
      end

      def term_cleanup(docxml)
        docxml.xpath("//p[@class = 'Terms']").each do |d|
          h2 = d.at("./preceding-sibling::*[@class = 'TermNum'][1]")
          d["id"] = h2["id"]
          d.add_first_child "<strong>#{to_xml(h2.remove.children)}</strong>&#xa0;"
        end
        docxml
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72",
                      "xml:lang": "EN-US", class: "container" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def info(isoxml, out)
        @meta.ext isoxml, out
        super
      end
    end
  end
end
