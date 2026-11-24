# frozen_string_literal: true

require "tmpdir"
require "spec_helper"
require "metanorma/generic/presentation/transformer"
require_relative "native_fixture"

# Needs the document compile pipeline (metanorma-core line of #689).
# Skipped where the installed metanorma gem predates it.
pipeline_available = begin
  require "metanorma"
  require "metanorma/compile/document_pipeline"
  true
rescue LoadError
  false
end

RSpec.describe Metanorma::Generic::Presentation::Transformer, "in the compile pipeline",
               skip: (pipeline_available ? false : "metanorma document pipeline unavailable") do
  include NativeGenericFixture

  # The source stage (Coridoc builder) has no Generic::Document::Root branch yet,
  # so the semantic model is supplied from the real SDK fixture; discovery of the
  # presenter, LADL labelling and rendering are the real pipeline stages.
  it "presents and renders a generic model through the Document pipeline without writing XML" do
    Dir.mktmpdir do |dir|
      source = File.join(dir, "document.adoc")
      File.write(source, "= Example\n")
      compiler = Metanorma::Compile.new
      allow_any_instance_of(Metanorma::Compile::DocumentPipeline)
        .to receive(:source_model).and_return(native_generic_fixture)
      allow(compiler).to receive(:generate_semantic_xml).and_call_original
      result = compiler.compile(source, pipeline: :document, type: :generic,
                                        extension_keys: [:html], novalid: true)
      expect(result.semantic_model).to be_a(Metanorma::Generic::Document::Root)
      expect(result.presentation_model.type).to eq("presentation")
      expect(File.read(result.outputs.fetch(:html))).to include(
        "Retained body.", "rich", "Clause 2"
      )
      expect(compiler).not_to have_received(:generate_semantic_xml)
      expect(Dir.glob(File.join(dir, "**", "*.xml"))).to be_empty
    end
  end
end
