require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Generic::Processor do
  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Generic::Processor)

  let(:processor) do
    registry.find_processor(:generic)
  end

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  context "configure processor" do
    before do
      FileUtils.rm_f(Metanorma::Generic::YAML_CONFIG_FILE)
    end

    after do
      FileUtils.rm_f(Metanorma::Generic::YAML_CONFIG_FILE)
    end

    it "registers output formats against metanorma" do
      output = <<~OUTPUT
        [[:doc, "doc"], [:html, "html"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
      OUTPUT

      Metanorma::Generic.configuration = nil
      Metanorma::Generic.configure {}
      expect(Metanorma::Generic::Processor.new.output_formats.sort.to_s)
        .to be_equivalent_to output
    end

    it "sets output formats by configuration" do
      output = <<~OUTPUT
        [[:html, "html"], [:pdf, "pdf"], [:presentation, "presentation.xml"], [:rxl, "rxl"], [:xml, "xml"]]
      OUTPUT

      yaml_content = { "formats" => %w(html pdf) }

      FileUtils.rm_f(Metanorma::Generic::YAML_CONFIG_FILE)
      File.new(Metanorma::Generic::YAML_CONFIG_FILE, "w+").tap do |file|
        file.puts(yaml_content.to_yaml)
      end.close

      Metanorma::Generic.configuration = nil
      Metanorma::Generic.configure {}
      expect(Metanorma::Generic::Processor.new.output_formats.sort.to_s)
        .to be_equivalent_to output.to_s

      Metanorma::Generic.configure do |config|
        config.formats = Metanorma::Generic::Configuration.new.formats
      end

      FileUtils.rm_f(Metanorma::Generic::YAML_CONFIG_FILE)
    end
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Generic })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~"INPUT"
      #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
          #{BLANK_HDR}
      <sections/>
      </metanorma>
    OUTPUT

    expect(strip_guid(Xml::C14n.format(processor
      .input_to_isodoc(input, nil))))
      .to be_equivalent_to strip_guid(Xml::C14n.format(output))
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    input = <<~INPUT
      <metanorma xmlns="http://riboseinc.com/isoxml">
        <sections>
          <terms id="H" obligation="normative" displayorder="1"><fmt-title>Terms, Definitions, Symbols and Abbreviated Terms</fmt-title>
            <term id="J">
              <fmt-preferred><p>Term2</p></fmt-preferred>
            </term>
          </terms>
        </sections>
      </metanorma>
    INPUT

    output = <<~OUTPUT
      <main class="main-section">
         <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
         <div id="H">
           <h1 id="_">
             <a class="anchor" href="#H"/>
             <a class="header" href="#H">Terms, Definitions, Symbols and Abbreviated Terms</a>
           </h1>
           <p class="Terms" style="text-align:left;" id="J"><strong/> Term2</p>
         </div>
       </main>
    OUTPUT

    processor.output(input, "test.xml", "test.html", :html)

    expect(
      Xml::C14n.format(strip_guid(File.read("test.html", encoding: "utf-8")
      .gsub(%r{^.*<main}m, "<main")
      .gsub(%r{</main>.*}m, "</main>"))),
    ).to be_equivalent_to Xml::C14n.format(output)
  end
end
