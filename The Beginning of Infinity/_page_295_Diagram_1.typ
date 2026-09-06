#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
// Initialize translator
#let t = load-i18n("_page_295_Diagram_1.i18n.yml")

/// Renders the quantum multiverse splitting and entanglement diagram
#let multiverse-entanglement-diagram(
  box1-w: 92pt,
  arrow1-w: 36pt,
  box2-w: 136pt,
  arrow2-w: 56pt,
  box3-w: 164pt,
  obj-w: 34pt,
  box-h: 30pt,
  header-h: 15pt,
  transition-h: 30pt,
  transition-w: 64pt,
  font-size: 7.5pt,
  header-size: 8pt,
  arrow-label-size: 7.5pt,
  v-padding: 1.5em,
) = {
  let sans-fonts = fonts-for-current-lang.sans
  let solid-stroke = 0.75pt + black
  let dashed-stroke = (paint: black, thickness: 0.75pt, dash: (2.5pt, 2pt))

  // Header helper for tables
  let make-header(width, has-obj: true) = {
    box(width: width, height: header-h)[
      #align(center + top)[
        #grid(
          columns: (obj-w, 1fr),
          rows: auto,
          stroke: none,
          if has-obj {
            align(center + top)[
              #text(font: sans-fonts, size: header-size)[#t("Object")]
            ]
          } else {
            align(center + top)[
              #text(size: 16pt)[#sym.arrow.b.double]
            ]
          },
          align(center + top)[
            #text(font: sans-fonts, size: header-size)[#t("Rest of world")]
          ],
        )
      ]
    ]
  }

  // Horizontal arrow cell helper (vertically centered to box-h)
  let make-h-arrow(label, symbol, width) = {
    box(width: width, height: box-h)[
      #align(center + horizon)[
        #text(font: sans-fonts, style: "italic", weight: "regular", size: arrow-label-size)[#label]
        #text(size: 13pt)[#symbol]
      ]
    ]
  }

  // --- Box 1: Object X | Unaffected ---
  let box-1 = rect(
    width: box1-w,
    height: box-h,
    stroke: solid-stroke,
    inset: 0pt,
    grid(
      columns: (obj-w, 1fr),
      rows: 100%,
      stroke: none,
      rect(
        width: 100%,
        height: 100%,
        stroke: (right: solid-stroke),
        inset: 0pt,
        align(center + horizon)[$X$],
      ),
      align(center + horizon)[
        #box(inset: (x: 2pt))[
          #text(font: sans-fonts, size: font-size)[#t("Unaffected")]
        ]
      ],
    ),
  )

  // --- Box 2: Object [X / Y] | Not differentially affected by X and Y ---
  let box-2 = rect(
    width: box2-w,
    height: box-h,
    stroke: solid-stroke,
    inset: 0pt,
    grid(
      columns: (obj-w, 1fr),
      rows: 100%,
      stroke: none,
      rect(
        width: 100%,
        height: 100%,
        stroke: (right: solid-stroke),
        inset: 0pt,
        grid(
          columns: 100%,
          rows: (1fr, 1fr),
          stroke: none,
          rect(
            width: 100%,
            height: 100%,
            stroke: (bottom: solid-stroke),
            inset: 0pt,
            align(center + horizon)[$X$],
          ),
          align(center + horizon)[$Y$],
        ),
      ),
      align(center + horizon)[
        #set par(leading: 0.35em)
        #box(inset: (x: 2pt))[
          #text(font: sans-fonts, size: font-size)[#t(
            "Not differentially\naffected by X and Y",
          )]
        ]
      ],
    ),
  )

  // --- Box 3: Entangled [X: Affected by X / Y: Affected by Y] ---
  let box-3 = rect(
    width: box3-w,
    height: box-h,
    stroke: solid-stroke,
    inset: 0pt,
    grid(
      columns: 100%,
      rows: (1fr, 1fr),
      stroke: none,
      // Top row: X | Affected by X
      rect(
        width: 100%,
        height: 100%,
        stroke: (bottom: solid-stroke),
        inset: 0pt,
        grid(
          columns: (obj-w, 1fr),
          rows: 100%,
          stroke: none,
          rect(
            width: 100%,
            height: 100%,
            stroke: (right: dashed-stroke),
            inset: 0pt,
            align(center + horizon)[$X$],
          ),
          align(center + horizon)[
            #box(inset: (x: 2pt))[
              #text(font: sans-fonts, size: font-size)[#t("Affected by X")]
            ]
          ],
        ),
      ),
      // Bottom row: Y | Affected (differently) by Y
      grid(
        columns: (obj-w, 1fr),
        rows: 100%,
        stroke: none,
        rect(
          width: 100%,
          height: 100%,
          stroke: (right: dashed-stroke),
          inset: 0pt,
          align(center + horizon)[$Y$],
        ),
        align(center + horizon)[
          #box(inset: (x: 2pt))[
            #text(font: sans-fonts, size: font-size)[#t(
              "Affected (differently) by Y",
            )]
          ]
        ],
      ),
    ),
  )

  // --- Downward Transition Label + Arrow ---
  let vertical-transition = box(width: transition-w)[
    #align(center)[
      #v(4pt)
      #text(font: sans-fonts, style: "italic", weight: "bold", size: font-size)[#t(
        "no interference,",
      )]\
      #text(font: sans-fonts, style: "italic", weight: "regular", size: font-size)[#t(
        "just splitting",
      )]
    ]
  ]

  let transition-dx = box1-w + arrow1-w + box2-w + arrow2-w + obj-w / 2 - transition-w / 2
  let transition-dy = header-h + box-h

  // --- Box 4: 4-Subrow Split with Dashed Entanglement Divider ---
  let box-4 = rect(
    width: box3-w,
    height: box-h * 2,
    stroke: solid-stroke,
    inset: 0pt,
    grid(
      columns: 100%,
      rows: (1fr, 1fr),
      stroke: none,
      // Top half: left has [X, Y], right has Affected by X
      rect(
        width: 100%,
        height: 100%,
        stroke: (bottom: solid-stroke),
        inset: 0pt,
        grid(
          columns: (obj-w, 1fr),
          rows: 100%,
          stroke: none,
          rect(
            width: 100%,
            height: 100%,
            stroke: (right: dashed-stroke),
            inset: 0pt,
            grid(
              columns: 100%,
              rows: (1fr, 1fr),
              stroke: none,
              rect(
                width: 100%,
                height: 100%,
                stroke: (bottom: solid-stroke),
                inset: 0pt,
                align(center + horizon)[$X$],
              ),
              align(center + horizon)[$Y$],
            ),
          ),
          align(center + horizon)[
            #box(inset: (x: 2pt))[
              #text(font: sans-fonts, size: font-size)[#t("Affected by X")]
            ]
          ],
        ),
      ),
      // Bottom half: left has [Y, X], right has Affected (differently) by Y
      grid(
        columns: (obj-w, 1fr),
        rows: 100%,
        stroke: none,
        rect(
          width: 100%,
          height: 100%,
          stroke: (right: dashed-stroke),
          inset: 0pt,
          grid(
            columns: 100%,
            rows: (1fr, 1fr),
            stroke: none,
            rect(
              width: 100%,
              height: 100%,
              stroke: (bottom: solid-stroke),
              inset: 0pt,
              align(center + horizon)[$Y$],
            ),
            align(center + horizon)[$X$],
          ),
        ),
        align(center + horizon)[
          #box(inset: (x: 2pt))[
            #text(font: sans-fonts, size: font-size)[#t(
              "Affected (differently) by Y",
            )]
          ]
        ],
      ),
    ),
  )

  // Master Layout: Fully Grid-Structured
  align(center)[
    #block(inset: (y: v-padding))[
      #box[
        #grid(
          columns: (box1-w, arrow1-w, box2-w, arrow2-w, box3-w),
          column-gutter: 0pt,
          row-gutter: 0pt,
          align: (center + top, center + horizon, center + top, center + horizon, center + top),
          // Row 0: Headers
          make-header(box1-w, has-obj: true),
          [],
          make-header(box2-w, has-obj: true),
          [],
          make-header(box3-w, has-obj: true),
          // Row 1: Boxes + Centered Horizontal Arrows
          box-1,
          make-h-arrow(t("splitting"), sym.arrow.r.double, arrow1-w),
          box-2,
          make-h-arrow(t("entanglement"), sym.arrow.r, arrow2-w),
          box-3,
          // Row 2: Spacer only
          [], [], [], [], box(height: transition-h),
          // Row 3: Header for Box 4
          [], [], [], [], make-header(box3-w, has-obj: false),
          // Row 4: Box 4
          [], [], [], [], box-4,
        )
        // Independent overlay
        #place(top + left, dx: transition-dx, dy: transition-dy)[#vertical-transition]
      ]
    ]
  ]
}

// Auto-fit to available page width
#layout(size => {
  let target-w = size.width
  let diagram-w = 484pt
  let s = if target-w < diagram-w { (target-w / diagram-w) * 100% } else { 100% }
  scale(x: s, y: s, reflow: true)[
    #multiverse-entanglement-diagram()
  ]
})
