# frozen_string_literal: true

module Metanorma
  module Generic::Document
    class Root < Lutaml::Model::Serializable
      include Metanorma::Standoc::Document::RootAttributes

      attribute :bibdata,
                Metanorma::Standoc::Document::Metadata::StandardBibData
      attribute :preface,
                Metanorma::Standoc::Document::Sections::Preface
      attribute :sections,
                Metanorma::Standoc::Document::Sections::Sections,
                collection: true
      attribute :annex,
                Metanorma::Standoc::Document::Sections::AnnexSection,
                collection: true
      attribute :misccontainer,
                Metanorma::Standoc::Document::Sections::MiscContainer

      xml do
        element "metanorma"
        namespace Metanorma::Standoc::Document::Namespace

        Metanorma::Standoc::Document::RootXmlMapping.apply(self)

        map_element "misc-container", to: :misccontainer
      end
    end
  end
end