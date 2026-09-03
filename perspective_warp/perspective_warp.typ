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
