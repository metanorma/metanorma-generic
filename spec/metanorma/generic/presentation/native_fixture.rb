# frozen_string_literal: true

# Semantic-only fixture built through the real generic/Document SDK. No fmt-* input.
module NativeGenericFixture
  def inline
    Metanorma::Document::Components::Inline
  end

  def ordered(node, *names)
    node.element_order = names.map do |name|
      if name.is_a?(Array)
        Lutaml::Xml::Element.new("Text", "text",
                                 text_content: name.first)
      else
        Lutaml::Xml::Element.new("Element", name)
      end
    end
    node
  end

  def native_generic_fixture
    sections = Metanorma::Standoc::Document::Sections
    paragraph_class = Metanorma::Document::Components::Paragraphs::ParagraphBlock
    title = ordered(inline::TitleWithAnnotationElement.new(text: ["A ", " title"],
                                                           em: [inline::EmRawElement.new(text: ["rich"])]), ["A "], "em", [" title"])
    xref = inline::XrefElement.new(target: "method")
    authored = inline::XrefElement.new(target: "method",
                                       text: ["the procedure"])
    paragraph = ordered(paragraph_class.new(text: ["See ", " or ", "."],
                                            xref: [xref,
                                                   authored]), ["See "], "xref", [" or "], "xref", ["."])
    lead = sections::ClauseSection.new(id: "scope", title: title,
                                       paragraphs: [paragraph])
    ordered(lead, "title", "p")
    body = sections::ClauseSection.new(id: "method", title: inline::TitleWithAnnotationElement.new(text: ["Method"]),
                                       paragraphs: [paragraph_class.new(text: ["Retained body."])])
    ordered(body, "title", "p")
    container = ordered(sections::Sections.new(clause: [lead, body]), "clause",
                        "clause")
    relaton = Metanorma::Document::Relaton
    bib = Metanorma::Standoc::Document::Metadata::StandardBibData.new(type: "standard",
                                                                      title: [relaton::TypedTitleString.new(
                                                                        content: ["Native generic presentation"], type: "main"
                                                                      )],
                                                                      docidentifier: [relaton::DocumentIdentifier.new(id: "GEN 99999:2026",
                                                                                                                      type: "GEN", primary: true)])
    Metanorma::Generic::Document::Root.new(type: "semantic", flavor: "generic",
                                           bibdata: bib, sections: [container])
  end

  def native_labeler(profile: Metanorma::Ladl::Profile.iso_iec)
    lambda do |root, flavor:, **|
      raise ArgumentError, flavor unless flavor == :generic

      engine = Metanorma::Ladl::Engine.new(profile: profile)
      engine.call(root,
                  adapter: Metanorma::Generic::Presentation::Transformer.ladl_adapter.new(mode: :presentation))
    end
  end
end
