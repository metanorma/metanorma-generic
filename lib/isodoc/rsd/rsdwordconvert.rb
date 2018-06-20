require "isodoc"
require_relative "rsdwordrender"
require_relative "metadata"

module IsoDoc
  module Rsd
    # A {Converter} implementation that generates GB output, and a document
    # schema encapsulation of the document for validation

    class WordConvert < IsoDoc::WordConvert
      def html_doc_path(file)
        File.join(File.dirname(__FILE__), File.join("html", file))
      end

      def initialize(options)
        super
        @wordstylesheet = generate_css(html_doc_path("wordstyle.scss"), false, default_fonts(options))
        @standardstylesheet = generate_css(html_doc_path("rsd.scss"), false, default_fonts(options))
        @header = html_doc_path("header.html")
        @wordcoverpage = html_doc_path("word_rsd_titlepage.html")
        @wordintropage = html_doc_path("word_rsd_intro.html")
        @ulstyle = "l3"
        @olstyle = "l2"
        system "cp #{html_doc_path('logo.jpg')}  logo.jpg"
      end

      def default_fonts(options)
        b = options[:bodyfont] ||
          (options[:script] == "Hans" ? '"SimSun",serif' :
           '"Garamond",serif')
        h = options[:headerfont] ||
          (options[:script] == "Hans" ? '"SimHei",sans-serif' :
           '"Garamond",serif')
        m = options[:monospacefont] || '"Courier New",monospace'
        "$bodyfont: #{b};\n$headerfont: #{h};\n$monospacefont: #{m};\n"
      end

      def metadata_init(lang, script, labels)
        @meta = Metadata.new(lang, script, labels)
      end

      def make_body(xml, docxml)
        body_attr = { lang: "EN-US", link: "blue", vlink: "#954F72" }
        xml.body **body_attr do |body|
          make_body1(body, docxml)
          make_body2(body, docxml)
          make_body3(body, docxml)
        end
      end

      def make_body2(body, docxml)
        body.div **{ class: "WordSection2" } do |div2|
          info docxml, div2
          div2.p { |p| p << "&nbsp;" } # placeholder
        end
        body.br **{ clear: "all", style: "page-break-before:auto;mso-break-type:section-break;" }
      end

      def title(isoxml, _out)
        main = isoxml&.at(ns("//title[@language='en']"))&.text
        set_metadata(:doctitle, main)
      end

      def generate_header(filename, dir)
        return unless @header
        template = Liquid::Template.parse(File.read(@header, encoding: "UTF-8"))
        meta = @meta.get
        meta[:filename] = filename
        params = meta.map { |k, v| [k.to_s, v] }.to_h
        File.open("header.html", "w") { |f| f.write(template.render(params)) }
        @files_to_delete << "header.html"
        "header.html"
      end

      def header_strip(h)
        h = h.to_s.gsub(%r{<br/>}, " ").sub(/<\/?h[12][^>]*>/, "")
        h1 = to_xhtml_fragment(h.dup)
        h1.traverse do |x|
          x.replace(" ") if x.name == "span" &&
            /mso-tab-count/.match?(x["style"])
          x.remove if x.name == "span" && x["class"] == "MsoCommentReference"
          x.remove if x.name == "a" && x["epub:type"] == "footnote"
          x.replace(x.children) if x.name == "a"
        end
        from_xhtml(h1)
      end
    end
  end
end
