#import "i18n.typ": current-lang, load-i18n

// Initialize translator for this diagram
#let t = load-i18n("_page_14_Diagram_2.i18n.yml")

#let in-text = t("Sensory experiences")
#let out-text = t("Theories / knowledge of reality")
#let step-text = t("‘Derivation’")
#let sub-text = t("(such as ‘Extrapolation’,\n‘Generalization’ or ‘Induction’)")

#let derivation-diagram(
  // Sizing & geometry
  arrow-width: 145pt,
  box-inset: (x: 9pt, y: 7pt),
  stroke: 0.75pt,
  head-length: 6.5pt,
  head-width: 6.5pt,
  v-padding: 2.2em,

  // Typography with Khmer & Western fallback fonts
  font-size: 8.5pt,
  sub-font-size: 7.5pt,
  color: black,
) = {
  // 1. Arrow element (shaft line + filled triangular head)
  let arrow-element = box(width: 100%, height: head-width, {
    place(
      horizon + left,
      line(
        length: 100%,
        stroke: (paint: color, thickness: stroke),
      ),
    )
    place(
      horizon + right,
      polygon(
        fill: color,
        stroke: none,
        (-head-length, -head-width / 2),
        (0pt, 0pt),
        (-head-length, head-width / 2),
      ),
    )
  })

  // 2. Middle column: arrow anchored to box horizon + labels above/below
  let middle-column = box(width: arrow-width, {
    // Label above arrow
    place(
      bottom + center,
      dy: -head-width / 2 - 3.5pt,
      text(size: font-size)[#step-text],
    )

    // Horizontal arrow
    arrow-element

    // Multi-line sub-label below arrow
    place(
      top + center,
      dy: head-width / 2 + 4pt,
      block(width: 100%)[
        #set par(leading: 0.35em)
        #text(size: sub-font-size)[#sub-text]
      ],
    )
  })

  // 3. Full layout
  align(center)[
    #block(inset: (y: v-padding))[
      #set text(font: font, size: font-size, fill: color)
      #grid(
        columns: (auto, arrow-width, auto),
        column-gutter: 0pt,
        align: horizon,

        // Left box
        rect(stroke: stroke, inset: box-inset)[
          #align(center + horizon)[#in-text]
        ],

        // Center arrow + labels
        middle-column,

        // Right box
        rect(stroke: stroke, inset: box-inset)[
          #align(center + horizon)[#out-text]
        ],
      )
    ]
  ]
}

// Default preview
#derivation-diagram()
