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

      def metadata_committee_types(_node)
        Array(configuration.committee_types || "committee")
      end

      def metadata_status(node, xml)
        xml.status do |s|
          add_noko_elem(s, "stage", node.attr("status") ||
                        node.attr("docstage") ||
                   configuration.default_stage || "published",
                        abbreviation: node.attr("docstage-abbrev"))
          add_noko_elem(s, "substage", node.attr("substage"))
          add_noko_elem(s, "iteration", node.attr("iteration"))
        end
      end

      def metadata_id(node, xml)
        if id = node.attr("docidentifier") || configuration.docid_template ||
            "{{ agency }} {{ docnumeric }}"
          add_noko_elem(xml, "docidentifier",
                        id, primary: "true", boilerplate: true,
                            type: metadata_id_primary_type(node))
        else
          metadata_id_primary(node, xml)
        end
      end

      def metadata_id_primary_type(node)
        node.attr("publisher_abbr") || node.attr("publisher") ||
          configuration.organization_name_short
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
        empty_metadata_cleanup(ext.parent)
      end

      # Keep cleaning until no more elements are removed (recursive depth-first)
      # Process elements in reverse doc order to handle nested removals properly
      def empty_metadata_cleanup(ext)
        loop do
          removed_count = 0
          ext.xpath(".//*").reverse_each do |element|
            element.children.empty? && element.attributes.empty? or next
            element.remove
            removed_count += 1
          end
          removed_count.zero? and break # Stop when no elems removed this pass
        end
      end

      def metadata_doctype(node, xml)
        d = doctype(node)
        add_noko_elem(xml, "doctype", d,
                      abbreviation: node.attr("doctype-abbrev") ||
                      configuration&.doctypes&.dig(d))
      end

      EXT_STRUCT = %w(_output _attribute _list).freeze

      def metadata_ext_hash(node, ext, hash)
        hash.each do |k, v|
          EXT_STRUCT.include?(k) || (!v.is_a?(Hash) && !node.attr(k)) and next
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
        h = hash.is_a?(Hash)
        h && hash["_attribute"] and return
        is_hash = h && !hash.keys.reject { |n| EXT_STRUCT.include?(n) }.empty?
        !is_hash && (value.nil? || value.empty?) and return
        name = h ? (hash["_output"] || key) : key
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
