#let rn(..args) = {
  let pos = args.pos()
  let body = if pos.len() > 1 { pos.at(1) } else if pos.len() == 1 { pos.at(0) } else { "" }
  box(text(font: ("Liberation Sans", "Arial"), weight: "bold", body))
}

// Archaic Roman 50: matches cap-height of sans-serif 'V'
#let roman-fifty(..args) = context {
  let m = measure(rn[V])
  let h = m.height
  let w = m.width * 0.95
  box(width: w, height: h)[#place(line(start: (w / 2, h), end: (0.8pt, 0pt), stroke: 0.85pt))#place(line(start: (w / 2, h), end: (w / 2, 0pt), stroke: 0.85pt))#place(line(start: (w / 2, h), end: (w - 0.8pt, 0pt), stroke: 0.85pt))#place(line(start: (-0.2pt, 0pt), end: (1.8pt, 0pt), stroke: 0.55pt))#place(line(start: (w / 2 - 1pt, 0pt), end: (w / 2 + 1pt, 0pt), stroke: 0.55pt))#place(line(start: (w - 1.8pt, 0pt), end: (w + 0.2pt, 0pt), stroke: 0.55pt))]
}

// Archaic Roman 500: sans-serif D with an internal horizontal crossbar
#let roman-five-hundred(..args) = box[#rn[D]#place(left + horizon, dx: 1.2pt, line(length: 4.8pt, stroke: 0.9pt))]

// Archaic Roman 1,000 (ↀ): oval/capsule split by central vertical line
#let roman-one-thousand(..args) = context {
  let m = measure(rn[O])
  let h = m.height
  let w = m.width * 1.15
  box(width: w, height: h, baseline: 0%)[#place(rect(width: w, height: h, radius: h / 2, stroke: 0.9pt))#place(top + left, dx: w / 2, line(start: (0pt, 0pt), end: (0pt, h), stroke: 0.9pt))]
}

// Tally dimensions
#let tally-h = 1.15em
#let tally-base = 0.25em
#let tally-stroke = 0.7pt
#let tally-step = 4.25pt

#let get-text(body) = {
  if body == none {
    ""
  } else if type(body) == str {
    body
  } else if type(body) == content {
    if body.has("text") {
      str(body.text)
    } else if body.func() == [ ].func() {
      " "
    } else if body.has("children") {
      if body.children.len() == 0 {
        ""
      } else {
        let res = body.children.map(get-text).join("")
        if res == none { "" } else { str(res) }
      }
    } else if body.has("body") {
      get-text(body.body)
    } else {
      ""
    }
  } else {
    ""
  }
}

#let render-tally-strokes(c, crossed: false) = {
  if crossed and c > 1 {
    let overhang = 2.5pt
    let w = (c - 1) * tally-step + 2 * overhang
    box(height: tally-h, baseline: tally-base)[
      #box(width: w, height: tally-h)[
        #place(top + left, dy: tally-h / 2, line(start: (0pt, 0pt), end: (w, 0pt), stroke: tally-stroke))
        #for i in range(c) {
          place(top + left, dx: overhang + i * tally-step, line(start: (0pt, 0pt), end: (0pt, tally-h), stroke: tally-stroke))
        }
      ]
    ]
  } else if c == 1 {
    box(height: tally-h, baseline: tally-base)[
      #box(width: 2.5pt, height: tally-h)[
        #place(top + left, line(start: (1.25pt, 0pt), end: (1.25pt, tally-h), stroke: tally-stroke))
      ]
    ]
  } else {
    let w = (c - 1) * tally-step + 2.5pt
    box(height: tally-h, baseline: tally-base)[
      #box(width: w, height: tally-h)[
        #for i in range(c) {
          place(top + left, dx: 1.25pt + i * tally-step, line(start: (0pt, 0pt), end: (0pt, tally-h), stroke: tally-stroke))
        }
      ]
    ]
  }
}

#let tally(..args) = {
  let pos = args.pos()
  let named = args.named()
  let attrs = if pos.len() > 0 { pos.at(0) } else { named.at("attrs", default: named) }
  let body = if pos.len() > 1 { pos.at(1) } else { named.at("body", default: none) }

  let count = attrs.at("count", default: attrs.at("n", default: none))
  let crossed = attrs.at("crossed", default: none)
  let is-crossed = (crossed != none and crossed != false and crossed != "false")
  let group = attrs.at("group", default: none)
  let raw-text = if body != none { str(get-text(body)).trim() } else { "" }

  if count != none {
    let c = int(count)
    if is-crossed {
      render-tally-strokes(c, crossed: true)
    } else if group != none and int(group) > 0 and c > int(group) {
      let g = int(group)
      let parts = ()
      let rem = c
      while rem > 0 {
        let cur = calc.min(rem, g)
        parts.push(cur)
        rem -= cur
      }
      let rendered = parts.map(cnt => render-tally-strokes(cnt, crossed: false))
      rendered.join(h(0.45em))
    } else {
      render-tally-strokes(c, crossed: false)
    }
  } else if raw-text != "" {
    let is-num = raw-text.clusters().all(ch => ch in ("0", "1", "2", "3", "4", "5", "6", "7", "8", "9"))
    if is-num {
      let c = int(raw-text)
      if is-crossed or (c == 5 and crossed != "false") {
        render-tally-strokes(c, crossed: true)
      } else {
        render-tally-strokes(c, crossed: false)
      }
    } else {
      let parts = raw-text.split(regex("\s+"))
      let rendered-parts = parts.map(part => {
        let c = part.clusters().filter(ch => ch in ("|", "⎥", "l", "I", "1", "/")).len()
        if c == 0 {
          none
        } else {
          let p-crossed = is-crossed or (c == 5 and crossed != "false")
          render-tally-strokes(c, crossed: p-crossed)
        }
      }).filter(p => p != none)
      rendered-parts.join(h(0.45em))
    }
  } else {
    if is-crossed {
      render-tally-strokes(5, crossed: true)
    } else {
      render-tally-strokes(1, crossed: false)
    }
  }
}
