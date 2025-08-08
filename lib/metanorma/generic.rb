require "metanorma/generic/processor"
require "metanorma/generic/version"
require "forwardable"
require "yaml"

module Metanorma
  module Generic # rubocop:disable Style/MutableConstant
    ORGANIZATION_NAME_SHORT = "Acme"
    ORGANIZATION_NAME_LONG = "Acme Corp."
    DOCUMENT_NAMESPACE = "https://www.metanorma.org/ns/generic"
    YAML_CONFIG_FILE = "metanorma.yml"

    class DummyProcessor < ::Metanorma::Processor
      def initialize; end # rubocop:disable Lint/MissingSuper
    end

    class Configuration
      CONFIG_ATTRS = %i[
        organization_name_short
        organization_name_long
        bibliography_titles
        boilerplate
        committees
        committee_types
        document_namespace
        docid_template
        doctypes
        default_doctype
        fonts_manifest
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
        pdf_stylesheet
        formats
      ].freeze

      def filepath_attrs
        %i[i18nyaml boilerplate logo_path logo_paths header boilerplate
           htmlcoverpage htmlintropage htmlstylesheet scripts scripts_pdf
           standardstylesheet validate_rng_file wordcoverpage wordintropage
           wordstylesheet pdf_stylesheet]
      end

      attr_accessor(*CONFIG_ATTRS)

      class << self
        attr_accessor :_file
      end

      def self.inherited(klass) # rubocop:disable Lint/MissingSuper
        klass._file = caller_locations(1..1).first.absolute_path
      end

      def initialize(*args)
        super
        # Try to set config values from yaml file in current directory
        @yaml = File.join(File.dirname(self.class::_file || __FILE__), "..",
                          "..", YAML_CONFIG_FILE)
        set_default_values_from_yaml_file(@yaml)
      end

      # may be invoked multiple times, needs to not overwrite
      def postprocess_defaults
        default_org
        default_formats
        default_titles
      end

      def default_org
        self.organization_name_short ||= ORGANIZATION_NAME_SHORT
        self.organization_name_long ||= ORGANIZATION_NAME_LONG
        self.document_namespace ||= DOCUMENT_NAMESPACE
      end

      # convert array to hash; if already is hash (no override in customize),
      # don't reconvert
      def default_formats
        formats.is_a?(Hash) and return
        self.formats ||= %w(html doc)
        self.formats = self.formats.each_with_object({}) do |k, m|
          m[k.to_sym] = k
        end
        self.formats.merge! DummyProcessor.new.output_formats
      end

      def default_titles
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
        if File.file?(config_file)
          root_path, default_config_options =
            set_default_values_from_yaml_file_prep(config_file)
          CONFIG_ATTRS.each do |attr|
            set_default_value_from_yaml_file(attr, root_path,
                                             default_config_options)
          end
        end
        postprocess_defaults
      end

      def set_default_value_from_yaml_file(attr, root_path, default_options)
        value = default_options[attr.to_s]
        value && filepath_attrs.include?(attr) and
          value = absolute_path(value, root_path)
        instance_variable_set("@#{attr}", value)
      end

      def set_default_values_from_yaml_file_prep(config_file)
        root_path = File.dirname(config_file)
        default_config_options =
          YAML.safe_load(File.read(config_file, encoding: "UTF-8"))
        default_config_options["doctypes"].is_a? Array and
          default_config_options["doctypes"] =
            default_config_options["doctypes"].each_with_object({}) do |k, m|
              m[k] = nil
            end
        [root_path, default_config_options]
      end

      def blank?(val)
        val.nil? || (val.respond_to?(:empty?) && val.empty?)
      end

      def absolute_path(value, root_path)
        case value
        when Hash then absolute_path1(value, root_path)
        when Array then absolute_path1_array(value, root_path)
        when String
          if !value.empty? && !Pathname.new(value).absolute?
            Pathname.new(File.join(root_path, value)).cleanpath.to_s
          else value
          end
        else value
        end
      end

      def absolute_path1(hash, pref)
        hash.reject { |_k, v| blank?(v) }.transform_values do |v|
          absolute_path(v, pref)
        end
      end

      def absolute_path1_array(value, pref)
        value.reject { |a| blank?(a) }.each_with_object([]) do |v1, g|
          g << absolute_path(v1, pref)
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
