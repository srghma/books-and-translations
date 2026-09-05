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
) = {
  let to-num(v) = if type(v) == std.length { v / 1pt } else { float(v) }

  let config = bytes(
    json.encode((
      start_x: to-num(start-x),
      start_y: to-num(start-y),
      vanish_x: to-num(vanish-x),
      vanish_y: to-num(vanish-y),
      radius: to-num(radius),
      gap_btw_turns: to-num(gap-btw-turns),
      nodes_per_turn: nodes-per-turn,
      thickness_of_non_warped_spiral: to-num(thickness-of-non-warped-spiral),
      thickness_of_non_warped_axis: to-num(thickness-of-non-warped-axis),
      color: color,
      axis_color: axis-color,
      draw_axis: draw-axis,
      color2: color2,
      crossover_lines_color: crossover-lines-color,
    )),
  )

  let svg-bytes = warp-plugin.render_gene_spiral(config)
  let s = str(svg-bytes)
  let m-w = s.match(regex("width=\"([0-9.]+)\""))
  let m-h = s.match(regex("height=\"([0-9.]+)\""))
  let orig-w = float(m-w.captures.at(0))
  let orig-h = float(m-h.captures.at(0))

  let img-width = if output-width == auto {
    to-num(vanish-x) * 1pt
  } else if output-width != none {
    output-width
  } else {
    orig-w * 1pt
  }
  let img-height = (to-num(img-width) / orig-w) * orig-h * 1pt

  let img-args = (format: "svg", width: img-width, height: img-height)
  image(svg-bytes, ..img-args)
}

