module Metanorma
  module Generic
    class Cleanup < Standoc::Cleanup
      extend Forwardable

      def sections_cleanup(xml)
        super
        xml.xpath("//*[@inline-header]").each do |h|
          h.delete("inline-header")
        end
      end

      def boilerplate_isodoc(xmldoc)
        conv = super or return nil
        Metanorma::Generic::Configuration::CONFIG_ATTRS.each do |a|
          conv.meta.set(a, configuration.send(a))
        end
        @isodoc = conv
        @isodoc
      end

      def boilerplate_file(xmldoc)
        f = configuration.boilerplate
        f.nil? and return super
        f.is_a? String and return @conv.baselocation(f)
        f.is_a? Hash and f[@lang] and return @conv.baselocation(f[@lang])
        super
      end

      def published?(status, _xmldoc)
        stages = configuration&.published_stages || ["published"]
        (Array(stages).map(&:downcase).include? status.downcase)
      end

      def configuration
        @conv.configuration
      end
    end
  end
end
