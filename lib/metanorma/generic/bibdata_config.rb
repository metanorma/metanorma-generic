module Metanorma
  module Generic
    class BibdataConfig < ::Lutaml::Model::Serializable
      class Bibdata < ::Lutaml::Model::Serializable
        model ::RelatonBib::BibliographicItem
      end

      attribute :bibdata, Bibdata

      xml do
        root "metanorma"
        map_element "bibdata", to: :bibdata, with: { from: :bibdata_from_xml,
                                                     to: :bibdata_to_xml }
      end

      def bibdata_from_xml(model, node)
        node or return
        model.bibdata = Relaton::Cli.parse_xml(node.adapter_node)
      end

      def bibdata_to_xml(model, parent, doc); end
    end
  end
end
