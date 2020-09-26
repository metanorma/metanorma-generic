require "isodoc"
require "nokogiri"
require_relative "init"
require_relative "utils"

class Nokogiri::XML::Node
  TYPENAMES = {1=>'element',2=>'attribute',3=>'text',4=>'cdata',8=>'comment'}
  def to_hash
    ret = {kind:TYPENAMES[node_type],name:name}.tap do |h|
      h.merge! text:text&.strip 
      a = attribute_nodes.map(&:to_hash)
      if element? && !a.empty?
        h.merge! attr: a.inject({}) { |m, v| m[v[:name]] = v[:text]; m }
      end
      c = children.map(&:to_hash)
      if element? && !(c&.size == 1 && c[0][:kind] == "text")
        h.merge! kids: c.delete_if { |n| n[:kind] == "text" && n[:text].empty? }
      end
    end
    ret
  end
end

class Nokogiri::XML::Document
  def to_hash; root.to_hash; end
end

module IsoDoc
  module Generic

    class Metadata < IsoDoc::Metadata
      def initialize(lang, script, labels)
        super
        here = File.dirname(__FILE__)
        default_logo_path = File.expand_path(File.join(here, "html", "logo.jpg"))
        set(:logo, baselocation(configuration.logo_path) || default_logo_path)
        unless configuration.logo_paths.nil?
          set(:logo_paths, Array(configuration.logo_paths).map { |p| baselocation(p) })
        end
      end

      class << self
        attr_accessor :_file
      end

      def self.inherited( k )
        k._file = caller_locations.first.absolute_path
      end

      def author(isoxml, _out)
        super
        tc = isoxml.at(ns("//bibdata/ext/editorialgroup/committee"))
        set(:tc, tc.text) if tc
      end

      def stage_abbr(status)
        return super unless configuration.stage_abbreviations
        Hash(configuration.stage_abbreviations).dig(status)
      end

      def unpublished(status)
        stages = configuration&.published_stages || ["published"]
        !(Array(stages).map { |m| m.downcase }.include? status.downcase)
      end

      def xmlhash2hash(h)
        ret = {}
        return ret if h.nil? || h[:kind] != "element"
        h[:attr].nil? or h[:attr].each { |k, v| ret["#{h[:name]}_#{k}"] = v }
        ret[h[:name]] = h[:kids] ? xmlhash2hash_kids(h) : h[:text]
        ret
      end

      def xmlhash2hash_kids(h)
        c = {}
        h[:kids].each do |n|
          xmlhash2hash(n).each do |k1, v1|
            c[k1] = c[k1].nil? ? v1 :
              c[k1].is_a?(Array) ? c[k1] << v1 :
              [c[k1], v1]
          end
        end
        c
      end

      def ext(isoxml, out)
        b = isoxml&.at(ns("//bibdata/ext")) or return
        set(:metadata_extensions, xmlhash2hash(b.to_hash)["ext"])
      end

      include Utils
    end
  end
end
