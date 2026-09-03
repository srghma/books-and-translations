#import "i18n.typ": current-lang, get-font-bytes-for-lang, load-i18n
#import "../perspective_warp/perspective_warp.typ": render-perspective-diagram

// Initialize translator for this diagram
#let t = load-i18n("_page_180_Figure_1.i18n.yml")

#let label-top = t("Natural numbers")
#let label-bot = t("Odd numbers")

#let natural-vs-odd-diagram(width: 100%) = {
  let font = get-font-bytes-for-lang(current-lang)
  render-perspective-diagram(
    top-label: label-top,
    bot-label: label-bot,
    font-top: font,
    font-bottom: font,
    top-start: 1,
    top-step: 1,
    bot-start: 1,
    bot-step: 2,
    rate: 0.00095,
    width: 1000.0,
    height: 240.0,
    output-width: width,
  )
}

// Default preview
#natural-vs-odd-diagram()
