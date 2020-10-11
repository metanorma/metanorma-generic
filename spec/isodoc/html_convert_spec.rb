require "spec_helper"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "isodoc", "generic", "html"))

RSpec.describe IsoDoc::Generic do

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
  <doctype>standard</doctype>
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

    output = <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"Acme",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"1000",
:doctitle=>"Main Title",
:doctype=>"Standard",
:docyear=>"2001",
:draft=>"3.4",
:draftinfo=>" (draft 3.4, 2000-01-01)",
:edition=>"2",
:implementeddate=>"XXX",
:issueddate=>"XXX",
:logo=>"#{File.join(logoloc, "logo.jpg")}",
:metadata_extensions=>{"doctype"=>"standard", "editorialgroup"=>{"committee_type"=>"A", "committee"=>"TC"}, "comment-period_type"=>"E", "comment-period"=>{"from"=>["A", "B", "C"], "to"=>"D", "reply-to"=>"F"}, "security"=>"X"},
:obsoleteddate=>"XXX",
:publisheddate=>"XXX",
:publisher=>"Acme",
:receiveddate=>"XXX",
:revdate=>"2000-01-01",
:revdate_monthyear=>"January 2000",
:stage=>"Working Draft",
:stageabbr=>"WD",
:tc=>"TC",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>true,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(metadata(csdc.info(docxml, nil))).to be_equivalent_to output
  end

   context 'with configuration options' do
    subject(:convert) do
      xmlpp(Asciidoctor.convert(input, backend: :generic, header_footer: true))
    end

    context 'organization' do
      let(:published_stages) { "working-draft" }
      let(:logo_path) { 'lib/example.jpg' }
      let(:logo_paths) { ['lib/example1.jpg', 'lib/example2.jpg'] }
      let(:stage_abbreviations) { { "working-draft" => "wd" } }
      let(:metadata_extensions) { [ "security", "insecurity" ] }
      let(:webfont) { [ "Jack&amp;x", "Jill?x" ] }
      let(:i18nyaml) { "spec/assets/i18n.yaml" }

      it 'processes default metadata' do
        Metanorma::Generic.configure do |config|
          config.logo_path = logo_path
          config.logo_paths = logo_paths
          config.published_stages = published_stages
          config.stage_abbreviations = stage_abbreviations
          config.metadata_extensions = metadata_extensions
          config.webfont = webfont
          config.i18nyaml = i18nyaml
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
        end
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

    output = <<~"OUTPUT"
{:accesseddate=>"XXX",
:agency=>"Acme",
:circulateddate=>"XXX",
:confirmeddate=>"XXX",
:copieddate=>"XXX",
:createddate=>"XXX",
:docnumber=>"1000",
:doctitle=>"Main Title",
:doctype=>"Standard",
:docyear=>"2001",
:draft=>"3.4",
:draftinfo=>" (draft 3.4, 2000-01-01)",
:edition=>"2",
:implementeddate=>"XXX",
:issueddate=>"XXX",
:logo=>"#{File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "example.jpg"))}",
:logo_paths=>["#{File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "example1.jpg"))}", "#{File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "example2.jpg"))}"],
:metadata_extensions=>{"doctype"=>"standard", "editorialgroup"=>{"committee_type"=>"A", "committee"=>"TC"}, "security"=>"Client Confidential", "insecurity"=>"Client Unconfidential"},
:obsoleteddate=>"XXX",
:publisheddate=>"XXX",
:publisher=>"Acme",
:receiveddate=>"XXX",
:revdate=>"2000-01-01",
:revdate_monthyear=>"January 2000",
:stage=>"Working Draft",
:tc=>"TC",
:transmitteddate=>"XXX",
:unchangeddate=>"XXX",
:unpublished=>false,
:updateddate=>"XXX",
:vote_endeddate=>"XXX",
:vote_starteddate=>"XXX"}
    OUTPUT

        docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(metadata(csdc.info(docxml, nil))).to be_equivalent_to output

        FileUtils.rm_f "test.html"
        presxml = pcsdc.convert("test", input, true)
        csdc.convert("test", presxml, false) 
        html = File.read("test.html", encoding: "utf-8")
        expect(html).to include '<link href="Jack&amp;x" rel="stylesheet" />'
        expect(html).to include '<link href="Jill?x" rel="stylesheet" />'
        expect(html.gsub(%r{^.*<main}m, "<main").gsub(%r{</main>.*}m, "</main>")).to be_equivalent_to <<~OUTPUT
        <main class="main-section"><button onclick="topFunction()" id="myBtn" title="Go to top">Top</button>
      <p class="zzSTDTitle1">Main Title</p>
      <div>
        <h1></h1>
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

        Metanorma::Generic.configure do |config|
          config.logo_path = Metanorma::Generic::Configuration.new.logo_path
          config.logo_paths = Metanorma::Generic::Configuration.new.logo_paths
          config.published_stages = Metanorma::Generic::Configuration.new.published_stages
          config.stage_abbreviations = Metanorma::Generic::Configuration.new.stage_abbreviations
          config.metadata_extensions = Metanorma::Generic::Configuration.new.metadata_extensions
          config.webfont = Metanorma::Generic::Configuration.new.webfont
          config.i18nyaml = Metanorma::Generic::Configuration.new.i18nyaml
      end
    end
  end


  it "processes pre" do
    input = <<~"INPUT"
<generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
<preface><foreword>
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
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(
      IsoDoc::Generic::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

  it "processes keyword" do
    input = <<~"INPUT"
<generic-standard xmlns="#{Metanorma::Generic::DOCUMENT_NAMESPACE}">
<preface><foreword>
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
             <p class="zzSTDTitle1"/>
           </div>
         </body>
    OUTPUT

    expect(
      IsoDoc::Generic::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

  it "processes simple terms & definitions" do
    input = <<~"INPUT"
     <generic-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <name>1.1.</name>
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </generic-standard>
    INPUT

    output = <<~"OUTPUT"
        #{HTML_HDR}
             <p class="zzSTDTitle1"/>
             <div id="H"><h1>1.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
       <p class="TermNum" id="J">1.1.</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
           </div>
         </body>
    OUTPUT

    expect(
      IsoDoc::Generic::HtmlConvert.new({}).
      convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    ).to be_equivalent_to output
  end

  it "processes section names" do
    input = <<~"INPUT"
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

    output = <<~"OUTPUT"
    <generic-standard xmlns='http://riboseinc.com/isoxml' type="presentation">
  <preface>
    <foreword obligation='informative'>
      <title>Foreword</title>
      <p id='A'>This is a preamble</p>
    </foreword>
    <introduction id='B' obligation='informative'>
      <title>Introduction</title>
      <clause id='C' inline-header='false' obligation='informative'>
        <title depth='2'>Introduction Subsection</title>
      </clause>
    </introduction>
  </preface>
  <sections>
    <clause id='D' obligation='normative'>
      <title depth='1'>
        4.
        <tab/>
        Scope
      </title>
      <p id='E'>Text</p>
    </clause>
    <clause id='H' obligation='normative'>
      <title depth='1'>
        2.
        <tab/>
        Terms, Definitions, Symbols and Abbreviated Terms
      </title>
      <terms id='I' obligation='normative'>
        <title depth='2'>
          2.1.
          <tab/>
          Normal Terms
        </title>
        <term id='J'>
          <name>2.1.1.</name>
          <preferred>Term2</preferred>
        </term>
      </terms>
      <definitions id='K'>
        <title>2.2.</title>
        <dl>
          <dt>Symbol</dt>
          <dd>Definition</dd>
        </dl>
      </definitions>
    </clause>
    <definitions id='L'>
      <title>3.</title>
      <dl>
        <dt>Symbol</dt>
        <dd>Definition</dd>
      </dl>
    </definitions>
    <clause id='M' inline-header='false' obligation='normative'>
      <title depth='1'>
        5.
        <tab/>
        Clause 4
      </title>
      <clause id='N' inline-header='false' obligation='normative'>
        <title depth='2'>
          5.1.
          <tab/>
          Introduction
        </title>
      </clause>
      <clause id='O' inline-header='false' obligation='normative'>
        <title depth='2'>
          5.2.
          <tab/>
          Clause 4.2
        </title>
      </clause>
    </clause>
  </sections>
  <annex id='P' inline-header='false' obligation='normative'>
    <title>
      <strong>Annex A</strong>
      <br/>
      (normative)
      <br/>
      <strong>Annex</strong>
    </title>
    <clause id='Q' inline-header='false' obligation='normative'>
      <title depth='2'>
        A.1.
        <tab/>
        Annex A.1
      </title>
      <clause id='Q1' inline-header='false' obligation='normative'>
        <title depth='3'>
          A.1.1.
          <tab/>
          Annex A.1a
        </title>
      </clause>
    </clause>
  </annex>
  <bibliography>
    <references id='R' obligation='informative' normative='true'>
      <title depth='1'>
        1.
        <tab/>
        Normative References
      </title>
    </references>
    <clause id='S' obligation='informative'>
      <title depth='1'>Bibliography</title>
      <references id='T' obligation='informative' normative='false'>
        <title depth='2'>Bibliography Subsection</title>
      </references>
    </clause>
  </bibliography>
</generic-standard>
    OUTPUT

    expect(
      xmlpp(IsoDoc::Generic::PresentationXMLConvert.new({}).convert("test", input, true))).to be_equivalent_to xmlpp(output)
  end

end
