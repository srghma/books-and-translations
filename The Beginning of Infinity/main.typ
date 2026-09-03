#import "@preview/transl:0.2.1": transl
#import "@preview/cmarker:0.1.10"

// Global Language Setup
#let current-lang = "en" // Change to "km" for Khmer
#set text(lang: current-lang)
#transl(data: yaml("i18n.yml"))

#let (title-fonts, cover-fonts) = {
  import "fonts.typ": get-fonts
  get-fonts(current-lang)
}

#{
  import "cover.typ": cover-page
  cover-page(
    (
      (transl("THE"), 0.8),
      (transl("BEGINNING"), 1.0),
      (transl("OF"), 0.8),
      (transl("INFINITY"), 1.0),
      (transl("EXPLANATIONS_THAT_TRANSFORM_THE_WORLD"), 0.3),
      (transl("DAVID_DEUTSCH"), 0.9),
      (transl("AUTHOR_OF"), 0.3),
      (transl("THE_FABRIC_OF_REALITY"), 0.6),
    ),
    cover-fonts,
  )
}

#pagebreak()

#{
  import "page2.typ": title-page
  title-page(
    author: transl("DAVID_DEUTSCH"),
    title: transl("THE_BEGINNING_OF_INFINITY"),
    subtitle: transl("EXPLANATIONS_THAT_TRANSFORM_THE_WORLD"),
    publisher: "VIKING",
    lang: current-lang,
    fonts: title-fonts,
  )
}


// #pagebreak()

#pagebreak()
#{
  import "page4.typ": half-title-page
  half-title-page(
    title: transl("THE_BEGINNING_OF_INFINITY"),
    logo-width: 2.2cm,
    lang: current-lang,
    fonts: title-fonts,
  )
}

#pagebreak()

#{
  import "page6.typ": title-page
  title-page(
    author: transl("DAVID_DEUTSCH"),
    title: transl("THE_BEGINNING_OF_INFINITY"),
    subtitle: transl("EXPLANATIONS_THAT_TRANSFORM_THE_WORLD"),
    publisher: "VIKING",
    lang: current-lang,
    fonts: title-fonts,
  )
}

#pagebreak()

#{
  // Adjust font size here
  set text(size: 10pt)

  // Adjust spacing between lines here (default is around 0.65em)
  set par(leading: 0.45em)

  align(center)[
    #read("page7-1.md").split("\n").join([\ ])
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

// Markdown chapters imported via cmarker
#let render-md = {
  file => cmarker.render(
    read(file),
    scope: (
      image: image,
    ),
  )
}

// Unnumbered front matter (automatically italicized by outrageous)
#heading(numbering: none, outlined: true)[Acknowledgements]
#render-md("Acknowledgements.md")
#pagebreak()
#heading(numbering: none, outlined: true)[Introduction]
#render-md("Introduction.md")
#pagebreak()

// Chapters (numbered 1., 2., ...)
#set heading(numbering: "1.")
= The Reach of Explanations
#render-md("1. The Reach of Explanations.md")
#pagebreak()
= Closer to Reality
#render-md("2. Closer to Reality.md")
#pagebreak()

// #render-md("3. The Spark.md")
// #render-md("4. Creation.md")
// #render-md("5. The Reality of Abstractions.md")
// #render-md("6. The Jump to Universality.md")
// #render-md("7. Artificial Creativity.md")
// #render-md("8. A Window on Infinity.md")
// #render-md("9. Optimism.md")
// #render-md("10. A Dream of Socrates.md")
// #render-md("11. The Multiverse.md")
// #render-md("12. A Physicist’s History of Bad Philosophy.md")
// #render-md("13. Choices.md")
// #render-md("14. Why are Flowers Beautiful?.md")
// #render-md("15. The Evolution of Culture.md")
// #render-md("16. The Evolution of Creativity.md")
// #render-md("17. Unsustainable.md")
// #render-md("18. The Beginning.md")
// #render-md("Bibliography.md")
// #render-md("Index.md")

// #import "_page_306_Diagram_1.typ": pipeline-diagram
// #pipeline-diagram(
//   input: $X$,
//   output: $f(X)$,
//   step1: transl("_page_306_Diagram_1.splitting"),
//   step2: transl("_page_306_Diagram_1.interference"),
//   branches: ([$Y_1$], [$Y_2$]),
//   last-branch: $Y(italic(#transl("_page_306_Diagram_1.many")))$,
// )
