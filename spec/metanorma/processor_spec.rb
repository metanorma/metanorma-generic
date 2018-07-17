require "spec_helper"
require "metanorma"

RSpec.describe Metanorma::Sample::Processor do

  registry = Metanorma::Registry.instance
  registry.register(Metanorma::Sample::Processor)

  let(:processor) {
    registry.find_processor(:sample)
  }

  it "registers against metanorma" do
    expect(processor).not_to be nil
  end

  it "registers output formats against metanorma" do
    expect(processor.output_formats.sort.to_s).to be_equivalent_to <<~"OUTPUT"
    [[:doc, "doc"], [:html, "html"], [:pdf, "pdf"], [:xml, "xml"]]
    OUTPUT
  end

  it "registers version against metanorma" do
    expect(processor.version.to_s).to match(%r{^Asciidoctor::Sample })
  end

  it "generates IsoDoc XML from a blank document" do
    input = <<~"INPUT"
    #{ASCIIDOC_BLANK_HDR}
    INPUT

    output = <<~"OUTPUT"
    #{BLANK_HDR}
<sections/>
</sample-standard>
    OUTPUT

    expect(processor.input_to_isodoc(input)).to be_equivalent_to output
  end

  it "generates HTML from IsoDoc XML" do
    system "rm -f test.xml"
    input = <<~"INPUT"
    <sample-standard xmlns="http://riboseinc.com/isoxml">
      <sections>
        <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
          <term id="J">
            <preferred>Term2</preferred>
          </term>
        </terms>
      </sections>
    </sample-standard>
    INPUT

    output = <<~"OUTPUT"
    <main class="main-section">
      <button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
      <p class="zzSTDTitle1"></p>
      <div id="H">
        <h1>1.&#xA0; Terms and definitions</h1>
        <p>For the purposes of this document, the following terms and definitions apply.</p>
        <h2 class="TermNum" id="J">1.1&#xA0;<p class="Terms" style="text-align:left;">Term2</p></h2>
      </div>
    </main>
    OUTPUT

    processor.output(input, "test.html", :html)

    expect(
      File.read("test.html", encoding: "utf-8").
      gsub(%r{^.*<main}m, "<main").
      gsub(%r{</main>.*}m, "</main>")
    ).to be_equivalent_to output

  end

end
