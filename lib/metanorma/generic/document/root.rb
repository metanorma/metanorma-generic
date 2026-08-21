# frozen_string_literal: true

module Metanorma
  module Generic::Document
    class Root < Lutaml::Model::Serializable
      include Metanorma::StandardDocument::RootAttributes

      attribute :bibdata,
                Metanorma::StandardDocument::Metadata::StandardBibData
      attribute :preface,
                Metanorma::StandardDocument::Sections::Preface
      attribute :sections,
                Metanorma::StandardDocument::Sections::Sections,
                collection: true
      attribute :annex,
                Metanorma::StandardDocument::Sections::AnnexSection,
                collection: true
      attribute :misccontainer,
                Metanorma::StandardDocument::Sections::MiscContainer

      xml do
        element "metanorma"
        namespace Metanorma::StandardDocument::Namespace

        Metanorma::StandardDocument::RootXmlMapping.apply(self)

        map_element "misc-container", to: :misccontainer
      end
    end
  end
end