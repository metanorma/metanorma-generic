require "spec_helper"
require "fileutils"

OPTIONS = [backend: :generic, header_footer: true].freeze

RSpec.describe Metanorma::Generic do
  it "processes a blank document" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
          #{BLANK_HDR}
      <sections/>
      </generic-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
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
      </generic-standard>
    OUTPUT

    FileUtils.rm_f "test.html"
    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
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
      <generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}" type="semantic" version="#{Metanorma::Generic::VERSION}">
      <bibdata type="standard">
        <title language="en" format="text/plain">Main Title</title>
        <docidentifier type="Acme">Acme 1000</docidentifier>
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
        <editorialgroup>
          <committee type="A">TC</committee>
          <committee type="B">TC1</committee>
        </editorialgroup>
        </ext>
      </bibdata>
               <metanorma-extension>
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
      </generic-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, *OPTIONS)))
      .to be_equivalent_to xmlpp(output)
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
          <generic-standard xmlns='https://www.metanorma.org/ns/generic'  type="semantic" version="#{Metanorma::Generic::VERSION}">
        <preface>
          <introduction id='_' obligation='informative'>
            <title>Introduction</title>
          </introduction>
        </preface>
        <sections>
          <clause id='_' obligation='normative' type="scope">
            <title>Scope</title>
          </clause>
          <terms id='_' obligation='normative'>
            <title>Terms and definitions</title>
            <p id='_'>No terms and definitions are listed in this document.</p>
          </terms>
          <definitions id='_' obligation="normative" type="symbols">
            <title>Symbols</title>
          </definitions>
          <clause id='_' obligation='normative'>
            <title>Clause</title>
          </clause>
        </sections>
        <annex id='_' obligation='normative'>
          <title>Annex</title>
        </annex>
        <bibliography>
          <references id='_' obligation='informative' normative="true">
            <title>Normative references</title>
            <p id='_'>There are no normative references in this document.</p>
          </references>
          <references id='_' obligation='informative' normative="false">
            <title>Bibliography</title>
          </references>
        </bibliography>
      </generic-standard>
    OUTPUT
    xml = Nokogiri::XML(Asciidoctor.convert(input, *OPTIONS))
    xml.at("//xmlns:bibdata").remove
    xml.at("//xmlns:metanorma-extension").remove
    expect(xmlpp(strip_guid(xml.to_xml)))
      .to be_equivalent_to xmlpp(strip_guid(output))
  end

  context "with configuration options" do
    subject(:convert) do
      xmlpp(Asciidoctor.convert(input, *OPTIONS))
    end

    context "organization" do
      let(:input) { File.read(fixture_path("metanorma/test_input.adoc")) }
      let(:output) do
        File.read(fixture_path("metanorma/test_output.xml")) %
          { organization_name_short: organization_name_short,
            organization_name_long: organization_name_long,
            metadata_extensions_out: "<security>Client Confidential</security>" \
                                     "<insecurity>Client Unconfidential</insecurity>",
            document_namespace: document_namespace,
            version: Metanorma::Generic::VERSION }
      end

      let(:organization_name_short) { "Test" }
      let(:organization_name_long) { "Test Corp." }
      let(:document_namespace) { "https://example.com/" }
      let(:docid_template) do
        "{{ organization_name_long }} {{ docnumeric }} {{ stage }}"
      end
      let(:metadata_extensions) { ["security", "insecurity"] }
      let(:metadata_extensions1) do
        {
          "comment-period" => {
            "comment-period-type" => { "_output" => "type",
                                       "_attribute" => true },
            "comment-period-from" => { "_output" => "from", "_list" => true },
            "comment-period-to" => { "_output" => "to" },
            "reply-to" => nil, "more" => { "more1" => nil }
          }, "security" => nil
        }
      end
      let(:stage_abbreviations) { { "ready" => "", "steady" => "" } }
      let(:doctypes) { { "lion" => nil, "elephant" => "E" } }
      let(:default_doctype) { "elephant" }
      let(:default_stage) { "working-draft" }
      let(:termsdefs_titles) { ["ABC", "DEF"] }
      let(:symbols_titles) { ["GHI", "JKL"] }
      let(:normref_titles) { ["MNO", "PQR"] }
      let(:bibliography_titles) { ["STU", "VWX"] }
      let(:committees) { ["YZ1", "234"] }
      let(:relations) { ["supersedes", "superseded-by"] }
      let(:i18nyaml) { "spec/assets/i18n.yaml" }
      let(:i18nyaml1) { { "en" => "spec/assets/i18n.yaml" } }
      let(:boilerplate) { "spec/fixtures/metanorma/boilerplate.xml" }
      let(:boilerplate1) do
        { "en" => "spec/fixtures/metanorma/boilerplate.xml" }
      end

      it "uses configuration options for organization and namespace" do
        Metanorma::Generic.configure do |config|
          config.organization_name_short = organization_name_short
          config.organization_name_long = organization_name_long
          config.document_namespace = document_namespace
          config.docid_template = docid_template
          config.metadata_extensions = metadata_extensions
          config.stage_abbreviations = stage_abbreviations
          config.doctypes = doctypes
          config.default_doctype = default_doctype
          config.default_stage = default_stage
          config.termsdefs_titles = termsdefs_titles
          config.symbols_titles = symbols_titles
          config.normref_titles = normref_titles
          config.bibliography_titles = bibliography_titles
          config.committees = committees
          config.relations = relations
          config.i18nyaml = i18nyaml
          config.boilerplate = boilerplate
        end

        FileUtils.rm_f "test.err.html"
        expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
          .to(be_equivalent_to(xmlpp(output)))
        expect(File.read("test.err.html"))
          .to include "working-draft is not a recognised status"
        expect(File.read("test.err.html"))
          .to include "TC is not a recognised committee"
        expect(File.read("test.err.html"))
          .to include "standard is not a legal document type: reverting to 'elephant'"
      end

      it "internationalises with language; uses complex metadata extensions" do
        Metanorma::Generic.configure do |config|
          config.organization_name_short = organization_name_short
          config.organization_name_long = organization_name_long
          config.document_namespace = document_namespace
          config.docid_template = docid_template
          config.metadata_extensions = metadata_extensions1
          config.stage_abbreviations = stage_abbreviations
          config.doctypes = doctypes
          config.default_doctype = default_doctype
          config.default_stage = default_stage
          config.termsdefs_titles = termsdefs_titles
          config.symbols_titles = symbols_titles
          config.normref_titles = normref_titles
          config.bibliography_titles = bibliography_titles
          config.committees = committees
          config.relations = relations
          config.i18nyaml = i18nyaml1
          config.boilerplate = boilerplate1
        end
        output = File.read(fixture_path("metanorma/test_output.xml")) %
          { organization_name_short: organization_name_short,
            organization_name_long: organization_name_long,
            metadata_extensions_out: "<comment-period type='N1'><from>N2" \
                                     "</from><from>N3</from><to>N4</to></comment-period>" \
                                     "<security>Client Confidential</security>",
            document_namespace: document_namespace,
            version: Metanorma::Generic::VERSION }
        expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
          .to(be_equivalent_to(xmlpp(output)))
      end

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
             <title>Foreword</title>
             <p id="_">This is a preamble</p>
           </foreword></preface><sections>
           <clause id="_" obligation="normative">
             <title>Section 1</title>
           </clause></sections>
           </generic-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
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

  context "customize directive" do
    subject(:config) { Metanorma::Generic.configuration }
    let(:config_file) { Tempfile.new("my_custom_config_file.yml") }
    let(:organization_name_short) { "Test" }
    let(:organization_name_long) { "Test Corp." }
    let(:document_namespace) { "https://example.com/" }
    let(:input) do
      <<~"INPUT"
        = Document title
        Author
        :customize: #{config_file.path}
        :docfile: test.adoc
        :novalid:
      INPUT
    end
    let(:yaml_content) do
      {
        "organization_name_short" => organization_name_short,
        "organization_name_long" => organization_name_long,
        "document_namespace" => document_namespace,
        "doctypes" => ["standard", "guide"],
        "default_doctype" => "standard",
      }
    end

    before do
      FileUtils.rm_f "test.html"
      config_file.tap { |file| file.puts(yaml_content.to_yaml) }.close
      Metanorma::Generic.configure do |config|
        config.organization_name_short = ""
        config.organization_name_long = ""
        config.document_namespace = ""
      end
    end

    after do
      FileUtils.rm_f "test.html"
    end

    it "recognizes `customize` option and uses supplied file as the config file" do
      expect { Asciidoctor.convert(input, *OPTIONS) }
        .to(change do
              [config.organization_name_short, config.organization_name_long,
               config.document_namespace]
            end.from(["", "", ""])
              .to([organization_name_short, organization_name_long,
                   document_namespace]))
    end
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
               </generic-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, *OPTIONS))))
      .to be_equivalent_to xmlpp(output)
  end
end
