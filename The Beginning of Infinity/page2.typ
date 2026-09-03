#let title-page(
  author: "",
  title: "",
  subtitle: none,
  publisher: none,
  lang: "en",
  fonts: (),
) = {
  // Khmer has no uppercase and tracking breaks Khmer subscript/vowel clusters
  let is-km = lang == "km"
  let cap-track(text-content, tracking: 0.25em, size: 1em) = {
    text(
      size: size,
      tracking: if is-km { 0em } else { tracking },
      if is-km { text-content } else { upper(text-content) },
    )
  }

  set text(font: fonts, lang: lang)
  set align(center)

  // Flexible vertical proportions that adapt to any page size/margin
  v(1.2fr)

  if author != "" {
    cap-track(author, tracking: 0.25em, size: 1.1em)
  }

  v(1.8em)

  if title != "" {
    text(size: 1.9em, weight: "regular", title)
  }

  if subtitle != none and subtitle != "" {
    v(0.8em)
    text(
      size: 1.25em,
      style: if is-km { "normal" } else { "italic" },
      subtitle,
    )
  }

  v(4fr)

  if publisher != none and publisher != "" {
    cap-track(publisher, tracking: 0.22em, size: 0.95em)
  }

  v(0.8fr)
}
