#import "i18n.typ": load-i18n

#let t = load-i18n("_page_171_Table_1.i18n.yml")

#let cantor-diagonal-table() = {
  table(
    columns: (85pt, 85pt),
    align: (col, row) => {
      if row == 0 or row == 5 { center }
      else if col == 0 { center }
      else { left }
    },
    stroke: 0.5pt,
    inset: (x: 8pt, y: 6pt),
    t("Which room"), t("Which card"),
    [1], [0.#strong[6]77976...],
    [2], [0.6#strong[9]4698...],
    [3], [0.39#strong[9]221...],
    [4], [0.236#strong[6]46...],
    $dots.v$, $dots.v$,
  )
}

#cantor-diagonal-table()
