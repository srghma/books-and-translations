// Global Language Setting
#let current-lang = sys.inputs.at("current-lang", default: "km") // Change to "km", "de", etc.

#let str-to-lines(str) = {
  str.split("\n").join([\ ])
}

// Reads a diagram's YAML file and returns a translator function
#let load-i18n(yaml-path) = {
  let dict = yaml(yaml-path)

  key => {
    if current-lang == "en" {
      return str-to-lines(key)
    }

    // Lookup the key in dict only once
    let entry = dict.at(key, default: none)
    if entry == none {
      panic("Translation key not found in " + yaml-path + ": " + repr(key))
    }

    let translation = entry.at(current-lang, default: none)
    if translation == none {
      panic(
        "Missing '" + current-lang + "' translation in " + yaml-path + " for key: " + repr(key),
      )
    }

    str-to-lines(translation)
  }
}

#let fonts-data = json("../fonts.json")
#let base-serif = fonts-data.at("base-serif", default: ())
#let base-sans = fonts-data.at("base-sans", default: ())
#let lang-to-fonts-map = fonts-data.at("lang-to-fonts-map", default: (:))

#let get-fonts-for-lang(lang) = {
  let lang-fonts = lang-to-fonts-map.at(str(lang), default: (:))

  (
    serif: lang-fonts.at("serif", default: ()) + base-serif,
    sans: lang-fonts.at("sans", default: ()) + base-sans,
  )
}

#let fonts-for-current-lang = {
  get-fonts-for-lang(current-lang)
}

#let get-font-bytes-for-lang(lang, style: "serif") = {
  let fonts-info = get-fonts-for-lang(lang)
  let list = fonts-info.at(style, default: ())
  for font-name in list {
    let font-path = "/.fonts/" + font-name
    return read(font-path, encoding: none)
  }
  panic("Could not find font for lang: " + str(lang))
}
