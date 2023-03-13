# frozen_string_literal: true

require "spec_helper"

RSpec.describe Metanorma::Generic do
  it "has a version number" do
    expect(Metanorma::Generic::VERSION).not_to be nil
  end

  describe "#configuration" do
    it "has `configuration` attribute accessable" do
      expect(Metanorma::Generic.configuration)
        .to(be_instance_of(Metanorma::Generic::Configuration))
    end

    context "YAML config support" do
      subject(:config) { Metanorma::Generic::Configuration.new }

      logoloc = File.join(
        File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib",
                                   "metanorma")), "..", ".."
      )

      let(:config_file_name) { Metanorma::Generic::YAML_CONFIG_FILE }
      let(:organization_name_short) { "Test" }
      let(:organization_name_long) { "Test Corp." }
      let(:document_namespace) { "https://example.com/" }
      let(:boilerplate) do
        { "en" => "lib/isodoc/bipm/i18n-en.yaml",
          "fr" => "lib/isodoc/bipm/i18n-fr.yaml" }
      end
      let(:logo_path) { "" }
      let(:logo_paths) do
        ["lib/isodoc/bipm/html/logo.png", "lib/isodoc/bipm/html/logo1.png"]
      end
      let(:boilerplate1) do
        { "en" => File.join(logoloc, "lib/isodoc/bipm/i18n-en.yaml"),
          "fr" => File.join(logoloc, "lib/isodoc/bipm/i18n-fr.yaml") }
      end
      let(:logo_paths1) do
        [File.join(logoloc, "lib/isodoc/bipm/html/logo.png"),
         File.join(logoloc, "lib/isodoc/bipm/html/logo1.png")]
      end
      let(:yaml_content) do
        {
          "organization_name_short" => organization_name_short,
          "organization_name_long" => organization_name_long,
          "document_namespace" => document_namespace,
          "boilerplate" => boilerplate,
          "logo_paths" => logo_paths,
          "logo_path" => logo_path,
        }
      end

      before do
        File.new(config_file_name, "w+").tap do |file|
          file.puts(yaml_content.to_yaml)
        end.close
      end

      after do
        FileUtils.rm_f(config_file_name)
      end

      it "checks for metnorma.yml file and if it finds one, use its values" do
        expect(config.organization_name_short).to eq(organization_name_short)
        expect(config.organization_name_long).to eq(organization_name_long)
        expect(config.document_namespace).to eq(document_namespace)
        expect(config.boilerplate).to eq(boilerplate1)
        expect(config.logo_paths).to eq(logo_paths1)
        expect(config.logo_path).to eq(logo_path)
      end
    end

    context "default attributes" do
      subject(:config) { Metanorma::Generic.configuration }
      let(:default_organization_name_short) { "Acme" }
      let(:default_organization_name_long) { "Acme Corp." }
      let(:default_document_namespace) do
        "https://www.metanorma.org/ns/generic"
      end

      it "sets default atrributes" do
        expect(config.organization_name_short)
          .to(eq(default_organization_name_short))
        expect(config.organization_name_long)
          .to(eq(default_organization_name_long))
        expect(config.document_namespace)
          .to(eq(default_document_namespace))
      end

      it "processes docidentifier override" do
        input = <<~INPUT
          = Document title
          Author
          :docfile: test.adoc
          :nodoc:
          :novalid:
          :no-isobib:
          :docidentifier: OVERRIDE
          :docnumber: 1000
        INPUT
        output = <<~OUTPUT
          <generic-standard xmlns="https://www.metanorma.org/ns/generic" type="semantic">
            <bibdata type="standard">
              <title language="en" format="text/plain">Document title</title>
              <docidentifier type="Acme">OVERRIDE</docidentifier>
              <docnumber>1000</docnumber>
              <contributor>
                <role type="author"/>
                <organization>
                  <name>Acme Corp.</name>
                  <abbreviation>Acme</abbreviation>
                </organization>
              </contributor>
              <contributor>
                <role type="publisher"/>
                <organization>
                  <name>Acme Corp.</name>
                  <abbreviation>Acme</abbreviation>
                </organization>
              </contributor>
              <language>en</language>
              <script>Latn</script>
              <status>
                <stage>published</stage>
              </status>
              <copyright>
                <from>2023</from>
                <owner>
                  <organization>
                    <name>Acme Corp.</name>
                    <abbreviation>Acme</abbreviation>
                  </organization>
                </owner>
              </copyright>
              <ext>
                <doctype>standard</doctype>
              </ext>
            </bibdata>
            <sections/>
          </generic-standard>
        OUTPUT
        xml = Nokogiri::XML(Asciidoctor.convert(input, backend: :generic,
                                                header_footer: true))
        xml.at("//xmlns:metanorma-extension").remove
        xml.at("//xmlns:generic-standard/@version").remove
        expect(xmlpp(xml.to_xml))
          .to be_equivalent_to xmlpp(output)
      end
    end

    context "attribute setters" do
      subject(:config) { Metanorma::Generic.configuration }
      let(:organization_name_short) { "Test" }
      let(:organization_name_long) { "Test Corp." }
      let(:document_namespace) { "https://example.com/" }

      it "sets atrributes" do
        Metanorma::Generic.configure do |config|
          config.organization_name_short = organization_name_short
          config.organization_name_long = organization_name_long
          config.document_namespace = document_namespace
        end
        expect(config.organization_name_short).to eq(organization_name_short)
        expect(config.organization_name_long).to eq(organization_name_long)
        expect(config.document_namespace).to eq(document_namespace)
      end
    end
  end
end
