require "spec_helper"

RSpec.describe Metanorma::Generic do
  context "when xref_error.adoc compilation" do
    around do |example|
      FileUtils.rm_f "spec/assets/xref_error.err.html"
      example.run
      Dir["spec/assets/xref_error*"].each do |file|
        next if file.match?(/adoc$/)

        FileUtils.rm_f(file)
      end
    end

    it "generates error file" do
      expect do
        Metanorma::Compile
          .new
          .compile("spec/assets/xref_error.adoc", type: "generic", "agree-to-terms": true)
      end.to(change { File.exist?("spec/assets/xref_error.err.html") }
              .from(false).to(true))
    end
  end

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
