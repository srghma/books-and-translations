#let up-arrow(
  height: 1.5em,
  width: auto,
  head-percent: 70%, // % of total height occupied by the arrow head
  stem-width-percent: 30%, // % of total width occupied by the stem
  fill: white,
  stroke: (paint: rgb("#6b7280"), thickness: 1.2pt, join: "round"),
  baseline: 15%,
) = {
  // Convert percentage/ratio to float (0.0 - 1.0)
  let h-ratio = if type(head-percent) == ratio { head-percent / 100% } else { float(head-percent) }
  let s-ratio = if type(stem-width-percent) == ratio { stem-width-percent / 100% } else { float(stem-width-percent) }

  // Derive dimensions using native Typst length arithmetic
  let h = height
  let w = if width == auto { h * 0.85 } else { width }

  let head-h = h * h-ratio
  let half-w = w / 2
  let half-stem = (w * s-ratio) / 2

  let x-stem-left = half-w - half-stem
  let x-stem-right = half-w + half-stem

  box(
    baseline: baseline,
    polygon(
      fill: fill,
      stroke: stroke,
      (half-w, 0pt), // Apex
      (w, head-h), // Right tip
      (x-stem-right, head-h), // Right inner corner
      (x-stem-right, h), // Stem bottom right
      (x-stem-left, h), // Stem bottom left
      (x-stem-left, head-h), // Left inner corner
      (0pt, head-h), // Left tip
    ),
  )
}

// 1. Default (inline with text)
// Click the #up-arrow() button.
