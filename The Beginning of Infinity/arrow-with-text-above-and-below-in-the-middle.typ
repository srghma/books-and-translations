#import "@preview/cetz:0.5.2": canvas, draw

#let arrow-with-text-above-and-below(
  start,
  end,
  label-above: "",
  label-below: "",

  // Label positioning
  position: 0.5,
  offset-above: 5pt,
  offset-below: 5pt,
  anchor-above: "south",
  anchor-below: "north",

  // Typography
  font: "New Computer Modern",
  font-size: 10.5pt,
  font-style: "italic",
  font-weight: "regular",
  letter-spacing: 0.3pt,
  text-color: auto, // auto matches `color`

  // Arrow styling
  color: rgb("#a4a9af"),
  thickness: 3.2pt,
  stroke-cap: "round",
  arrow-mark: "triangle",
  arrow-length: 9pt,
  arrow-width: 7.5pt,
  arrow-fill: auto,

  // Alignment
  rotate-text: true,
  auto-flip: true, // Prevents text from being upside-down on reverse arrows
  overlay: false,

  // Fallbacks / legacy aliases
  ..sink,
) = {
  // Aliases
  let lbl-above = if "label1" in sink.named() { sink.named().at("label1") } else { label-above }
  let lbl-below = if "label2" in sink.named() { sink.named().at("label2") } else { label-below }
  let pos-ratio = if "pos" in sink.named() { sink.named().at("pos") } else { position }
  let f-size-val = if "label-size" in sink.named() { sink.named().at("label-size") } else { font-size }

  let to-pt(v) = if type(v) == length { v / 1pt } else { float(v) }

  let sx = to-pt(start.at(0))
  let sy = to-pt(start.at(1))
  let ex = to-pt(end.at(0))
  let ey = to-pt(end.at(1))
  let off-a = to-pt(offset-above)
  let off-b = to-pt(offset-below)
  let f-size = to-pt(f-size-val)

  let dx = ex - sx
  let dy = ey - sy
  let chord-len = calc.sqrt(dx * dx + dy * dy)
  if chord-len == 0.0 { return [] }

  let pad = calc.max(25.0, f-size * 3.0 + calc.max(off-a, off-b))
  let min-x = calc.min(sx, ex) - pad
  let min-y = calc.min(sy, ey) - pad

  // Canvas coordinates (+y up)
  let to-canvas(x, y) = (x - min-x, -(y - min-y))

  let p0 = to-canvas(sx, sy)
  let p1 = to-canvas(ex, ey)

  let vx = p1.at(0) - p0.at(0)
  let vy = p1.at(1) - p0.at(1)

  // Tangent and left-normal unit vectors in canvas space
  let ux = vx / chord-len
  let uy = vy / chord-len
  let nx = -uy
  let ny = ux

  // Midpoint
  let mx = p0.at(0) + pos-ratio * vx
  let my = p0.at(1) + pos-ratio * vy

  let pos-a = (mx + off-a * nx, my + off-a * ny)
  let pos-b = (mx - off-b * nx, my - off-b * ny)

  let actual-text-color = if text-color != auto { text-color } else { color }

  // Angle handling
  let raw-angle = calc.atan2(vx, vy)
  let (draw-angle, final-pos-a, final-pos-b) = if rotate-text {
    if auto-flip and (raw-angle > 90deg or raw-angle < -90deg) {
      (raw-angle + 180deg, pos-b, pos-a)
    } else {
      (raw-angle, pos-a, pos-b)
    }
  } else {
    (0deg, pos-a, pos-b)
  }

  let c = canvas(length: 1pt, {
    // 1. Arrow line
    draw.line(
      p0,
      p1,
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

    // 2. Label above
    if lbl-above != none and lbl-above != "" {
      draw.content(
        final-pos-a,
        angle: draw-angle,
        anchor: anchor-above,
        std.text(
          font: font,
          size: f-size * 1pt,
          style: font-style,
          weight: font-weight,
          fill: actual-text-color,
          tracking: letter-spacing,
          lbl-above,
        ),
      )
    }

    // 3. Label below
    if lbl-below != none and lbl-below != "" {
      draw.content(
        final-pos-b,
        angle: draw-angle,
        anchor: anchor-below,
        std.text(
          font: font,
          size: f-size * 1pt,
          style: font-style,
          weight: font-weight,
          fill: actual-text-color,
          tracking: letter-spacing,
          lbl-below,
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
