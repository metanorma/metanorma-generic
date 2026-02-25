module Metanorma
  module Generic
    class Validate < Standoc::Validate
      def schema_location
        baselocation(configuration.validate_rng_file) ||
          File.join(File.dirname(__FILE__), "generic.rng")
      end

      def schema_file
        configuration.validate_rng_file || "generic.rng"
      end

      def content_validate(doc)
        super
        bibdata_validate(doc.root)
      end

      def bibdata_validate(doc)
        stage_validate(doc)
        committee_validate(doc)
      end

      def stage_validate(xmldoc)
        stages = configuration.stage_abbreviations&.keys || return
        stages.empty? and return
        stage = xmldoc.at("//bibdata/status/stage")&.text
        stages.include? stage or
          @log.add("GENERIC_2", nil, params: [stage])
      end

      def committee_validate(xmldoc)
        committees = Array(configuration&.committees) || return
        committees.empty? and return
        xmldoc.xpath("//bibdata/contributor[role/description = 'committee']/" \
            "organization/subdivision/name").each do |c|
          committees.include? c.text or
            @log.add("GENERIC_3", nil, params: [c.text])
        end
      end

      def configuration
        Metanorma::Generic.configuration
      end
    end
  end
end
