# frozen_string_literal: true

require "spec_helper"
require "relaton/cli"

RSpec.describe Metanorma::Generic::BibdataConfig do
  it "preserves embedded MathML when deserialising a bibdata title" do
    input = <<~XML
      <metanorma xmlns="https://www.metanorma.org/ns/standoc">
        <bibdata type="standard">
          <title language="en" format="text/plain" type="title-main">Internal Standard Reference Data for qNMR: 4,4-Dimethyl-4-silapentane-1-sulfonic acid-<stem block="false" type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><mstyle displaystyle="false"><msub><mi>d</mi><mn>6</mn></msub></mstyle></math><asciimath>d_6</asciimath></stem> [ISRD-07]</title>
          <docidentifier primary="true" type="BIPM">BIPM-2019/04</docidentifier>
          <language>en</language>
          <script>Latn</script>
          <status><stage>published</stage></status>
        </bibdata>
      </metanorma>
    XML

    xmldoc = Nokogiri::XML(input)
    b = xmldoc.at("//bibdata") || xmldoc.at("//xmlns:bibdata")
    stripped = Nokogiri::XML(b.to_xml)
    stripped.remove_namespaces!
    bib = described_class
      .from_xml("<metanorma>#{stripped.root.to_xml}</metanorma>")
      .bibdata

    expect(bib).not_to be_nil
    # schema_version tracks Relaton model versions and would force this
    # fixture to be re-blessed on every Relaton release, so strip it.
    actual = bib.to_yaml.sub(/^schema_version: .*\n/, "")
    expect(actual)
      .to eq(File.read(fixture_path("bibdata_mathml_title.yml")))
  end
end
