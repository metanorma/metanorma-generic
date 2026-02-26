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
        # conv.meta.set(:bibdata, bibdata_hash(xmldoc))
        @isodoc = conv
        @isodoc
      end

      def bibdata_hash(xmldoc)
        b = xmldoc.at("//bibdata") || xmldoc.at("//xmlns:bibdata")
        BibdataConfig.from_xml("<metanorma>#{b.to_xml}</metanorma>")
          .bibdata.to_hash
      end

      def boilerplate_file(xmldoc)
        f = configuration.boilerplate
        f.nil? and return super
        f.is_a? String and return @converter.baselocation(f)
        f.is_a? Hash and f[@lang] and return @converter.baselocation(f[@lang])
        super
      end

      def published?(status, _xmldoc)
        stages = configuration&.published_stages || ["published"]
        (Array(stages).map(&:downcase).include? status.downcase)
      end

      def configuration
        @converter.configuration
      end
    end
  end
end
