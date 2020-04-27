# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Metanorma::Generic do
  it 'has a version number' do
    expect(Metanorma::Generic::VERSION).not_to be nil
  end

  describe '#configuration' do
    it 'has `configuration` attribute accessable' do
      expect(Metanorma::Generic.configuration)
        .to(be_instance_of(Metanorma::Generic::Configuration))
    end

    context 'YAML config support' do
      subject(:config) { Metanorma::Generic::Configuration.new }
      let(:config_file_name) { Metanorma::Generic::YAML_CONFIG_FILE }
      let(:organization_name_short) { 'Test' }
      let(:organization_name_long) { 'Test Corp.' }
      let(:document_namespace) { 'https://example.com/' }
      let(:yaml_content) do
        {
          'organization_name_short' => organization_name_short,
          'organization_name_long' => organization_name_long,
          'document_namespace' => document_namespace
        }
      end

      before do
        File.new(config_file_name, 'w+').tap { |file| file.puts(yaml_content.to_yaml) }.close
      end

      after do
        FileUtils.rm_f(config_file_name)
      end

      it 'checks for metnorma.yml file and if it finds one, use its values' do
        expect(config.organization_name_short).to eq(organization_name_short)
        expect(config.organization_name_long).to eq(organization_name_long)
        expect(config.document_namespace).to eq(document_namespace)
      end
    end

    context 'default attributes' do
      subject(:config) { Metanorma::Generic.configuration }
      let(:default_organization_name_short) { 'Acme' }
      let(:default_organization_name_long) { 'Acme Corp.' }
      let(:default_document_namespace) do
        'https://www.metanorma.org/ns/generic'
      end

      it 'sets default atrributes' do
        expect(config.organization_name_short)
          .to(eq(default_organization_name_short))
        expect(config.organization_name_long)
          .to(eq(default_organization_name_long))
        expect(config.document_namespace)
          .to(eq(default_document_namespace))
      end
    end

    context 'attribute setters' do
      subject(:config) { Metanorma::Generic.configuration }
      let(:organization_name_short) { 'Test' }
      let(:organization_name_long) { 'Test Corp.' }
      let(:document_namespace) { 'https://example.com/' }

      it 'sets atrributes' do
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
