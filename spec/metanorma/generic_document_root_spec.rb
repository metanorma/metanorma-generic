require "spec_helper"
require "metanorma/generic/document"

RSpec.describe Metanorma::Generic::Document::Root do
  let(:xml) do
    <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" flavor="generic">
      <sections><clause id="a" type="scope"><title>Scope</title><p id="b">Hi.</p></clause></sections>
      </metanorma>
    XML
  end

  # metanorma-mirror walks the document model through a single Sections
  # object; an Array here yields an empty JSON document (metanorma-cli#518).
  it "parses the sections element into one Sections object" do
    sections = described_class.from_xml(xml).sections

    expect(sections).to be_a(Metanorma::Standoc::Document::Sections::Sections)
  end
end
