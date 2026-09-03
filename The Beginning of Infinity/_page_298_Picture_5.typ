#import "@preview/cetz:0.5.2"

#let curved-cross(
  length: 1.8, // Distance from center to arrow tip / tail
  gap: 0.08, // Offset away from center (controls the spacing between curves)
  bend: 0.1, // Curvature control distance (higher = wider curve, lower = sharper)
  thickness: 7.5pt, // Stroke thickness
  color: rgb("86898e"),
  mark-size: 0.35,
  mark-type: "triangle",
) = {
  cetz.canvas({
    import cetz.draw: *

    let stroke-style = (paint: color, thickness: thickness, cap: "round")
    let mark-style = (end: mark-type, fill: color, size: mark-size)

    // Base curve: starts left, bends upwards
    let base = (
      start: (-length, -gap),
      end: (-gap, length),
      ctrl1: (-bend, -gap),
      ctrl2: (-gap, bend),
    )

    // Second curve: reflected across the diagonal y = x: (x, y) -> (y, x)
    let reflect(pt) = (pt.at(1), pt.at(0))

    let reflected = (
      start: reflect(base.start),
      end: reflect(base.end),
      ctrl1: reflect(base.ctrl1),
      ctrl2: reflect(base.ctrl2),
    )

    for c in (base, reflected) {
      bezier(
        c.start,
        c.end,
        c.ctrl1,
        c.ctrl2,
        stroke: stroke-style,
        mark: mark-style,
      )
    }
  })
}

// Default (matches your image)
#curved-cross()
