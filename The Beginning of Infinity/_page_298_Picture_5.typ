#import "@preview/cetz:0.5.2": canvas, draw

#v(0.6em)
#align(center)[
  #canvas(length: 1cm, {
    import draw: *

    let ray-color = rgb("787d82")
    let stroke-style = (paint: ray-color, thickness: 5.5pt, cap: "round")
    let arrow-style = (end: "stealth", size: 0.38, fill: ray-color)

    let xc = -0.1
    let yc = -0.1
    let x-start = -1.15
    let x-end = 1.35
    let y-start = -1.2
    let y-end = 1.35
    let gap = 0.02

    // Top-left deflecting ray: incoming horizontal from left, bends up to top
    let x-bend = xc - gap
    let y-bend = yc + gap
    bezier(
      (x-start, y-bend), (x-bend, y-end),
      (x-bend - 0.1, y-bend), (x-bend, y-bend + 0.1),
      stroke: stroke-style,
      mark: arrow-style,
    )

    // Bottom-right deflecting ray: incoming vertical from bottom, bends right to horizontal
    let xb2 = xc + gap
    let yb2 = yc - gap
    bezier(
      (xb2, y-start), (x-end, yb2),
      (xb2, yb2 - 0.1), (xb2 + 0.1, yb2),
      stroke: stroke-style,
      mark: arrow-style,
    )
  })
]
#v(0.6em)
