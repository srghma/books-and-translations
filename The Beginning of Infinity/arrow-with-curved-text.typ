#import "@preview/cetz:0.5.2": canvas, draw

#let arrow-with-curved-text(
  start,
  end,
  label: "",

  // Curve geometry
  bend: 50pt,
  ctrl1: none,
  ctrl2: none,

  // Text placement along the curve
  text-position: 0.5,
  text-offset: 4pt,
  text-anchor: "south",

  // Typography
  font: "New Computer Modern",
  font-size: 11pt,
  font-style: "italic",
  font-weight: "regular",
  letter-spacing: 0.5pt,
  text-color: auto,

  // Arrow styling
  color: rgb("#a4a9af"),
  thickness: 3.2pt,
  stroke-cap: "round",
  arrow-mark: "triangle",
  arrow-length: 9pt,
  arrow-width: 7.5pt,
  arrow-fill: auto,

  // Layout & sampling
  samples: 80,
  overlay: false,

  // Accepts legacy aliases like `text: ...` or `label-pos: ...`
  ..sink,
) = {
  // Resolve legacy parameter aliases if provided
  let label-val = if "text" in sink.named() { sink.named().at("text") } else { label }
  let pos-ratio = if "label-pos" in sink.named() { sink.named().at("label-pos") } else { text-position }
  let f-size-val = if "label-size" in sink.named() { sink.named().at("label-size") } else { font-size }
  let l-spacing-val = if "tracking" in sink.named() {
    sink.named().at("tracking")
  } else if "spacing" in sink.named() {
    sink.named().at("spacing")
  } else {
    letter-spacing
  }
  let actual-text-color = if "text-color" in sink.named() {
    sink.named().at("text-color")
  } else if text-color != auto {
    text-color
  } else {
    color
  }

  let to-pt(v) = if type(v) == length { v / 1pt } else { float(v) }

  let sx = to-pt(start.at(0))
  let sy = to-pt(start.at(1))
  let ex = to-pt(end.at(0))
  let ey = to-pt(end.at(1))
  let b = to-pt(bend)
  let t-offset = to-pt(text-offset)
  let f-size = to-pt(f-size-val)
  let l-spacing = to-pt(l-spacing-val)

  let dx = ex - sx
  let dy = ey - sy
  let chord-len = calc.sqrt(dx * dx + dy * dy)
  if chord-len == 0.0 { return [] }

  // Unit tangent (u) and left-normal (n) in screen coordinates (+y down)
  let ux = dx / chord-len
  let uy = dy / chord-len
  let nx = uy
  let ny = -ux

  // Bézier control points in screen coordinates
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

  // Bounding box with margin
  let pad = calc.max(20.0, f-size * 2.0 + calc.abs(t-offset))
  let min-x = calc.min(sx, ex, c1x, c2x) - pad
  let min-y = calc.min(sy, ey, c1y, c2y) - pad

  // Convert screen coordinates (+y down) to CeTZ canvas coordinates (+y up)
  let to-canvas(x, y) = (x - min-x, -(y - min-y))

  let p0 = to-canvas(sx, sy)
  let p1 = to-canvas(c1x, c1y)
  let p2 = to-canvas(c2x, c2y)
  let p3 = to-canvas(ex, ey)

  // Cubic Bézier position and derivative
  let b-pt(t) = {
    let u = 1.0 - t
    (
      u * u * u * p0.at(0) + 3.0 * u * u * t * p1.at(0) + 3.0 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
      u * u * u * p0.at(1) + 3.0 * u * u * t * p1.at(1) + 3.0 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
    )
  }

  let b-deriv(t) = {
    let u = 1.0 - t
    (
      3.0 * u * u * (p1.at(0) - p0.at(0)) + 6.0 * u * t * (p2.at(0) - p1.at(0)) + 3.0 * t * t * (p3.at(0) - p2.at(0)),
      3.0 * u * u * (p1.at(1) - p0.at(1)) + 6.0 * u * t * (p2.at(1) - p1.at(1)) + 3.0 * t * t * (p3.at(1) - p2.at(1)),
    )
  }

  // Pre-sample cumulative arc-length
  let cum-dist = (0.0,)
  let prev = b-pt(0.0)
  let total-len = 0.0

  for i in range(1, samples + 1) {
    let t = i / samples
    let p = b-pt(t)
    let d = calc.sqrt(calc.pow(p.at(0) - prev.at(0), 2) + calc.pow(p.at(1) - prev.at(1), 2))
    total-len += d
    cum-dist.push(total-len)
    prev = p
  }

  let t-from-dist(d) = {
    let clamped = calc.max(0.0, calc.min(total-len, d))
    let idx = 0
    while idx < samples and cum-dist.at(idx + 1) < clamped {
      idx += 1
    }
    if idx >= samples { return 1.0 }
    let d0 = cum-dist.at(idx)
    let d1 = cum-dist.at(idx + 1)
    let f = if d1 > d0 { (clamped - d0) / (d1 - d0) } else { 0.0 }
    (idx + f) / samples
  }

  // Context required for accurate font glyph measurement
  context {
    let label-str = if type(label-val) == str {
      label-val
    } else if type(label-val) == content and label-val.has("text") {
      label-val.text
    } else if label-val == none {
      ""
    } else {
      repr(label-val)
    }

    let chars = label-str.clusters()
    let widths = chars.map(c => {
      (
        measure(
          std.text(
            font: font,
            size: f-size * 1pt,
            style: font-style,
            weight: font-weight,
            c,
          ),
        ).width
          / 1pt
      )
    })

    let total-text-w = widths.fold(0.0, (a, b) => a + b) + calc.max(0, chars.len() - 1) * l-spacing
    let cursor = pos-ratio * total-len - total-text-w / 2.0

    let c = canvas(length: 1pt, {
      // 1. Draw Bézier curve with arrow tip
      draw.bezier(
        p0,
        p3,
        p1,
        p2,
        stroke: (
          paint: color,
          thickness: thickness,
          cap: stroke-cap,
        ),
        mark: (
          end: arrow-mark,
          fill: if arrow-fill != auto { arrow-fill } else { color },
          stroke: none,
          length: arrow-length,
          width: arrow-width,
        ),
      )

      // 2. Draw curved text along tangent
      for i in range(chars.len()) {
        let ch = chars.at(i)
        let cw = widths.at(i)
        let mid-dist = cursor + cw / 2.0
        let t = t-from-dist(mid-dist)

        let pt = b-pt(t)
        let deriv = b-deriv(t)
        let dlen = calc.sqrt(deriv.at(0) * deriv.at(0) + deriv.at(1) * deriv.at(1))

        if dlen > 0.0 and ch != " " {
          // Tangent angle in Typst calc.atan2(x, y)
          let angle = calc.atan2(deriv.at(0), deriv.at(1))

          // Normal vector pointing away (+y in CeTZ canvas)
          let normal = (-deriv.at(1) / dlen, deriv.at(0) / dlen)
          let pos = (
            pt.at(0) + t-offset * normal.at(0),
            pt.at(1) + t-offset * normal.at(1),
          )

          draw.content(
            pos,
            angle: angle,
            anchor: text-anchor,
            std.text(
              font: font,
              size: f-size * 1pt,
              style: font-style,
              weight: font-weight,
              fill: actual-text-color,
              ch,
            ),
          )
        }
        cursor += cw + l-spacing
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
}

// #set page(width: auto, height: auto, margin: 25pt)
//
// #arrow-with-curved-text(
//   (0pt, 0pt),
//   (280pt, 0pt),
//   bend: 45pt,
//   label: "Causes behaviour",
//   font: "New Computer Modern",
//   font-size: 11pt,
// )
//
// #arrow-with-curved-text(
//   (20pt, 80pt),
//   (200pt, 20pt),
//   bend: 35pt,
//   label: "Feedback loop",
//   color: rgb("#4a6fa5"),
//   font-size: 10pt,
// )
//
// #box(width: 140pt, height: 110pt, stroke: 0.5pt + luma(200))[
//   // Icon A at (29pt, 19.5pt)
//   // Icon B at (68pt, 62pt)
//   #arrow-with-curved-text(
//     (29pt, 19.5pt),
//     (68pt, 62pt),
//     bend: 25pt,
//     label: "Causes behaviour",
//     font-size: 8pt,
//     thickness: 2pt,
//     overlay: true,
//   )
// ]

// TODO: maybe better https://github.com/cetz-package/cetz/issues/395#issuecomment-2201321936
