require "spec_helper"

logoloc = File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "isodoc", "generic", "html"))

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
  <security>Client Confidential</security>
  </ext>
</bibdata>
<sections/>
</generic-standard>
    INPUT

    output = <<~"OUTPUT"
    {:accesseddate=>"XXX", :agency=>"Acme", :authors=>[], :authors_affiliations=>{}, :circulateddate=>"XXX", :confirmeddate=>"XXX", :copieddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000", :docnumeric=>nil, :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>"2001", :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :edition=>"2", :implementeddate=>"XXX", :issueddate=>"XXX", :logo=>"#{File.join(logoloc, "logo.jpg")}", :obsoleteddate=>"XXX", :publisheddate=>"XXX", :publisher=>"Acme", :receiveddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"January 2000", :stage=>"Working Draft", :stageabbr=>"WD", :tc=>"TC", :transmitteddate=>"XXX", :unchangeddate=>"XXX", :unpublished=>true, :updateddate=>"XXX", :vote_endeddate=>"XXX", :vote_starteddate=>"XXX"}
    OUTPUT

    docxml, filename, dir = csdc.convert_init(input, "test", true)
    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to output
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

      it 'processes default metadata' do
        Metanorma::Generic.configure do |config|
          config.logo_path = logo_path
          config.logo_paths = logo_paths
          config.published_stages = published_stages
          config.stage_abbreviations = stage_abbreviations
          config.metadata_extensions = metadata_extensions
          config.webfont = webfont
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
<sections/>
</generic-standard>
    INPUT

    output = <<~"OUTPUT"
    {:accesseddate=>"XXX", :agency=>"Acme", :authors=>[], :authors_affiliations=>{}, :circulateddate=>"XXX", :confirmeddate=>"XXX", :copieddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000", :docnumeric=>nil, :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>"2001", :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :edition=>"2", :implementeddate=>"XXX", :insecurity=>"Client Unconfidential", :issueddate=>"XXX", :logo=>"#{File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "example.jpg"))}", :logo_paths=>["#{File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "example1.jpg"))}", "#{File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "lib", "example2.jpg"))}"], :obsoleteddate=>"XXX", :publisheddate=>"XXX", :publisher=>"Acme", :receiveddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"January 2000", :security=>"Client Confidential", :stage=>"Working Draft", :tc=>"TC", :transmitteddate=>"XXX", :unchangeddate=>"XXX", :unpublished=>false, :updateddate=>"XXX", :vote_endeddate=>"XXX", :vote_starteddate=>"XXX"}
    OUTPUT

        docxml, filename, dir = csdc.convert_init(input, "test", true)
        expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to output

        FileUtils.rm_f "test.html"
        IsoDoc::Generic::HtmlConvert.new({}).convert("test", input, false) 
        html = File.read("test.html", encoding: "utf-8")
        expect(html).to include '<link href="Jack&amp;x" rel="stylesheet" />'
        expect(html).to include '<link href="Jill?x" rel="stylesheet" />'

        Metanorma::Generic.configure do |config|
          config.logo_path = Metanorma::Generic::Configuration.new.logo_path
          config.logo_paths = Metanorma::Generic::Configuration.new.logo_paths
          config.published_stages = Metanorma::Generic::Configuration.new.published_stages
          config.stage_abbreviations = Metanorma::Generic::Configuration.new.stage_abbreviations
          config.metadata_extensions = Metanorma::Generic::Configuration.new.metadata_extensions
          config.webfont = Metanorma::Generic::Configuration.new.webfont
        end
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
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
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
        #{HTML_HDR}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">Introduction</h1>
               <div id="C">
          <h2>Introduction Subsection</h2>
        </div>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="D">
               <h1>1.&#160; Scope</h1>
               <p id="E">Text</p>
             </div>
             <div>
               <h1>2.&#160; Normative references</h1>
             </div>
             <div id="H"><h1>3.&#160; Terms, Definitions, Symbols and Abbreviated Terms</h1>
       <div id="I">
          <h2>3.1.&#160; Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1.</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>3.2.&#160; Symbols and abbreviated terms</h2>
          <dl><dt><p>Symbol</p></dt><dd>Definition</dd></dl>
        </div></div>
             <div id="L" class="Symbols">
               <h1>4.&#160; Symbols and abbreviated terms</h1>
               <dl>
                 <dt>
                   <p>Symbol</p>
                 </dt>
                 <dd>Definition</dd>
               </dl>
             </div>
             <div id="M">
               <h1>5.&#160; Clause 4</h1>
               <div id="N">
          <h2>5.1.&#160; Introduction</h2>
        </div>
               <div id="O">
          <h2>5.2.&#160; Clause 4.2</h2>
        </div>
             </div>
             <br/>
             <div id="P" class="Section3">
                <h1 class="Annex"><b>Annex A</b><br/>(normative)<br/><b>Annex</b></h1>
               <div id="Q">
          <h2>A.1.&#160; Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1.&#160; Annex A.1a</h3>
          </div>
        </div>
             </div>
             <br/>
             <div>
               <h1 class="Section3">Bibliography</h1>
               <div>
                 <h2 class="Section3">Bibliography Subsection</h2>
               </div>
             </div>
           </div>
         </body>
    OUTPUT

    expect(
      xmlpp(IsoDoc::Generic::HtmlConvert.new({}).convert("test", input, true).
      gsub(%r{^.*<body}m, "<body").
      gsub(%r{</body>.*}m, "</body>")
    )).to be_equivalent_to xmlpp(output)
  end

end
