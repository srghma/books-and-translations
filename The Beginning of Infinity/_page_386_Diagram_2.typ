#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n

// Initialize translator
#let t = load-i18n("_page_386_Diagram_2.i18n.yml")

// Static cartoon gesticulating hand SVG (decoded once)
#let hand-svg = image(
  bytes(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 20" width="22" height="18">
    <path d="M 2 12 C 0 8, 2 3, 6 2 C 9 1, 11 4, 12 6 C 13 3, 16 3, 18 5 C 19 4, 21 5, 22 8 C 23 12, 20 16, 15 17 C 9 18, 4 16, 2 12 Z"
          fill="white" stroke="black" stroke-width="1.6" stroke-linejoin="round" />
  </svg>`.text,
  ),
)

/// Renders the Meme Transmission & Imitation Cycle diagram
#let meme-transmission-diagram(
  width: 440pt,
  height: 245pt,
  arrow-color: rgb("#a4a9af"),
  v-padding: 1.5em,
) = {
  let serif-fonts = fonts-for-current-lang.serif

  // Horizontal anchors for Person 1 and Person 2
  let x1 = 112pt
  let x2 = 328pt

  // Vertical body geometry
  let y-head = 66pt
  let r-head = 36pt
  let y-neck = y-head + r-head // 102pt
  let y-shoulder = y-neck + 5pt // 107pt
  let y-hips = 175pt
  let y-ankle = 226pt

  // Transmission beam slope between Person 1's hand and Person 2's eye
  let beam-angle = -15.3deg

  // Dynamic curved arrow SVG matching arrow-color
  let curved-arrow-svg = image(
    bytes(
      `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 55 75" width="48" height="66">
    <path d="M 4 22 C 10 3, 44 2, 36 68"
          fill="none" stroke="`.text
        + arrow-color.to-hex()
        + `" stroke-width="3.2" stroke-linecap="round" />
      </svg>`.text,
    ),
  )

  // Helper: Place content centered at (x, y)
  let put-at(x, y, content) = {
    place(
      center + horizon,
      dx: x - width / 2,
      dy: y - height / 2,
      content,
    )
  }

  // Helper: Draw single line segment
  let draw-line(start, end, stroke: 2.4pt + black) = {
    place(top + left, line(start: start, end: end, stroke: stroke))
  }

  // Helper: Draw directional filled triangle arrowhead
  let draw-triangle-head(x, y, angle, len: 10.5pt, half-w: 4.8pt) = {
    let cos-a = calc.cos(angle)
    let sin-a = calc.sin(angle)
    let b1 = (x - len * cos-a - half-w * sin-a, y - len * sin-a + half-w * cos-a)
    let b2 = (x - len * cos-a + half-w * sin-a, y - len * sin-a - half-w * cos-a)
    place(top + left, polygon(fill: arrow-color, stroke: none, (x, y), b1, b2))
  }

  // Helper: Draw thick beam with optional dashes and arrowhead
  let draw-beam(start, end, dashed: false, with-head: false, angle: beam-angle) = {
    let stroke-style = (
      paint: arrow-color,
      thickness: 3.2pt,
      cap: "round",
      dash: if dashed { (7pt, 5pt) } else { none },
    )
    draw-line(start, end, stroke: stroke-style)
    if with-head {
      draw-triangle-head(end.at(0), end.at(1), angle)
    }
  }

  // Helper: Renders one stick figure with gesturing hand and facial expression
  let draw-person(x0, brain-label) = {
    // 1. Head circle
    place(
      top + left,
      dx: x0 - r-head,
      dy: y-head - r-head,
      circle(radius: r-head, stroke: 1.6pt + black, fill: white),
    )

    // 2. Forehead labels
    put-at(x0, y-head - 18pt, text(font: serif-fonts, weight: "bold", style: "italic", size: 11pt, t("Meme")))
    put-at(x0, y-head - 5pt, text(font: serif-fonts, size: 7.5pt, brain-label))

    // 3. Right-looking eyes
    let draw-eye(ex) = {
      let ey = y-head + 10pt
      place(top + left, dx: ex - 5.5pt, dy: ey - 5.5pt, circle(radius: 5.5pt, stroke: 1.2pt + black, fill: white))
      place(top + left, dx: ex - 1.2pt, dy: ey - 3.2pt, circle(radius: 3.2pt, fill: black))
    }
    draw-eye(x0 - 13pt)
    draw-eye(x0 + 16pt)

    // 4. Torso & Arms
    draw-line((x0, y-neck), (x0, y-hips)) // Torso
    draw-line((x0, y-shoulder), (x0 - 14pt, y-hips + 5pt), stroke: 2.3pt + black) // Left arm
    draw-line((x0, y-shoulder), (x0 + 32pt, y-shoulder + 18pt), stroke: 2.3pt + black) // Right upper arm
    draw-line((x0 + 32pt, y-shoulder + 18pt), (x0 + 49pt, y-shoulder + 3pt), stroke: 2.3pt + black) // Right forearm

    // 5. Gesticulating Hand
    place(top + left, dx: x0 + 47pt, dy: y-shoulder - 7pt, hand-svg)

    // 6. Legs & Feet
    draw-line((x0, y-hips), (x0 - 12pt, y-ankle)) // Left leg
    draw-line((x0 - 12pt, y-ankle), (x0 - 22pt, y-ankle), stroke: 3.4pt + black) // Left foot
    draw-line((x0, y-hips), (x0 + 12pt, y-ankle)) // Right leg
    draw-line((x0 + 12pt, y-ankle), (x0 + 22pt, y-ankle), stroke: 3.4pt + black) // Right foot

    // 7. Behaviour label below hand
    put-at(x0 + 64pt, y-shoulder + 30pt, text(
      font: serif-fonts,
      weight: "bold",
      style: "italic",
      size: 10.5pt,
      t("Behaviour"),
    ))

    // 8. Arched "Causes behaviour" arrow
    place(top + left, dx: x0 + 18pt, dy: 14pt, curved-arrow-svg)
    draw-triangle-head(x0 + 54pt, 82pt, 105deg, len: 9.5pt, half-w: 4.5pt)

    // 9. Labels arched along curved arrow
    put-at(x0 + 26pt, 17pt, rotate(18deg, text(font: serif-fonts, style: "italic", size: 7.5pt, t("Causes"))))
    put-at(x0 + 61pt, 43pt, rotate(-65deg, text(font: serif-fonts, style: "italic", size: 7.5pt, t("behaviour"))))
  }

  align(center)[
    #block(inset: (y: v-padding))[
      #box(width: width, height: height)[
        // 1. Incoming stimulus arrow
        #draw-beam((18pt, 92pt), (x1 - r-head, 76pt), dashed: true, with-head: true)

        // 2. Person 1 (left)
        #draw-person(x1, t("(in brain no. 1)"))

        // 3. Central observation beam (Person 1 hand -> Person 2 eye)
        #let p1-hand = (x1 + 68pt, y-shoulder - 3pt)
        #let p2-eye = (x2 - r-head, y-head + 10pt)
        #draw-beam(p1-hand, p2-eye, dashed: false, with-head: true)

        // 4. Slanted labels flanking the central beam
        #let mid-x = (p1-hand.at(0) + p2-eye.at(0)) / 2
        #let mid-y = (p1-hand.at(1) + p2-eye.at(1)) / 2
        #put-at(mid-x - 1pt, mid-y - 10.5pt, rotate(beam-angle, text(
          font: serif-fonts,
          style: "italic",
          size: 8pt,
          t("Which is observed"),
        )))
        #put-at(mid-x + 1pt, mid-y + 11.5pt, rotate(beam-angle, text(
          font: serif-fonts,
          style: "italic",
          size: 8pt,
          t("and copied"),
        )))

        // 5. Person 2 (right)
        #draw-person(x2, t("(in brain no. 2)"))

        // 6. Outgoing propagation arrow
        #draw-beam((x2 + 68pt, y-shoulder - 3pt), (width - 15pt, y-shoulder - 14pt), dashed: true, with-head: false)
      ]
    ]
  ]
}

// Default preview
#meme-transmission-diagram()
