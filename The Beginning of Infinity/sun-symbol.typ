#let sun-symbol(
  size: 1.2em,
  dot-percent: 34%,          // Diameter of the center dot as a % of size
  stroke-percent: 11%,       // Outer ring stroke thickness as a % of size
  color: rgb("#111827"),     // Color for ring and dot
  fill: none,                // Background inside the ring (none for transparent, or white)
  baseline: 15%,
) = {
  // Convert ratios/percentages to float factors (0.0 - 1.0)
  let d-ratio = if type(dot-percent) == ratio { dot-percent / 100% } else { float(dot-percent) }
  let s-ratio = if type(stroke-percent) == ratio { stroke-percent / 100% } else { float(stroke-percent) }

  let stroke-width = size * s-ratio
  let outer-radius = (size - stroke-width) / 2
  let dot-radius = (size * d-ratio) / 2

  box(
    width: size,
    height: size,
    baseline: baseline,
    {
      // Outer ring
      place(
        center + horizon,
        circle(
          radius: outer-radius,
          stroke: (paint: color, thickness: stroke-width),
          fill: fill,
        ),
      )
      // Center filled dot
      place(
        center + horizon,
        circle(
          radius: dot-radius,
          fill: color,
        ),
      )
    },
  )
}

// 1. Default (inline with text)
// Select option #sun-symbol() here.

// // 2. Custom size
// #sun-symbol(size: 24pt)

// // 3. Larger center dot (bullseye style)
// #sun-symbol(size: 2em, dot-percent: 50%, stroke-percent: 8%)

// // 4. Smaller dot with thicker outer ring
// #sun-symbol(size: 30pt, dot-percent: 20%, stroke-percent: 15%)

// // 5. Custom colors
// #sun-symbol(
//   size: 28pt,
//   color: blue.darken(20%),
//   fill: blue.lighten(90%),
// )