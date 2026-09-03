#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n

// Initialize translator
#let t = load-i18n("_page_296_Picture_1.i18n.yml")

/// Renders the beam-splitter single photon path splitting diagram
#let photon-beam-splitter(
  width: 210pt,
  height: 140pt,
  beam-color: rgb("#868a90"),
  mirror-color: rgb("#72767c"),
  text-color: rgb("#222428"),
  stroke-width: 1.2pt,
  font-size: 11pt,
  v-padding: 1.5em,
) = {
  let serif-fonts = fonts-for-current-lang.serif

  // Anchor coordinates
  let x-bs = 108pt // Center of beam splitter
  let y-bs = 38pt
  let x-start = 12pt
  let x-end = 196pt
  let y-end = 134pt

  // Helper: Open "vee" wireframe arrowhead
  let draw-arrowhead(x, y, dir: "right") = {
    let (dx, dy) = if dir == "right" { (6.2pt, 2.8pt) } else { (2.8pt, 6.2pt) }
    let (b1, b2) = if dir == "right" {
      ((x - dx, y - dy), (x - dx, y + dy))
    } else {
      ((x - dx, y - dy), (x + dx, y - dy))
    }
    place(top + left, line(start: b1, end: (x, y), stroke: (paint: beam-color, thickness: stroke-width, cap: "round")))
    place(top + left, line(start: b2, end: (x, y), stroke: (paint: beam-color, thickness: stroke-width, cap: "round")))
  }

  // Helper: Draw solid or dotted beam line
  let draw-beam(start, end, dotted: false) = {
    let stroke-style = (
      paint: beam-color,
      thickness: stroke-width,
      cap: "round",
      dash: if dotted { (0.5pt, 2.5pt) } else { none },
    )
    place(top + left, line(start: start, end: end, stroke: stroke-style))
  }

  // Helper: Place label centered at canvas coordinate (x, y)
  let place-label(x, y, content, font: serif-fonts, size: font-size) = {
    place(
      center + horizon,
      dx: x - width / 2,
      dy: y - height / 2,
      text(font: serif-fonts, size: size, fill: text-color, content),
    )
  }

  align(center)[
    #block(inset: (y: v-padding))[
      #box(width: width, height: height)[
        // 1. Incoming Beam (solid) & Arrowhead
        #draw-beam((x-start, y-bs), (x-bs - 3.5pt, y-bs), dotted: false)
        #draw-arrowhead(x-bs - 3.5pt, y-bs, dir: "right")

        // 2. Transmitted Beam X (dotted) & Arrowhead
        #draw-beam((x-bs, y-bs), (x-end, y-bs), dotted: true)
        #draw-arrowhead(x-end, y-bs, dir: "right")

        // 3. Reflected Beam Y (dotted) & Arrowhead
        #draw-beam((x-bs, y-bs), (x-bs, y-end), dotted: true)
        #draw-arrowhead(x-bs, y-end, dir: "down")

        // 4. Semi-silvered Mirror (angled at 45 degrees)
        #place(
          center + horizon,
          dx: x-bs - width / 2,
          dy: y-bs - height / 2,
          rotate(
            45deg,
            rect(
              width: 36pt,
              height: 5.2pt,
              fill: mirror-color,
              stroke: none,
              radius: 0.4pt,
            ),
          ),
        )

        // 5. Labels: "Photon" above line, "in" below line
        #place-label(52pt, y-bs - 7pt, t("Photon"))
        #place-label(52pt, y-bs + 7pt, t("in"))

        // 6. Math variable labels: X and Y
        #place-label(172pt, y-bs - 9pt, [$X$], font: (), size: font-size + 0.5pt)
        #place-label(x-bs + 10pt, y-end - 15pt, [$Y$], font: (), size: font-size + 0.5pt)
      ]
    ]
  ]
}

// Default preview
#photon-beam-splitter()
