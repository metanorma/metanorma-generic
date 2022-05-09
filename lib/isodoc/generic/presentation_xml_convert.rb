require_relative "init"
require_relative "metadata"
require "isodoc"

module IsoDoc
  module Generic
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def annex1(elem)
        lbl = @xrefs.anchor(elem["id"], :label)
        if t = elem.at(ns("./title"))
          t.children = "<strong>#{t.children.to_xml}</strong>"
        end
        prefix_name(elem, "<br/>", lbl, "title")
      end

      include Init
    end
  end
end
