#import "i18n.typ": current-lang, fonts-for-current-lang


/// Generic reusable Carved Stone Inscription Plaque component
#let carved-stone-plaque(
  text-content,
  width: 250pt,
  height: 146pt,
  radius: 13pt,
  font-size: 22.5pt,
  font-weight: "medium",
  tracking: 0.10em,
  line-leading: 0.70em,
  v-padding: 1.8em,
) = {
  let sans-fonts = fonts-for-current-lang.sans

  // Multi-layer 3D chiseled inscription generator
  let carved-inscription(body) = {
    let base-style(content, fill: black) = text(
      font: sans-fonts,
      size: font-size,
      weight: font-weight,
      tracking: tracking,
      fill: fill,
      content,
    )

    box[
      #set par(leading: line-leading, justify: false)
      #set align(center)

      // 1. Bottom-right specular rim highlight (simulating reflected light along chiseled groove)
      #place(
        center + horizon,
        dx: 0.85pt,
        dy: 0.95pt,
        base-style(body, fill: rgb(240, 244, 248, 220)),
      )

      // 2. Primary recessed cast shadow (top-left inner edge)
      #place(
        center + horizon,
        dx: -0.95pt,
        dy: -0.95pt,
        base-style(body, fill: rgb(32, 35, 39, 235)),
      )

      // 3. Secondary shadow for soft gradient beveling
      #place(
        center + horizon,
        dx: -0.45pt,
        dy: -0.45pt,
        base-style(body, fill: rgb(18, 20, 23, 175)),
      )

      // 4. Recessed groove body
      #place(
        center + horizon,
        base-style(body, fill: rgb(88, 93, 98, 245)),
      )

      // Invisible layout placeholder to establish natural box dimensions
      #hide(base-style(body, fill: black))
    ]
  }

  align(center)[
    #block(inset: (y: v-padding))[
      #box(width: width, height: height)[
        // Cast drop shadow below stone slab
        #place(
          top + left,
          dx: 5pt,
          dy: 5.5pt,
          rect(
            width: width,
            height: height,
            radius: radius,
            fill: rgb(0, 0, 0, 50),
          ),
        )
        #place(
          top + left,
          dx: 2.5pt,
          dy: 3pt,
          rect(
            width: width,
            height: height,
            radius: radius,
            fill: rgb(0, 0, 0, 80),
          ),
        )

        // Outer beveled edge
        #place(
          top + left,
          rect(
            width: width,
            height: height,
            radius: radius,
            fill: gradient.linear(
              angle: 135deg,
              rgb("#cacfd5"),
              rgb("#767a80"),
              rgb("#4a4d52"),
            ),
          ),
        )

        // Stone face container with granite texture and clipped corners
        #place(
          center + horizon,
          box(
            width: width - 3.2pt,
            height: height - 3.2pt,
            radius: radius - 1.6pt,
            stroke: 0.5pt + rgb(110, 115, 120, 160),
            clip: true,
            [
              // Procedural granite texture background
              #place(
                top + left,
                image(
                  "stone_plaque_granite.jpg",
                  width: 100%,
                  height: 100%,
                  fit: "stretch",
                ),
              )

              // Inner metallic edge highlights
              #place(
                top + left,
                rect(
                  width: 100%,
                  height: 100%,
                  radius: radius - 1.6pt,
                  stroke: (
                    top: 0.75pt + rgb(255, 255, 255, 80),
                    left: 0.75pt + rgb(255, 255, 255, 80),
                    bottom: 0.75pt + rgb(0, 0, 0, 75),
                    right: 0.75pt + rgb(0, 0, 0, 75),
                  ),
                ),
              )

              // Centered engraved inscription
              #align(center + horizon)[
                #carved-inscription(text-content)
              ]
            ],
          ),
        )
      ]
    ]
  ]
}
