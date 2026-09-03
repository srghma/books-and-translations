#import "modules/extrude.typ": extrude-3d

// Page background
#let bg = rgb("#030406")

// Palette - Top section ("THE", "BEGINNING", "OF", "INFINITY")
#let color-the-front = rgb("#f5fcff")
#let color-the-start = rgb("#0091ea")
#let color-the-end = rgb("#031b38")

#let color-beg-front = rgb("#ffffff")
#let color-beg-start = rgb("#2979ff")
#let color-beg-end = rgb("#05081e")

#let color-of-front = rgb("#ffffff")
#let color-of-start = rgb("#d50000")
#let color-of-end = rgb("#380306")

#let color-inf-front = rgb("#fffff5")
#let color-inf-start = rgb("#7e836b")
#let color-inf-end = rgb("#23261c")

// Palette - Middle Banner ("EXPLANATIONS THAT TRANSFORM THE WORLD")
#let color-gold-border = rgb("#ffea00")
#let color-gold-text = rgb("#ffea00")

// Palette - Bottom section ("DAVID DEUTSCH", "AUTHOR OF", "FABRIC")
#let color-auth-front = rgb("#ffffff")
#let color-auth-start = rgb("#b71c1c")
#let color-auth-end = rgb("#240305")

#let color-meta-text = rgb("#b0bec5")

#let color-fab-front = rgb("#ffffff")
#let color-fab-start = rgb("#0097a7")
#let color-fab-end = rgb("#031e24")

// Slot styling matching the original cover
#let slot-config = (
  // 0: THE (extrudes down)
  (
    extrude-dir: 1,
    extrude-depth-ratio: 0.55,
    scale-end: 0.76,
    front: color-the-front,
    start: color-the-start,
    end: color-the-end,
    weight: "bold",
    tracking: 0.28em,
    pill: false,
    flat: false,
    gap-weight: 1.0,
  ),
  // 1: BEGINNING (extrudes down)
  (
    extrude-dir: 1,
    extrude-depth-ratio: 0.90,
    scale-end: 0.50,
    front: color-beg-front,
    start: color-beg-start,
    end: color-beg-end,
    weight: "black",
    tracking: 0.12em,
    pill: false,
    flat: false,
    gap-weight: 1.1,
  ),
  // 2: OF (extrudes down)
  (
    extrude-dir: 1,
    extrude-depth-ratio: 0.55,
    scale-end: 0.65,
    front: color-of-front,
    start: color-of-start,
    end: color-of-end,
    weight: "bold",
    tracking: 0.26em,
    pill: false,
    flat: false,
    gap-weight: 1.1,
  ),
  // 3: INFINITY (extrudes down)
  (
    extrude-dir: 1,
    extrude-depth-ratio: 0.75,
    scale-end: 0.72,
    front: color-inf-front,
    start: color-inf-start,
    end: color-inf-end,
    weight: "black",
    tracking: 0.13em,
    pill: false,
    flat: false,
    gap-weight: 1.0,
  ),
  // 4: EXPLANATIONS THAT TRANSFORM THE WORLD (Center Pill Badge)
  (
    extrude-dir: 0,
    extrude-depth-ratio: 0.0,
    scale-end: 1.0,
    front: color-gold-text,
    start: color-gold-border,
    end: color-gold-border,
    weight: "bold",
    tracking: 0.06em,
    pill: true,
    flat: false,
    gap-weight: 1.2,
  ),
  // 5: DAVID DEUTSCH (extrudes up)
  (
    extrude-dir: -1,
    extrude-depth-ratio: 0.85,
    scale-end: 0.58,
    front: color-auth-front,
    start: color-auth-start,
    end: color-auth-end,
    weight: "black",
    tracking: 0.12em,
    pill: false,
    flat: false,
    gap-weight: 1.0,
  ),
  // 6: AUTHOR OF (Flat label, positioned safely above FABRIC)
  (
    extrude-dir: 0,
    extrude-depth-ratio: 0.0,
    scale-end: 1.0,
    front: color-meta-text,
    start: color-meta-text,
    end: color-meta-text,
    weight: "bold",
    tracking: 0.35em,
    pill: false,
    flat: true,
    gap-weight: 0.8,
  ),
  // 7: THE FABRIC OF REALITY (extrudes up, sits at the bottom margin)
  (
    extrude-dir: -1,
    extrude-depth-ratio: 0.90,
    scale-end: 0.60,
    front: color-fab-front,
    start: color-fab-start,
    end: color-fab-end,
    weight: "black",
    tracking: 0.14em,
    pill: false,
    flat: false,
    gap-weight: 0.0,
  ),
)

#let cover-page(
  items,
  fonts,
) = {
  page(
    fill: bg,
    margin: (x: 5%, top: 4.5%, bottom: 4.5%),
  )[
    #layout(size => {
      let h = size.height
      let base-size = h * 0.046

      context {
        let is-khmer = text.lang == "km"

        // 1. Filter out empty items (like "THE" in Khmer) and build self-contained blocks
        let valid-blocks = ()
        for (slot-idx, entry) in items.enumerate() {
          let (word, mult) = if type(entry) == array {
            (entry.at(0), entry.at(1))
          } else {
            (entry, 1.0)
          }

          // Non-empty check
          if measure(word).width > 0pt {
            let cfg = slot-config.at(calc.min(slot-idx, slot-config.len() - 1))
            let resolved-size = base-size * mult
            let tracking = if is-khmer { 0.01em } else { cfg.tracking }
            let dy = cfg.extrude-dir * (resolved-size * cfg.extrude-depth-ratio)

            // Construct the self-contained block (text + extrusion as one object)
            let block-content = if cfg.pill {
              rect(
                fill: bg,
                stroke: 1.5pt + color-gold-border,
                radius: 4pt,
                inset: (x: 8pt, y: 4.5pt),
                text(
                  font: fonts,
                  fill: cfg.front,
                  size: resolved-size,
                  weight: cfg.weight,
                  tracking: tracking,
                  word,
                ),
              )
            } else if cfg.flat {
              text(
                font: fonts,
                fill: cfg.front,
                size: resolved-size,
                weight: cfg.weight,
                tracking: tracking,
                word,
              )
            } else {
              extrude-3d(
                word,
                fonts,
                dy: dy,
                scale-end: cfg.scale-end,
                layers: 28,
                color-front: cfg.front,
                color-side-start: cfg.start,
                color-side-end: cfg.end,
                size: resolved-size,
                weight: cfg.weight,
                tracking: tracking,
              )
            }

            let measured-h = measure(block-content).height

            valid-blocks.push((
              content: block-content,
              h: measured-h,
              gap-weight: cfg.gap-weight,
            ))
          }
        }

        let num-blocks = valid-blocks.len()
        if num-blocks == 0 { return }

        // 2. Compute dynamic gaps so that the first block touches the top margin
        //    and the last block touches the bottom margin
        let total-blocks-h = valid-blocks.map(it => it.h).sum()
        let available-space = calc.max(0pt, h - total-blocks-h)

        let gap-weights = valid-blocks.slice(0, -1).map(it => it.gap-weight)
        let total-weight = gap-weights.sum()
        if total-weight == 0 { total-weight = 1.0 }

        // 3. Render blocks in flow; gaps are placed between the outer boundaries
        align(center + top)[
          #for (i, block-item) in valid-blocks.enumerate() {
            block-item.content

            if i < num-blocks - 1 {
              let this-gap = available-space * (gap-weights.at(i) / total-weight)
              v(this-gap)
            }
          }
        ]
      }
    })
  ]
}
