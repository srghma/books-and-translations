#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n

// Initialize translator
#let t = load-i18n("_page_386_Diagram_2.i18n.yml")

/// Renders the Meme Transmission & Imitation Cycle diagram using the traced human vector figure
#let meme-transmission-diagram(
  width: 440pt,
  height: 205pt,
  human-height: 165pt,
  arrow-color: rgb("#a4a9af"),
  v-padding: 1.5em,
) = {
  let serif-fonts = fonts-for-current-lang.serif

  // Calculate SVG scale factor from native viewBox (93.44 x 158.72)
  let s = human-height / 158.72pt
  let human-width = 93.44pt * s

  // Person 1 and Person 2 placement anchors
  let (x1, y1) = (54pt, 18pt)
  let (x2, y2) = (274pt, 18pt)

  // Anchors relative to SVG human coordinates
  let p1-hand = (x1 + 78pt * s, y1 + 55pt * s)
  let p2-eye = (x2 + 0pt * s, y2 + 35pt * s)
  let p1-eye = (x1 - 4pt * s, y1 + 42pt * s)
  let p2-hand = (x2 + 79pt * s, y2 + 55pt * s)

  // Beam transmission angle
  let beam-angle = calc.atan2(
    (p2-eye.at(0) - p1-hand.at(0)) / 1pt,
    (p2-eye.at(1) - p1-hand.at(1)) / 1pt,
  )

  // --- Helper: Filled triangular arrowhead ---
  let draw-triangle-head(x, y, angle, len: 10pt, half-w: 4.5pt) = {
    let cos-a = calc.cos(angle)
    let sin-a = calc.sin(angle)
    let b1 = (
      x - len * cos-a - half-w * sin-a,
      y - len * sin-a + half-w * cos-a,
    )
    let b2 = (
      x - len * cos-a + half-w * sin-a,
      y - len * sin-a - half-w * cos-a,
    )
    place(top + left, polygon(fill: arrow-color, stroke: none, (x, y), b1, b2))
  }

  // --- Helper: Plain solid transmission beam ---
  let draw-beam(start, end, with-head: false, angle: beam-angle) = {
    let stroke-style = (paint: arrow-color, thickness: 3.2pt, cap: "round")
    place(top + left, line(start: start, end: end, stroke: stroke-style))
    if with-head {
      draw-triangle-head(end.at(0), end.at(1), angle)
    }
  }

  // --- Helper: Beam made of exactly 3 dashes ---
  let draw-dashes-3(start, end, with-head: false, angle: beam-angle) = {
    let step = ((end.at(0) - start.at(0)) / 5, (end.at(1) - start.at(1)) / 5)
    let pt(i) = (start.at(0) + step.at(0) * i, start.at(1) + step.at(1) * i)
    let stroke-style = (paint: arrow-color, thickness: 3.2pt, cap: "round")
    place(top + left, line(start: pt(0), end: pt(1), stroke: stroke-style))
    place(top + left, line(start: pt(2), end: pt(3), stroke: stroke-style))
    place(top + left, line(start: pt(4), end: pt(5), stroke: stroke-style))
    if with-head {
      draw-triangle-head(end.at(0), end.at(1), angle)
    }
  }

  // --- Helper: Parametric "Causes behaviour" arrow with text wrapping along path ---
  let causes-behaviour-arrow(
    brain-start-point,
    hand-end-point,
    label1: t("Causes"),
    label2: t("behaviour"),
    color: arrow-color,
    font-size: 11,
  ) = {
    let to-pt(v) = if type(v) == length { v / 1pt } else { float(v) }
    let sx = to-pt(brain-start-point.at(0))
    let sy = to-pt(brain-start-point.at(1))
    let ex = to-pt(hand-end-point.at(0))
    let ey = to-pt(hand-end-point.at(1))

    let dx = ex - sx
    let dy = ey - sy
    let arch-h = calc.max(16.0, dy * 0.36)

    // Bézier control points: arch loops up above brain and curves down to hand
    let y-peak = sy - arch-h
    let c1x = sx + 0.22 * dx
    let c1y = y-peak
    let c2x = ex + 0.48 * dx
    let c2y = y-peak

    // Tangent vector and orthogonal normal at the hand end-point for arrowhead
    let tx = ex - c2x
    let ty = ey - c2y
    let t-len = calc.sqrt(tx * tx + ty * ty)
    let (ux, uy) = if t-len > 0 { (tx / t-len, ty / t-len) } else { (0.0, 1.0) }
    let (nx, ny) = (-uy, ux)

    let head-len = 9.0
    let head-half-w = 6.2
    let b1x = ex - head-len * ux + head-half-w * nx
    let b1y = ey - head-len * uy + head-half-w * ny
    let b2x = ex - head-len * ux - head-half-w * nx
    let b2y = ey - head-len * uy - head-half-w * ny

    // Compute bounding box with padding for stroke and text ascent
    let pad = 16.0
    let min-x = calc.min(sx, ex, c1x, c2x) - pad
    let min-y = calc.min(sy, ey, y-peak) - pad
    let max-x = calc.max(sx, ex, c1x, c2x) + pad
    let max-y = calc.max(sy, ey) + pad
    let vb-w = max-x - min-x
    let vb-h = max-y - min-y

    // Safe color conversion for Typst
    let hex-color = if type(color) == str { color } else { color.to-hex() }

    let svg-code = (
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='"
        + str(min-x)
        + " "
        + str(min-y)
        + " "
        + str(vb-w)
        + " "
        + str(vb-h)
        + "' width='"
        + str(vb-w)
        + "' height='"
        + str(vb-h)
        + "'>"
        + "<path id='causes-arc' d='M "
        + str(sx)
        + " "
        + str(sy)
        + " C "
        + str(c1x)
        + " "
        + str(c1y)
        + ", "
        + str(c2x)
        + " "
        + str(c2y)
        + ", "
        + str(ex)
        + " "
        + str(ey)
        + "' fill='none' stroke='"
        + hex-color
        + "' stroke-width='3.2' stroke-linecap='round' />"
        + "<polygon points='"
        + str(ex)
        + ","
        + str(ey)
        + " "
        + str(b1x)
        + ","
        + str(b1y)
        + " "
        + str(b2x)
        + ","
        + str(b2y)
        + "' fill='"
        + hex-color
        + "' />"
        + "<text font-family='New Computer Modern, Georgia, serif' font-style='italic' font-size='"
        + str(font-size)
        + "' fill='"
        + hex-color
        + "' letter-spacing='0.5'>"
        + "<textPath href='#causes-arc' startOffset='6%'>"
        + label1
        + "</textPath>"
        + "</text>"
        + "<text font-family='New Computer Modern, Georgia, serif' font-style='italic' font-size='"
        + str(font-size)
        + "' fill='"
        + hex-color
        + "' letter-spacing='0.5'>"
        + "<textPath href='#causes-arc' startOffset='56%'>"
        + label2
        + "</textPath>"
        + "</text>"
        + "</svg>"
    )

    place(
      top + left,
      dx: min-x * 1pt,
      dy: min-y * 1pt,
      image(bytes(svg-code), format: "svg", width: vb-w * 1pt, height: vb-h * 1pt),
    )
  }

  // --- Helper: Put content centered at (x, y) on the canvas ---
  let put-at(x, y, content) = {
    place(center + horizon, dx: x - width / 2, dy: y - height / 2, content)
  }

  // --- Helper: Single person unit with parametric anchors ---
  let person-unit(brain-label) = box(width: human-width + 20pt, height: human-height + 15pt)[
    // 1. Vector human stick figure
    #place(top + left, image(
      "_page_386_Diagram_2_human.svg",
      width: human-width,
      height: human-height,
    ))

    // 2. Parametric curved "Causes behaviour" arrow anchored directly between brain and hand
    #causes-behaviour-arrow(
      (29pt * s, 19.5pt * s), // brain-start-point
      (68pt * s, 62pt * s), // hand-end-point
    )

    // 3. Forehead brain labels
    #place(center + horizon, dx: 40pt * s - human-width / 2 - 10pt, dy: 22pt * s - human-height / 2 - 13.5pt)[
      #text(font: serif-fonts, weight: "bold", style: "italic", size: 10.5pt, t("Meme"))
    ]
    #place(center + horizon, dx: 40pt * s - human-width / 2 - 10pt, dy: 33pt * s - human-height / 2 - 14.5pt)[
      #text(font: serif-fonts, size: 7.5pt, brain-label)
    ]

    // 4. "Behaviour" label below the waving hand
    #place(center + horizon, dx: 76pt * s - human-width / 2 - 10pt, dy: 88pt * s - human-height / 2 - 7.5pt)[
      #text(font: serif-fonts, weight: "bold", style: "italic", size: 10.5pt, t("Behaviour"))
    ]
  ]

  align(center)[
    #block(inset: (y: v-padding))[
      #box(width: width, height: height)[
        // 1. Incoming beam to Person 1 (3 dashes with head)
        #let p1-start = (
          12pt,
          p1-eye.at(1) + (p1-eye.at(0) - 12pt) * calc.tan(-beam-angle),
        )
        #draw-dashes-3(p1-start, p1-eye, with-head: true, angle: beam-angle)

        // 2. Person 1 (left)
        #place(top + left, dx: x1 - 10pt, dy: y1 - 7.5pt, person-unit(t("(in brain no. 1)")))

        // 3. Central observation beam: Person 1's hand -> Person 2's eye (solid with head)
        #draw-beam(p1-hand, p2-eye, with-head: true, angle: beam-angle)

        // 4. Flanking labels along the central beam
        #let mid-x = (p1-hand.at(0) + p2-eye.at(0)) / 2
        #let mid-y = (p1-hand.at(1) + p2-eye.at(1)) / 2
        #put-at(mid-x, mid-y - 10pt, rotate(beam-angle, text(
          font: serif-fonts,
          style: "italic",
          size: 8pt,
          t("Which is observed"),
        )))
        #put-at(mid-x, mid-y + 11pt, rotate(beam-angle, text(
          font: serif-fonts,
          style: "italic",
          size: 8pt,
          t("and copied"),
        )))

        // 5. Person 2 (right)
        #place(top + left, dx: x2 - 10pt, dy: y2 - 7.5pt, person-unit(t("(in brain no. 2)")))

        // 6. Outgoing beam from Person 2 (3 dashes without head)
        #let p2-end = (
          width - 15pt,
          p2-hand.at(1) + (width - 15pt - p2-hand.at(0)) * calc.tan(beam-angle),
        )
        #draw-dashes-3(p2-hand, p2-end, with-head: false)
      ]
    ]
  ]
}

// Default preview
#meme-transmission-diagram()
