#import "@preview/cetz:0.5.2"
#import "i18n.typ": current-lang, load-i18n

// Initialize translator for this diagram
#let t = load-i18n("_page_167_Diagram_1.i18n.yml")

#let label-top = t("The set of all natural numbers")
#let label-bot = t("Part of that set")

// ==========================================
// Reusable 1: Double-headed vertical arrow
// ==========================================
#let draw-double-arrow(
  x,
  y-top,
  y-bot,
  scale: 1.0,
  stroke-base: 0.7pt,
) = {
  import cetz.draw: *
  let len = y-top - y-bot
  if len <= 0 { return }

  let mark-size = 0.16 * scale
  let stroke-w = stroke-base * scale

  // When large enough, draw full double-headed arrow
  if len > mark-size * 2.2 {
    line(
      (x, y-top),
      (x, y-bot),
      stroke: stroke-w + black,
      mark: (start: "triangle", end: "triangle", fill: black, size: mark-size),
    )
  } else if len > 0.04 {
    // When very small in the distance, draw a thin tick line
    line((x, y-top), (x, y-bot), stroke: stroke-w * 0.7 + rgb("606060"))
  }
}

// ==========================================
// Reusable 2: Perspective stream of numbers
// ==========================================
#let draw-perspective-stream(
  x-start: 5.8,
  x-vanish: 14.2,
  y-center: 1.4,
  h-span: 0.95,
  rate: 0.082,
  count: 45,
) = {
  import cetz.draw: *

  let dist = x-vanish - x-start

  for k in range(count) {
    let denom = 1.0 + rate * k
    let sc = 1.0 / denom
    let x = x-vanish - (dist / denom)

    let y-top = y-center + h-span * sc
    let y-bot = y-center - h-span * sc

    // Numbers (Top: 1, 2, 3... ; Bottom: 2, 3, 4...)
    let n-top = str(k + 1)
    let n-bot = str(k + 2)

    // Render numbers while legible
    if sc > 0.18 {
      content(
        (x, y-top),
        [#text(size: 1em * sc)[#n-top]],
      )
      content(
        (x, y-bot),
        [#text(size: 1em * sc)[#n-bot]],
      )
    }

    // Vertical double arrow linking the pair
    let arrow-top = y-top - 0.28 * sc
    let arrow-bot = y-bot + 0.28 * sc
    draw-double-arrow(x, arrow-top, arrow-bot, scale: sc)
  }

  // Dense streak fading into the vanishing point
  for k in range(count, count + 35) {
    let denom = 1.0 + rate * k
    let sc = 1.0 / denom
    let x = x-vanish - (dist / denom)
    let y-t = y-center + h-span * sc * 0.7
    let y-b = y-center - h-span * sc * 0.7
    line((x, y-t), (x, y-b), stroke: 0.35pt + rgb("808080"))
  }
}

// ==========================================
// Reusable 3: Faint convergence guide lines
// ==========================================
#let draw-vanishing-lines(
  x-from: 12.8,
  x-vanish: 14.2,
  y-center: 1.4,
  h-span: 0.95,
  rate: 0.082,
  k-start: 40,
) = {
  import cetz.draw: *
  let sc-start = 1.0 / (1.0 + rate * k-start)

  // Subtle convergence envelope lines meeting at the horizon tip
  let y-top-start = y-center + h-span * sc-start
  let y-bot-start = y-center - h-span * sc-start

  line((x-from, y-top-start), (x-vanish, y-center), stroke: 0.35pt + rgb("a0a0a0"))
  line((x-from, y-center + 0.05), (x-vanish, y-center), stroke: 0.25pt + rgb("b0b0b0"))
  line((x-from, y-center - 0.05), (x-vanish, y-center), stroke: 0.25pt + rgb("b0b0b0"))
  line((x-from, y-bot-start), (x-vanish, y-center), stroke: 0.35pt + rgb("a0a0a0"))
}

// ==========================================
// Reusable 4: Perspective Text Label
// ==========================================
#let draw-label(pos, body, angle: 2.2deg) = {
  import cetz.draw: *
  group({
    rotate(angle, origin: pos)
    content(pos, [
      #set par(justify: false)
      #align(right + horizon)[#body #h(0.4em) ➔]
    ])
  })
}

// ==========================================
// Main Diagram Function
// ==========================================
#let infinite-sets-diagram(scale: 1.0) = {
  align(center)[
    #cetz.canvas(length: 1cm * scale, {
      let x-start = 5.7
      let x-vanish = 14.2
      let y-center = 1.4
      let h-span = 0.95

      // 1. Text labels on the left (tilted along perspective lines)
      draw-label((x-start - 0.2, y-center + h-span), label-top)
      draw-label((x-start - 0.2, y-center - h-span), label-bot)

      // 2. Infinite number stream with double-headed arrows
      draw-perspective-stream(
        x-start: x-start,
        x-vanish: x-vanish,
        y-center: y-center,
        h-span: h-span,
      )

      // 3. Vanishing guide rays at the horizon tip
      draw-vanishing-lines(
        x-from: 12.8,
        x-vanish: x-vanish,
        y-center: y-center,
        h-span: h-span,
      )
    })
  ]
}

// Default preview
#infinite-sets-diagram()
