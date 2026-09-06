#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#import "arrow-with-curved-text.typ": arrow-with-curved-text
#import "arrow-with-text-above-and-below-in-the-middle.typ": arrow-with-text-above-and-below
#import "dashed.typ": dashed-line, dashed-arrow

// Initialize translator
#let t = load-i18n("_page_386_Diagram_2.i18n.yml")

/// Renders the Meme Transmission & Imitation Cycle diagram using the traced human vector figure
#let meme-transmission-diagram(
  width: 370pt,
  height: 172pt,
  human-height: 165pt,
  arrow-color: rgb("#a4a9af"),
  v-padding: 0em,
) = {
  let serif-fonts = fonts-for-current-lang.serif

  // Calculate SVG scale factor from native viewBox (93.44 x 158.72)
  let s = human-height / 158.72pt
  let human-width = 93.44pt * s

  // Person 1 and Person 2 placement anchors
  let (x1, y1) = (54pt, 18pt)
  let (x2, y2) = (214pt, 18pt)

  // Anchors relative to SVG human coordinates
  let p1-hand = (x1 + 109pt * s, y1 + 75pt * s)
  let p2-eye = (x2 + 40pt * s, y2 + 56pt * s)
  let p1-eye = (x1 + 18pt * s, y1 + 50pt * s)
  let p2-hand = (x2 + 100pt * s, y2 + 69pt * s)

  // Transmission beam slope
  let beam-dx = (p2-eye.at(0) - p1-hand.at(0)) / 1pt
  let beam-dy = (p2-eye.at(1) - p1-hand.at(1)) / 1pt
  let slope = beam-dy / beam-dx

  // --- Helper: Single person unit with parametric anchors ---
  let person-unit(brain-label) = box(width: human-width + 20pt, height: human-height + 15pt)[
    // 1. Vector human stick figure
    #place(top + left, image(
      "_page_386_Diagram_2_human.svg",
      width: human-width,
      height: human-height,
    ))

    // 2. Parametric curved "Causes behaviour" arrow anchored directly between brain and hand
    #{
      let brain-start = (76pt * s, 29.5pt * s)
      let hand-end = (100pt * s, 72pt * s)

      let sx = brain-start.at(0) / 1pt
      let sy = brain-start.at(1) / 1pt
      let ex = hand-end.at(0) / 1pt
      let ey = hand-end.at(1) / 1pt

      let dx = ex - sx
      let dy = ey - sy
      let arch-h = calc.max(16.0, dy * 0.36)
      let y-peak = sy - arch-h

      let c1 = (sx + 0.22 * dx, y-peak)
      let c2 = (ex + 0.48 * dx, y-peak)

      arrow-with-curved-text(
        brain-start,
        hand-end,
        ctrl1: c1,
        ctrl2: c2,
        label: t("Causes behaviour"),
        font: serif-fonts,
        font-size: 9.5pt,
        font-style: "italic",
        text-color: black,
        letter-spacing: 0pt,
        color: arrow-color,
        thickness: 3.2pt,
        arrow-length: 9pt,
        arrow-width: 7.5pt,
        text-position: 0.44,
        text-offset: 4pt,
        overlay: true,
      )
    }

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
    #box(width: width, height: height)[
      // 1. Incoming beam to Person 1 (dashed line with arrowhead into eye)
      #let p1-start = (
        32pt,
        p1-eye.at(1) + (12pt - p1-eye.at(0)) * slope,
      )
      #dashed-arrow(
        p1-start,
        p1-eye,
        dash: (9pt, 6pt),
        color: arrow-color,
        thickness: 3.2pt,
        arrow-length: 9pt,
        arrow-width: 7.5pt,
        overlay: true,
      )

      // 2. Person 1 (left)
      #place(top + left, dx: x1 - 10pt, dy: y1 - 7.5pt, person-unit(t("(in brain no. 1)")))

      // 3. Central observation beam: Person 1's hand -> Person 2's eye (solid arrow with labels)
      #arrow-with-text-above-and-below(
        p1-hand,
        p2-eye,
        label-above: t("Which is observed"),
        label-below: t("and copied"),
        font: serif-fonts,
        font-size: 8pt,
        font-style: "italic",
        text-color: black,
        color: arrow-color,
        thickness: 3.2pt,
        arrow-length: 9pt,
        arrow-width: 7.5pt,
        offset-above: 6pt,
        offset-below: 6pt,
        overlay: true,
      )

      // 4. Person 2 (right)
      #place(top + left, dx: x2 - 10pt, dy: y2 - 7.5pt, person-unit(t("(in brain no. 2)")))

      // 5. Outgoing beam from Person 2 (dashed line continuing out from hand)
      #let p2-end = (
        width - 15pt,
        p2-hand.at(1) + (width - 15pt - p2-hand.at(0)) * slope,
      )
      #dashed-line(
        p2-hand,
        p2-end,
        dash: (9pt, 6pt),
        color: arrow-color,
        thickness: 3.2pt,
        overlay: true,
      )
    ]
  ]
}

// Default preview
#meme-transmission-diagram()