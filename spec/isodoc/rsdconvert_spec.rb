require "spec_helper"

RSpec.describe IsoDoc::Rsd do
  it "processes default metadata" do
        csdc = IsoDoc::Rsd::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <title language="en" format="plain">Main Title</title>
  <docidentifier>1000</docidentifier>
  <contributor>
    <role type="author"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>Ribose</name>
    </organization>
  </contributor>
  <language>en</language>
  <script>Latn</script>
  <status format="plain">working-draft</status>
  <copyright>
    <from>2001</from>
    <owner>
      <organization>
        <name>Ribose</name>
      </organization>
    </owner>
  </copyright>
  <editorialgroup>
    <technical-committee type="A">TC</technical-committee>
  </editorialgroup>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</rsd-standard>
    INPUT
        expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
           {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"1000(wd)", :doctitle=>"Main Title", :doctype=>"Standard", :docyear=>"2001", :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"January 2000", :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Working Draft", :tc=>"TC", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT
  end

  it "abbreviates committee-draft" do
            csdc = IsoDoc::Rsd::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <status format="plain">committee-draft</status>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</rsd-standard>
    INPUT
            expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
           {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"(cd)", :doctitle=>nil, :doctype=>"Standard", :docyear=>nil, :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"January 2000", :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Committee Draft", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT
  end

  it "abbreviates draft-standard" do
                csdc = IsoDoc::Rsd::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <status format="plain">draft-standard</status>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</rsd-standard>
    INPUT
                expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
           {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>"(d)", :doctitle=>nil, :doctype=>"Standard", :docyear=>nil, :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"January 2000", :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Draft Standard", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT
  end

  it "ignores unrecognised status" do
                    csdc = IsoDoc::Rsd::HtmlConvert.new({})
    docxml, filename, dir = csdc.convert_init(<<~"INPUT", "test", true)
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<bibdata type="standard">
  <status format="plain">standard</status>
</bibdata><version>
  <edition>2</edition>
  <revision-date>2000-01-01</revision-date>
  <draft>3.4</draft>
</version>
<sections/>
</rsd-standard>
    INPUT
                    expect(htmlencode(Hash[csdc.info(docxml, nil).sort].to_s)).to be_equivalent_to <<~"OUTPUT"
           {:accesseddate=>"XXX", :confirmeddate=>"XXX", :createddate=>"XXX", :docnumber=>nil, :doctitle=>nil, :doctype=>"Standard", :docyear=>nil, :draft=>"3.4", :draftinfo=>" (draft 3.4, 2000-01-01)", :editorialgroup=>[], :implementeddate=>"XXX", :issueddate=>"XXX", :obsoleteddate=>"XXX", :obsoletes=>nil, :obsoletes_part=>nil, :publisheddate=>"XXX", :revdate=>"2000-01-01", :revdate_monthyear=>"January 2000", :sc=>"XXXX", :secretariat=>"XXXX", :status=>"Standard", :tc=>"XXXX", :updateddate=>"XXX", :wg=>"XXXX"}
    OUTPUT
  end

  it "processes pre" do
    expect(IsoDoc::Rsd::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")).to be_equivalent_to <<~"OUTPUT"
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<pre>ABC</pre>
</foreword></preface>
</rsd-standard>
    INPUT
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
  end

  it "processes keyword" do
    expect(IsoDoc::Rsd::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")).to be_equivalent_to <<~"OUTPUT"
<rsd-standard xmlns="https://open.ribose.com/standards/rsd">
<preface><foreword>
<keyword>ABC</keyword>
</foreword></preface>
</rsd-standard>
    INPUT
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
  end

  it "processes simple terms & definitions" do
    expect(IsoDoc::Rsd::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")).to be_equivalent_to <<~"OUTPUT"
               <rsd-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
        </terms>
        </sections>
        </rsd-standard>
    INPUT
        #{HTML_HDR}
             <p class="zzSTDTitle1"/>
             <div id="H"><h1>1.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <p class="TermNum" id="J">1.1</p>
         <p class="Terms" style="text-align:left;">Term2</p>
       </div>
           </div>
         </body>
    OUTPUT
  end

  it "processes terms & definitions with external source" do
    expect(IsoDoc::Rsd::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")).to be_equivalent_to <<~"OUTPUT"
               <rsd-standard xmlns="http://riboseinc.com/isoxml">
         <termdocsource type="inline" bibitemid="ISO712"/>
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
         <term id="J">
         <preferred>Term2</preferred>
       </term>
       </terms>
        </sections>
        <bibliography>
        <references id="_normative_references" obligation="informative"><title>Normative References</title>
<bibitem id="ISO712" type="standard">
  <title format="text/plain">Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</title>
  <docidentifier>ISO 712</docidentifier>
  <contributor>
    <role type="publisher"/>
    <organization>
      <name>International Organization for Standardization</name>
    </organization>
  </contributor>
</bibitem></references>
</bibliography>
        </rsd-standard>
    INPUT
        #{HTML_HDR}
             <p class="zzSTDTitle1"/>
             <div>
               <h1>1.&#160; Normative references</h1>
               <p>The following documents are referred to in the text in such a way that some or all of their content constitutes requirements of this document. For dated references, only the edition cited applies. For undated references, the latest edition of the referenced document (including any amendments) applies.</p>
                 <p id="ISO712" class="NormRef">ISO 712, <i> Cereals and cereal products?~@~I?~@~T?~@~IDetermination of moisture content?~@~I?~@~T?~@~IReference method</i></p>
                              </div>
             <div id="H"><h1>2.&#160; Terms and definitions</h1><p>For the purposes of this document, the terms and definitions
         given in ISO 712 and the following apply.</p>
       <p class="TermNum" id="J">2.1</p>
                <p class="Terms" style="text-align:left;">Term2</p>
              </div>
           </div>
         </body>
    OUTPUT
  end

  it "processes empty terms & definitions" do
    expect(IsoDoc::Rsd::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")).to be_equivalent_to <<~"OUTPUT"
               <rsd-standard xmlns="http://riboseinc.com/isoxml">
       <sections>
       <terms id="H" obligation="normative"><title>Terms, Definitions, Symbols and Abbreviated Terms</title>
       </terms>
        </sections>
        </rsd-standard>
    INPUT
        #{HTML_HDR}
             <p class="zzSTDTitle1"/>
             <div id="H"><h1>1.&#160; Terms and definitions</h1><p>No terms and definitions are listed in this document.</p>
       </div>
           </div>
         </body>
    OUTPUT
  end

  it "processes section names" do
    expect(IsoDoc::Rsd::HtmlConvert.new({}).convert("test", <<~"INPUT", true).gsub(%r{^.*<body}m, "<body").gsub(%r{</body>.*}m, "</body>")).to be_equivalent_to <<~"OUTPUT"
               <rsd-standard xmlns="http://riboseinc.com/isoxml">
      <preface>
      <foreword obligation="informative">
         <title>Foreword</title>
         <p id="A">This is a preamble</p>
       </foreword>
        <introduction id="B" obligation="informative"><title>Introduction</title><clause id="C" inline-header="false" obligation="informative">
         <title>Introduction Subsection</title>
       </clause>
       <patent-notice>
       <p>This is patent boilerplate</p>
       </patent-notice>
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
       <symbols-abbrevs id="K">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
       </clause>
       <symbols-abbrevs id="L">
         <dl>
         <dt>Symbol</dt>
         <dd>Definition</dd>
         </dl>
       </symbols-abbrevs>
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
              <appendix id="Q2" inline-header="false" obligation="normative">
         <title>An Appendix</title>
       </appendix>
       </annex><bibliography><references id="R" obligation="informative">
         <title>Normative References</title>
       </references><clause id="S" obligation="informative">
         <title>Bibliography</title>
         <references id="T" obligation="informative">
         <title>Bibliography Subsection</title>
       </references>
       </clause>
       </bibliography>
       </rsd-standard>
    INPUT
        #{HTML_HDR}
             <br/>
             <div>
               <h1 class="ForewordTitle">Foreword</h1>
               <p id="A">This is a preamble</p>
             </div>
             <br/>
             <div class="Section3" id="B">
               <h1 class="IntroTitle">0.&#160; Introduction</h1>
               <div id="C">
          <h2>0.1. Introduction Subsection</h2>
        </div>
               <p>This is patent boilerplate</p>
             </div>
             <p class="zzSTDTitle1"/>
             <div id="D">
               <h1>1.&#160; Scope</h1>
               <p id="E">Text</p>
             </div>
             <div>
               <h1>2.&#160; Normative references</h1>
               <p>There are no normative references in this document.</p>
             </div>
             <div id="H"><h1>3.&#160; Terms and definitions</h1><p>For the purposes of this document,
           the following terms and definitions apply.</p>
       <div id="I">
          <h2>3.1. Normal Terms</h2>
          <p class="TermNum" id="J">3.1.1</p>
          <p class="Terms" style="text-align:left;">Term2</p>

        </div><div id="K"><h2>3.2. Symbols and abbreviated terms</h2>
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
          <h2>5.1. Introduction</h2>
        </div>
               <div id="O">
          <h2>5.2. Clause 4.2</h2>
        </div>
             </div>
             <br/>
             <div id="P" class="Section3">
               <h1 class="Annex"><b>Appendix A</b> (normative) <b>Annex</b></h1>
               <div id="Q">
          <h2>A.1. Annex A.1</h2>
          <div id="Q1">
          <h3>A.1.1. Annex A.1a</h3>
          </div>
        </div>
               <div id="Q2">
          <h2>Appendix 1. An Appendix</h2>
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
  end

  it "injects JS into blank html" do
    system "rm -f test.html"
    expect(Asciidoctor.convert(<<~"INPUT", backend: :rsd, header_footer: true)).to be_equivalent_to <<~"OUTPUT"
      = Document title
      Author
      :docfile: test.adoc
      :novalid:
    INPUT
    #{BLANK_HDR}
<sections/>
</rsd-standard>
    OUTPUT
    html = File.read("test.html", encoding: "utf-8")
    expect(html).to match(%r{jquery\.min\.js})
    expect(html).to match(%r{Overpass})
  end


end
