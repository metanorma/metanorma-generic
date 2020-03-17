require "metanorma/acme/processor"
require "metanorma/acme/version"
require 'forwardable'
require 'yaml'

module Metanorma
  module Acme
    ORGANIZATION_NAME_SHORT = "Acme"
    ORGANIZATION_NAME_LONG = "Acme Corp."
    DOCUMENT_NAMESPACE = "https://metanorma.org/ns/acme"
    YAML_CONFIG_FILE = 'metanorma.yml'

    class Configuration
      CONFIG_ATTRS = %i[
        organization_name_short
        organization_name_long
        document_namespace
        docid_template
        i18nyaml
        logo_path
        header
        htmlcoverpage
        htmlintropage
        htmlstylesheet
        published_stages
        stage_abbreviations
        scripts
        scripts_pdf
        standardstylesheet
        validate_rng_file
        wordcoverpage
        wordintropage
        wordstylesheet
        xml_root_tag
      ].freeze

      attr_accessor(*CONFIG_ATTRS)

      class << self
        attr_accessor :_file
      end

      def self.inherited( k )
        k._file = caller_locations.first.absolute_path
      end

      def initialize(*args)
        super
        # Try to set config values from yaml file in current directory
        @yaml = File.join(File.dirname(self.class::_file || __FILE__), "..", "..", YAML_CONFIG_FILE)
        set_default_values_from_yaml_file(@yaml) if File.file?(@yaml)
        self.organization_name_short ||= ORGANIZATION_NAME_SHORT
        self.organization_name_long ||= ORGANIZATION_NAME_LONG
        self.document_namespace ||= DOCUMENT_NAMESPACE
      end

      def set_default_values_from_yaml_file(config_file)
        default_config_options = YAML.load(File.read(config_file))
        CONFIG_ATTRS.each do |attr_name|
          instance_variable_set("@#{attr_name}", default_config_options[attr_name.to_s])
        end
      end
    end

    class << self
      extend Forwardable

      attr_accessor :configuration

      Configuration::CONFIG_ATTRS.each do |attr_name|
        def_delegator :@configuration, attr_name
      end

      def configure
        self.configuration ||= Configuration.new
        yield(configuration)
      end
    end

    configure {}
  end
end
