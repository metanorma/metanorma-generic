require_relative "init"
require_relative "metadata"
require "isodoc"

module IsoDoc
  module Generic
    class PresentationXMLConvert < IsoDoc::PresentationXMLConvert
      def annex_delim(_elem)
        "<br/>"
      end

      include Init
    end
  end
end
