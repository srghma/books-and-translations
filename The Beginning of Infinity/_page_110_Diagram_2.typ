#import "@preview/cetz:0.5.2"
#import "@preview/maquette:0.1.3": render-obj
#import cetz.draw: content, group, line, rect, rotate
#import "i18n.typ": current-lang, load-i18n

#let t = load-i18n("_page_110_Diagram_2.i18n.yml")

#let text-1 = t("With one constant,\n20% of the choices\nare within 10% of\nthe boundary.")
#let text-2 = t("With two constants,\n36% of them are.")
#let text-3 = t("With three constants,\nit's 48.8%.")
#let text-100 = t("With 100 constants,\nit's over 99.9999999%.")

#let scene-3d = read("_page_110_Diagram_2.obj", encoding: none)

#let render-cube = render-obj(
  scene-3d,
  // Camera params copied from the working "mannequin" attempt — these
  // give the correct cube orientation. The previous up:(0,0,1),
  // azimuth:-32, elevation:5, distance:6.4 combo was the source of the
  // wrong rotation.
  up: (0, 0, 0.1),
  azimuth: -34,
  elevation: 1,
  distance: 5.2,
  background: none,
  shading: "flat",
  materials: (
    inner_cube: "#7c8186",
    outer_frame: "#000000",
    // FIX: the .obj group/material is named "arrow" (g arrow / usemtl
    // arrow), not "arrow_shadow". The mismatched key meant this face
    // group never resolved to a material and rendered invisible.
    arrow: "#111111",
  ),
  highlight: (
    inner_cube: "#7c8186",
    outer_frame: "#000000",
    arrow: "#111111",
  ),
  lights: (
    (
      type: "directional",
      vector: (-0.7, -1.3, 1.6),
      color: "#ffffff",
      intensity: 1.15,
    ),
    (
      type: "ambient",
      color: "#ffffff",
      intensity: 0.55,
    ),
  ),
  antialias: 4,
  // Keep the compact size from the original layout (the "frame too big"
  // issue in the second attempt was just its own width:9cm, unrelated
  // to the camera fix above).
  width: 3.2cm,
)

#let draw-callout(pos, width, height, body, radius: 0.22, stroke: 0.85pt + black, fill: white) = {
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

#let draw-arrow(from, to, stroke: 0.75pt + black, mark-size: 0.18) = {
  line(from, to, stroke: stroke, mark: (end: "triangle", fill: stroke.paint, size: mark-size))
}

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

  line((cx - half-axis, cy), (cx + half-axis, cy), stroke: 0.6pt + stroke.paint)
  line((cx - half-bounds, cy - th), (cx - half-bounds, cy + th), stroke: stroke)
  line((cx + half-bounds, cy - th), (cx + half-bounds, cy + th), stroke: stroke)
  rect((cx - half-inner, cy - bh), (cx + half-inner, cy + bh), fill: fill, stroke: none)
}

#let draw-2d(
  center: (6.2, 2.7),
  size: 2.3,
  inner-ratio: 0.8,
  angle: 11deg,
  stroke: 0.75pt + black,
  fill: rgb("73767c"),
) = {
  let half-out = size / 2
  let half-in = half-out * inner-ratio
  group({
    rotate(angle, origin: center)
    let (cx, cy) = center
    rect((cx - half-out, cy - half-out), (cx + half-out, cy + half-out), stroke: stroke, fill: white)
    rect((cx - half-in, cy - half-in), (cx + half-in, cy + half-in), fill: fill, stroke: none)
  })
}

#let boundary-constants-diagram(
  scale: 1.0,
  font-size: 7.2pt,
  font: ("Liberation Sans", "Arial", "Noto Sans Khmer"),
) = {
  align(center)[
    #set text(font: font, size: font-size)
    #cetz.canvas(length: 1cm * scale, {
      // 1. 1D & 2D Shapes
      draw-1d()
      draw-2d()

      // 2. 3D OBJ Rendered via Maquette
      content((9.75, 2.55), render-cube)

      // 3. Callouts
      draw-callout((2.0, 5.35), 3.0, 1.55, text-1)
      draw-callout((5.7, 4.95), 3.0, 1.1, text-2)
      draw-callout((9.4, 4.25), 3.3, 1.0, text-3)
      draw-callout((2.45, 1.35), 3.7, 1.0, text-100, stroke: 1.5pt + black)

      // 4. Arrows
      draw-arrow((1.4, 4.57), (1.3, 3.48))
      draw-arrow((2.8, 4.57), (3.5, 3.48))
      draw-arrow((5.6, 4.4), (6.1, 3.8))
      // Arrow from 3D callout pointing directly at the 3D shadow on the cube
      draw-arrow((9.1, 3.75), (9.5, 2.3))
    })
  ]
}

#boundary-constants-diagram()
