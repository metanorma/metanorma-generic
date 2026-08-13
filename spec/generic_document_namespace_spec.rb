# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Metanorma::Generic::Document namespace" do
  describe "canonical namespace" do
    it "exposes Metanorma::Generic::Document as a Module" do
      expect(Metanorma::Generic::Document).to be_a(Module)
    end

    it "exposes Root with the canonical name" do
      expect(Metanorma::Generic::Document::Root.name)
        .to eq("Metanorma::Generic::Document::Root")
    end

    it "Root is a lutaml Serializable" do
      expect(Metanorma::Generic::Document::Root < Lutaml::Model::Serializable).to be(true)
    end

    it "Root includes Standoc::Document::RootAttributes" do
      expect(Metanorma::Generic::Document::Root.ancestors)
        .to include(Metanorma::Standoc::Document::RootAttributes)
    end
  end

  describe "backwards-compat alias" do
    it "Metanorma::GenericDocument aliases to the new namespace" do
      expect(Metanorma::GenericDocument).to eq(Metanorma::Generic::Document)
    end

    it "the alias preserves class identity" do
      expect(Metanorma::GenericDocument::Root.equal?(
               Metanorma::Generic::Document::Root)).to be(true)
    end
  end

  describe "parent namespace" do
    it "Metanorma::Standoc::Document is available" do
      expect(Metanorma::Standoc::Document).to be_a(Module)
    end

    it "Metanorma::StandardDocument alias is available" do
      expect(Metanorma::StandardDocument).to eq(Metanorma::Standoc::Document)
    end
  end
end
