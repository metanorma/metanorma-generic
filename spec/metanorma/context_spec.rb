require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Generic do
  context "customize directive" do
    subject(:config) { Metanorma::Generic.configuration }
    let(:config_file) { Tempfile.new("my_custom_config_file.yml") }
    let(:outdir) { File.dirname(config_file) }
    let(:organization_name_short) { "Test" }
    let(:organization_name_long) { "Test Corp." }
    let(:document_namespace) { "https://example.com/" }
    let(:fonts_manifest) do
      { "TeXGyreChorus" => ["Regular"] }
    end
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
        "fonts_manifest" => fonts_manifest,
      }
    end

    before do
      FileUtils.rm_f "test.html"
      FileUtils.mkdir_p "#{outdir}/ass1ets"
      FileUtils.cp "spec/assets/i18n.yaml", "#{outdir}/ass1ets"
      yaml_content["i18nyaml"] = "#{outdir}/ass1ets/i18n.yaml"
      config_file.tap { |file| file.puts(yaml_content.to_yaml) }.close

      Metanorma::Generic.configure do |config|
        config.organization_name_short = ""
        config.organization_name_long = ""
        config.document_namespace = ""
        config.i18nyaml = ""
      end
    end

    after do
      FileUtils.rm_f "test.html"
    end

    it "recognizes `customize` option and uses supplied file as the config file" do
      expect { Asciidoctor.convert(input, *OPTIONS) }
        .to(change do
              [config.organization_name_short, config.organization_name_long,
               config.document_namespace, config.i18nyaml]
            end.from(["", "", "", ""])
              .to([organization_name_short, organization_name_long,
                   document_namespace, "#{outdir}/ass1ets/i18n.yaml"]))
    end

    it "uses config to populate fonts" do
      registry = Metanorma::Registry.instance
      registry.register(Metanorma::Generic::Processor)
      expect(registry.find_processor(:generic).fonts_manifest)
        .to be_equivalent_to(fonts_manifest)
    end
  end

  context "with configuration options" do
    subject(:convert) do
      Xml::C14n.format(Asciidoctor.convert(input, *OPTIONS))
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
            docidentifier: "Test Corp. 1000 Working Draft",
            version: Metanorma::Generic::VERSION }
      end

      let(:organization_name_short) { "Test" }
      let(:organization_name_long) { "Test Corp." }
      let(:document_namespace) { "https://example.com/" }
      let(:docid_template) do
        "{{ organization_name_long }} {{ docnumeric }} {{ stage }}"
      end
      let(:docid_template_bibdata) do
        "{{ bibdata.docstatus.stage.value }} {{ bibdata.ext.doctype.type }} {{ bibdata.docnumber }}"
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
      let(:metadata_extensions2) do
        {
          "comment-period" => {
            "comment-period-typex" => { "_output" => "type",
                                       "_attribute" => true },
            "comment-period-fromx" => { "_output" => "from", "_list" => true },
            "comment-period-tox" => { "_output" => "to" },
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

      before do
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
      end

      it "uses configuration options for organization and namespace" do
        FileUtils.rm_f "test.err.html"
        expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input,
                                                               *OPTIONS))))
          .to(be_equivalent_to(Xml::C14n.format(output)))
        expect(File.read("test.err.html"))
          .to include("working-draft is not a recognised status")
        expect(File.read("test.err.html"))
          .to include("TC is not a recognised committee")
        expect(File.read("test.err.html"))
          .to include("standard is not a legal document type: reverting to 'elephant'")
      end

      it "internationalises with language; uses complex metadata extensions" do
        Metanorma::Generic.configure do |config|
          config.organization_name_short = organization_name_short
          config.organization_name_long = organization_name_long
          config.document_namespace = document_namespace
          #config.docid_template = docid_template_bibdata
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
            #docidentifier: "working-draft elephant 1000",
            docidentifier: "Test Corp. 1000 Working Draft",
            version: Metanorma::Generic::VERSION }
        expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input,
                                                               *OPTIONS))))
          .to(be_equivalent_to(Xml::C14n.format(output)))

        Metanorma::Generic.configure do |config|
          config.metadata_extensions = metadata_extensions2
        end
                output = File.read(fixture_path("metanorma/test_output.xml")) %
          { organization_name_short: organization_name_short,
            organization_name_long: organization_name_long,
            metadata_extensions_out: "<security>Client Confidential</security>",
            document_namespace: document_namespace,
            #docidentifier: "working-draft elephant 1000",
            docidentifier: "Test Corp. 1000 Working Draft",
            version: Metanorma::Generic::VERSION }
        expect(Xml::C14n.format(strip_guid(Asciidoctor.convert(input,
                                                               *OPTIONS))))
          .to(be_equivalent_to(Xml::C14n.format(output)))
      end

      after do
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
  end
end
