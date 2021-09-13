require "metanorma/generic/processor"
require "metanorma/generic/version"
require "forwardable"
require "yaml"

module Metanorma
  module Generic
    ORGANIZATION_NAME_SHORT = "Acme"
    ORGANIZATION_NAME_LONG = "Acme Corp."
    DOCUMENT_NAMESPACE = "https://www.metanorma.org/ns/generic"
    YAML_CONFIG_FILE = "metanorma.yml"

    class Configuration
      CONFIG_ATTRS = %i[
        organization_name_short
        organization_name_long
        bibliography_titles
        boilerplate
        committees
        document_namespace
        docid_template
        doctypes
        default_doctype
        i18nyaml
        logo_path
        logo_paths
        header
        htmlcoverpage
        htmlintropage
        htmlstylesheet
        html_bodyfont
        html_headerfont
        html_monospacefont
        html_normalfontsize
        html_monospacefontsize
        html_smallerfontsize
        html_footnotefontsize
        metadata_extensions
        metanorma_name
        normref_titles
        published_stages
        relations
        default_stage
        stage_abbreviations
        scripts
        scripts_pdf
        standardstylesheet
        symbols_titles
        termsdefs_titles
        validate_rng_file
        webfont
        wordcoverpage
        wordintropage
        wordstylesheet
        word_bodyfont
        word_headerfont
        word_monospacefont
        word_normalfontsize
        word_monospacefontsize
        word_smallerfontsize
        word_footnotefontsize
        xml_root_tag
      ].freeze

      def filepath_attrs
        %i[
          i18nyaml
          boilerplate
          logo_path
          logo_paths
          header
          htmlcoverpage
          htmlintropage
          htmlstylesheet
          scripts
          scripts_pdf
          standardstylesheet
          validate_rng_file
          wordcoverpage
          wordintropage
          wordstylesheet
        ]
      end

      attr_accessor(*CONFIG_ATTRS)

      class << self
        attr_accessor :_file
      end

      def self.inherited(klass)
        klass._file = caller_locations(1..1).first.absolute_path
      end

      def initialize(*args)
        super
        # Try to set config values from yaml file in current directory
        @yaml = File.join(File.dirname(self.class::_file || __FILE__), "..",
                          "..", YAML_CONFIG_FILE)
        set_default_values_from_yaml_file(@yaml) if File.file?(@yaml)
        self.organization_name_short ||= ORGANIZATION_NAME_SHORT
        self.organization_name_long ||= ORGANIZATION_NAME_LONG
        self.document_namespace ||= DOCUMENT_NAMESPACE
        self.termsdefs_titles ||=
          ["Terms and definitions", "Terms, definitions, symbols and abbreviated terms",
           "Terms, definitions, symbols and abbreviations", "Terms, definitions and symbols",
           "Terms, definitions and abbreviations", "Terms, definitions and abbreviated terms"]
        self.symbols_titles ||=
          ["Symbols and abbreviated terms", "Symbols", "Abbreviated terms",
           "Abbreviations"]
        self.normref_titles ||=
          ["Normative references"]
        self.bibliography_titles ||= ["Bibliography"]
      end

      def set_default_values_from_yaml_file(config_file)
        root_path = File.dirname(self.class::_file || __FILE__)
        default_config_options = YAML.load(File.read(config_file))
        if default_config_options["doctypes"].is_a? Array
          default_config_options["doctypes"] =
            default_config_options["doctypes"].each_with_object({}) do |k, m|
              m[k] = nil
            end
        end
        CONFIG_ATTRS.each do |attr_name|
          value = default_config_options[attr_name.to_s]
          if value && filepath_attrs.include?(attr_name)
            value = absolute_path(value, root_path)
          end

          instance_variable_set("@#{attr_name}", value)
        end
      end

      def blank?(val)
        val.nil? || val.respond_to?(:empty?) && val.empty?
      end

      def absolute_path(value, root_path)
        if value.is_a? Hash then absolute_path1(value, root_path)
        elsif value.is_a? Array
          value.reject { |a| blank?(a) }.each_with_object([]) do |v1, g|
            g << absolute_path(v1, root_path)
          end
        elsif value.is_a?(String) && !value.empty?
          File.join(root_path, "..", "..", value)
        else
          value
        end
      end

      def absolute_path1(hash, pref)
        hash.reject { |_k, v| blank?(v) }
          .each_with_object({}) do |(k, v), g|
          g[k] = absolute_path(v, pref)
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
