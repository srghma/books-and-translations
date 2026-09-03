// Global Language Setting
#let current-lang = "en" // Change to "km", "de", etc.

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
      panic("Missing '" + current-lang + "' translation in " + yaml-path + " for key: " + repr(key))
    }

    str-to-lines(translation)
  }
}
