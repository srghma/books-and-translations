#import "i18n.typ": load-i18n
#import "stone_plaque.typ": carved-stone-plaque

// Initialize translator for this diagram
#let t = load-i18n("_page_75_Picture_2.i18n.yml")

#let plaque-text = t("PROBLEMS\nARE\nSOLUBLE")

/// Renders the carved granite tablet: "PROBLEMS ARE SOLUBLE"
#let problems-soluble-stone(..args) = {
  carved-stone-plaque(plaque-text, ..args)
}

// Default preview
#problems-soluble-stone()
