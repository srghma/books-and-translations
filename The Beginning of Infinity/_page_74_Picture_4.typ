#import "i18n.typ": load-i18n
#import "stone_plaque.typ": carved-stone-plaque

// Initialize translator for this diagram
#let t = load-i18n("_page_74_Picture_4.i18n.yml")

#let plaque-text = t("PROBLEMS\nARE\nINEVITABLE")

/// Renders the carved granite tablet: "PROBLEMS ARE INEVITABLE"
#let problems-inevitable-stone(..args) = {
  carved-stone-plaque(plaque-text, ..args)
}

// Default preview
#problems-inevitable-stone()
