#import "@preview/cmarker:0.1.10"
#import "@preview/mitex:0.2.7": mitex

#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n, str-to-lines
#import "sun-symbol.typ": sun-symbol
#import "up-arrow.typ": up-arrow
#import "tallies-and-roman.typ": rn, roman-fifty, roman-five-hundred, roman-one-thousand, tally
#import "simultaneous-dialog.typ": simultaneous-dialog2
#import "dialogue.typ": dialogue

#let t = load-i18n("main.i18n.yml")

#set page(
  paper: "a5",
  margin: (x: 2.2cm, top: 3cm, bottom: 2.5cm),
)

// #{
//   import "cover.typ": cover-page
//   cover-page(
//     (
//       (t("THE"), 0.8),
//       (t("BEGINNING"), 1.0),
//       (t("OF"), 0.8),
//       (t("INFINITY"), 1.0),
//       (t("EXPLANATIONS THAT TRANSFORM THE WORLD"), 0.3),
//       (t("DAVID DEUTSCH"), 0.9),
//       (t("AUTHOR OF"), 0.3),
//       (t("THE FABRIC OF REALITY"), 0.6),
//     ),
//     fonts-for-current-lang.sans,
//   )
// }
//
// #pagebreak()
//
// #{
//   import "page2.typ": title-page
//   title-page(
//     author: t("DAVID DEUTSCH"),
//     title: t("The Beginning of Infinity"),
//     subtitle: t("EXPLANATIONS THAT TRANSFORM THE WORLD"),
//     publisher: "VIKING",
//     lang: current-lang,
//     fonts: fonts-for-current-lang.serif,
//   )
// }
//
//
// // #pagebreak()
//
// #pagebreak()
// #{
//   import "page4.typ": half-title-page
//   half-title-page(
//     title: t("The Beginning of Infinity"),
//     logo-width: 2.2cm,
//     lang: current-lang,
//     fonts: fonts-for-current-lang.serif,
//   )
// }
//
// #pagebreak()
//
// #{
//   import "page6.typ": title-page
//   title-page(
//     author: t("DAVID DEUTSCH"),
//     title: t("The Beginning of Infinity"),
//     subtitle: t("EXPLANATIONS THAT TRANSFORM THE WORLD"),
//     publisher: "VIKING",
//     lang: current-lang,
//     fonts: fonts-for-current-lang.serif,
//   )
// }
//
// #pagebreak()
//
// #{
//   // Adjust font size here
//   set text(size: 10pt)
//
//   // Adjust spacing between lines here (default is around 0.65em)
//   set par(leading: 0.45em)
//
//   align(center)[
//     #str-to-lines(read("page7-1.md"))
//   ]
//
//   v(1.5em) // Spacing between the top block and the bottom disclaimer
//
//   cmarker.render(read("page7-2.md"))
// }
//
// #pagebreak()

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
      #text(size: 13pt)[#counter(heading).display("1")]
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
}

#let cite(attrs, body) = {
  v(0.45em)
  align(right)[#body]
}

#let terminology(attrs, body) = [
  #v(2.5em)
  #block(width: 100%, sticky: true)[
    #align(center)[
      #text(size: 8.5pt, tracking: 0.12em)[#smallcaps[Terminology]]
    ]
    #v(1.2em)
  ]
  #set text(size: 9.5pt)
  #set par(
    hanging-indent: 1.8em,
    first-line-indent: 0pt,
    leading: 0.65em,
    spacing: 0.9em,
  )
  #show emph: it => [#it #h(0.5em)]
  #body
]

#let meanings(attrs, body) = [
  #v(2.5em)
  #block(width: 100%, sticky: true)[
    #align(center)[
      #text(
        size: 8.5pt,
        tracking: 0.08em,
      )[#smallcaps[Meanings of 'The Beginning of Infinity'\ Encountered in This Chapter]]
    ]
    #v(1.2em)
  ]
  #set text(size: 9.5pt)
  #set par(leading: 0.65em, spacing: 0.9em)
  #set list(marker: [–])
  #body
]

#let summary(attrs, body) = [
  #v(2.5em)
  #block(width: 100%, sticky: true)[
    #align(center)[
      #text(size: 8.5pt, tracking: 0.12em)[#smallcaps[Summary]]
    ]
    #v(1.2em)
  ]
  #set text(size: 9.5pt)
  #set par(leading: 0.65em, spacing: 0.9em)
  #body
]


#let announcement(attrs, body) = [
  #v(0.8em)
  #rect(
    width: 100%,
    stroke: (dash: "dotted", thickness: 0.75pt, paint: black),
    inset: (x: 12pt, top: 10pt, bottom: 10pt),
  )[
    #set text(size: 9.5pt)
    #set par(
      justify: true,
      leading: 0.65em,
      first-line-indent: (amount: 1.5em, all: true),
    )
    #body
  ]
  #v(0.8em)
]

#let center-block(attrs, body) = [
  #v(0.5em)
  #align(center)[
    #set par(first-line-indent: 0pt, leading: 0.65em)
    #body
  ]
  #v(0.5em)
]

#let chapter-ref(attrs) = link(
  label("chapter-" + str(attrs.to)),
  [#t("Chapter") #attrs.to],
)

#let render-md(file, images: (:), math: false) = {
  cmarker.render(
    read(file),
    math: if math { mitex } else { none },
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
      terminology: terminology,
      meanings: meanings,
      summary: summary,
      dialogue: dialogue,
      "simultaneous-dialog2": simultaneous-dialog2,
      center: center-block,
      principle: center-block,
      announcement: announcement,
      instructions: announcement,
      "dotted-box": announcement,
      pre: (attrs, body) => [
        #text(
          font: ("Courier New", "Liberation Mono"),
          size: 0.9em,
          body,
        )
      ],
      chapter: ("void", chapter-ref),
      "sun-symbol": ("void", attrs => sun-symbol()),
      "up-arrow": ("void", attrs => up-arrow()),
      treason: (
        "void",
        attrs => box(
          height: 1.5em,
          baseline: 20%,
          image("treason.svg", height: 1.5em),
        ),
      ),
      tally: ("void", attrs => tally(attrs, none)),
      tally4: ("void", attrs => tally((count: 4, crossed: true), none)),
      tally1: ("void", attrs => tally((count: 1), none)),
      rn: rn,
      roman: rn,
      "roman-50": ("void", attrs => roman-fifty()),
      "roman-500": ("void", attrs => roman-five-hundred()),
      "roman-1000": ("void", attrs => roman-one-thousand()),
      "rn-50": ("void", attrs => roman-fifty()),
      "rn-500": ("void", attrs => roman-five-hundred()),
      "rn-1000": ("void", attrs => roman-one-thousand()),
    ),
  )
}

#let render-chapter(num, title, images: (:), math: false) = [
  #heading(
    level: 1,
    t(title),
  )
  #label("chapter-" + str(num))
  #render-md(
    str(num) + ". " + title + ".md",
    images: images,
    math: math,
  )
  #pagebreak()
]

// Chapters (numbered 1., 2., ...)
#set heading(numbering: "1.")
#set page(
  paper: "a5",
  margin: (x: 2.2cm, top: 3cm, bottom: 2.5cm),
  footer: context align(center)[#text(
    size: 9.5pt,
    font: "Libertinus Serif",
  )[#counter(page).display()]],
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

#render-chapter(
  1,
  "The Reach of Explanations",
  images: (
    _page_14_Diagram_2: include "_page_14_Diagram_2.typ",
    _page_34_Picture_2: image("_page_34_Picture_2.jpeg"),
  ),
)

#render-chapter(
  2,
  "Closer to Reality",
  images: (
    _page_44_Picture_5: image("_page_44_Picture_5.jpeg"),
    _page_48_Picture_4: image("_page_48_Picture_4.jpeg"),
  ),
)

#render-chapter(
  3,
  "The Spark",
  images: (
    _page_74_Picture_4: include "_page_74_Picture_4.typ",
    _page_75_Picture_2: include "_page_75_Picture_2.typ",
  ),
)

#render-chapter(
  4,
  "Creation",
  images: (
    _page_110_Diagram_2: include "_page_110_Diagram_2.typ",
  ),
)

#render-chapter(5, "The Reality of Abstractions")

#render-chapter(6, "The Jump to Universality", math: true)

#render-chapter(7, "Artificial Creativity")

#render-chapter(
  8,
  "A Window on Infinity",
  images: (
    _page_171_Table_1: include "_page_171_Table_1.typ",
    _page_172_Table_1: include "_page_172_Table_1.typ",
    _page_176_Table_1: include "_page_176_Table_1.typ",
    _page_177_Figure_4: include "_page_177_Figure_4.typ",
    _page_178_Picture_2: image("_page_178_Picture_2.jpeg"),
    _page_180_Figure_1: include "_page_180_Figure_1.typ",
    _page_183_Figure_2: include "_page_183_Figure_2.typ",
    _page_184_Diagram_5: image("_page_184_Diagram_5.jpeg"),
  ),
)

#render-chapter(9, "Optimism")

#render-chapter(10, "A Dream of Socrates")

#render-chapter(
  11,
  "The Multiverse",
  math: true,
  images: (
    _page_295_Diagram_1: include "_page_295_Diagram_1.typ",
    _page_296_Picture_1: include "_page_296_Picture_1.typ",
    _page_298_Picture_5: include "_page_298_Picture_5.typ",
    _page_298_Picture_7: include "_page_298_Picture_7.typ",
    _page_306_Diagram_1: include "_page_306_Diagram_1.typ",
  ),
)

#render-chapter(12, "A Physicist’s History of Bad Philosophy")

#render-chapter(13, "Choices")

#render-chapter(
  14,
  "Why are Flowers Beautiful?",
  images: (
    _page_367_Picture_1: image("_page_367_Picture_1.jpeg"),
    _page_367_Picture_3: image("_page_367_Picture_3.jpeg"),
    _page_370_Picture_1: image("_page_370_Picture_1.jpeg"),
  ),
)

#render-chapter(
  15,
  "The Evolution of Culture",
  images: (
    _page_386_Diagram_2: include "_page_386_Diagram_2.typ",
    _page_387_Diagram_1: include "_page_387_Diagram_1.typ",
  ),
)

#render-chapter(16, "The Evolution of Creativity")

#render-chapter(
  17,
  "Unsustainable",
  images: (
    _page_430_Picture_3: image("_page_430_Picture_3.jpeg"),
    _page_436_Picture_1: image("_page_436_Picture_1.jpeg"),
  ),
)

#render-chapter(18, "The Beginning")

// #render-md("Bibliography.md")
// #render-md("Index.md")

// #import "_page_306_Diagram_1.typ": pipeline-diagram
// #pipeline-diagram()
