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
        conv.meta.set(:bibdata, bibdata_hash(xmldoc))
        @isodoc = conv
        @isodoc
      end

      def bibdata_hash(xmldoc)
        b = xmldoc.at("//bibdata") || xmldoc.at("//xmlns:bibdata") or return nil
        stripped = Nokogiri::XML(b.to_xml)
        stripped.remove_namespaces!
        # Drop @boilerplate="true" docidentifiers before handing the
        # bibdata to Relaton::Cli.parse_xml: their content is an
        # unresolved Liquid template, and recent relaton-iho /
        # relaton-cc / etc. eagerly call pubid in their docidentifier
        # content= setter, which crashes on raw Liquid syntax. The
        # template variables for substitution come from other bibdata
        # fields (seriesabbr, docnumeric, …), not from the
        # docidentifier itself, so dropping it here does not affect
        # what we feed back into isodoc.meta. Substitution still runs
        # on the original xmldoc via standoc's
        # docidentifier_boilerplate_isodoc; afterwards
        # refresh_isodoc_bibdata re-calls bibdata_hash to seed
        # isodoc.meta with the resolved docidentifier.
        # See https://github.com/metanorma/metanorma/issues/558.
        stripped.xpath("//docidentifier[@boilerplate = 'true']").each(&:remove)
        bib = BibdataConfig.from_xml(
          "<metanorma>#{stripped.root.to_xml}</metanorma>",
        ).bibdata or return nil
        YAML.safe_load(bib.to_yaml, permitted_classes: [Date, Symbol],
                                    symbolize_names: true)
      end

      # Override standoc's hook: in addition to re-running
      # isodoc_bibdata_parse, refresh conv.meta[:bibdata] with the
      # bibdata_hash now that docidentifiers have been substituted, so
      # downstream consumers (boilerplate Liquid expansion, coverpage
      # interpolation, etc.) see the resolved values.
      def refresh_isodoc_bibdata(xmldoc, conv)
        super
        conv.meta.set(:bibdata, bibdata_hash(xmldoc))
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
