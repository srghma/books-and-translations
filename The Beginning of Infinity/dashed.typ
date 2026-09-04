#import "@preview/cetz:0.5.2": canvas, draw

#let dashed-line(
  start,
  end,

  // Dash & stroke
  dash: "dashed",
  color: rgb("#a4a9af"),
  thickness: 2pt,
  stroke-cap: "round",

  // Curvature (0pt = straight line)
  bend: 0pt,
  ctrl1: none,
  ctrl2: none,

  // Optional label
  label: none,
  label-pos: 0.5,
  label-offset: 4pt,
  label-anchor: "south",
  font: "New Computer Modern",
  font-size: 10pt,
  font-style: "normal",
  font-weight: "regular",

  overlay: false,
) = {
  let to-pt(v) = if type(v) == length { v / 1pt } else { float(v) }

  let sx = to-pt(start.at(0))
  let sy = to-pt(start.at(1))
  let ex = to-pt(end.at(0))
  let ey = to-pt(end.at(1))
  let b = to-pt(bend)

  let dx = ex - sx
  let dy = ey - sy
  let chord-len = calc.sqrt(dx * dx + dy * dy)
  if chord-len == 0.0 { return [] }

  let ux = dx / chord-len
  let uy = dy / chord-len
  let nx = uy
  let ny = -ux

  let (c1x, c1y) = if ctrl1 != none {
    (to-pt(ctrl1.at(0)), to-pt(ctrl1.at(1)))
  } else {
    (sx + 0.25 * dx + nx * b, sy + 0.25 * dy + ny * b)
  }

  let (c2x, c2y) = if ctrl2 != none {
    (to-pt(ctrl2.at(0)), to-pt(ctrl2.at(1)))
  } else {
    (ex - 0.25 * dx + nx * b, ey - 0.25 * dy + ny * b)
  }

  let pad = 20.0
  let min-x = calc.min(sx, ex, c1x, c2x) - pad
  let min-y = calc.min(sy, ey, c1y, c2y) - pad

  let to-canvas(x, y) = (x - min-x, -(y - min-y))

  let p0 = to-canvas(sx, sy)
  let p1 = to-canvas(c1x, c1y)
  let p2 = to-canvas(c2x, c2y)
  let p3 = to-canvas(ex, ey)

  let c = canvas(length: 1pt, {
    if b == 0.0 and ctrl1 == none and ctrl2 == none {
      draw.line(
        p0,
        p3,
        stroke: (
          paint: color,
          thickness: thickness,
          cap: stroke-cap,
          dash: dash,
        ),
      )
    } else {
      draw.bezier(
        p0,
        p3,
        p1,
        p2,
        stroke: (
          paint: color,
          thickness: thickness,
          cap: stroke-cap,
          dash: dash,
        ),
      )
    }

    if label != none and label != "" {
      let mx = (p0.at(0) + p3.at(0)) / 2.0
      let my = (p0.at(1) + p3.at(1)) / 2.0
      draw.content(
        (mx, my + to-pt(label-offset)),
        anchor: label-anchor,
        std.text(
          font: font,
          size: font-size,
          style: font-style,
          weight: font-weight,
          fill: color,
          label,
        ),
      )
    }
  })

  if overlay {
    place(
      top + left,
      dx: min-x * 1pt,
      dy: min-y * 1pt,
      c,
    )
  } else {
    c
  }
}

#let dashed-arrow(
  start,
  end,

  // Dash & stroke
  dash: "dashed",
  color: rgb("#a4a9af"),
  thickness: 2.2pt,
  stroke-cap: "round",

  // Curvature
  bend: 0pt,
  ctrl1: none,
  ctrl2: none,

  // Arrowhead tip
  arrow-mark: "triangle",
  arrow-length: 8pt,
  arrow-width: 6.5pt,
  arrow-fill: auto,
  arrow-end: true,
  arrow-start: false,

  // Optional label
  label: none,
  label-pos: 0.5,
  label-offset: 4pt,
  label-anchor: "south",
  font: "New Computer Modern",
  font-size: 10pt,
  font-style: "normal",
  font-weight: "regular",

  overlay: false,
) = {
  let to-pt(v) = if type(v) == length { v / 1pt } else { float(v) }

  let sx = to-pt(start.at(0))
  let sy = to-pt(start.at(1))
  let ex = to-pt(end.at(0))
  let ey = to-pt(end.at(1))
  let b = to-pt(bend)

  let dx = ex - sx
  let dy = ey - sy
  let chord-len = calc.sqrt(dx * dx + dy * dy)
  if chord-len == 0.0 { return [] }

  let ux = dx / chord-len
  let uy = dy / chord-len
  let nx = uy
  let ny = -ux

  let (c1x, c1y) = if ctrl1 != none {
    (to-pt(ctrl1.at(0)), to-pt(ctrl1.at(1)))
  } else {
    (sx + 0.25 * dx + nx * b, sy + 0.25 * dy + ny * b)
  }

  let (c2x, c2y) = if ctrl2 != none {
    (to-pt(ctrl2.at(0)), to-pt(ctrl2.at(1)))
  } else {
    (ex - 0.25 * dx + nx * b, ey - 0.25 * dy + ny * b)
  }

  let pad = 20.0
  let min-x = calc.min(sx, ex, c1x, c2x) - pad
  let min-y = calc.min(sy, ey, c1y, c2y) - pad

  let to-canvas(x, y) = (x - min-x, -(y - min-y))

  let p0 = to-canvas(sx, sy)
  let p1 = to-canvas(c1x, c1y)
  let p2 = to-canvas(c2x, c2y)
  let p3 = to-canvas(ex, ey)

  let mark-config = (
    end: if arrow-end { arrow-mark } else { none },
    start: if arrow-start { arrow-mark } else { none },
    fill: if arrow-fill != auto { arrow-fill } else { color },
    stroke: none,
    length: arrow-length,
    width: arrow-width,
  )

  let c = canvas(length: 1pt, {
    if b == 0.0 and ctrl1 == none and ctrl2 == none {
      draw.line(
        p0,
        p3,
        stroke: (
          paint: color,
          thickness: thickness,
          cap: stroke-cap,
          dash: dash,
        ),
        mark: mark-config,
      )
    } else {
      draw.bezier(
        p0,
        p3,
        p1,
        p2,
        stroke: (
          paint: color,
          thickness: thickness,
          cap: stroke-cap,
          dash: dash,
        ),
        mark: mark-config,
      )
    }

    if label != none and label != "" {
      let mx = (p0.at(0) + p3.at(0)) / 2.0
      let my = (p0.at(1) + p3.at(1)) / 2.0
      draw.content(
        (mx, my + to-pt(label-offset)),
        anchor: label-anchor,
        std.text(
          font: font,
          size: font-size,
          style: font-style,
          weight: font-weight,
          fill: color,
          label,
        ),
      )
    }
  })

  if overlay {
    place(
      top + left,
      dx: min-x * 1pt,
      dy: min-y * 1pt,
      c,
    )
  } else {
    c
  }
}
