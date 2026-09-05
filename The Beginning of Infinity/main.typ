#import "@preview/cmarker:0.1.10"

#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n, str-to-lines

#let t = load-i18n("main.i18n.yml")

#set page(
  paper: "a5",
  margin: (x: 2.2cm, top: 3cm, bottom: 2.5cm),
)

#{
  import "cover.typ": cover-page
  cover-page(
    (
      (t("THE"), 0.8),
      (t("BEGINNING"), 1.0),
      (t("OF"), 0.8),
      (t("INFINITY"), 1.0),
      (t("EXPLANATIONS THAT TRANSFORM THE WORLD"), 0.3),
      (t("DAVID DEUTSCH"), 0.9),
      (t("AUTHOR OF"), 0.3),
      (t("THE FABRIC OF REALITY"), 0.6),
    ),
    fonts-for-current-lang.sans,
  )
}

#pagebreak()

#{
  import "page2.typ": title-page
  title-page(
    author: t("DAVID DEUTSCH"),
    title: t("The Beginning of Infinity"),
    subtitle: t("EXPLANATIONS THAT TRANSFORM THE WORLD"),
    publisher: "VIKING",
    lang: current-lang,
    fonts: fonts-for-current-lang.serif,
  )
}


// #pagebreak()

#pagebreak()
#{
  import "page4.typ": half-title-page
  half-title-page(
    title: t("The Beginning of Infinity"),
    logo-width: 2.2cm,
    lang: current-lang,
    fonts: fonts-for-current-lang.serif,
  )
}

#pagebreak()

#{
  import "page6.typ": title-page
  title-page(
    author: t("DAVID DEUTSCH"),
    title: t("The Beginning of Infinity"),
    subtitle: t("EXPLANATIONS THAT TRANSFORM THE WORLD"),
    publisher: "VIKING",
    lang: current-lang,
    fonts: fonts-for-current-lang.serif,
  )
}

#pagebreak()

#{
  // Adjust font size here
  set text(size: 10pt)

  // Adjust spacing between lines here (default is around 0.65em)
  set par(leading: 0.45em)

  align(center)[
    #str-to-lines(read("page7-1.md"))
  ]

  v(1.5em) // Spacing between the top block and the bottom disclaimer

  cmarker.render(read("page7-2.md"))
}

#pagebreak()

#import "@preview/outrageous:0.4.1"

// 1. Configure the outline entry style
#show outline.entry: outrageous.show-entry.with(
  ..outrageous.presets.typst,
  fill: (none,), // No dot leaders
  font-style: ("italic", auto), // Unnumbered front/back matter italic
  vspace: (0.7em,), // Row gap
)

// 2. Center and narrow the TOC block
#align(center)[
  #block(width: 75%)[
    #set text(features: ("onum",)) // Old-style figures
    #outline(
      title: align(center)[#text(style: "italic", size: 1.4em)[Contents]],
      indent: 1.5em,
    )
  ]
]

#pagebreak()


// ==========================================
// Front Matter Page Settings (Roman numerals)
// ==========================================
#set page(
  numbering: "i",
  number-align: center + bottom,
)
// If you want Acknowledgements to explicitly be page "vi":
#counter(page).update(6)

// Style Level-1 headings
#show heading.where(level: 1): it => {
  if it.numbering == none {
    // Generous breathing room from the top
    v(15%)
    align(center)[
      #text(size: 1.4em, weight: "regular", style: "italic")[#it.body]
    ]
    // Space between title and body text
    v(3.5em)
  } else {
    // Reset footnote numbering per chapter
    counter(footnote).update(0)

    // Chapter Number
    align(center)[
      #text(size: 13pt)[#counter(heading).display("I")]
    ]

    v(0.6em)

    // Chapter Title
    align(center)[
      #text(size: 16pt)[#it.body]
    ]

    v(3.5em)
  }
}

// Justify paragraph text and set paragraph spacing
#set par(
  justify: true,
  leading: 0.75em, // line spacing
  spacing: 1.5em, // blank space between paragraphs
)

// ==========================================
// Acknowledgements Page
// ==========================================


#heading(numbering: none, outlined: true)[#t("Acknowledgements")]
#cmarker.render(read("Acknowledgements.md"))
#pagebreak()
#heading(numbering: none, outlined: true)[#t("Introduction")]
#cmarker.render(read("Introduction.md"))
#pagebreak()

#let epigraph(attrs, body) = {
  align(center)[
    #box[
      #set align(left)
      #set text(size: 9.2pt)
      #set par(leading: 0.62em, first-line-indent: 0pt, spacing: 0pt)
      #body
    ]
  ]
  v(2.8em)
}

#let cite(attrs, body) = {
  v(0.45em)
  align(right)[#body]
}

#let render-md(file, images: (:)) = {
  let content = read(file)
  cmarker.render(
    content,
    scope: (
      image: (path, ..args) => {
        let img = images.at(path, default: none)
        let content-item = if img != none { img } else { image(path) }
        let alt = args.named().at("alt", default: none)
        if alt != none and alt != "" {
          align(center)[
            #content-item
            #text(size: 9pt)[#alt]
          ]
        } else {
          align(center)[#content-item]
        }
      },
    ),
    html: (
      epigraph: epigraph,
      cite: cite,
      footnote: (attrs, body) => footnote(body),
      fn: (attrs, body) => footnote(body),
      span: (attrs, body) => {
        if "explanation" in attrs {
          [#body#footnote(attrs.explanation)]
        } else {
          body
        }
      },
    ),
  )
}

// Chapters (numbered 1., 2., ...)
#set heading(numbering: "1.")
#set page(
  paper: "a5",
  margin: (x: 2.2cm, top: 3cm, bottom: 2.5cm),
  footer: context align(center)[#text(size: 9.5pt, font: "Libertinus Serif")[#counter(page).display()]],
  numbering: "1",
)

#set text(
  font: "Libertinus Serif",
  size: 10pt,
  lang: "en",
  features: (onum: 1),
)

// Body text settings
#set par(
  justify: true,
  leading: 0.68em,
  first-line-indent: 1.5em,
)

= #t("The Reach of Explanations")
#render-md(
  "1. The Reach of Explanations.md",
  images: (
    _page_14_Diagram_2: include "_page_14_Diagram_2.typ",
    _page_34_Picture_2: image("_page_34_Picture_2.jpeg"),
  ),
)
#pagebreak()

= #t("Closer to Reality")
#render-md(
  "2. Closer to Reality.md",
  images: (
    _page_44_Picture_5: image("_page_44_Picture_5.jpeg"),
    _page_48_Picture_4: image("_page_48_Picture_4.jpeg"),
  ),
)
#pagebreak()

= #t("The Spark")
#render-md(
  "3. The Spark.md",
  images: (
    _page_74_Picture_4: include "_page_74_Picture_4.typ",
    _page_75_Picture_2: include "_page_75_Picture_2.typ",
  ),
)
#pagebreak()

= #t("Creation")
#render-md(
  "4. Creation.md",
  images: (
    _page_110_Diagram_2: include "_page_110_Diagram_2.typ",
  ),
)
#pagebreak()

= #t("The Reality of Abstractions")
#render-md("5. The Reality of Abstractions.md")
#pagebreak()

= #t("The Jump to Universality")
#render-md("6. The Jump to Universality.md")
#pagebreak()

= #t("Artificial Creativity")
#render-md("7. Artificial Creativity.md")
#pagebreak()

= #t("A Window on Infinity")
#render-md(
  "8. A Window on Infinity.md",
  images: (
    _page_177_Figure_4: include "_page_177_Figure_4.typ",
    _page_178_Picture_2: image("_page_178_Picture_2.jpeg"),
    _page_180_Figure_1: include "_page_180_Figure_1.typ",
    _page_183_Figure_2: include "_page_183_Figure_2.typ",
    _page_184_Diagram_5: image("_page_184_Diagram_5.jpeg"),
  ),
)
#pagebreak()

= #t("Optimism")
#render-md("9. Optimism.md")
#pagebreak()

= #t("A Dream of Socrates")
#render-md("10. A Dream of Socrates.md")
#pagebreak()

= #t("The Multiverse")
#render-md(
  "11. The Multiverse.md",
  images: (
    _page_295_Diagram_1: include "_page_295_Diagram_1.typ",
    _page_296_Picture_1: include "_page_296_Picture_1.typ",
    _page_298_Picture_5: include "_page_298_Picture_5.typ",
    _page_298_Picture_7: include "_page_298_Picture_7.typ",
    _page_306_Diagram_1: include "_page_306_Diagram_1.typ",
  ),
)
#pagebreak()

= #t("A Physicist’s History of Bad Philosophy")
#render-md("12. A Physicist’s History of Bad Philosophy.md")
#pagebreak()

= #t("Choices")
#render-md("13. Choices.md")
#pagebreak()

= #t("Why are Flowers Beautiful?")
#render-md(
  "14. Why are Flowers Beautiful?.md",
  images: (
    _page_367_Picture_1: image("_page_367_Picture_1.jpeg"),
    _page_367_Picture_3: image("_page_367_Picture_3.jpeg"),
    _page_370_Picture_1: image("_page_370_Picture_1.jpeg"),
  ),
)
#pagebreak()

= #t("The Evolution of Culture")
#render-md(
  "15. The Evolution of Culture.md",
  images: (
    _page_386_Diagram_2: include "_page_386_Diagram_2.typ",
    _page_387_Diagram_1: include "_page_387_Diagram_1.typ",
  ),
)
#pagebreak()

= #t("The Evolution of Creativity")
#render-md("16. The Evolution of Creativity.md")
#pagebreak()

= #t("Unsustainable")
#render-md(
  "17. Unsustainable.md",
  images: (
    _page_430_Picture_3: image("_page_430_Picture_3.jpeg"),
    _page_436_Picture_1: image("_page_436_Picture_1.jpeg"),
  ),
)
#pagebreak()

= #t("The Beginning")
#render-md("18. The Beginning.md")
#pagebreak()

// #render-md("Bibliography.md")
// #render-md("Index.md")

// #import "_page_306_Diagram_1.typ": pipeline-diagram
// #pipeline-diagram()

