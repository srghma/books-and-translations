#import "@preview/cetz:0.5.2": canvas, draw
#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n

#let t = load-i18n("_page_297_Picture_1.i18n.yml")

#v(0.6em)
#align(center)[
  #canvas(length: 0.95cm, {
    import draw: *

    let ray-color = rgb("7c8186")
    let semi-mirror = rgb("7a808580")
    let full-mirror = rgb("222428")
    let faint-color = rgb("b5b8bd")

    let arrow-style = (end: ">", size: 0.35, stroke: 1.8pt + ray-color, fill: none)

    let mirror-thickness = 8pt
    let off = (mirror-thickness / 2) / 0.95cm / calc.sqrt(2)

    // --- Helper function for mirrors ---
    let draw-mirror(x, y, color, dx: 0, dy: 0) = {
      let mx = x + dx
      let my = y + dy
      line(
        (mx - 0.5, my + 0.5),
        (mx + 0.5, my - 0.5),
        stroke: (paint: color, thickness: mirror-thickness, cap: "butt"),
      )
    }

    // --- Interferometer loop rays (dotted with mid-arrows) ---
    // Top arm (X)
    line((0, 3), (1.5, 3), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"), mark: arrow-style)
    line((1.5, 3), (3, 3), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"))

    // Left arm (Y)
    line((0, 3), (0, 1.5), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"), mark: arrow-style)
    line((0, 1.5), (0, 0), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"))

    // Bottom arm
    line((0, 0), (1.5, 0), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"), mark: arrow-style)
    line((1.5, 0), (3, 0), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"))

    // Right arm
    line((3, 3), (3, 1.5), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"), mark: arrow-style)
    line((3, 1.5), (3, 0), stroke: (paint: ray-color, thickness: 1.8pt, dash: "densely-dotted"))

    // --- Incoming ray ---
    line(
      (-2.5, 3),
      (0, 3),
      stroke: (paint: ray-color, thickness: 1.8pt),
      mark: arrow-style,
    )

    // --- Outgoing rays ---
    // Horizontal (Photon out)
    line(
      (3, 0),
      (5.5, 0),
      stroke: (paint: ray-color, thickness: 1.8pt),
      mark: arrow-style,
    )

    // Vertical downward (faint: nothing out)
    line(
      (3, 0),
      (3, -1.0),
      stroke: (paint: faint-color, thickness: 1pt),
    )

    // --- Mirrors (drawn on top of rays) ---
    draw-mirror(0, 3, semi-mirror, dx: off, dy: off) // Top-Left (semi-silvered)
    draw-mirror(3, 3, full-mirror, dx: off, dy: off) // Top-Right (fully silvered)
    draw-mirror(0, 0, full-mirror, dx: -off, dy: -off) // Bottom-Left (fully silvered)
    draw-mirror(3, 0, semi-mirror, dx: off, dy: off) // Bottom-Right (semi-silvered)

    // --- Labels ---
    // Input
    content((-1.5, 3.4), text(font: fonts-for-current-lang.serif, size: 10.5pt)[#t("Photon")])
    content((-1.5, 2.6), text(font: fonts-for-current-lang.serif, size: 10.5pt)[#t("in")])

    // Arm labels
    content((1.5, 3.4), text(size: 11pt, style: "italic")[$X$])
    content((-0.4, 1.5), text(size: 11pt, style: "italic")[$Y$])

    // Output
    content((4.1, 0.4), text(font: fonts-for-current-lang.serif, size: 10.5pt)[#t("Photon")])
    content((4.1, -0.4), text(font: fonts-for-current-lang.serif, size: 10.5pt)[#t("out")])

    // Nothing out label
    content((3.0, -1.35), text(font: fonts-for-current-lang.serif, size: 10pt, fill: faint-color, style: "italic")[#t(
      "(nothing out)",
    )])
  })
]
#v(0.6em)
