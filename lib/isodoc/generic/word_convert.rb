require_relative "base_convert"
require "isodoc"

module IsoDoc
  module Generic
    # A {Converter} implementation that generates Word output, and a document
    # schema encapsulation of the document for validation

    class WordConvert < IsoDoc::WordConvert
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
          bodyfont: (options[:script] == "Hans" ? '"SimSun",serif' : configuration.word_bodyfont || '"Arial",sans-serif'),
          headerfont: (options[:script] == "Hans" ? '"SimHei",sans-serif' :  configuration.word_headerfont ||  '"Arial",sans-serif'),
          monospacefont:  configuration.word_monospacefont ||  '"Courier New",monospace'
        }
      end

      def default_file_locations(options)
        {
          wordstylesheet: baselocation(configuration.wordstylesheet) ||
            html_doc_path("wordstyle.scss"),
          standardstylesheet: baselocation(configuration.standardstylesheet) ||
            html_doc_path("generic.scss"),
          header: baselocation(configuration.header) ||
            html_doc_path("header.html"),
          wordcoverpage: baselocation(configuration.wordcoverpage) ||
            html_doc_path("word_generic_titlepage.html"),
          wordintropage: baselocation(configuration.wordintropage) ||
            html_doc_path("word_generic_intro.html"),
          i18nyaml: baselocation(configuration.i18nyaml),
          ulstyle: "l3",
          olstyle: "l2",
        }
      end

      def configuration
        Metanorma::Generic.configuration
      end

      include BaseConvert
    end
  end
end
