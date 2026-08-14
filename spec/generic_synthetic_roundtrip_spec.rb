# frozen_string_literal: true

require "bundler/setup"
require "rspec/matchers"
require "metanorma/generic/document"

RSpec.describe "Generic synthetic round-trip" do
  def round_trip(root_class, xml)
    doc = root_class.from_xml(xml)
    output = doc.to_xml
    reparsed = root_class.from_xml(output)
    [doc, reparsed, output]
  end

describe "Generic" do
  let(:xml) do
    <<~XML
      <metanorma type="semantic" version="1.0">
        <bibdata type="standard"><title>Generic Doc</title></bibdata>
        <sections>
          <clause id="_c1"><title>Part 1</title><p>Text</p></clause>
        </sections>
        <sections>
          <clause id="_c2"><title>Part 2</title><p>More text</p></clause>
        </sections>
        <misc-container semx-id="_mc1">
          <presentation-metadata><name>TOC Heading Levels</name><value>2</value></presentation-metadata>
        </misc-container>
      </metanorma>
    XML
  end

  it "parses the flavor root with its distinguishing features" do
    doc = Metanorma::Generic::Document::Root.from_xml(xml)
    metadata = doc.misccontainer.presentation_metadata.first
    expect(doc.sections.length).to eq(2)
    expect(doc.sections.last.clause.first.id).to eq("_c2")
    expect(doc.misccontainer.semx_id).to eq("_mc1")
    expect(metadata.name).to eq("TOC Heading Levels")
    expect(metadata.value).to eq("2")
  end

  it "round-trips the flavor-specific structures" do
    _, reparsed, output = round_trip(Metanorma::Generic::Document::Root, xml)
    expect(output).to include("<misc-container")
    expect(output).to include("<presentation-metadata>")
    expect(output).to include("<name>TOC Heading Levels</name>")
    expect(output).to include("<value>2</value>")
    expect(reparsed.sections.length).to eq(2)
    expect(reparsed.misccontainer.presentation_metadata.first.value)
      .to eq("2")
  end
end
end
