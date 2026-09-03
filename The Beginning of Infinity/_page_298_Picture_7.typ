#let axis-cross(
  size: 140pt,                  // Canvas dimension (width and height)
  arrow-length: 110pt,          // Total length of both arrows (identical)
  cross-ratio: 45%,             // Percentage of arrow length behind the crossing point
  thickness: 8pt,               // Stroke thickness
  color: rgb("86898e"),
  head-length: 15pt,            // Length of arrowhead triangle
  head-width: 20pt,             // Width/spread of arrowhead triangle
) = {
  // 1. Resolve crossing point from percentages
  let cross = 50% // Crossing point as percentages (x%, y%) of canvas
  let (px, py) = if type(cross) == array { cross } else { (cross, cross) }
  let cx = size * px
  let cy = size * py

  // 2. Both arrows have the exact same total length and arm segments
  let tail-len = arrow-length * cross-ratio
  let tip-len = arrow-length * (100% - cross-ratio)
  let hw = head-width / 2
  let stroke-style = (paint: color, thickness: thickness, cap: "round")

  box(width: size, height: size, {
    // ----------------------------------------------------
    // Horizontal Arrow (Tail at left, Tip at right)
    // ----------------------------------------------------
    let x-start = cx - tail-len
    let x-tip   = cx + tip-len

    place(line(
      start: (x-start, cy),
      end:   (x-tip - head-length / 2, cy), // Overlaps into head to prevent gap
      stroke: stroke-style,
    ))
    place(polygon(
      fill: color,
      (x-tip - head-length, cy - hw),
      (x-tip, cy),
      (x-tip - head-length, cy + hw),
    ))

    // ----------------------------------------------------
    // Vertical Arrow (Tail at bottom, Tip at top)
    // ----------------------------------------------------
    let y-start = cy + tail-len
    let y-tip   = cy - tip-len

    place(line(
      start: (cx, y-start),
      end:   (cx, y-tip + head-length / 2), // Overlaps into head to prevent gap
      stroke: stroke-style,
    ))
    place(polygon(
      fill: color,
      (cx - hw, y-tip + head-length),
      (cx, y-tip),
      (cx + hw, y-tip + head-length),
    ))
  })
}

// 1. Default: perfectly centered cross with identical arrow lengths
#axis-cross()

// 2. Off-center crossing point using percentages:
// #axis-cross(cross: (40%, 60%))

// 3. Offset crossing along the arrow (e.g. crossing closer to tail):
// #axis-cross(cross-ratio: 35%)