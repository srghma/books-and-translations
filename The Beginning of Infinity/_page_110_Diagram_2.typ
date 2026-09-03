#import "@preview/cetz:0.5.2"
#import cetz.draw: content, group, line, rect, rotate
#import "i18n.typ": current-lang, load-i18n

// Initialize translator for this diagram
#let t = load-i18n("_page_110_Diagram_2.i18n.yml")

#let text-1 = t("With one constant,\n20% of the choices\nare within 10% of\nthe boundary.")
#let text-2 = t("With two constants,\n36% of them are.")
#let text-3 = t("With three constants,\nit's 48.8%.")
#let text-100 = t("With 100 constants,\nit's over 99.9999999%.")

// ==========================================
// Reusable 1: Callout Bubble
// ==========================================
#let draw-callout(
  pos,
  width,
  height,
  body,
  radius: 0.22,
  stroke: 0.85pt + black,
  fill: white,
) = {
  rect(
    (pos.at(0) - width / 2, pos.at(1) - height / 2),
    (pos.at(0) + width / 2, pos.at(1) + height / 2),
    radius: radius,
    stroke: stroke,
    fill: fill,
  )
  content(pos, box(
    width: width * 1cm - 12pt,
    height: height * 1cm - 6pt,
    align(left + horizon)[
      #set par(leading: 0.35em, justify: false)
      #body
    ],
  ))
}

// ==========================================
// Reusable 2: Indicator Arrow
// ==========================================
#let draw-arrow(
  from,
  to,
  stroke: 0.7pt + black,
  mark-size: 0.18,
) = {
  line(
    from,
    to,
    stroke: stroke,
    mark: (end: "triangle", fill: stroke.paint, size: mark-size),
  )
}

// ==========================================
// Reusable 3: 1D Axis with Bounds
// ==========================================
#let draw-1d(
  center: (2.4, 3.4),
  axis-length: 3.8,
  bounds-length: 2.5,
  inner-ratio: 0.8,
  bar-height: 0.22,
  tick-height: 0.36,
  stroke: 0.75pt + black,
  fill: rgb("73767c"),
) = {
  let (cx, cy) = center
  let half-axis = axis-length / 2
  let half-bounds = bounds-length / 2
  let half-inner = half-bounds * inner-ratio
  let th = tick-height / 2
  let bh = bar-height / 2

  // Axis line
  line((cx - half-axis, cy), (cx + half-axis, cy), stroke: 0.6pt + stroke.paint)
  // Boundary ticks
  line((cx - half-bounds, cy - th), (cx - half-bounds, cy + th), stroke: stroke)
  line((cx + half-bounds, cy - th), (cx + half-bounds, cy + th), stroke: stroke)
  // Inner solid bar (80%)
  rect((cx - half-inner, cy - bh), (cx + half-inner, cy + bh), fill: fill, stroke: none)
}

// ==========================================
// Reusable 4: 2D Rotated Squares
// ==========================================
#let draw-2d(
  center: (6.2, 2.7),
  size: 2.3,
  inner-ratio: 0.8,
  angle: 7deg,
  stroke: 0.75pt + black,
  fill: rgb("73767c"),
) = {
  let half-out = size / 2
  let half-in = half-out * inner-ratio

  group({
    rotate(angle, origin: center)
    let (cx, cy) = center
    // Outer square
    rect((cx - half-out, cy - half-out), (cx + half-out, cy + half-out), stroke: stroke, fill: white)
    // Inner solid square (80%)
    rect((cx - half-in, cy - half-in), (cx + half-in, cy + half-in), fill: fill, stroke: none)
  })
}

// ==========================================
// Reusable 5: 3D Axonometric Cube
// ==========================================
// Rotated ~30deg so the front-right vertical edge is closest to viewer,
// creating a broad, readable front-left face and narrower right side.
#let draw-3d(
  center: (9.8, 2.0),
  width: 2.35,
  inner-ratio: 0.8,
  stroke: 0.75pt + black,
  mid-fill: rgb("73767c"),
  dark-fill: rgb("505358"),
) = {
  let (cx, cy) = center
  let h = width

  let norm(u, v) = (
    cx + (u - 0.5) * width,
    cy + (v - 0.5) * h,
  )

  // 8 outer vertices - symmetric left/right, no visible top face:
  // the top/bottom "ridge" vertices sit on the vertical centerline,
  // so only the left and right faces of the inner cube are seen.
  let p-fb = norm(0.5, 0.0)
  let p-lb = norm(0.0, 0.15)
  let p-rb = norm(1.0, 0.15)
  let p-bb = norm(0.5, 0.30)

  let p-ft = norm(0.5, 0.70)
  let p-lt = norm(0.0, 0.85)
  let p-rt = norm(1.0, 0.85)
  let p-bt = norm(0.5, 1.00)

  let r = inner-ratio
  let scale-pt(p) = (cx + r * (p.at(0) - cx), cy + r * (p.at(1) - cy))

  let ip-fb = scale-pt(p-fb)
  let ip-lb = scale-pt(p-lb)
  let ip-rb = scale-pt(p-rb)

  let ip-ft = scale-pt(p-ft)
  let ip-lt = scale-pt(p-lt)
  let ip-rt = scale-pt(p-rt)

  // 1. Back wireframe edges (outer transparent box outline)
  line(p-bb, p-bt, stroke: stroke)
  line(p-bb, p-lb, stroke: stroke)
  line(p-bb, p-rb, stroke: stroke)
  line(p-bt, p-lt, stroke: stroke)
  line(p-bt, p-rt, stroke: stroke)

  // 2. Inner solid cube - only the two front-facing sides are visible
  // (no top face), meeting along the centered front edge.
  // Left face (medium grey)
  line(ip-fb, ip-lb, ip-lt, ip-ft, close: true, fill: mid-fill, stroke: none)
  // Right face (dark grey in shadow)
  line(ip-fb, ip-rb, ip-rt, ip-ft, close: true, fill: dark-fill, stroke: none)

  // 3. Front wireframe edges
  line(p-fb, p-ft, stroke: stroke) // front vertical edge
  line(p-lb, p-lt, stroke: stroke) // left vertical edge
  line(p-rb, p-rt, stroke: stroke) // right vertical edge
  line(p-fb, p-lb, stroke: stroke)
  line(p-fb, p-rb, stroke: stroke)
  line(p-ft, p-lt, stroke: stroke)
  line(p-ft, p-rt, stroke: stroke)
}

// ==========================================
// Main Diagram Function
// ==========================================
#let boundary-constants-diagram(
  scale: 1.0,
  font-size: 7.2pt,
  font: ("Liberation Sans", "Arial", "Noto Sans Khmer"),
) = {
  align(center)[
    #set text(font: font, size: font-size)
    #cetz.canvas(length: 1cm * scale, {
      // 1. Geometric Shapes
      draw-1d()
      draw-2d()
      draw-3d()

      // 2. Callouts
      draw-callout((2.0, 5.35), 3.0, 1.55, text-1)
      draw-callout((5.7, 4.95), 3.0, 1.1, text-2)
      draw-callout((9.4, 4.25), 3.3, 1.0, text-3)
      draw-callout((2.45, 1.35), 3.7, 1.0, text-100, stroke: 1.5pt + black)

      // 3. Arrows
      draw-arrow((1.4, 4.57), (1.3, 3.48)) // 1D left tick gap
      draw-arrow((2.8, 4.57), (3.5, 3.48)) // 1D right tick gap
      draw-arrow((5.6, 4.4), (6.1, 3.8)) // 2D border gap
      draw-arrow((9.6, 3.75), (9.8, 2.2)) // 3D cube inner face gap
    })
  ]
}

// Default preview
#boundary-constants-diagram()
