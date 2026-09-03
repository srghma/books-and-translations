#import "../perspective_warp/perspective_warp.typ": render-gene-spiral

/// Renders the 3D perspective infinite gene spiral converging towards a vanishing point
#let infinite-gene-spiral(
  width: 266pt,
  height: 210pt,
  start-x: 35.0,
  start-y: 118.0,
  vanish-x: 245.0,
  vanish-y: 55.0,
  radius-x: 52.0,
  radius-y: 68.0,
  nodes-per-turn: 8,
  num-turns: 60,
  rate: 0.0042,
  pitch: 26.0,
  gap:21,
  theta-offset-deg: -70.0,
  tilt-deg: -10.0,
  black-color: "#16181b",
  gray-color: "#8b9097",
  spoke-color: "#686d75",
  axis-color: "rgba(130, 135, 142, 0.6)",
  draw-axis: true,
  stroke-base: 2.4,
  v-padding: 1.5em,
) = {
  align(center)[
    #block(inset: (y: v-padding))[
      #render-gene-spiral(
        width: width / 1pt,
        height: height / 1pt,
        start-x: start-x,
        start-y: start-y,
        vanish-x: vanish-x,
        vanish-y: vanish-y,
        radius-x: radius-x,
        radius-y: radius-y,
        nodes-per-turn: nodes-per-turn,
        num-turns: num-turns,
        rate: rate,
        pitch: pitch,
        gap: gap,
        theta-offset-deg: theta-offset-deg,
        tilt-deg: tilt-deg,
        black-color: black-color,
        gray-color: gray-color,
        spoke-color: spoke-color,
        axis-color: axis-color,
        draw-axis: draw-axis,
        stroke-base: stroke-base,
        output-width: width,
      )
    ]
  ]
}

// Default preview
#infinite-gene-spiral()
