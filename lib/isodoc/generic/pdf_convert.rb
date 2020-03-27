require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Generic
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::PdfConvert
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
          scripts_pdf: baselocation(configuration.scripts_pdf) ||
            html_doc_path("scripts.pdf.html")
        }
      end

      def googlefonts
        <<~HEAD.freeze
    <link href="https://fonts.googleapis.com/css?family=Open+Sans:300,300i,400,400i,600,600i|Space+Mono:400,700" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Overpass:300,300i,600,900" rel="stylesheet">
        HEAD
      end

      def html_toc(docxml)
        docxml
      end

      def configuration
        Metanorma::Generic.configuration
      end

      include BaseConvert
    end
  end
end

