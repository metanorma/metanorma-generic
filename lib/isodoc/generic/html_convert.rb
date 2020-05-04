require_relative "base_convert"
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

      def self.inherited( k )
        k._file = caller_locations.first.absolute_path
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' 
                     : configuration.html_bodyfont || '"Overpass",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : 
                       configuration.html_headerfont || '"Overpass",sans-serif'),
          monospacefont: configuration.html_monospacefont || '"Space Mono",monospace'
        }
      end

      def default_file_locations(_options)
        {
          htmlstylesheet: baselocation(configuration.htmlstylesheet) ||
            html_doc_path("htmlstyle.scss"),
          htmlcoverpage: baselocation(configuration.htmlcoverpage) ||
            html_doc_path("html_generic_titlepage.html"),
          htmlintropage: baselocation(configuration.htmlintropage) ||
            html_doc_path("html_generic_intro.html"),
          scripts: baselocation(configuration.scripts) ||
            html_doc_path("scripts.html"),
          i18nyaml: baselocation(configuration.i18nyaml)
        }
      end

      def configuration
        Metanorma::Generic.configuration
      end

      def googlefonts
        return unless configuration.webfont
        Array(configuration.webfont).map { |x| %{<link href="#{x.gsub(/\&amp;/, '&')}" rel="stylesheet">} }.join("\n")
      end

      include BaseConvert
    end
  end
end

