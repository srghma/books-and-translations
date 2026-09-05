#import "@preview/cetz:0.5.2": canvas, draw
#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#import "arrow-with-text-above-and-below-in-the-middle.typ": arrow-with-text-above-and-below
#import "_page_387_Diagram_1_gene_spiral.typ": infinite-gene-spiral

// Initialize translator
#let t = load-i18n("_page_387_Diagram_1.i18n.yml")

/// Renders the Gene Replication and Expression diagram (The Beginning of Infinity, page 387, Diagram 1)
#let gene-replication-diagram(
  width: 380pt,
  box-w: 70pt,
  box-h: 70pt,
  box-h-mid: 58pt,
  arrow-color: rgb("#b5b9bf"),
  v-padding: 1.5em,
) = {
  let serif-fonts = fonts-for-current-lang.serif
  let spiral-scale = box-w / 155pt

  // Dog dimensions
  let dog-h = 68pt
  let dog-w = dog-h * (322.44 / 292.58)

  // Arrow beam height from top of gene box
  let y-beam = 24.5pt

  // Helper for rendering each Gene box
  let make-gene-box(h: box-h) = box(
    width: box-w,
    height: h,
    stroke: 0.5pt + black,
  )[
    #place(top + left)[
      #box(width: box-w, height: 42pt, clip: true)[
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
    #place(top + center, dx: 13pt, dy: 44pt)[
      #text(font: serif-fonts, weight: "bold", style: "italic", size: 15.5pt, t("Gene"))
    ]
  ]

  // Helper for horizontal arrows in the top row
  let arrow-cell(w, dashed: false, label: none) = canvas(length: 1pt, {
    draw.rect((0, 0), (w / 1pt, -box-h / 1pt), stroke: none)

    draw.line(
      (3, -y-beam / 1pt),
      (w / 1pt, -y-beam / 1pt),
      stroke: (
        paint: arrow-color,
        thickness: 3.5pt,
        cap: "round",
        dash: if dashed { (6pt, 4.5pt) } else { none },
      ),
      mark: (
        end: "triangle",
        fill: arrow-color,
        stroke: none,
        length: 9pt,
        width: 8pt,
      ),
    )

    if label != none {
      draw.content(
        (w / 1pt / 2, -(y-beam / 1pt) + 7),
        anchor: "south",
        text(font: serif-fonts, size: 12.5pt, style: "italic", fill: black, label),
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
        size: 8.8pt,
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
    #place(top + left, dx: -8pt)[
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
      #place(top + left, dx: -16pt, dy: 10pt)[
        #text(font: serif-fonts, size: 9pt, t("Behaviour"))
      ]
    ]

    #if has-expressed [
      #arrow-with-text-above-and-below(
        (83pt, -8pt),
        (45pt, 36pt),
        label-above: t("expressed"),
        font: serif-fonts,
        font-size: 10.5pt,
        font-style: "italic",
        text-color: black,
        color: black,
        thickness: 1.8pt,
        arrow-length: 8pt,
        arrow-width: 6pt,
        offset-above: 5pt,
        overlay: true,
      )
    ]
  ]

  let col-arrow-in = 30pt
  let col-arrow-mid = 47pt
  let col-arrow-out = 32pt

  align(center)[
    #block(inset: (y: v-padding))[
      #grid(
        columns: (col-arrow-in, box-w, col-arrow-mid, box-w, col-arrow-mid, box-w, col-arrow-out),
        align: (col, row) => left + top,
        row-gutter: 4pt,

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
}

// Default preview
#gene-replication-diagram()

