require "spec_helper"

RSpec.describe Metanorma::Generic do
  it "does not issue doctype warning if doctype not supplied" do
    Metanorma::Generic.configure do |config|
      config.default_doctype = "pizza"
      config.doctypes = { "default" => "A", "standard" => "B" }
    end
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
      :doctype: pizza
    INPUT
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(input, backend: :generic, header_footer: true)
    expect(File.read("test.err.html"))
      .to include("is not a legal document type: reverting to")

    Metanorma::Generic.configure do |config|
      config.default_doctype = "pizza"
      config.doctypes = { "default" => "A", "standard" => "B" }
    end
    input = <<~INPUT
      = Document title
      Author
      :docfile: test.adoc
    INPUT
    FileUtils.rm_f "test.err.html"
    Asciidoctor.convert(input, backend: :generic, header_footer: true)
    expect(File.read("test.err.html"))
      .not_to include("is not a legal document type: reverting to")
  end
end
