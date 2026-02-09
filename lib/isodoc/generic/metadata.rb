require "isodoc"
require "nokogiri"
require_relative "utils"

class Nokogiri::XML::Node
  TYPENAMES = { 1 => "element", 2 => "attribute", 3 => "text",
                4 => "cdata", 8 => "comment" }.freeze
  def to_hash
    { kind: TYPENAMES[node_type], name: name }.tap do |h|
      h[:text] = text&.strip
      a = attribute_nodes.map(&:to_hash)
      if element? && !a.empty?
        h[:attr] = a.inject({}) do |m, v|
          m[v[:name]] = v[:text]
          m
        end
      end
      c = children.map(&:to_hash)
      if element? && !(c&.size == 1 && c[0][:kind] == "text")
        h.merge! kids: c.delete_if { |n| n[:kind] == "text" && n[:text].empty? }
      end
    end
  end
end

class Nokogiri::XML::Document
  def to_hash; root.to_hash; end
end

module IsoDoc
  module Generic
    class Metadata < IsoDoc::Metadata
      class << self
        attr_accessor :_file
      end

      def self.inherited(klass) # rubocop:disable Lint/MissingSuper
        klass._file = caller_locations(1..1).first.absolute_path
      end

      def images(isoxml, out)
        default_logo_path =
          File.expand_path(File.join(File.dirname(__FILE__), "html",
                                     "logo.jpg"))
        set(:logo, baselocation(configuration.logo_path) || default_logo_path)
        unless configuration.logo_paths.nil?
          set(:logo_paths,
              Array(configuration.logo_paths).map { |p| baselocation(p) })
        end
      end

      def author(isoxml, _out)
        super
        tc = isoxml.at(ns("//bibdata/contributor[role/description = 'committee']/organization/subdivision[@type = 'Committee']/name"))
        set(:tc, tc.text) if tc
      end

      def stage_abbr(status)
        configuration.stage_abbreviations or return super
        Hash(configuration.stage_abbreviations).dig(status)
      end

      def doctype(isoxml, _out)
        super
        b = isoxml&.at(ns("//bibdata/ext/doctype#{currlang}")) ||
          isoxml&.at(ns("//bibdata/ext/doctype#{NOLANG}")) || return
        a = b["abbreviation"] and set(:doctype_abbr, a)
      end

      def xmlhash2hash(hash)
        ret = {}
        hash.nil? || hash[:kind] != "element" and return ret
        hash[:attr]&.each { |k, v| ret["#{hash[:name]}_#{k}"] = v }
        ret[hash[:name]] = hash[:kids] ? xmlhash2hash_kids(hash) : hash[:text]
        ret
      end

      def xmlhash2hash_kids(hash)
        c = {}
        hash[:kids].each do |n|
          xmlhash2hash(n).each do |k1, v1|
            c[k1] = if c[k1].nil? then v1
                    elsif c[k1].is_a?(Array) then c[k1] << v1
                    else [c[k1], v1]
                    end
          end
        end
        c
      end

      def ext(isoxml, _out)
        b = isoxml&.at(ns("//bibdata/ext")) or return
        set(:metadata_extensions, xmlhash2hash(b.to_hash)["ext"])
      end

      include Utils
    end
  end
end
