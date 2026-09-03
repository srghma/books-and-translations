#let get-fonts(lang) = {
  let base-serif = ("EB Garamond", "Libertinus Serif", "Times New Roman", "serif")
  let base-sans = ("Trebuchet MS", "Impact", "Liberation Sans", "Arial", "sans-serif")

  let lang-map = (
    km: (
      serif: ("Noto Serif Khmer", "Khmer OS"),
      sans: ("Noto Sans Khmer", "Khmer OS"),
    ),
    ja: (
      serif: ("Noto Serif CJK JP",),
      sans: ("Noto Sans CJK JP",),
    ),
    zh: (
      serif: ("Noto Serif CJK SC",),
      sans: ("Noto Sans CJK SC",),
    ),
    ar: (
      serif: ("Amiri",),
      sans: ("Noto Sans Arabic",),
    ),
  ).at(str(lang), default: (:))

  (
    lang-map.at("serif", default: ()) + base-serif,
    lang-map.at("sans", default: ()) + base-sans,
  )
}
