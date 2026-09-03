#let title-page(
  author: "",
  title: "",
  subtitle: none,
  publisher: "VIKING",
  lang: "en",
  fonts: (),
) = {
  let is-km = lang == "km"

  // Khmer script has no uppercase and tracking breaks vowel/subscript clusters
  let cap-track(text-content, tracking: 0.26em, size: 1em) = {
    text(
      size: size,
      tracking: if is-km { 0em } else { tracking },
      if is-km { text-content } else { upper(text-content) },
    )
  }

  set text(font: fonts, lang: lang)
  set align(center)

  // Top spacing to position author block around ~15% down
  v(1.4fr)

  // Author
  if author != "" {
    cap-track(author, tracking: 0.26em, size: 1.15em)
  }

  v(1.8em)

  // Main Title
  if title != "" {
    text(size: 2.1em, weight: "regular", title)
  }

  // Subtitle
  if subtitle != none and subtitle != "" {
    v(0.85em)
    text(
      size: 1.35em,
      style: if is-km { "normal" } else { "italic" },
      subtitle,
    )
  }

  // Pushes publisher to the bottom
  v(5.5fr)

  // Publisher
  if publisher != none and publisher != "" {
    cap-track(publisher, tracking: 0.24em, size: 0.95em)
  }

  // Bottom margin
  v(1.2fr)
}
