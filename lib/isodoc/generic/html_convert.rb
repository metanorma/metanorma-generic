require_relative "base_convert"
require_relative "init"
require "isodoc"

module IsoDoc
  module Generic
    # A {Converter} implementation that generates HTML output, and a document
    # schema encapsulation of the document for validation
    #
    class HtmlConvert < IsoDoc::HtmlConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      class << self
        attr_accessor :_file
      end

      def self.inherited(k)
        k._file = caller_locations(1..1).first.absolute_path
      end

      def default_fonts(options)
        {
          bodyfont: (
            if options[:script] == "Hans"
              '"Source Han Sans",serif'
            else
              configuration.html_bodyfont || '"Overpass",sans-serif'
            end
          ),
          headerfont: (
            if options[:script] == "Hans"
              '"Source Han Sans",sans-serif'
            else
              configuration.html_headerfont || '"Overpass",sans-serif'
            end
          ),
          monospacefont: configuration.html_monospacefont || '"Space Mono",monospace',
          normalfontsize: configuration.html_normalfontsize,
          smallerfontsize: configuration.html_smallerfontsize,
          footnotefontsize: configuration.html_footnotefontsize,
          monospacefontsize: configuration.html_monospacefontsize,
        }.transform_values { |v| v&.empty? ? nil : v }
      end

      def default_file_locations(_options)
        {
          htmlstylesheet: baselocation(configuration.htmlstylesheet) ||
            html_doc_path("htmlstyle.scss"),
          htmlcoverpage: baselocation(configuration.htmlcoverpage) ||
            html_doc_path("html_generic_titlepage.html"),
          htmlintropage: baselocation(configuration.htmlintropage) ||
            html_doc_path("html_generic_intro.html"),
          scripts: baselocation(configuration.scripts),
          i18nyaml: (if configuration.i18nyaml.is_a?(String)
                       baselocation(configuration.i18nyaml)
                     end),
        }.transform_values { |v| v&.empty? ? nil : v }
      end

      def googlefonts
        return unless configuration.webfont

        Array(configuration.webfont).map do |x|
          %{<link href="#{x}" rel="stylesheet"/>}
        end.join("\n")
      end

      include BaseConvert
      include Init
    end
  end
end
