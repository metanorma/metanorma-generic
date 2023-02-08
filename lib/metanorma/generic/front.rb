module Metanorma
  module Generic
    class Converter < Standoc::Converter
      def default_publisher
        configuration.organization_name_long
      end

      def org_abbrev
        if !configuration.organization_name_long.empty? &&
            !configuration.organization_name_short.empty? &&
            configuration.organization_name_long !=
                configuration.organization_name_short
          { configuration.organization_name_long =>
            configuration.organization_name_short }
        else
          super
        end
      end

      def relaton_relations
        Array(configuration.relations) || []
      end

      def metadata_committee(node, xml)
        return unless node.attr("committee")

        xml.editorialgroup do |a|
          a.committee node.attr("committee"),
                      **attr_code(type: node.attr("committee-type"))
          i = 2
          while node.attr("committee_#{i}")
            a.committee node.attr("committee_#{i}"),
                        **attr_code(type: node.attr("committee-type_#{i}"))
            i += 1
          end
        end
      end

      def metadata_status(node, xml)
        xml.status do |s|
          s.stage ( node.attr("status") || node.attr("docstage") ||
                   configuration.default_stage || "published")
          x = node.attr("substage") and s.substage x
          x = node.attr("iteration") and s.iteration x
        end
      end

      def metadata_id(node, xml)
        xml.docidentifier type:
                              configuration.organization_name_short do |i|
          i << "DUMMY"
        end
        xml.docnumber { |i| i << node.attr("docnumber") }
      end

      def metadata_ext(node, ext)
        super
        if configuration.metadata_extensions.is_a? Hash
          metadata_ext_hash(node, ext, configuration.metadata_extensions)
        else
          Array(configuration.metadata_extensions).each do |e|
            a = node.attr(e) and ext.send e, a
          end
        end
      end

      def metadata_doctype(node, xml)
        d = doctype(node)
        xml.doctype d, attr_code(abbreviation: configuration&.doctypes&.dig(d))
      end

      EXT_STRUCT = %w(_output _attribute _list).freeze

      def metadata_ext_hash(node, ext, hash)
        hash.each do |k, v|
          next if EXT_STRUCT.include?(k) || (!v.is_a?(Hash) && !node.attr(k))

          if v.is_a?(Hash) && v["_list"]
            csv_split(node.attr(k), ",").each do |val|
              metadata_ext_hash1(k, val, ext, v, node)
            end
          else
            metadata_ext_hash1(k, node.attr(k), ext, v, node)
          end
        end
      end

      def metadata_ext_hash1(key, value, ext, hash, node)
        return if hash.is_a?(Hash) && hash["_attribute"]

        is_hash = hash.is_a?(Hash) &&
          !hash.keys.reject { |n| EXT_STRUCT.include?(n) }.empty?
        return if !is_hash && (value.nil? || value.empty?)

        name = hash.is_a?(Hash) ? (hash["_output"] || key) : key
        ext.send name, **attr_code(metadata_ext_attrs(hash, node)) do |e|
          is_hash ? metadata_ext_hash(node, e, hash) : (e << value)
        end
      end

      def metadata_ext_attrs(hash, node)
        return {} unless hash.is_a?(Hash)

        ret = {}
        hash.each do |k, v|
          next unless v.is_a?(Hash) && v["_attribute"]

          ret[(v["_output"] || k).to_sym] = node.attr(k)
        end
        ret
      end
    end
  end
end
