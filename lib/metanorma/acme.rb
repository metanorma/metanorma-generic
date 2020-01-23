require "metanorma/acme/processor"
require "metanorma/acme/version"
require 'forwardable'

module Metanorma
  module Acme
    ORGANIZATION_NAME_SHORT = "Acme"
    ORGANIZATION_NAME_LONG = "Acme Corp."
    DOCUMENT_NAMESPACE = "https://open.ribose.com/standards/acme"

    class Configuration
      CONFIG_ATTRS = %i[
        organization_name_short
        organization_name_long
        document_namespace
        html_extract_attributes
        doc_extract_attributes
      ].freeze

      attr_accessor(*CONFIG_ATTRS)

      def initialize(*args)
        super
        self.organization_name_short ||= ORGANIZATION_NAME_SHORT
        self.organization_name_long ||= ORGANIZATION_NAME_LONG
        self.document_namespace ||= DOCUMENT_NAMESPACE
        self.html_extract_attributes ||= {}
        self.doc_extract_attributes ||= {}
      end

      def html_extract_attributes=(attributes)
        unless attributes.is_a?(Hash) &&
                attributes.keys.all? { |name| name.is_a?(String) }
          raise(ArgumentError,
                'html_extract_attributes requires a hash with string keys')
        end

        instance_variable_set(:@html_extract_attributes, attributes)
      end

      def doc_extract_attributes=(attributes)
        unless attributes.is_a?(Hash) &&
               attributes.keys.all? { |name| name.is_a?(String) }
          raise(ArgumentError,
            'doc_extract_attributes requires a hash with string keys')
        end

        instance_variable_set(:@doc_extract_attributes, attributes)
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
