#let half-title-page(
  title: "",
  logo-width: 2.2cm,
  lang: "en",
  fonts: (),
) = {
  set text(font: fonts, lang: lang)
  set align(center)

  // Top spacing (~20-25% from page top)
  v(2.2fr)

  if title != "" {
    text(size: 1.85em, weight: "regular", title)
  }

  // Pushes logo down to bottom
  v(7fr)

  image("_page_3_Picture_1.png", width: logo-width)

  // Bottom margin breathing room
  v(1.4fr)
}
