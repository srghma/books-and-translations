#import "i18n.typ": fonts-for-current-lang, load-i18n

#let t = load-i18n("_page_176_Table_1.i18n.yml")

#let rearrangement-table() = {
  let sans-fonts = fonts-for-current-lang.sans
  set text(font: sans-fonts, size: 10pt)
  table(
    columns: (2.1em,) * 13,
    rows: 2.2em,
    align: center + horizon,
    stroke: 0.5pt + black,
    fill: (col, _) => if col in (0, 3, 6, 9) { luma(218) },
    [1], [2], [4], [3], [6], [8], [5], [10], [12], [7], [14], [16], [...]
  )
}

#rearrangement-table()
