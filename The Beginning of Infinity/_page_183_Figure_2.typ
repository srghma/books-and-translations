#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n

// Initialize translator
#let t = load-i18n("_page_183_Figure_2.i18n.yml")

/// Renders a single hotel corridor diagram panel for a given step (1, 2, or 3).
/// Each panel is structured into 3 columns:
/// - Left column: left wall rooms (Rooms 4, 2)
/// - Middle column: corridor with trash bag circles and dashed transfer arrows
/// - Right column: right wall rooms (Rooms 5, 3, 1)
#let hotel-corridor-panel(
  step,
  width: 100%,
  height: 220pt,
) = {
  let sans-fonts = fonts-for-current-lang.sans
  let h = height

  // Equispaced vertical room centers (1 to 5, plus off-screen 6)
  let y-rooms = (
    "1": 0.80 * h,
    "2": 0.65 * h,
    "3": 0.50 * h,
    "4": 0.35 * h,
    "5": 0.20 * h,
    "6": 0.05 * h,
  )

  let circle-r = 7.5pt
  let dy-offset = 7.5pt // Vertical shift for stacked circles

  // Room label in wall column
  let room-label(room-num, y) = {
    place(
      center + horizon,
      dy: y - h / 2,
      block[
        #set par(leading: 0.25em)
        #set align(center)
        #text(
          font: sans-fonts,
          fill: rgb("#000000"),
          stroke: 0.35pt + rgb("#000000"),
          weight: "medium",
          size: 8.5pt,
        )[#t("Room")\ #room-num]
      ],
    )
  }

  // 1. Left Wall Column (Rooms 4 and 2)
  let left-wall = box(
    width: 100%,
    height: 100%,
    fill: gradient.linear(
      angle: 180deg,
      (rgb("#82878e"), 0%),
      (rgb("#c2c6cb"), 30%),
      (rgb("#c2c6cb"), 100%),
    ),
    stroke: (right: 0.75pt + black),
    [
      #room-label("4", y-rooms.at("4"))
      #room-label("2", y-rooms.at("2"))
    ],
  )

  // 3. Right Wall Column (Rooms 5, 3, 1)
  let right-wall = box(
    width: 100%,
    height: 100%,
    fill: rgb("#c2c6cb"),
    stroke: (left: 0.75pt + black),
    [
      #room-label("5", y-rooms.at("5"))
      #room-label("3", y-rooms.at("3"))
      #room-label("1", y-rooms.at("1"))
    ],
  )

  // 2. Middle Corridor Column (Circles + Arrows)
  let middle-corridor = layout(size => {
    let cw = size.width

    // Circle centers positioned inside the corridor next to door thresholds
    let left-circle-x = circle-r + 1.5pt
    let right-circle-x = cw - circle-r - 1.5pt

    // Labeled circle (grey for sending bag, black for received bag)
    let circle-node(x, y, num, is-black: false) = {
      let bg = if is-black { rgb("#181a1c") } else { rgb("#a6abb2") }
      place(
        top + left,
        dx: x - circle-r,
        dy: y - circle-r,
        circle(
          radius: circle-r,
          fill: bg,
          stroke: 0.55pt + white,
          align(center + horizon)[
            #text(
              font: sans-fonts,
              fill: white,
              weight: "bold",
              size: 8pt,
            )[#num]
          ],
        ),
      )
    }

    // Dashed arrow with directional triangular head
    let draw-arrow(x1, y1, x2, y2) = {
      let dx = x2 - x1
      let dy = y2 - y1
      let dx-pt = dx / 1pt
      let dy-pt = dy / 1pt
      let len = calc.sqrt(dx-pt * dx-pt + dy-pt * dy-pt) * 1pt
      if len <= 0pt { return }
      let ux = dx / len
      let uy = dy / len

      let p1x = x1 + circle-r * ux
      let p1y = y1 + circle-r * uy
      let p2x = x2 - circle-r * ux
      let p2y = y2 - circle-r * uy

      // Dashed shaft
      place(
        top + left,
        line(
          start: (p1x, p1y),
          end: (p2x, p2y),
          stroke: (paint: rgb("#90959c"), thickness: 1.1pt, dash: (2.5pt, 2pt)),
        ),
      )

      // Arrowhead
      let head-len = 4.2pt
      let head-w = 2.4pt
      let base-x = p2x - head-len * ux
      let base-y = p2y - head-len * uy

      place(
        top + left,
        polygon(
          fill: rgb("#90959c"),
          stroke: none,
          (p2x, p2y),
          (base-x + head-w * uy, base-y - head-w * ux),
          (base-x - head-w * uy, base-y + head-w * ux),
        ),
      )
    }

    box(
      width: 100%,
      height: 100%,
      fill: white,
      [
        // Arrows between rooms
        #{
          for k in range(1, 6) {
            let r-from = k + step - 1
            if r-from <= 5 {
              let r-to = r-from + 1
              let x1 = if calc.even(r-from) { left-circle-x } else {
                right-circle-x
              }
              let y1 = y-rooms.at(str(r-from)) - dy-offset

              if r-to <= 5 {
                let x2 = if calc.even(r-to) { left-circle-x } else {
                  right-circle-x
                }
                let y2 = y-rooms.at(str(r-to)) + dy-offset
                draw-arrow(x1, y1, x2, y2)
              } else if r-to == 6 {
                // Diagonal exit arrow pointing towards virtual Room 6 off-screen
                let x2 = left-circle-x
                let y2 = y-rooms.at("6") + dy-offset
                draw-arrow(x1, y1, x2, y2)
              }
            }
          }
        }

        // Circle Nodes (Trash Bags)
        #{
          for r in range(1, 6) {
            let x = if calc.even(r) { left-circle-x } else { right-circle-x }
            let base-y = y-rooms.at(str(r))

            // Upper grey circle (sending bag)
            if r >= step {
              let bag-num = r - step + 1
              circle-node(x, base-y - dy-offset, bag-num, is-black: false)
            }

            // Lower black circle (received bag)
            if r >= step + 1 {
              let rec-num = r - step
              circle-node(x, base-y + dy-offset, rec-num, is-black: true)
            }
          }
        }
      ],
    )
  })

  // Panel box split into 3 columns: Left Rooms, Middle Corridor (Circles + Arrows), Right Rooms
  box(
    width: width,
    height: height,
    stroke: 0.75pt + black,
    clip: true,
    grid(
      columns: (28%, 1fr, 28%),
      rows: 100%,
      stroke: none,
      left-wall, middle-corridor, right-wall,
    ),
  )
}

/// Renders the complete 3-column, 2-row diagram without gaps
#let infinity-hotel-waste-disposal(
  panel-height: 225pt,
  caption-size: 8pt,
  v-padding: 1.5em,
) = {
  let sans-fonts = fonts-for-current-lang.sans

  align(center)[
    #block(inset: (y: v-padding))[
      #table(
        columns: (1fr, 1fr, 1fr),
        rows: (auto, auto),
        stroke: none,
        column-gutter: 0pt,
        row-gutter: 0pt,
        inset: 0pt,
        align: center + top,

        // Row 1: The three panels
        hotel-corridor-panel(1, height: panel-height),
        hotel-corridor-panel(2, height: panel-height),
        hotel-corridor-panel(3, height: panel-height),

        // Row 2: Captions (flush below panels)
        [
          #v(4.5pt)
          #text(font: sans-fonts, size: caption-size)[#t(
            "Step 1 (takes 1 second)",
          )]
        ],
        [
          #v(4.5pt)
          #text(font: sans-fonts, size: caption-size)[#t(
            "Step 2 (takes ½ of a second)",
          )]
        ],
        [
          #v(4.5pt)
          #text(font: sans-fonts, size: caption-size)[#t(
            "Step 3 (takes ¼ of a second)",
          )]
        ],
      )
    ]
  ]
}

// Default preview
#infinity-hotel-waste-disposal()
