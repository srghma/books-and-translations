#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#let t = load-i18n("_page_306_Diagram_1.i18n.yml")

// --- Dimensions ---
#let H = 5.5em
#let W = 4.6em
#let W-mid = 4.8em

// --- Diagram Boxes ---
#let box-left = rect(
  width: W,
  height: H,
  stroke: 0.75pt,
  inset: 0pt,
)[#align(center + horizon)[$X$]]

#let box-right = rect(
  width: W,
  height: H,
  stroke: 0.75pt,
  inset: 0pt,
)[#align(center + horizon)[$f(X)$]]

#let box-mid = box(
  width: W-mid,
  height: H,
  stack(
    dir: ttb,
    // Top double-box for Y_1 and Y_2 (height 3.0em, each row 1.5em)
    table(
      columns: 100%,
      rows: (1.5em, 1.5em),
      align: center + horizon,
      stroke: 0.75pt,
      inset: 0pt,
      [$Y_1$],
      [$Y_2$],
    ),
    // Vertical dots
    rect(
      width: 100%,
      height: 1.0em,
      stroke: none,
      inset: 0pt,
    )[
      #align(center + horizon)[$dots.v$]
    ],
    // Bottom box for Y(many)
    rect(
      width: 100%,
      height: 1.5em,
      stroke: 0.75pt,
      inset: 0pt,
    )[
      #align(center + horizon)[$Y(italic(#t("many")))$]
    ],
  ),
)

#v(0.6em)
// --- Diagram Layout ---
#align(center)[
  #grid(
    columns: 5,
    column-gutter: 1.4em,
    align: center + horizon,
    box-left,
    [
      #text(style: "italic")[#t("splitting")] \
      #text(size: 2em)[$arrow.r.double$]
    ],
    box-mid,
    [
      #text(style: "italic")[#t("interference")] \
      #text(size: 2em)[$arrow.r.double$]
    ],
    box-right,
  )
]
