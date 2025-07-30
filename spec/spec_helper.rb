require "simplecov"
SimpleCov.start do
  add_filter "/spec/"
end

require "bundler/setup"
require "metanorma-generic"
require "rspec/matchers"
require "equivalent-xml"
require "htmlentities"
require "metanorma"
require "canon"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Set defaults before each run
  config.before(:each) do
    Metanorma::Generic.configure do |cn|
      cn.organization_name_short = Metanorma::Generic::ORGANIZATION_NAME_SHORT
      cn.organization_name_long = Metanorma::Generic::ORGANIZATION_NAME_LONG
      #cn.document_namespace = Metanorma::Generic::DOCUMENT_NAMESPACE
    end
  end
end

def metadata(xml)
  xml.sort.to_h.delete_if do |_k, v|
    v.nil? || (v.respond_to?(:empty?) && v.empty?)
  end
end

def fixture_path(path)
  File.join(File.expand_path("./fixtures", __dir__), path)
end

def strip_guid(xml)
  xml.gsub(%r{ id="_[^"]+"}, ' id="_"')
    .gsub(%r{ semx-id="[^"]*"}, "")
    .gsub(%r{ target="_[^"]+"}, ' target="_"')
    .gsub(%r{ source="_[^"]+"}, ' source="_"')
    .gsub(%r{ href="#_[^"]+"}, ' href="#_"')
    .gsub(%r{<fetched>[^<]+</fetched>}, "<fetched/>")
    .gsub(%r{ schema-version="[^"]+"}, "")
end

def htmlencode(xml)
  HTMLEntities.new.encode(xml, :hexadecimal).gsub(/&#x3e;/, ">")
    .gsub(/&#xa;/, "\n")
    .gsub(/&#x22;/, '"').gsub(/&#x3c;/, "<").gsub(/&#x26;/, "&")
    .gsub(/&#x27;/, "'").gsub(/\\u(....)/) do |_s|
    "&#x#{$1.downcase};"
  end
end

def presxml_options
  { semanticxmlinsert: "false" }
end

ASCIIDOC_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:
  :novalid:

HDR

VALIDATING_BLANK_HDR = <<~HDR.freeze
  = Document title
  Author
  :docfile: test.adoc
  :nodoc:

HDR

BLANK_HDR = <<~"HDR".freeze
  <?xml version="1.0" encoding="UTF-8"?>
  <metanorma xmlns="https://www.metanorma.org/ns/standoc" type="semantic" version="#{Metanorma::Generic::VERSION}" flavor="generic">
  <bibdata type="standard">
   <title language="en" format="text/plain">Document title</title>
    <docidentifier primary="true" type="Acme">Acme </docidentifier>
    <contributor>
      <role type="author"/>
      <organization>
        <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
        <abbreviation>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</abbreviation>
      </organization>
    </contributor>
    <contributor>
      <role type="publisher"/>
      <organization>
        <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
        <abbreviation>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</abbreviation>
      </organization>
    </contributor>

    <language>en</language>
    <script>Latn</script>
    <status>
           <stage>published</stage>
   </status>
    <copyright>
      <from>#{Time.new.year}</from>
      <owner>
        <organization>
          <name>#{Metanorma::Generic::ORGANIZATION_NAME_LONG}</name>
        <abbreviation>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</abbreviation>
        </organization>
      </owner>
    </copyright>
    <ext>
    <doctype>standard</doctype>
    <flavor>generic</flavor>
    </ext>
  </bibdata>
            <metanorma-extension>
            <presentation-metadata>
              <name>TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>HTML TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>DOC TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
            <presentation-metadata>
              <name>PDF TOC Heading Levels</name>
              <value>2</value>
            </presentation-metadata>
          </metanorma-extension>
HDR

HTML_HDR = <<~HDR.freeze
  <body lang="EN-US" link="blue" vlink="#954F72" xml:lang="EN-US" class="container">
  <div class="title-section">
    <p>&#160;</p>
  </div>
  <br/>
  <div class="prefatory-section">
    <p>&#160;</p>
  </div>
  <br/>
  <div class="main-section">
HDR

OPTIONS = [backend: :generic, header_footer: true].freeze

def mock_pdf
  allow(Mn2pdf).to receive(:convert) do |url, output, _c, _d|
    FileUtils.cp(url.gsub(/"/, ""), output.gsub(/"/, ""))
  end
end
