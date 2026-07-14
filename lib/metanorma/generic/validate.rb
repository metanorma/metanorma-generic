module Metanorma
  module Generic
    class Validate < Standoc::Validate
      def schema_location
        @conv.baselocation(configuration.validate_rng_file) ||
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
        stages = recognised_stages
        stages.nil? || stages.empty? and return
        stage = xmldoc.at("//bibdata/status/stage")&.text
        stages.include? stage or
          @log.add("GENERIC_2", nil, params: [stage])
      end

      # The stage repertoire of a taste layered on this flavour
      # (:docstage-valid:, populated with the base stages the taste maps
      # its own stages to) supersedes the flavour's own repertoire.
      # The flavour's repertoire is not just the stages needing
      # abbreviations: published stages and the default stage are
      # recognised too.
      def recognised_stages
        @docstage_valid and return @docstage_valid
        keys = configuration.stage_abbreviations&.keys or return
        (keys.map(&:to_s) +
          Array(configuration.published_stages).map(&:to_s) +
          [configuration.default_stage]).compact.uniq
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
        @conv.configuration
      end
    end
  end
end
