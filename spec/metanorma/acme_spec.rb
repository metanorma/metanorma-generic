require "spec_helper"

RSpec.describe Metanorma::Acme do
  it "has a version number" do
    expect(Metanorma::Acme::VERSION).not_to be nil
  end

  describe '#configuration' do
    it 'has `configuration` attribute accessable' do
      expect(Metanorma::Acme.configuration).to be_instance_of(Metanorma::Acme::Configuration)
    end

    context 'default attributes' do
      subject(:config) { Metanorma::Acme.configuration }
      let(:default_organization_name_short) { "Acme" }
      let(:default_organization_name_long) { "Acme Corp." }
      let(:default_document_namespace) { "https://open.ribose.com/standards/acme" }
      let(:default_html_extract_attributes) { {} }

      it 'sets default atrributes' do
        expect(config.organization_name_short).to eq(default_organization_name_short)
        expect(config.organization_name_long).to eq(default_organization_name_long)
        expect(config.document_namespace).to eq(default_document_namespace)
        expect(config.html_extract_attributes).to eq(default_html_extract_attributes)
      end
    end

    context 'attribute setters' do
      subject(:config) { Metanorma::Acme.configuration }
      let(:organization_name_short) { "Test" }
      let(:organization_name_long) { "Test Corp." }
      let(:document_namespace) { "https://example.com/" }
      let(:html_extract_attributes) do
        {
          'one' => 'sting',
          'two' => 'number'
        }
      end

      it 'sets atrributes' do
        Metanorma::Acme.configure do |config|
          config.organization_name_short = organization_name_short
          config.organization_name_long = organization_name_long
          config.document_namespace = document_namespace
          config.html_extract_attributes = html_extract_attributes
        end
        expect(config.organization_name_short).to eq(organization_name_short)
        expect(config.organization_name_long).to eq(organization_name_long)
        expect(config.document_namespace).to eq(document_namespace)
        expect(config.html_extract_attributes).to eq(html_extract_attributes)
      end
    end
  end
end
