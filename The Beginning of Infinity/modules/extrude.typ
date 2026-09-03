/// Renders a 3D perspective extrusion whose outer container physically
/// encloses BOTH the text and its extrusion trail.
#let extrude-3d(
  body,
  fonts,
  dy: 40pt,
  scale-end: 0.65,
  layers: 28,
  color-front: white,
  color-side-start: rgb("#1976d2"),
  color-side-end: rgb("#070b1a"),
  size: 28pt,
  weight: "black",
  tracking: 0.12em,
) = {
  let item = text(
    font: fonts,
    size: size,
    weight: weight,
    tracking: tracking,
    body,
  )

  let abs-dy = calc.abs(dy)

  context {
    let m = measure(item)
    let text-w = m.width
    let text-h = m.height

    if abs-dy == 0pt {
      // Flat text, no extrusion
      item
    } else if dy > 0pt {
      // Extrudes DOWN:
      // Front text sits at the top (y = 0), extrusion extends downwards to dy.
      let total-h = text-h + dy

      box(width: text-w, height: total-h)[
        // Draw slices from back (t = 1) to front (t = 0)
        #for i in range(layers, 0, step: -1) {
          let t = i / layers
          let col = color.mix((color-side-end, t), (color-side-start, 1 - t))
          let slice-scale = 100% * (1 - t) + 100% * scale-end * t
          place(
            top + center,
            dy: dy * t,
            scale(
              x: slice-scale,
              y: slice-scale,
              text(fill: col, item),
            ),
          )
        }
        // Front face at top
        #place(top + center, dy: 0pt, text(fill: color-front, item))
      ]
    } else {
      // Extrudes UP:
      // Deepest slice sits at the top (y = 0), front text sits at the bottom (y = abs-dy).
      let D = abs-dy
      let total-h = text-h + D

      box(width: text-w, height: total-h)[
        // Draw slices from back (t = 1, at y = 0) to front (t = 0, at y = D)
        #for i in range(layers, 0, step: -1) {
          let t = i / layers
          let col = color.mix((color-side-end, t), (color-side-start, 1 - t))
          let slice-scale = 100% * (1 - t) + 100% * scale-end * t
          place(
            top + center,
            dy: D * (1 - t),
            scale(
              x: slice-scale,
              y: slice-scale,
              text(fill: col, item),
            ),
          )
        }
        // Front face at bottom
        #place(top + center, dy: D, text(fill: color-front, item))
      ]
    }
  }
}
