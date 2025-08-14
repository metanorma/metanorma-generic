require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Generic do
  before do
    Metanorma::Generic.configure do |config|
      config.organization_name_short = Metanorma::Generic::Configuration.new.organization_name_short
      config.organization_name_long = Metanorma::Generic::Configuration.new.organization_name_long
      config.document_namespace = Metanorma::Generic::Configuration.new.document_namespace
      config.docid_template = Metanorma::Generic::Configuration.new.docid_template
      config.metadata_extensions = Metanorma::Generic::Configuration.new.metadata_extensions
      config.stage_abbreviations = Metanorma::Generic::Configuration.new.stage_abbreviations
      config.doctypes = Metanorma::Generic::Configuration.new.doctypes
      config.default_doctype = Metanorma::Generic::Configuration.new.default_doctype
      config.default_stage = Metanorma::Generic::Configuration.new.default_stage
      config.termsdefs_titles = Metanorma::Generic::Configuration.new.termsdefs_titles
      config.symbols_titles = Metanorma::Generic::Configuration.new.symbols_titles
      config.normref_titles = Metanorma::Generic::Configuration.new.normref_titles
      config.bibliography_titles = Metanorma::Generic::Configuration.new.bibliography_titles
      config.committees = Metanorma::Generic::Configuration.new.committees
      config.relations = Metanorma::Generic::Configuration.new.relations
      config.i18nyaml = Metanorma::Generic::Configuration.new.i18nyaml
      config.boilerplate = Metanorma::Generic::Configuration.new.boilerplate
    end
  end

  it "processes a blank document" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
          #{BLANK_HDR}
      <sections/>
      </metanorma>
    OUTPUT

    expect(strip_guid(Canon.format_xml(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to strip_guid(Canon.format_xml(output))
  end

  it "converts a blank document" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    output = <<~"OUTPUT"
          #{BLANK_HDR}
      <sections/>
      </metanorma>
    OUTPUT

    FileUtils.rm_f "test.html"
    expect(strip_guid(Canon.format_xml(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to strip_guid(Canon.format_xml(output))
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :nodoc:
      :novalid:
      :docnumber: 1000
      :doctype: standard
      :edition: 2
      :revdate: 2000-01-01
      :draft: 3.4
      :committee: TC
      :committee-number: 1
      :committee-type: A
      :committee_2: TC1
      :committee-number_2: 1
      :committee-type_2: B
      :subcommittee: SC
      :subcommittee-number: 2
      :subcommittee-type: B
      :workgroup: WG
      :workgroup-number: 3
      :workgroup-type: C
      :secretariat: SECRETARIAT
      :copyright-year: 2001
      :status: working-draft
      :iteration: 3
      :language: en
      :title: Main Title
      :security: Client Confidential
    INPUT

    output = <<~"OUTPUT"
          <?xml version="1.0" encoding="UTF-8"?>
      <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Generic::VERSION}" flavor="generic">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
        <docidentifier primary="true" type="Acme">Acme 1000</docidentifier>
        <docnumber>1000</docnumber>
      <contributor>
          <role type="author"/>
          <organization>
            <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
            <abbreviation>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</abbreviation>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
            <abbreviation>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</abbreviation>
          </organization>
        </contributor>
      <contributor>
         <role type="author">
            <description>committee</description>
         </role>
         <organization>
            <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
            <subdivision type="Committee" subtype="A">
               <name>TC</name>
               <identifier>A 1</identifier>
               <identifier type="full">A 1</identifier>
            </subdivision>
         </organization>
      </contributor>
      <contributor>
         <role type="author">
            <description>committee</description>
         </role>
         <organization>
            <name>Acme Corp.</name>
            <subdivision type="Committee" subtype="B">
               <name>TC1</name>
               <identifier>B 1</identifier>
               <identifier type="full">B 1</identifier>
            </subdivision>
         </organization>
      </contributor>
        <edition>2</edition>
      <version>
        <revision-date>2000-01-01</revision-date>
        <draft>3.4</draft>
      </version>
        <language>en</language>
        <script>Latn</script>
        <status>
          <stage>working-draft</stage>
          <iteration>3</iteration>
        </status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
            <abbreviation>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</abbreviation>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype>standard</doctype>
        <flavor>generic</flavor>
        </ext>
      </bibdata>
               <metanorma-extension>
                     <semantic-metadata>
         <stage-published>false</stage-published>
      </semantic-metadata>
           <presentation-metadata>
             <name>TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>HTML TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
             <name>DOC TOC Heading Levels</name>
             <value>2</value>
           </presentation-metadata>
           <presentation-metadata>
            <name>PDF TOC Heading Levels</name>
           <value>2</value>
          </presentation-metadata>
         </metanorma-extension>
      <sections/>
      </metanorma>
    OUTPUT

    expect(strip_guid(Canon.format_xml(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to strip_guid(Canon.format_xml(output))
  end

  it "processes default section titles" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc

      == Introduction

      == Scope

      [bibliography]
      == Normative References

      == Terms and definitions

      == Symbols

      == Clause

      [appendix]
      == Annex

      [bibliography]
      == Bibliography
    INPUT
    output = <<~"OUTPUT"
          <metanorma xmlns='https://www.metanorma.org/ns/standoc'  type="semantic" version="#{Metanorma::Generic::VERSION}" flavor="generic">
          <preface>
             <introduction id="_" obligation="informative">
                <title id="_">Introduction</title>
             </introduction>
          </preface>
          <sections>
             <clause id="_" type="scope" obligation="normative">
                <title id="_">Scope</title>
             </clause>
             <terms id="_" obligation="normative">
                <title id="_">Terms and definitions</title>
                <p id="_">No terms and definitions are listed in this document.</p>
             </terms>
             <definitions id="_" type="symbols" obligation="normative">
                <title id="_">Symbols</title>
             </definitions>
             <clause id="_" obligation="normative">
                <title id="_">Clause</title>
             </clause>
          </sections>
          <annex id="_" obligation="normative">
             <title id="_">Annex</title>
          </annex>
          <bibliography>
             <references id="_" normative="true" obligation="informative">
                <title id="_">Normative references</title>
                <p id="_">There are no normative references in this document.</p>
             </references>
             <references id="_" normative="false" obligation="informative">
                <title id="_">Bibliography</title>
             </references>
          </bibliography>
       </metanorma>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:bibdata").remove
    xml.at("//xmlns:metanorma-extension").remove
    expect(strip_guid(Canon.format_xml(strip_guid(xml.to_xml))))
      .to be_equivalent_to strip_guid(Canon.format_xml(output))
  end

  it "strips inline header" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      This is a preamble

      == Section 1
    INPUT

    output = <<~"OUTPUT"
      #{BLANK_HDR}
                 <preface><foreword id="_" obligation="informative">
             <title id="_">Foreword</title>
             <p id="_">This is a preamble</p>
           </foreword></preface><sections>
           <clause id="_" obligation="normative">
             <title id="_">Section 1</title>
           </clause></sections>
           </metanorma>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end

  it "uses default fonts" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, *OPTIONS)

    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html)
      .to match(%r[ div[^{]+\{[^}]+font-family: "Overpass", sans-serif;]m)
    expect(html)
      .to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Overpass", sans-serif;]m)
  end

  it "uses Chinese fonts" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, *OPTIONS)

    html = File.read("test.html", encoding: "utf-8")
    expect(html)
      .to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html)
      .to match(%r[ div[^{]+\{[^}]+font-family: "Source Han Sans", serif;]m)
    expect(html)
      .to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Source Han Sans", sans-serif;]m)
  end

  it "uses specified fonts" do
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
      :body-font: Zapf Chancery
      :header-font: Comic Sans
      :monospace-font: Andale Mono
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, *OPTIONS)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html)
      .to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes inline_quoted formatting" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      [keyword]#keyword#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT

    output = <<~"OUTPUT"
      #{BLANK_HDR}
               <sections>
                <p id="_">
               <keyword>keyword</keyword>
               <strike>strike</strike>
               <smallcap>smallcap</smallcap></p>
               </sections>
               </metanorma>
    OUTPUT

    expect(Canon.format_xml(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to Canon.format_xml(output)
  end
end
