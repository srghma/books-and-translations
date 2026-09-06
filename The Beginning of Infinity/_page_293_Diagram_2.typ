#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#let t = load-i18n("_page_293_Diagram_2.i18n.yml")

// Define the single and split history boxes
#let box-size = 2.6em

#let single-box(val) = table(
  columns: box-size,
  rows: box-size,
  align: center + horizon,
  stroke: 0.6pt,
  val,
)

#let split-box(top, bottom) = table(
  columns: box-size,
  rows: (box-size / 2, box-size / 2),
  align: center + horizon,
  stroke: 0.6pt,
  top,
  bottom,
)

#v(0.6em)
#align(center)[
  #grid(
    columns: 3,
    gutter: 1.5em,
    align: horizon,
    split-box($X$, $Y$),
    grid(
      align: center,
      gutter: 0.2em,
      text(style: "italic", size: 0.95em)[#t("interference")],
      text(size: 2.5em)[$arrow.r.double$],
    ),
    single-box($X$),
  )
]
#v(0.6em)
