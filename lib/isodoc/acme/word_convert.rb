require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Acme
    # A {Converter} implementation that generates Word output, and a document
    # schema encapsulation of the document for validation

    class WordConvert < IsoDoc::WordConvert
      def initialize(options)
        @libdir = File.dirname(__FILE__)
        super
      end

      def default_fonts(options)
        {
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : '"Arial",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' : '"Arial",sans-serif'),
          monospacefont: '"Courier New",monospace'
        }
      end

      def default_file_locations(options)
        {
          wordstylesheet: Metanorma::Acme.configuration.wordstylesheet ||
            html_doc_path("wordstyle.scss"),
          standardstylesheet: Metanorma::Acme.configuration.standardstylesheet ||
            html_doc_path("acme.scss"),
          header: Metanorma::Acme.configuration.header ||
            html_doc_path("header.html"),
          wordcoverpage: Metanorma::Acme.configuration.wordcoverpage ||
            html_doc_path("word_acme_titlepage.html"),
          wordintropage: Metanorma::Acme.configuration.wordintropage ||
            html_doc_path("word_acme_intro.html"),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      include BaseConvert
    end
  end
end
