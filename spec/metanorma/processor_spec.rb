require "spec_helper"
require "fileutils"

RSpec.describe Metanorma::Acme::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Acme::Processor)

  let(:processor) {
    registry.find_processor(:acme)
  }

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    output = <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:rxl, "rxl"], [:xml, "xml"]]
    OUTPUT

    expect(processor.output_formats.sort.to_s).to be_equivalent_to output
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Metanorma::Acme })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
    #{BLANK_HDR}
<sections/>
</acme-standard>
    OUTPUT

    expect(xmlpp(processor.input_to_isodoc(input, nil))).to be_equivalent_to xmlpp(output)
  end

  it "generates HTML from IsoDoc XML" do
    FileUtils.rm_f "test.xml"
    input = <<~"INPUT"
    <acme-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
          <term id="J">
            <preferred>Term2</preferred>
          </term>
        </terms>
      </sections>
    </acme-standard>
    INPUT

    output = <<~"OUTPUT"
    <main class="main-section">
      <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
      <p class="zzSTDTitle1"></p>
      <div id="H">
        <h1>1.&#xA0; Terms and definitions</h1>
        <h2 class="TermNum" id="J">1.1.&#xA0;<p class="Terms" style="text-align:left;">Term2</p></h2>
      </div>
    </main>
    OUTPUT

    processor.output(input, "test.html", :html)

    expect(
      xmlpp(File.read("test.html", encoding: "utf-8").
      gsub(%r{^.*<main}m, "<main").
      gsub(%r{</main>.*}m, "</main>")
           )).to be_equivalent_to xmlpp(output)

  end

end
