#import "i18n.typ": fonts-for-current-lang, load-i18n

#let t = load-i18n("_page_172_Table_1.i18n.yml")

#let reassignment-table() = {
  let sans-fonts = fonts-for-current-lang.sans
  set text(font: sans-fonts, size: 9.5pt)

  table(
    columns: 1,
    align: left,
    stroke: 0.5pt + black,
    inset: (x: 10pt, y: 7pt),
    [
      #t("Guest in room number")
      #v(3pt)
      #grid(
        columns: (2.2em, 3em, 2.2em, 2.2em, 2em),
        align: center,
        [1], [2], [3], [4], [...]
      )
    ],
    [
      #t("Moves to")
      #v(3pt)
      #grid(
        columns: (2.2em, 3em, 2.2em, 2.2em, 2em),
        align: center,
        [38], [173], [80], [30], [...]
      )
    ],
  )
}

#reassignment-table()
