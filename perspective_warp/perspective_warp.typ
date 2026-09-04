#let warp-plugin = plugin(
  "target/wasm32-unknown-unknown/release/perspective_warp.wasm",
)

#let render-perspective-diagram(
  top-label: "",
  bot-label: "",
  font-top: none,
  font-bottom: none,
  top-start: 1,
  top-step: 1,
  bot-start: 2,
  bot-step: 1,
  rate: 0.00095,
  width: 1000.0,
  height: 240.0,
  output-width: 100%,
) = {
  assert(
    font-top != none,
    message: "font-top must be provided as font bytes from read(..., encoding: none)",
  )
  let font-bottom = if font-bottom != none { font-bottom } else { font-top }

  let config = bytes(
    json.encode((
      top_label: top-label,
      bot_label: bot-label,
      top_start: top-start,
      top_step: top-step,
      bot_start: bot-start,
      bot_step: bot-step,
      rate: rate,
      width: width,
      height: height,
    )),
  )

  let svg-bytes = warp-plugin.render(font-top, font-bottom, config)
  align(center)[
    #image(svg-bytes, format: "svg", width: output-width)
  ]
}

#let render-gene-spiral(
  width: 266.0,
  height: 210.0,
  start-x: 35.0,
  start-y: 118.0,
  vanish-x: 245.0,
  vanish-y: 55.0,
  radius-x: 52.0,
  radius-y: 68.0,
  nodes-per-turn: 8,
  num-turns: 60,
  rate: 0.0042,
  gap: 21.0,
  theta-offset-deg: -70.0,
  tilt-deg: -10.0,
  black-color: "#16181b",
  gray-color: "#8b9097",
  spoke-color: "#686d75",
  axis-color: "rgba(130, 135, 142, 0.6)",
  draw-axis: true,
  stroke-base: 2.4,
  output-width: 100%,
) = {
  let config = bytes(
    json.encode((
      width: width,
      height: height,
      start_x: start-x,
      start_y: start-y,
      vanish_x: vanish-x,
      vanish_y: vanish-y,
      radius_x: radius-x,
      radius_y: radius-y,
      nodes_per_turn: nodes-per-turn,
      num_turns: num-turns,
      rate: rate,
      gap: gap,
      theta_offset_deg: theta-offset-deg,
      tilt_deg: tilt-deg,
      black_color: black-color,
      gray_color: gray-color,
      spoke_color: spoke-color,
      axis_color: axis-color,
      draw_axis: draw-axis,
      stroke_base: stroke-base,
    )),
  )

  let svg-bytes = warp-plugin.render_gene_spiral(config)
  align(center)[
    #image(svg-bytes, format: "svg", width: output-width)
  ]
}

