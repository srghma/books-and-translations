#import "@preview/cmarker:0.1.10"
#import "@preview/mitex:0.2.7": mitex

#import "@preview/cuti:0.4.0": show-fakeitalic, show-fakebold

#import "i18n.typ": current-lang, fonts-for-current-lang, i18n-file, load-i18n, str-to-lines
#import "sun-symbol.typ": sun-symbol
#import "up-arrow.typ": up-arrow
#import "tallies-and-roman.typ": rn, roman-fifty, roman-five-hundred, roman-one-thousand, tally
#import "simultaneous-dialog.typ": simultaneous-dialog2
#import "dialogue.typ": dialogue

#show: doc => if current-lang == "km" {
  show-fakeitalic(show-fakebold(doc))
} else {
  doc
}

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
    publisher: t("VIKING"),
    lang: current-lang,
    fonts: fonts-for-current-lang.serif,
  )
}

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
    publisher: t("VIKING"),
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
    #str-to-lines(read(i18n-file("page7-1.md")))
  ]

  v(1.5em) // Spacing between the top block and the bottom disclaimer

  cmarker.render(read(i18n-file("page7-2.md")))
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
    #set align(left)
    #set text(features: ("onum",)) // Old-style figures
    #outline(
      title: align(center)[#text(style: "italic", size: 1.4em)[#t("Contents")]],
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
  }
}

// Justify paragraph text and set paragraph spacing
#set par(
  justify: true,
  leading: 0.75em, // line spacing
  spacing: 0.75em, // blank space between paragraphs
)

// ==========================================
// Acknowledgements Page
// ==========================================


#heading(numbering: none, outlined: true)[#t("Acknowledgements")]
#cmarker.render(read(i18n-file("Acknowledgements.md")))
#pagebreak()
#heading(numbering: none, outlined: true)[#t("Introduction")]
#cmarker.render(read(i18n-file("Introduction.md")))
#pagebreak()

#let epigraph(attrs, body) = {
  let content = [
    #set text(size: 9.2pt)
    #set par(
      justify: true,
      leading: 0.65em,
      spacing: 0.65em,
      first-line-indent: (amount: 1.5em, all: true),
    )
    #body
  ]

  if "nopad" in attrs or attrs.at("pad", default: "") == "false" {
    content
  } else {
    v(0.8em)
    pad(x: 1.8em, content)
    v(0.8em)
  }
}

#let cite(attrs, body) = {
  v(0.45em)
  align(right)[
    #set par(first-line-indent: 0pt)
    #body
  ]
}

#let chapter-end-section(title, tracking: 0.12em, content) = {
  v(2.5em)
  block(width: 100%, sticky: true)[
    #align(center)[
      #text(size: 8.5pt, tracking: tracking)[#smallcaps[#title]]
    ]
    #v(1.2em)
  ]
  set text(size: 9.5pt)
  set par(leading: 0.65em, spacing: 0.9em)
  content
}

#let terminology(attrs, body) = chapter-end-section(t("Terminology"))[
  #set par(hanging-indent: 1.8em, first-line-indent: 0pt)
  #show emph: it => [#it #h(0.5em)]
  #body
]

#let meanings(attrs, body) = chapter-end-section(
  t("Meanings of 'The Beginning of Infinity'\nEncountered in This Chapter"),
  tracking: 0.08em,
)[
  #set list(marker: [–])
  #body
]

#let summary(attrs, body) = chapter-end-section(t("Summary"), body)

#let announcement(attrs, body) = {
  v(0.8em)
  rect(
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
  v(0.8em)
}

#let center-block(attrs, body) = {
  v(0.5em)
  align(center)[
    #set par(first-line-indent: 0pt, leading: 0.65em)
    #body
  ]
  v(0.5em)
}

#let is-ignorable-grid-child(c) = (
  c.func() in ([ ].func(), parbreak, v) or (c.func() == text and c.text.trim() == "")
)

#let parse-grid-length(val) = {
  if val.ends-with("fr") {
    float(val.slice(0, -2)) * 1fr
  } else if val.ends-with("%") {
    float(val.slice(0, -1)) * 1%
  } else if val.ends-with("pt") {
    float(val.slice(0, -2)) * 1pt
  } else if val.ends-with("em") { float(val.slice(0, -2)) * 1em } else { auto }
}

#let grid-tag(attrs, body) = {
  let raw-children = if type(body) == content and body.has("children") {
    body.children
  } else { (body,) }
  let items = raw-children.filter(c => not is-ignorable-grid-child(c))

  let cols = if "columns" in attrs {
    attrs.columns.split(" ").filter(p => p.trim() != "").map(parse-grid-length)
  } else if "cols" in attrs {
    (1fr,) * int(attrs.cols)
  } else if items.len() > 0 {
    (1fr,) * items.len()
  } else {
    (1fr, 1fr)
  }

  let align-val = (
    "top": top,
    "bottom": bottom,
    "center": horizon,
    "horizon": horizon,
  ).at(attrs.at("align", default: "horizon"), default: horizon)

  let gutter = if "gutter" in attrs { parse-grid-length(attrs.gutter) } else {
    1.2em
  }
  if gutter == auto { gutter = 1.2em }

  v(0.8em)
  grid(columns: cols, gutter: gutter, align: align-val, ..items)
  v(0.8em)
}

#let chapter-ref(attrs) = link(
  label("chapter-" + str(attrs.to)),
  [#t("Chapter") #attrs.to],
)

#let t-box(..items) = {
  let is-single = items.pos().len() == 1
  table(
    columns: 14pt,
    rows: if is-single { 14pt } else { (8pt, 8pt) },
    align: center + horizon,
    stroke: 0.5pt,
    inset: 0pt,
    ..items.pos().map(it => text(size: if is-single { 8pt } else { 7.5pt })[$#it$]),
  )
}

#let transporter-diagram(..items) = box(baseline: 25%)[
  #grid(columns: items.pos().len(), align: horizon, gutter: 3pt, ..items)
]

#let transporter-split() = transporter-diagram(
  t-box("X"),
  text(size: 9pt)[$arrow.r$],
  t-box("X", "Y"),
)

#let transporter-rejoin() = transporter-diagram(
  t-box("X", "Y"),
  text(size: 9pt)[$arrow.r$],
  t-box("X"),
)

#let transporter-cycle() = transporter-diagram(
  t-box("X"),
  text(size: 9pt)[$arrow.r.double$],
  t-box("X", "Y"),
  text(size: 9pt)[$arrow.r.double$],
  t-box("X"),
)

#let inline-html = (
  sub: (attrs, body) => sub(body),
  sup: (attrs, body) => super(body),
  i: (attrs, body) => emph(body),
  em: (attrs, body) => emph(body),
)

#let treason-symbol() = box(
  height: 1.5em,
  baseline: 20%,
  image("treason.svg", height: 1.5em),
)

#let roman-symbols = (
  rn: rn,
  roman: rn,
  "roman-50": ("void", attrs => roman-fifty()),
  "roman-500": ("void", attrs => roman-five-hundred()),
  "roman-1000": ("void", attrs => roman-one-thousand()),
  "rn-50": ("void", attrs => roman-fifty()),
  "rn-500": ("void", attrs => roman-five-hundred()),
  "rn-1000": ("void", attrs => roman-one-thousand()),
)

#let render-image-item(images, path, alt) = {
  let item = if path in images { images.at(path) } else { image(path) }
  if alt != none and alt != "" {
    align(center)[
      #item
      #v(0.3em)
      #text(size: 9pt)[#cmarker.render(alt, html: inline-html)]
    ]
  } else {
    align(center, item)
  }
}

#let render-md(file, images: (:), math: false) = {
  cmarker.render(
    read(i18n-file(file)),
    math: if math { mitex } else { none },
    scope: (
      image: (path, ..args) => render-image-item(
        images,
        path,
        args.named().at("alt", default: none),
      ),
    ),
    html: (
      ..inline-html,
      ..roman-symbols,
      epigraph: epigraph,
      cite: cite,
      footnote: (attrs, body) => footnote(body),
      fn: (attrs, body) => footnote(body),
      span: (attrs, body) => if "explanation" in attrs {
        [#body#footnote(attrs.explanation)]
      } else {
        body
      },
      terminology: terminology,
      meanings: meanings,
      summary: summary,
      dialogue: dialogue,
      "simultaneous-dialog2": simultaneous-dialog2,
      grid: grid-tag,
      "side-by-side": grid-tag,
      center: center-block,
      principle: center-block,
      announcement: announcement,
      instructions: announcement,
      "dotted-box": announcement,
      pre: (attrs, body) => text(
        font: ("Courier New", "Liberation Mono"),
        size: 0.9em,
        body,
      ),
      chapter: ("void", chapter-ref),
      noindent: (attrs, body) => [
        #set par(first-line-indent: 0pt)
        #body
      ],
      // br: ("void", attrs => v(1em)),
      "br-gap": (
        "void",
        attrs => {
          let sz = if "size" in attrs { parse-grid-length(attrs.size) } else {
            1.8em
          }
          v(if sz == auto { 1.8em } else { sz })
        },
      ),
      "sun-symbol": ("void", attrs => sun-symbol()),
      "up-arrow": ("void", attrs => up-arrow()),
      treason: ("void", attrs => treason-symbol()),
      tally: ("void", attrs => tally(attrs, none)),
      tally4: ("void", attrs => tally((count: 4, crossed: true), none)),
      tally1: ("void", attrs => tally((count: 1), none)),
      "transporter-split": ("void", attrs => transporter-split()),
      "transporter-rejoin": ("void", attrs => transporter-rejoin()),
      "transporter-cycle": ("void", attrs => transporter-cycle()),
    ),
  )
}

#let render-chapter(
  num,
  title,
  subtitle: none,
  images: (:),
  math: false,
) = [
  #heading(
    level: 1,
    t(title),
  )
  #label("chapter-" + str(num))
  #if subtitle != none [
    #align(center)[
      #text(size: 12pt, weight: "regular", style: "italic")[#t(subtitle)]
    ]
  ]
  #v(3.5em)
  #let chapter-file = str(num) + ". " + title.replace("?", "") + ".md"
  #render-md(
    chapter-file,
    images: images,
    math: math,
  )
  #pagebreak()
]

#let render-bibliography(file: "Bibliography.md") = [
  #show heading.where(level: 1): it => {
    // v(15%)
    align(center)[
      #text(size: 1.4em, weight: "regular", style: "italic")[#it.body]
    ]
    // v(2em, weak: true)
  }
  #heading(numbering: none, outlined: true)[#t("Bibliography")]
  #{
    set heading(numbering: none, outlined: false)
    show heading: it => if it.level > 1 {
      // v(1.8em, weak: true)
      block(sticky: true)[#text(size: 10pt, weight: "regular")[#it.body]]
      v(0.8em)
    } else {
      it
    }
    set par(
      justify: true,
      leading: 0.68em,
      spacing: 0.68em,
      first-line-indent: 0pt,
      hanging-indent: 1.5em,
    )
    render-md(file)
  }
  // #pagebreak()
]


// Chapters (numbered 1., 2., ...)
#set heading(numbering: "1.")
#set page(
  paper: "a5",
  margin: (x: 2.2cm, top: 3cm, bottom: 2.5cm),
  footer: context align(center)[#text(
    size: 9.5pt,
    font: fonts-for-current-lang.serif,
  )[#counter(page).display()]],
  numbering: "1",
)

#set text(
  font: fonts-for-current-lang.serif,
  size: 10pt,
  lang: current-lang,
  features: (onum: 1),
)

// Body text settings
#set par(
  justify: true,
  leading: 0.68em,
  first-line-indent: (amount: 1.5em, all: true),
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
    _page_293_Diagram_1: include "_page_293_Diagram_1.typ",
    _page_293_Diagram_2: include "_page_293_Diagram_2.typ",
    _page_294_Diagram_1: include "_page_294_Diagram_1.typ",
    _page_295_Diagram_1: include "_page_295_Diagram_1.typ",
    _page_295_Diagram_2: include "_page_295_Diagram_2.typ",
    _page_295_Diagram_3: include "_page_295_Diagram_3.typ",
    _page_296_Picture_1: include "_page_296_Picture_1.typ",
    _page_297_Picture_1: include "_page_297_Picture_1.typ",
    _page_298_Diagram_1: include "_page_298_Diagram_1.typ",
    _page_298_Picture_5: include "_page_298_Picture_5.typ",
    _page_298_Picture_7: include "_page_298_Picture_7.typ",
    _page_298_Picture_9: include "_page_298_Picture_9.typ",
    _page_306_Diagram_1: include "_page_306_Diagram_1.typ",
  ),
)

#render-chapter(
  12,
  "A Physicist’s History of Bad Philosophy",
  subtitle: "With Some Comments on Bad Science",
)

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

#render-bibliography()

// #render-md("Index.md")
