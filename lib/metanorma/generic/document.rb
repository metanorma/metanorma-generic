# frozen_string_literal: true

require "metanorma/standoc"
module Metanorma
  module Generic
  end
end

module Metanorma
  module Generic::Document
    autoload :Root, "metanorma/generic/document/root"
  end
end

module Metanorma
  existing = defined?(Metanorma::GenericDocument) && Metanorma::GenericDocument
  if !existing.equal?(Metanorma::Generic::Document)
    Metanorma.send(:remove_const, :GenericDocument) if existing
    GenericDocument = Metanorma::Generic::Document
  end
end

# OCP adoption: ONE registration in the metanorma-core flavor table
require "metanorma-core"

Metanorma::Core::Flavors.register(Metanorma::Core::Flavor.new(
  name: :generic,
  gem: "metanorma-generic",
  model_root: Metanorma::Generic::Document::Root,
  pubid_module: nil,
  renderers: { html: lambda do |_document, **_options|
    Metanorma::Html::StandardRenderer
  end },
))
