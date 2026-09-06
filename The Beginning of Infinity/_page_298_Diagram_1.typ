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
    columns: 5,
    gutter: 1.8em,
    align: horizon,
    split-box($X$, $Y$),
    text(size: 2.5em)[$arrow.r.double$],
    single-box($X$),
    text(size: 2.5em)[$arrow.r.double$],
    split-box($X$, $Y$),
  )
]
#v(0.6em)
