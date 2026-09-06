#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#let t = load-i18n("_page_295_Diagram_2.i18n.yml")

#let col1-w = 38pt
#let col2-w = 185pt
#let row-h = 20pt
#let brace-w = 68pt

// Pure native Typst: draws a smooth underbrace connected to the bottom of the table
#let drawn-brace(w) = {
  let mid = w / 2
  let arm-y = 5.5pt
  let tip-y = 9.5pt
  let r = 5.5pt
  let s = (paint: black, thickness: 0.6pt, cap: "round")

  // Generates smooth curve segments
  let qcurve(p0, p1, p2, steps: 5) = {
    let lines = ()
    let prev = p0
    for i in range(1, steps + 1) {
      let t = i / steps
      let ti = 1.0 - t
      let x = ti * ti * p0.at(0) + 2.0 * ti * t * p1.at(0) + t * t * p2.at(0)
      let y = ti * ti * p0.at(1) + 2.0 * ti * t * p1.at(1) + t * t * p2.at(1)
      let curr = (x, y)
      lines.push(place(top + left, line(start: prev, end: curr, stroke: s)))
      prev = curr
    }
    lines
  }

  let elements = ()
  // 1. Left corner touching bottom of table at (0, 0)
  elements += qcurve((0pt, 0pt), (0pt, arm-y), (r, arm-y))
  // 2. Left horizontal arm
  elements.push(place(top + left, line(start: (r, arm-y), end: (mid - r, arm-y), stroke: s)))
  // 3. Left side of cusp pointing down to (mid, tip-y)
  elements += qcurve((mid - r, arm-y), (mid, arm-y), (mid, tip-y))
  // 4. Right side of cusp
  elements += qcurve((mid, tip-y), (mid, arm-y), (mid + r, arm-y))
  // 5. Right horizontal arm
  elements.push(place(top + left, line(start: (mid + r, arm-y), end: (w - r, arm-y), stroke: s)))
  // 6. Right corner touching bottom of table at (w, 0)
  elements += qcurve((w - r, arm-y), (w, arm-y), (w, 0pt))

  box(
    width: w,
    height: tip-y,
    { for el in elements { el } },
  )
}

#let entanglement-diagram() = align(center)[
  #grid(
    columns: (auto, 40pt, auto),
    align: (top, center + horizon, top),

    // ==========================================
    // Left Box: Not entangled
    // ==========================================
    stack(
      spacing: 0pt,
      // Column labels
      pad(bottom: 4pt)[
        #grid(
          columns: (col1-w, col2-w),
          align(center)[#t("Object")], align(center)[#t("Rest of world")],
        )
      ],
      // Box
      table(
        columns: (col1-w, col2-w),
        rows: (row-h, row-h),
        align: center + horizon,
        stroke: 0.6pt,
        [$X$],
        table.cell(rowspan: 2)[
          #t("Not differentially\naffected by X and Y")
        ],
        [$Y$],
      ),
      // Underbrace attached directly to bottom border
      box(
        width: col1-w + col2-w,
        height: 22pt,
        place(
          top + left,
          dx: col1-w - brace-w / 2,
          stack(
            spacing: 3pt,
            drawn-brace(brace-w),
            box(width: brace-w, align(center)[#text(style: "italic", size: 10pt)[#t("not entangled")]]),
          ),
        ),
      ),
    ),

    // ==========================================
    // Arrow
    // ==========================================
    text(size: 1.3em)[$arrow$],

    // ==========================================
    // Right Box: Entangled
    // ==========================================
    stack(
      spacing: 0pt,
      // Column labels
      pad(bottom: 4pt)[
        #grid(
          columns: (col1-w, col2-w),
          align(center)[#t("Object")], align(center)[#t("Rest of world")],
        )
      ],
      // Box with dashed vertical divider
      table(
        columns: (col1-w, col2-w),
        rows: (row-h, row-h),
        align: center + horizon,
        stroke: (x, y) => {
          let solid = (paint: black, thickness: 0.6pt)
          let dashed = (paint: black, thickness: 0.6pt, dash: "dashed")
          (
            top: solid,
            bottom: solid,
            left: solid,
            right: solid,
          )
        },
        [$X$], [#t("Affected by X")],
        [$Y$], [#t("Affected (differently) by Y")],
      ),
      // Underbrace attached directly to bottom border
      box(
        width: col1-w + col2-w,
        height: 22pt,
        place(
          top + left,
          dx: col1-w - brace-w / 2,
          stack(
            spacing: 3pt,
            drawn-brace(brace-w),
            box(width: brace-w, align(center)[#text(style: "italic", size: 10pt)[#t("entangled")]]),
          ),
        ),
      ),
    ),
  )
]

#v(0.6em)
#layout(size => {
  let target-w = size.width
  let diagram-w = (col1-w + col2-w) * 2 + 40pt
  let s = if target-w < diagram-w { (target-w / diagram-w) * 100% } else { 100% }
  scale(x: s, y: s, reflow: true)[
    #entanglement-diagram()
  ]
})
#v(0.6em)
