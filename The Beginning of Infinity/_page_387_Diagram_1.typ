#import "@preview/cetz:0.5.2": canvas, draw
#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#import "arrow-with-text-above-and-below-in-the-middle.typ": arrow-with-text-above-and-below
#import "_page_387_Diagram_1_gene_spiral.typ": infinite-gene-spiral

// Initialize translator
#let t = load-i18n("_page_387_Diagram_1.i18n.yml")

/// Renders the Gene Replication and Expression diagram (The Beginning of Infinity, page 387, Diagram 1)
#let gene-replication-diagram(
  width: auto,
  box-w: none,
  box-h: none,
  box-h-mid: none,
  arrow-color: rgb("#b5b9bf"),
) = layout(size => {
  let target-width = if width == auto or width == none { size.width } else { width }
  let base-w = 366pt
  let s = target-width / base-w

  let box-w = if box-w != none { box-w } else { 70pt * s }
  let box-h = if box-h != none { box-h } else { 70pt * s }
  let box-h-mid = if box-h-mid != none { box-h-mid } else { 58pt * s }
  let serif-fonts = fonts-for-current-lang.serif
  let spiral-scale = box-w / 155pt

  // Dog dimensions
  let dog-h = 68pt * s
  let dog-w = dog-h * (322.44 / 292.58)

  // Arrow beam height from top of gene box
  let y-beam = 24.5pt * s

  // Helper for rendering each Gene box
  let make-gene-box(h: box-h) = box(
    width: box-w,
    height: h,
    stroke: 0.5pt + black,
  )[
    #place(top + left)[
      #box(width: box-w, height: 42pt * s, clip: true)[
        #align(right + top)[
          #infinite-gene-spiral(
            start-x: 35pt * spiral-scale,
            start-y: 105pt * spiral-scale,
            vanish-x: 255pt * spiral-scale,
            vanish-y: 55pt * spiral-scale,

            radius: 68pt * spiral-scale,
            gap-btw-turns: 155pt * spiral-scale,
            nodes-per-turn: 12,

            thickness-of-non-warped-spiral: 4.8pt * spiral-scale,
            thickness-of-non-warped-axis: 1.2pt * spiral-scale,

            color: "#16181b",
            axis-color: "rgba(130, 135, 142, 0.6)",
            draw-axis: false,
            color2: "#8b9097",
            crossover-lines-color: "#72777f",
            output-width: auto,
            v-padding: none,
          )
        ]
      ]
    ]
    #place(top + center, dx: 13pt * s, dy: 44pt * s)[
      #text(font: serif-fonts, weight: "bold", style: "italic", size: 15.5pt * s, t("Gene"))
    ]
  ]

  // Helper for horizontal arrows in the top row
  let arrow-cell(w, dashed: false, label: none) = canvas(length: 1pt, {
    draw.rect((0, 0), (w / 1pt, -box-h / 1pt), stroke: none)

    draw.line(
      (3 * s, -y-beam / 1pt),
      (w / 1pt, -y-beam / 1pt),
      stroke: (
        paint: arrow-color,
        thickness: 3.5pt * s,
        cap: "round",
        dash: if dashed { (6pt * s, 4.5pt * s) } else { none },
      ),
      mark: (
        end: "triangle",
        fill: arrow-color,
        stroke: none,
        length: 9pt * s,
        width: 8pt * s,
      ),
    )

    if label != none {
      draw.content(
        (w / 1pt / 2, -(y-beam / 1pt) + 7 * s),
        anchor: "south",
        text(font: serif-fonts, size: 12.5pt * s, style: "italic", fill: black, label),
      )
    }
  })

  // Box 2 with subtitle underneath
  let box2-content = box(width: box-w)[
    #make-gene-box(h: box-h-mid)
    #align(
      center,
      text(
        font: serif-fonts,
        size: 8.8pt * s,
        t("(Not necessarily\nexpressed in\nevery generation)"),
      ),
    )
  ]

  // Dog cell unit with optional "Behaviour" label and "expressed" arrow
  let dog-cell(
    is-happy: true,
    has-behaviour: true,
    has-expressed: true,
  ) = box(width: box-w, height: dog-h)[
    #place(top + left, dx: -8pt * s)[
      #image(
        if is-happy {
          "_page_387_Diagram_1_dog_happy.svg"
        } else {
          "_page_387_Diagram_1_dog_sad.svg"
        },
        width: dog-w,
        height: dog-h,
      )
    ]

    #if has-behaviour [
      #place(top + left, dx: -16pt * s, dy: 10pt * s)[
        #text(font: serif-fonts, size: 9pt * s, t("Behaviour"))
      ]
    ]

    #if has-expressed [
      #arrow-with-text-above-and-below(
        (83pt * s, -8pt * s),
        (45pt * s, 36pt * s),
        label-above: t("expressed"),
        font: serif-fonts,
        font-size: 10.5pt * s,
        font-style: "italic",
        text-color: black,
        color: black,
        thickness: 1.8pt * s,
        arrow-length: 8pt * s,
        arrow-width: 6pt * s,
        offset-above: 5pt * s,
        overlay: true,
      )
    ]
  ]

  let col-arrow-in = 30pt * s
  let col-arrow-mid = 47pt * s
  let col-arrow-out = 32pt * s

  align(center)[
    #box(width: target-width)[
      #grid(
        columns: (col-arrow-in, box-w, col-arrow-mid, box-w, col-arrow-mid, box-w, col-arrow-out),
        align: (col, row) => left + top,
        row-gutter: 4pt * s,

        // top row : arrow, box, arrow, box + text, arrow, box, arrow
        arrow-cell(col-arrow-in, dashed: true),
        make-gene-box(),
        arrow-cell(col-arrow-mid, label: t("copied")),
        box2-content,
        arrow-cell(col-arrow-mid, label: t("copied")),
        make-gene-box(),
        arrow-cell(col-arrow-out, dashed: true),

        // bottom row: _, dog, _, dog, _, dog, _
        [],
        dog-cell(is-happy: true, has-behaviour: true, has-expressed: true),
        [],
        dog-cell(is-happy: false, has-behaviour: false, has-expressed: false),
        [],
        dog-cell(is-happy: true, has-behaviour: true, has-expressed: true),
        [],
      )
    ]
  ]
})

// Default preview
#gene-replication-diagram()

