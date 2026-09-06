#import "@preview/cetz:0.5.2": canvas, draw

#v(0.6em)
#align(center)[
  #canvas(length: 1cm, {
    import draw: *

    let ray-color = rgb("787d82")
    let stroke-style = (paint: ray-color, thickness: 5.5pt, cap: "round")
    let arrow-style = (end: "stealth", size: 0.38, fill: ray-color)

    let xc = -0.2
    let yc = -0.2
    let x-start = -1.15
    let x-end = 1.35
    let y-start = -1.2
    let y-end = 1.35

    // --- Straight crossing rays ---
    line(
      (x-start, yc), (x-end, yc),
      stroke: stroke-style,
      mark: arrow-style,
    )

    line(
      (xc, y-start), (xc, y-end),
      stroke: stroke-style,
      mark: arrow-style,
    )

    // --- Superposed deflecting paths (fillets) ---
    bezier(
      (xc - 0.7, yc), (xc, yc + 0.7),
      (xc - 0.15, yc), (xc, yc + 0.15),
      stroke: (paint: ray-color, thickness: 5.5pt, cap: "butt"),
    )

    bezier(
      (xc, yc - 0.7), (xc + 0.7, yc),
      (xc, yc - 0.15), (xc + 0.15, yc),
      stroke: (paint: ray-color, thickness: 5.5pt, cap: "butt"),
    )
  })
]
#v(0.6em)
