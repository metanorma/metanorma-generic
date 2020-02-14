require "metanorma/acme/processor"
require "metanorma/acme/version"
require 'forwardable'

module Metanorma
  module Acme
    ORGANIZATION_NAME_SHORT = "Acme"
    ORGANIZATION_NAME_LONG = "Acme Corp."
    DOCUMENT_NAMESPACE = "https://open.ribose.com/standards/acme"
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

      def initialize(*args)
        super
        set_default_values_from_yaml_file
        self.organization_name_short ||= ORGANIZATION_NAME_SHORT
        self.organization_name_long ||= ORGANIZATION_NAME_LONG
        self.document_namespace ||= DOCUMENT_NAMESPACE
      end

      # Try to set config values from yaml file in current directory
      def set_default_values_from_yaml_file
        return unless File.file?(YAML_CONFIG_FILE)

        default_config_options = YAML.load(File.read(YAML_CONFIG_FILE))
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
