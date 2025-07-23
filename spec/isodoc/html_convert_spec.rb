require "spec_helper"

logoloc = File.expand_path(
  File.join(
    File.dirname(__FILE__), "..", "..", "lib", "isodoc", "generic", "html"
  ),
)

RSpec.describe IsoDoc::Generic do
  before do
    Metanorma::Generic.configure do |config|
      config.logo_path = Metanorma::Generic::Configuration.new.logo_path
      config.logo_paths = Metanorma::Generic::Configuration.new.logo_paths
      config.published_stages = Metanorma::Generic::Configuration.new
        .published_stages
      config.stage_abbreviations = Metanorma::Generic::Configuration.new
        .stage_abbreviations
      config.metadata_extensions = Metanorma::Generic::Configuration.new
        .metadata_extensions
      config.webfont = Metanorma::Generic::Configuration.new.webfont
      config.i18nyaml = Metanorma::Generic::Configuration.new.i18nyaml
      config.html_bodyfont = Metanorma::Generic::Configuration.new.html_bodyfont
      config.html_monospacefont = Metanorma::Generic::Configuration.new
        .html_monospacefont
      config.html_headerfont = Metanorma::Generic::Configuration.new
        .html_headerfont
      config.html_normalfontsize = Metanorma::Generic::Configuration.new
        .html_normalfontsize
      config.html_monospacefontsize = Metanorma::Generic::Configuration.new
        .html_monospacefontsize
      config.html_smallerfontsize = Metanorma::Generic::Configuration.new
        .html_smallerfontsize
      config.html_footnotefontsize = Metanorma::Generic::Configuration.new
        .html_footnotefontsize
      config.word_bodyfont = Metanorma::Generic::Configuration.new.word_bodyfont
      config.word_monospacefont = Metanorma::Generic::Configuration.new
        .word_monospacefont
      config.word_headerfont = Metanorma::Generic::Configuration.new
        .word_headerfont
      config.word_normalfontsize = Metanorma::Generic::Configuration.new
        .word_normalfontsize
      config.word_monospacefontsize = Metanorma::Generic::Configuration.new
        .word_monospacefontsize
      config.word_smallerfontsize = Metanorma::Generic::Configuration.new
        .word_smallerfontsize
      config.word_footnotefontsize = Metanorma::Generic::Configuration.new
        .word_footnotefontsize
      config.htmlstylesheet = Metanorma::Generic::Configuration.new
        .htmlstylesheet
      config.standardstylesheet = Metanorma::Generic::Configuration.new
        .standardstylesheet
      config.wordstylesheet = Metanorma::Generic::Configuration.new
        .wordstylesheet
      config.pdf_stylesheet = Metanorma::Generic::Configuration.new
        .pdf_stylesheet
    end
  end

  it "processes default metadata" do
    csdc = IsoDoc::Generic::HtmlConvert.new({})
    input = <<~"INPUT"
      <generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
      <bibdata type="standard">
        <title language="en" format="plain">Main Title</title>
        <docidentifier>1000</docidentifier>
        <edition>2</edition>
        <version>
        <revision-date>2000-01-01</revision-date>
        <draft>3.4</draft>
      </version>
        <contributor>
          <role type="author"/>
          <organization>
            <name>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</name>
          </organization>
        </contributor>
        <contributor>
          <role type="publisher"/>
          <organization>
            <name>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</name>
          </organization>
        </contributor>
        <language>en</language>
        <script>Latn</script>
        <status><stage>working-draft</stage></status>
        <copyright>
          <from>2001</from>
          <owner>
            <organization>
              <name>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</name>
            </organization>
          </owner>
        </copyright>
        <ext>
        <doctype abbreviation="S">standard</doctype>
        <editorialgroup>
          <committee type="A">TC</committee>
        </editorialgroup>
        <comment-period type="E">
          <from>A</from>
          <from>B</from>
          <from>C</from>
          <to>D</to>
          <reply-to>F</reply-to>
        </comment-period>
        <security>X</security>
        </ext>
      </bibdata>
      <sections/>
      </generic-standard>
    INPUT

    output =
      { accesseddate: "XXX",
        adapteddate: "XXX",
        agency: "Acme",
        announceddate: "XXX",
        circulateddate: "XXX",
        confirmeddate: "XXX",
        copieddate: "XXX",
        correcteddate: "XXX",
        createddate: "XXX",
        docnumber: "1000",
        doctitle: "Main Title",
        doctype: "Standard",
        doctype_abbr: "S",
        doctype_display: "Standard",
        docyear: "2001",
        draft: "3.4",
        draftinfo: " (draft 3.4, 2000-01-01)",
        edition: "2",
        implementeddate: "XXX",
        issueddate: "XXX",
        lang: "en",
        logo: File.join(logoloc, "logo.jpg"),
        metadata_extensions: { "doctype_abbreviation" => "S",
                               "doctype" => "standard",
                               "editorialgroup" => { "committee_type" => "A",
                                                     "committee" => "TC" },
                               "comment-period_type" => "E",
                               "comment-period" => {
                                 "from" => ["A", "B",
                                            "C"], "to" => "D", "reply-to" => "F"
                               },
                               "security" => "X" },
        obsoleteddate: "XXX",
        publisheddate: "XXX",
        publisher: "Acme",
        receiveddate: "XXX",
        revdate: "2000-01-01",
        revdate_monthyear: "January 2000",
        script: "Latn",
        stable_untildate: "XXX",
        stage: "Working Draft",
        stage_display: "Working Draft",
        stageabbr: "WD",
        tc: "TC",
        transmitteddate: "XXX",
        unchangeddate: "XXX",
        unpublished: true,
        updateddate: "XXX",
        vote_endeddate: "XXX",
        vote_starteddate: "XXX" }
    docxml, = csdc.convert_init(input, "test", true)
    expect(metadata(csdc.info(docxml, nil))).to be_equivalent_to output
  end

  context "with configuration options" do
    subject(:convert) do
      Xml::C14n.format(Asciidoctor.convert(input, backend: :generic,
                                                  header_footer: true))
    end

    context "organization" do
      let(:published_stages) { "working-draft" }
      let(:logo_path1) { "" }
      let(:logo_path) { "lib/example.jpg" }
      let(:logo_paths) { ["lib/example1.jpg", "lib/example2.jpg"] }
      let(:stage_abbreviations) { { "working-draft" => "wd" } }
      let(:metadata_extensions) { ["security", "insecurity"] }
      let(:webfont) { ["Jack&amp;x", "Jill?x"] }
      let(:i18nyaml) { "spec/assets/i18n.yaml" }
      let(:html_bodyfont) { "Zapf" }
      let(:html_monospacefont) { "Consolas" }
      let(:html_headerfont) { "Comic Sans" }
      let(:html_normalfontsize) { "30pt" }
      let(:html_monospacefontsize) { "29pt" }
      let(:html_smallerfontsize) { "28pt" }
      let(:html_footnotefontsize) { "27pt" }
      let(:word_bodyfont) { "Zapf" }
      let(:word_monospacefont) { "Consolas" }
      let(:word_headerfont) { "Comic Sans" }
      let(:word_normalfontsize) { "30pt" }
      let(:word_monospacefontsize) { "29pt" }
      let(:word_smallerfontsize) { "28pt" }
      let(:word_footnotefontsize) { "27pt" }
      let(:htmlstylesheet) { "spec/assets/htmlstylesheet.scss" }
      let(:standardstylesheet) { "spec/assets/standardstylesheet.scss" }
      let(:wordstylesheet) { "spec/assets/wordstylesheet.scss" }
      let(:pdf_stylesheet) { "spec/assets/pdf.xsl" }

      it "overrides default" do
        Metanorma::Generic.configure do |config|
          config.logo_path = logo_path1
        end
        csdc = IsoDoc::Generic::HtmlConvert.new({})
        docxml, = csdc.convert_init(<<~INPUT, "test", true)
                    <generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
          <bibdata type="standard">
          <langauge>en</language>
          </bibdata>
          </generic-standard>
        INPUT
        expect(metadata(csdc.info(docxml, nil)))
          .to be_equivalent_to({ accesseddate: "XXX",
                                 adapteddate: "XXX",
                                 announceddate: "XXX",
                                 circulateddate: "XXX",
                                 confirmeddate: "XXX",
                                 copieddate: "XXX",
                                 correcteddate: "XXX",
                                 createddate: "XXX",
                                 implementeddate: "XXX",
                                 issueddate: "XXX",
                                 lang: "en",
                                 obsoleteddate: "XXX",
                                 publisheddate: "XXX",
                                 receiveddate: "XXX",
                                 script: "Latn",
                                 stable_untildate: "XXX",
                                 transmitteddate: "XXX",
                                 unchangeddate: "XXX",
                                 unpublished: true,
                                 updateddate: "XXX",
                                 vote_endeddate: "XXX",
                                 vote_starteddate: "XXX" })
      end

      it "processes default metadata" do
        Metanorma::Generic.configure do |config|
          config.logo_path = logo_path
          config.logo_paths = logo_paths
          config.published_stages = published_stages
          config.stage_abbreviations = stage_abbreviations
          config.metadata_extensions = metadata_extensions
          config.webfont = webfont
          config.i18nyaml = i18nyaml
          config.html_bodyfont = html_bodyfont
          config.html_monospacefont = html_monospacefont
          config.html_headerfont = html_headerfont
          config.html_normalfontsize = html_normalfontsize
          config.html_monospacefontsize = html_monospacefontsize
          config.html_smallerfontsize = html_smallerfontsize
          config.html_footnotefontsize = html_footnotefontsize
          config.word_bodyfont = word_bodyfont
          config.word_monospacefont = word_monospacefont
          config.word_headerfont = word_headerfont
          config.word_normalfontsize = word_normalfontsize
          config.word_monospacefontsize = word_monospacefontsize
          config.word_smallerfontsize = word_smallerfontsize
          config.word_footnotefontsize = word_footnotefontsize
          config.htmlstylesheet = htmlstylesheet
          config.standardstylesheet = standardstylesheet
          config.wordstylesheet = wordstylesheet
          config.pdf_stylesheet = pdf_stylesheet
        end
        pcsdc = IsoDoc::Generic::PresentationXMLConvert.new({})
        Metanorma::Generic.configure do |config|
          config.logo_path = logo_path
          config.logo_paths = logo_paths
          config.published_stages = published_stages
          config.stage_abbreviations = stage_abbreviations
          config.metadata_extensions = metadata_extensions
          config.webfont = webfont
          config.i18nyaml = i18nyaml
          config.html_bodyfont = html_bodyfont
          config.html_monospacefont = html_monospacefont
          config.html_headerfont = html_headerfont
          config.html_normalfontsize = html_normalfontsize
          config.html_monospacefontsize = html_monospacefontsize
          config.html_smallerfontsize = html_smallerfontsize
          config.html_footnotefontsize = html_footnotefontsize
          config.word_bodyfont = word_bodyfont
          config.word_monospacefont = word_monospacefont
          config.word_headerfont = word_headerfont
          config.word_normalfontsize = word_normalfontsize
          config.word_monospacefontsize = word_monospacefontsize
          config.word_smallerfontsize = word_smallerfontsize
          config.word_footnotefontsize = word_footnotefontsize
          config.htmlstylesheet = htmlstylesheet
          config.standardstylesheet = standardstylesheet
          config.wordstylesheet = wordstylesheet
          config.pdf_stylesheet = pdf_stylesheet
        end

        csdc = IsoDoc::Generic::HtmlConvert.new({})
        wcsdc = IsoDoc::Generic::WordConvert.new({})
        input = <<~"INPUT"
          <generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
          <bibdata type="standard">
            <title language="en" format="plain">Main Title</title>
            <docidentifier>1000</docidentifier>
            <edition>2</edition>
            <version>
            <revision-date>2000-01-01</revision-date>
            <draft>3.4</draft>
          </version>
            <contributor>
              <role type="author"/>
              <organization>
                <name>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</name>
              </organization>
            </contributor>
            <contributor>
              <role type="publisher"/>
              <organization>
                <name>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</name>
              </organization>
            </contributor>
            <language>en</language>
            <script>Latn</script>
            <status><stage>working-draft</stage></status>
            <copyright>
              <from>2001</from>
              <owner>
                <organization>
                  <name>#{Metanorma::Generic::ORGANIZATION_NAME_SHORT}</name>
                </organization>
              </owner>
            </copyright>
            <ext>
            <doctype>standard</doctype>
            <editorialgroup>
              <committee type="A">TC</committee>
            </editorialgroup>
            <security>Client Confidential</security>
            <insecurity>Client Unconfidential</insecurity>
            </ext>
          </bibdata>
          <sections>
          <clause>
          <p><xref target="A"/></p>
          <figure id="A"><name>Illustration</name></figure>
          </clause>
          </sections>
          </generic-standard>
        INPUT

        output =
          { accesseddate: "XXX",
            adapteddate: "XXX",
            agency: "Acme",
            announceddate: "XXX",
            circulateddate: "XXX",
            confirmeddate: "XXX",
            copieddate: "XXX",
            correcteddate: "XXX",
            createddate: "XXX",
            docnumber: "1000",
            doctitle: "Main Title",
            doctype: "Standard",
            doctype_display: "Standard",
            docyear: "2001",
            draft: "3.4",
            draftinfo: " (draft 3.4, 2000-01-01)",
            edition: "2",
            implementeddate: "XXX",
            issueddate: "XXX",
            lang: "en",
            logo: "lib/example.jpg",
            logo_paths: ["lib/example1.jpg", "lib/example2.jpg"],
            metadata_extensions: { "doctype" => "standard",
                                   "editorialgroup" => { "committee_type" => "A",
                                                         "committee" => "TC" },
                                   "security" => "Client Confidential",
                                   "insecurity" => "Client Unconfidential" },
            obsoleteddate: "XXX",
            publisheddate: "XXX",
            publisher: "Acme",
            receiveddate: "XXX",
            revdate: "2000-01-01",
            revdate_monthyear: "January 2000",
            script: "Latn",
            stable_untildate: "XXX",
            stage: "Working Draft",
            stage_display: "Working Draft",
            tc: "TC",
            transmitteddate: "XXX",
            unchangeddate: "XXX",
            unpublished: false,
            updateddate: "XXX",
            vote_endeddate: "XXX",
            vote_starteddate: "XXX" }

        docxml, = wcsdc.convert_init(input, "test", true)
        expect(metadata(wcsdc.info(docxml, nil))).to be_equivalent_to output
        docxml, = csdc.convert_init(input, "test", true)
        expect(metadata(csdc.info(docxml, nil))).to be_equivalent_to output

        FileUtils.rm_f "test.html"
        FileUtils.rm_f "test.doc"
        presxml = pcsdc.convert("test", input, true)
        csdc.convert("test", presxml, false)
        wcsdc.convert("test", presxml, false)
        doc = File.read("test.doc", encoding: "utf-8")
        expect(doc).to match(/p \{[^}]*?font-family: Zapf/m)
        expect(doc).to match(/code \{[^}]*?font-family: Consolas/m)
        expect(doc).to match(/h1 \{[^}]*?font-family: Comic Sans/m)
        expect(doc).to match(/p \{[^}]*?font-size: 30pt/m)
        expect(doc).to match(/code \{[^}]*?font-size: 29pt/m)
        expect(doc).to match(/p\.note \{[^}]*?font-size: 28pt/m)
        expect(doc).to match(/aside \{[^}]*?font-size: 27pt/m)
        expect(doc).to match(/Word stylesheet/)
        html = File.read("test.html", encoding: "utf-8")
        expect(html).to include('<link href="Jack&#x26;x" rel="stylesheet" />')
        expect(html).to include('<link href="Jill?x" rel="stylesheet" />')
        expect(html).to match(/I am an HTML stylesheet/)
        expect(html).to match(/p \{[^}]*?font-family: Zapf/m)
        expect(html).to match(/code \{[^}]*?font-family: Consolas/m)
        expect(html).to match(/h1 \{[^}]*?font-family: Comic Sans/m)
        expect(html).to match(/p \{[^}]*?font-size: 30pt/m)
        expect(html).to match(/code \{[^}]*?font-size: 29pt/m)
        expect(html).to match(/p\.note \{[^}]*?font-size: 28pt/m)
        expect(html).to match(/aside \{[^}]*?font-size: 27pt/m)
        expect(Xml::C14n.format(strip_guid(html)
          .gsub(%r{^.*<main}m, "<main")
          .gsub(%r{</main>.*}m, "</main>")))
          .to be_equivalent_to Xml::C14n.format(<<~OUTPUT)
                <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
                <br/>
              <p class="zzSTDTitle1">Main Title</p>
              <div id="_">
                    <h1 id="_">
                <a class="anchor" href="#_"/>
                <a class="header" href="#_">1.</a>
                    </h1>
                <p>
                  <a href="#A">Illustration 1</a>
                </p>
                <div id="A" class="figure">
                  <p class="FigureTitle" style="text-align:center;">Illustration 1&#xA0;&#x2014; Illustration</p>
                </div>
              </div>
            </main>
          OUTPUT
      end

      it "configure XSLT stylesheet" do
        stylesheet_mock("spec/assets/xsl.pdf")
        convert_mock(Pathname.new(File.join(File.dirname(__FILE__), "..", "..",
                                            "spec", "assets",
                                            "xsl.pdf")).cleanpath.to_s)
        Asciidoctor.convert(File.read("spec/assets/test.pdf.adoc"), *OPTIONS)
        FileUtils.rm_rf("tmp.yml")
      end

      after do
        Metanorma::Generic.configure do |config|
          config.logo_path = Metanorma::Generic::Configuration.new.logo_path
          config.logo_paths = Metanorma::Generic::Configuration.new.logo_paths
          config.published_stages = Metanorma::Generic::Configuration.new
            .published_stages
          config.stage_abbreviations = Metanorma::Generic::Configuration.new
            .stage_abbreviations
          config.metadata_extensions = Metanorma::Generic::Configuration.new
            .metadata_extensions
          config.webfont = Metanorma::Generic::Configuration.new.webfont
          config.i18nyaml = Metanorma::Generic::Configuration.new.i18nyaml
          config.html_bodyfont = Metanorma::Generic::Configuration.new
            .html_bodyfont
          config.html_monospacefont = Metanorma::Generic::Configuration.new
            .html_monospacefont
          config.html_headerfont = Metanorma::Generic::Configuration.new
            .html_headerfont
          config.html_normalfontsize = Metanorma::Generic::Configuration.new
            .html_normalfontsize
          config.html_monospacefontsize = Metanorma::Generic::Configuration.new
            .html_monospacefontsize
          config.html_smallerfontsize = Metanorma::Generic::Configuration.new
            .html_smallerfontsize
          config.html_footnotefontsize = Metanorma::Generic::Configuration.new
            .html_footnotefontsize
          config.word_bodyfont = Metanorma::Generic::Configuration.new
            .word_bodyfont
          config.word_monospacefont = Metanorma::Generic::Configuration.new
            .word_monospacefont
          config.word_headerfont = Metanorma::Generic::Configuration.new
            .word_headerfont
          config.word_normalfontsize = Metanorma::Generic::Configuration.new
            .word_normalfontsize
          config.word_monospacefontsize = Metanorma::Generic::Configuration.new
            .word_monospacefontsize
          config.word_smallerfontsize = Metanorma::Generic::Configuration.new
            .word_smallerfontsize
          config.word_footnotefontsize = Metanorma::Generic::Configuration.new
            .word_footnotefontsize
          config.htmlstylesheet = Metanorma::Generic::Configuration.new
            .htmlstylesheet
          config.standardstylesheet = Metanorma::Generic::Configuration.new
            .standardstylesheet
          config.wordstylesheet = Metanorma::Generic::Configuration.new
            .wordstylesheet
          config.pdf_stylesheet = Metanorma::Generic::Configuration.new
            .pdf_stylesheet
        end
      end
    end
  end

  it "processes pre" do
    input = <<~"INPUT"
      <generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
      <preface><foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
      <pre>ABC</pre>
      </foreword></preface>
      </generic-standard>
    INPUT

    output = <<~"OUTPUT"
      #{HTML_HDR}
              <br/>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <pre>ABC</pre>
              </div>
            </div>
          </body>
    OUTPUT

    expect(
      IsoDoc::Generic::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"),
    ).to be_equivalent_to output
  end

  it "processes keyword" do
    input = <<~"INPUT"
      <generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
      <preface><foreword displayorder="1"><fmt-title id="_">Foreword</fmt-title>
      <keyword>ABC</keyword>
      </foreword></preface>
      </generic-standard>
    INPUT

    output = <<~"OUTPUT"
      #{HTML_HDR}
              <br/>
              <div>
                <h1 class="ForewordTitle">Foreword</h1>
                <span class="keyword">ABC</span>
              </div>
            </div>
          </body>
    OUTPUT

    expect(
      IsoDoc::Generic::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"),
    ).to be_equivalent_to output
  end

  it "processes simple terms & definitions" do
    input = <<~INPUT
      <generic-standard xmlns="http://riboseinc.com/isoxml">
        <sections>
        <terms id="H" obligation="normative" displayorder="1"><fmt-title id="_">1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</fmt-title>
          <term id="J">
          <fmt-name id="_">1.1.</fmt-name>
          <fmt-preferred><p>Term2</p></fmt-preferred>
        </term>
         </terms>
         </sections>
         </generic-standard>
    INPUT

    output = <<~"OUTPUT"
      #{HTML_HDR}
              <div id="H"><h1>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
        <p class="TermNum" id="J">1.1.</p>
          <p class="Terms" style="text-align:left;">Term2</p>
        </div>
            </div>
          </body>
    OUTPUT

    expect(
      IsoDoc::Generic::HtmlConvert.new({})
      .convert("test", input, true)
      .gsub(%r{^.*<body}m, "<body")
      .gsub(%r{</body>.*}m, "</body>"),
    ).to be_equivalent_to output
  end

  it "processes section names" do
    input = <<~INPUT
      <generic-standard xmlns="http://riboseinc.com/isoxml">
        <preface>
        <foreword obligation="informative">
           <title>Foreword</title>
           <p id="A">This is a preamble</p>
         </foreword>
          <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
           <title>Introduction Subsection</title>
         </clause>
         </introduction></preface><sections>
         <clause id="D" obligation="normative">
           <title>Scope</title>
           <p id="E">Text</p>
         </clause>

         <clause id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title><terms id="I" obligation="normative">
           <title>Normal Terms</title>
           <term id="J">
           <preferred>Term2</preferred>
         </term>
         </terms>
         <definitions id="K">
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         </clause>
         <definitions id="L">
           <dl>
           <dt>Symbol</dt>
           <dd>Definition</dd>
           </dl>
         </definitions>
         <clause id="M" inline-header="false" obligation="normative"><title>Clause 4</title><clause id="N" inline-header="false" obligation="normative">
           <title>Introduction</title>
         </clause>
         <clause id="O" inline-header="false" obligation="normative">
           <title>Clause 4.2</title>
         </clause></clause>

         </sections><annex id="P" inline-header="false" obligation="normative">
           <title>Annex</title>
           <clause id="Q" inline-header="false" obligation="normative">
           <title>Annex A.1</title>
           <clause id="Q1" inline-header="false" obligation="normative">
           <title>Annex A.1a</title>
           </clause>
         </clause>
         </annex><bibliography><references id="R" obligation="informative" normative="true">
           <title>Normative References</title>
         </references><clause id="S" obligation="informative">
           <title>Bibliography</title>
           <references id="T" obligation="informative" normative="false">
           <title>Bibliography Subsection</title>
         </references>
         </clause>
         </bibliography>
         </generic-standard>
    INPUT

    output = <<~OUTPUT
      <generic-standard xmlns="http://riboseinc.com/isoxml" type="presentation">
         <preface>
            <clause type="toc" id="_" displayorder="1">
               <fmt-title id="_" depth="1">Table of contents</fmt-title>
            </clause>
            <foreword obligation="informative" displayorder="2" id="_">
               <title id="_">Foreword</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Foreword</semx>
               </fmt-title>
               <p id="A">This is a preamble</p>
            </foreword>
            <introduction id="B" obligation="informative" displayorder="3">
               <title id="_">Introduction</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Introduction</semx>
               </fmt-title>
               <clause id="C" inline-header="false" obligation="informative">
                  <title id="_">Introduction Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Introduction Subsection</semx>
                  </fmt-title>
               </clause>
            </introduction>
         </preface>
         <sections>
            <clause id="D" obligation="normative" displayorder="7">
               <title id="_">Scope</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="D">4</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Scope</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="D">4</semx>
               </fmt-xref-label>
               <p id="E">Text</p>
            </clause>
            <clause id="H" obligation="normative" displayorder="5">
               <title id="_">Terms, Definitions, Symbols and Abbreviated Terms</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="H">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Terms, Definitions, Symbols and Abbreviated Terms</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="H">2</semx>
               </fmt-xref-label>
               <terms id="I" obligation="normative">
                  <title id="_">Normal Terms</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Normal Terms</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="I">1</semx>
                  </fmt-xref-label>
                  <term id="J">
                     <fmt-name id="_">
                        <span class="fmt-caption-label">
                           <semx element="autonum" source="H">2</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="I">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                           <semx element="autonum" source="J">1</semx>
                           <span class="fmt-autonum-delim">.</span>
                        </span>
                     </fmt-name>
                     <fmt-xref-label>
                        <span class="fmt-element-name">Clause</span>
                        <semx element="autonum" source="H">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="I">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="J">1</semx>
                     </fmt-xref-label>
                     <preferred id="_">Term2</preferred>
                  </term>
               </terms>
               <definitions id="K">
                  <title id="_">Symbols</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="H">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="K">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Symbols</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="H">2</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="K">2</semx>
                  </fmt-xref-label>
                  <dl>
                     <dt>Symbol</dt>
                     <dd>Definition</dd>
                  </dl>
               </definitions>
            </clause>
            <definitions id="L" displayorder="6">
               <title id="_">Symbols</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="L">3</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Symbols</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="L">3</semx>
               </fmt-xref-label>
               <dl>
                  <dt>Symbol</dt>
                  <dd>Definition</dd>
               </dl>
            </definitions>
            <clause id="M" inline-header="false" obligation="normative" displayorder="8">
               <title id="_">Clause 4</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Clause 4</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="M">5</semx>
               </fmt-xref-label>
               <clause id="N" inline-header="false" obligation="normative">
                  <title id="_">Introduction</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="N">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Introduction</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="N">1</semx>
                  </fmt-xref-label>
               </clause>
               <clause id="O" inline-header="false" obligation="normative">
                  <title id="_">Clause 4.2</title>
                  <fmt-title id="_" depth="2">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="M">5</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="O">2</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Clause 4.2</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Clause</span>
                     <semx element="autonum" source="M">5</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="O">2</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
            <references id="R" obligation="informative" normative="true" displayorder="4">
               <title id="_">Normative References</title>
               <fmt-title id="_" depth="1">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="R">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Normative References</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Clause</span>
                  <semx element="autonum" source="R">1</semx>
               </fmt-xref-label>
            </references>
         </sections>
         <annex id="P" inline-header="false" obligation="normative" autonum="A" displayorder="9">
            <title id="_">
               <strong>Annex</strong>
            </title>
            <fmt-title id="_">
               <strong>
                  <span class="fmt-caption-label">
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                  </span>
               </strong>
               <br/>
               <span class="fmt-obligation">(normative)</span>
               <span class="fmt-caption-delim">
                  <br/>
               </span>
               <semx element="title" source="_">
                  <strong>Annex</strong>
               </semx>
            </fmt-title>
            <fmt-xref-label>
               <span class="fmt-element-name">Annex</span>
               <semx element="autonum" source="P">A</semx>
            </fmt-xref-label>
            <clause id="Q" inline-header="false" obligation="normative" autonum="A.1">
               <title id="_">Annex A.1</title>
               <fmt-title id="_" depth="2">
                  <span class="fmt-caption-label">
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                  </span>
                  <span class="fmt-caption-delim">
                     <tab/>
                  </span>
                  <semx element="title" source="_">Annex A.1</semx>
               </fmt-title>
               <fmt-xref-label>
                  <span class="fmt-element-name">Annex</span>
                  <semx element="autonum" source="P">A</semx>
                  <span class="fmt-autonum-delim">.</span>
                  <semx element="autonum" source="Q">1</semx>
               </fmt-xref-label>
               <clause id="Q1" inline-header="false" obligation="normative" autonum="A.1.1">
                  <title id="_">Annex A.1a</title>
                  <fmt-title id="_" depth="3">
                     <span class="fmt-caption-label">
                        <semx element="autonum" source="P">A</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                        <semx element="autonum" source="Q1">1</semx>
                        <span class="fmt-autonum-delim">.</span>
                     </span>
                     <span class="fmt-caption-delim">
                        <tab/>
                     </span>
                     <semx element="title" source="_">Annex A.1a</semx>
                  </fmt-title>
                  <fmt-xref-label>
                     <span class="fmt-element-name">Annex</span>
                     <semx element="autonum" source="P">A</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q">1</semx>
                     <span class="fmt-autonum-delim">.</span>
                     <semx element="autonum" source="Q1">1</semx>
                  </fmt-xref-label>
               </clause>
            </clause>
         </annex>
         <bibliography>
            <clause id="S" obligation="informative" displayorder="10">
               <title id="_">Bibliography</title>
               <fmt-title id="_" depth="1">
                  <semx element="title" source="_">Bibliography</semx>
               </fmt-title>
               <references id="T" obligation="informative" normative="false">
                  <title id="_">Bibliography Subsection</title>
                  <fmt-title id="_" depth="2">
                     <semx element="title" source="_">Bibliography Subsection</semx>
                  </fmt-title>
               </references>
            </clause>
         </bibliography>
      </generic-standard>
    OUTPUT

    expect(
      Xml::C14n.format(strip_guid(IsoDoc::Generic::PresentationXMLConvert
      .new(presxml_options)
      .convert("test", input, true))),
    ).to be_equivalent_to Xml::C14n.format(output)
  end

  private

  def stylesheet_mock(dir)
    allow_any_instance_of(::IsoDoc::XslfoPdfConvert)
      .to receive(:pdf_stylesheet)
      .and_return(dir)
  end

  def convert_mock(dir)
    allow_any_instance_of(::Metanorma::Output::XslfoPdf)
      .to receive(:convert)
      .with(anything, anything, dir, anything)
  end
end
