#import "../perspective_warp/perspective_warp.typ": render-gene-spiral

/// Renders the 3D perspective infinite gene spiral converging towards a vanishing point
#let infinite-gene-spiral(
  start-x: none,
  start-y: none,
  vanish-x: none,
  vanish-y: none,

  radius: none,
  gap-btw-turns: none,
  nodes-per-turn: none,

  thickness-of-non-warped-spiral: none,
  thickness-of-non-warped-axis: none,

  color: none,
  axis-color: none,
  draw-axis: none,
  color2: none,
  crossover-lines-color: none,
  output-width: none,
  v-padding: none,
) = {
  let content = render-gene-spiral(
    start-x: start-x,
    start-y: start-y,
    vanish-x: vanish-x,
    vanish-y: vanish-y,
    radius: radius,
    gap-btw-turns: gap-btw-turns,
    nodes-per-turn: nodes-per-turn,
    thickness-of-non-warped-spiral: thickness-of-non-warped-spiral,
    thickness-of-non-warped-axis: thickness-of-non-warped-axis,
    color: color,
    axis-color: axis-color,
    draw-axis: draw-axis,
    color2: color2,
    crossover-lines-color: crossover-lines-color,
    output-width: output-width,
  )
  if v-padding != none {
    block(inset: (y: v-padding), content)
  } else {
    content
  }
}

// // Default preview
// #box(
//   width: 155pt,
//   height: 120pt,
//   stroke: 0.5pt + black,
//   clip: true,
// )[
//   #align(right + top)[
//     #infinite-gene-spiral(
//       start-x: 35pt,
//       start-y: 105pt,
//       vanish-x: 255pt,
//       vanish-y: 55pt,

//       radius: 68pt,
//       gap-btw-turns: 155pt,
//       nodes-per-turn: 12,

//       thickness-of-non-warped-spiral: 3.4pt,
//       thickness-of-non-warped-axis: 0.8pt,

//       color: "#16181b",
//       axis-color: "rgba(130, 135, 142, 0.6)",
//       draw-axis: true,
//       color2: "#8b9097",
//       crossover-lines-color: "#686d75",
//       output-width: auto,
//       v-padding: none,
//     )
//   ]
// ]
