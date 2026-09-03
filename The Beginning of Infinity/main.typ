#import "@preview/cmarker:0.1.10"

#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n, str-to-lines

#let t = load-i18n("main.i18n.yml")

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
    str-to-lines(#read("page7-1.md"))
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

// Style unnumbered Level-1 headings (Acknowledgements, Introduction)
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
    // Keep normal layout for numbered chapters (1. The Reach...)
    it
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


#heading(numbering: none, outlined: true)[t("Acknowledgements")]
#cmarker.render(read("Acknowledgements.md"))
#pagebreak()
#heading(numbering: none, outlined: true)[t("Introduction")]
#cmarker.render(read("Introduction.md"))
#pagebreak()

#let render-md = {
  file => cmarker.render(
    read(file),
    scope: (
      image: (path, ..args) => image(path, ..args),
    ),
  )
}

// Chapters (numbered 1., 2., ...)
#set heading(numbering: "1.")
= t("The Reach of Explanations")
// #render-md("1. The Reach of Explanations.md")
#pagebreak()
= t("Closer to Reality")
// #render-md("2. Closer to Reality.md")
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
// #pipeline-diagram()
