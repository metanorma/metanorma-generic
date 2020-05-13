require "spec_helper"
require "fileutils"

RSpec.describe Asciidoctor::Generic do
  it "processes a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
    #{BLANK_HDR}
<sections/>
</generic-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, backend: :generic, header_footer: true))).to be_equivalent_to xmlpp(output)
  end

  it "converts a blank document" do
    input = <<~"INPUT"
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
    expect(xmlpp(Asciidoctor.convert(input, backend: :generic, header_footer: true))).to be_equivalent_to xmlpp(output)
    expect(File.exist?("test.html")).to be true
  end

  it "processes default metadata" do
    input = <<~"INPUT"
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
<generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
<bibdata type="standard">
  <title language="en" format="text/plain">Main Title</title>
  <docidentifier type="Acme">Acme 1000</docidentifier>
  <docnumber>1000</docnumber>
<contributor>
    <role type="author"/>
    <organization>
      <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
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
<sections/>
</generic-standard>
    OUTPUT

    expect(xmlpp(Asciidoctor.convert(input, backend: :generic, header_footer: true))).to be_equivalent_to xmlpp(output)
  end

    it "processes default section titles" do
    input = <<~"INPUT"
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
    <generic-standard xmlns='https://www.metanorma.org/ns/generic'>
  <bibdata type='standard'>
    <title language='en' format='text/plain'>Document title</title>
    <docidentifier type='Acme'>Acme </docidentifier>
    <contributor>
      <role type='author'/>
      <organization>
        <name>Acme Corp.</name>
      </organization>
    </contributor>
    <contributor>
      <role type='publisher'/>
      <organization>
        <name>Acme Corp.</name>
      </organization>
    </contributor>
    <language>en</language>
    <script>Latn</script>
    <status>
      <stage>published</stage>
    </status>
    <copyright>
      <from>2020</from>
      <owner>
        <organization>
          <name>Acme Corp.</name>
        </organization>
      </owner>
    </copyright>
    <ext>
      <doctype>standard</doctype>
    </ext>
  </bibdata>
  <preface>
    <introduction id='_' obligation='informative'>
      <title>Introduction</title>
    </introduction>
  </preface>
  <sections>
    <clause id='_' obligation='normative'>
      <title>Scope</title>
    </clause>
    <terms id='_' obligation='normative'>
      <title>Terms and definitions</title>
      <p id='_'>No terms and definitions are listed in this document.</p>
    </terms>
    <definitions id='_'>
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
      <title>Normative References</title>
      <p id='_'>There are no normative references in this document.</p>
    </references>
    <references id='_' obligation='informative' normative="false">
      <title>Bibliography</title>
    </references>
  </bibliography>
</generic-standard>
      OUTPUT
      expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :generic, header_footer: true)))).to be_equivalent_to xmlpp(strip_guid(output))
    end

  context 'with configuration options' do
    subject(:convert) do
      xmlpp(Asciidoctor.convert(input, backend: :generic, header_footer: true))
    end

    context 'organization' do
      let(:input) { File.read(fixture_path('asciidoctor/test_input.adoc')) }
      let(:output) do
        File.read(fixture_path('asciidoctor/test_output.xml')) %
          { organization_name_short: organization_name_short,
            organization_name_long: organization_name_long,
            metadata_extensions_out: "<security>Client Confidential</security><insecurity>Client Unconfidential</insecurity>",
            document_namespace: document_namespace}
      end
      let(:organization_name_short) { 'Test' }
      let(:organization_name_long) { 'Test Corp.' }
      let(:document_namespace) { 'https://example.com/' }
      let(:docid_template) { "{{ organization_name_long }} {{ docnumeric }} {{ stage }}" }
      let(:metadata_extensions) { [ "security", "insecurity" ] }
      let(:stage_abbreviations) { { "ready" => "", "steady" => "" } }
      let(:doctypes) { [ "lion", "elephant" ] }
      let(:default_doctype) { "elephant" }
      let(:default_stage) { "working-draft" }
      let(:termsdefs_titles) { ["ABC", "DEF"] }
      let(:symbols_titles) { ["GHI", "JKL"] }
      let(:normref_titles) { ["MNO", "PQR"] }
      let(:bibliography_titles) { ["STU", "VWX"] }

      it 'uses configuration options for organization and namespace' do
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
        end

        FileUtils.rm_f "test.err"
        expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :generic, header_footer: true)))).to(be_equivalent_to(xmlpp(output)))
        expect(File.read("test.err")).to include "working-draft is not a recognised status"
        expect(File.read("test.err")).to include "standard is not a legal document type: reverting to 'elephant'"

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
        end
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

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :generic, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end

  it "uses default fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, backend: :generic, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "Overpass", sans-serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "Overpass", sans-serif;]m)
  end

  context 'customize directive' do
    subject(:config) { Metanorma::Generic.configuration }
    let(:config_file) { Tempfile.new('my_custom_config_file.yml') }
    let(:organization_name_short) { 'Test' }
    let(:organization_name_long) { 'Test Corp.' }
    let(:document_namespace) { 'https://example.com/' }
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
        'organization_name_short' => organization_name_short,
        'organization_name_long' => organization_name_long,
        'document_namespace' => document_namespace
      }
    end

    before do
      FileUtils.rm_f "test.html"
      config_file.tap { |file| file.puts(yaml_content.to_yaml) }.close
      Metanorma::Generic.configure do |config|
        config.organization_name_short = ''
        config.organization_name_long = ''
        config.document_namespace = ''
      end
    end

    after do
      FileUtils.rm_f "test.html"
    end

    it 'recognizes `customize` option and uses supplied file as the config file' do
      expect { Asciidoctor.convert(input, backend: :generic, header_footer: true) }
        .to(change {
          [config.organization_name_short, config.organization_name_long, config.document_namespace]
          }.from(['','','']).to([organization_name_short, organization_name_long, document_namespace]))
    end
  end

  it "uses Chinese fonts" do
    input = <<~"INPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
      :script: Hans
    INPUT

    FileUtils.rm_f "test.html"
    Asciidoctor.convert(input, backend: :generic, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^}]+font-family: "Space Mono", monospace;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: "SimSun", serif;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: "SimHei", sans-serif;]m)
  end

  it "uses specified fonts" do
    input = <<~"INPUT"
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
    Asciidoctor.convert(input, backend: :generic, header_footer: true)

    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r[\bpre[^{]+\{[^{]+font-family: Andale Mono;]m)
    expect(html).to match(%r[ div[^{]+\{[^}]+font-family: Zapf Chancery;]m)
    expect(html).to match(%r[h1, h2, h3, h4, h5, h6 \{[^}]+font-family: Comic Sans;]m)
  end

  it "processes inline_quoted formatting" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
      _emphasis_
      *strong*
      `monospace`
      "double quote"
      'single quote'
      super^script^
      sub~script~
      stem:[a_90]
      stem:[<mml:math><mml:msub xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:m="http://schemas.openxmlformats.org/officeDocument/2006/math"> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">F</mml:mi> </mml:mrow> </mml:mrow> <mml:mrow> <mml:mrow> <mml:mi mathvariant="bold-italic">&#x391;</mml:mi> </mml:mrow> </mml:mrow> </mml:msub> </mml:math>]
      [keyword]#keyword#
      [strike]#strike#
      [smallcap]#smallcap#
    INPUT

    output = <<~"OUTPUT"
            #{BLANK_HDR}
       <sections>
        <p id="_"><em>emphasis</em>
       <strong>strong</strong>
       <tt>monospace</tt>
       “double quote”
       ‘single quote’
       super<sup>script</sup>
       sub<sub>script</sub>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub><mi>a</mi><mn>90</mn></msub></math></stem>
       <stem type="MathML"><math xmlns="http://www.w3.org/1998/Math/MathML"><msub> <mrow> <mrow> <mi mathvariant="bold-italic">F</mi> </mrow> </mrow> <mrow> <mrow> <mi mathvariant="bold-italic">Α</mi> </mrow> </mrow> </msub> </math></stem>
       <keyword>keyword</keyword>
       <strike>strike</strike>
       <smallcap>smallcap</smallcap></p>
       </sections>
       </generic-standard>
    OUTPUT

    expect(xmlpp(strip_guid(Asciidoctor.convert(input, backend: :generic, header_footer: true)))).to be_equivalent_to xmlpp(output)
  end

end
