require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Acme
    # A {Converter} implementation that generates PDF HTML output, and a
    # document schema encapsulation of the document for validation
    class PdfConvert < IsoDoc::PdfConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Overpass",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Overpass",sans-serif'),
          monospacefont: '"Space Mono",monospace'
        }
      end

      def default_file_locations(_options)
        {
          htmlstylesheet: configuration.htmlstylesheet ||
            html_doc_path("htmlstyle.scss"),
          htmlcoverpage: configuration.htmlcoverpage ||
            html_doc_path("html_acme_titlepage.html"),
          htmlintropage: configuration.htmlintropage ||
            html_doc_path("html_acme_intro.html"),
          scripts_pdf: configuration.scripts_pdf ||
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
        Metanorma::Acme.configuration
      end

      include BaseConvert
    end
  end
end

