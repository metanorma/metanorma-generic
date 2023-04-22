require_relative "base_convert"
require_relative "init"
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

      def self.inherited(k)
        k._file = caller_locations(1..1).first.absolute_path
      end

      def default_fonts(options)
        {
          bodyfont: (
            if options[:script] == "Hans"
              '"Source Han Sans",serif'
            else
              configuration.word_bodyfont || '"Arial",sans-serif'
            end
          ),
          headerfont: (
            if options[:script] == "Hans"
              '"Source Han Sans",sans-serif'
            else
              configuration.word_headerfont || '"Arial",sans-serif'
            end
          ),
          monospacefont: configuration.word_monospacefont || '"Courier New",monospace',
          normalfontsize: configuration.word_normalfontsize,
          smallerfontsize: configuration.word_smallerfontsize,
          footnotefontsize: configuration.word_footnotefontsize,
          monospacefontsize: configuration.word_monospacefontsize,
        }.transform_values { |v| v&.empty? ? nil : v }
      end

      def default_file_locations(_options)
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
          i18nyaml: (if configuration.i18nyaml.is_a?(String)
                       baselocation(configuration.i18nyaml)
                     end),
          ulstyle: "l3",
          olstyle: "l2",
        }.transform_values { |v| v&.empty? ? nil : v }
      end

      include BaseConvert
      include Init
    end
  end
end
