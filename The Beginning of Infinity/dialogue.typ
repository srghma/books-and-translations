#let norm-apos(s) = s.replace("’", "'")

#let get-text(elem) = {
  if type(elem) == str {
    elem
  } else if elem.has("text") {
    elem.text
  } else if elem.func() == [ ].func() {
    " "
  } else if elem.has("children") {
    elem.children.map(get-text).join()
  } else if elem.has("body") {
    get-text(elem.body)
  } else {
    ""
  }
}

#let split-dialogue-elements(children) = {
  let items = ()
  let current = ()
  for c in children {
    if c.func() == parbreak {
      if current.len() > 0 {
        items.push(current)
        current = ()
      }
    } else if repr(c.func()) in ("sequence", "par") {
      if current.len() > 0 {
        items.push(current)
        current = ()
      }
      items.push((c,))
    } else {
      current.push(c)
    }
  }
  if current.len() > 0 {
    items.push(current)
  }
  items
}

#let render-blocks(blocks) = [
  #for b in blocks {
    for (i, item-info) in b.enumerate() {
      let item = item-info.elems
      if item.len() == 1 and repr(item.at(0).func()) in ("sequence", "par") {
        item.at(0)
      } else if i == 0 and item-info.actor != none {
        par(hanging-indent: 1.8em, first-line-indent: 0pt)[#item.join()]
      } else {
        let txt = item.map(get-text).join().trim()
        let is-stage-dir = txt.starts-with("[")
        let fli = if is-stage-dir { 1.8em } else { 1.8em + 1.5em }
        par(hanging-indent: 1.8em, first-line-indent: (amount: fli, all: true))[#item.join()]
      }
    }
  }
]

#let dialogue(attrs, body) = [
  #assert("actors" in attrs, message: "<dialogue> requires 'actors' attribute, e.g. <dialogue actors=\"HERMES,SOCRATES\" color=\"true\">")
  #assert("color" in attrs, message: "<dialogue> requires 'color' attribute, e.g. <dialogue actors=\"HERMES,SOCRATES\" color=\"true\">")

  #let actor-list = attrs.at("actors").split(",").map(a => a.trim()).filter(a => a.len() > 0)
  #let color-enabled = attrs.at("color") == "true"
  #let n = actor-list.len()

  #let actor-colors = (:)
  #for (i, a) in actor-list.enumerate() {
    let c = color.oklch(46%, 0.19, 20deg + i * (360deg / calc.max(n, 1)))
    actor-colors.insert(a, c)
  }

  #let sorted-actors = actor-list.sorted(by: (a, b) => a.len() > b.len())
  #let pat = if sorted-actors.len() > 0 {
    sorted-actors.map(a => {
      let esc = a.replace(".", "\\.").replace("'", "['’]").replace("’", "['’]")
      "\\b" + esc + "(?:['’][sS]|['’])?(?::|\\b)"
    }).join("|")
  } else {
    none
  }

  #let children = if body.has("children") { body.children } else { (body,) }
  #let items = split-dialogue-elements(children)

  #let get-actor-name(elems) = {
    let txt = norm-apos(elems.map(get-text).join().trim())
    for a in actor-list {
      if txt.starts-with(norm-apos(a) + ":") {
        return a
      }
    }
    none
  }

  #let blocks = ()
  #let current-block = ()

  #for item in items {
    let a = get-actor-name(item)
    if a != none and current-block.len() > 0 {
      blocks.push(current-block)
      current-block = ()
    }
    current-block.push((actor: a, elems: item))
  }
  #if current-block.len() > 0 {
    blocks.push(current-block)
  }

  #v(0.8em)
  #pad(x: 1.8em)[
    #set text(size: 9.5pt)
    #set par(
      justify: true,
      leading: 0.65em,
      spacing: 0.85em,
      first-line-indent: 0pt,
      hanging-indent: 0pt,
    )
    #if pat != none {
      show regex(pat): it => {
        let raw-text = it.text
        let norm-raw = norm-apos(raw-text)
        let matched-actor = none
        for a in sorted-actors {
          if norm-raw.starts-with(norm-apos(a)) {
            matched-actor = a
            break
          }
        }
        let c = if matched-actor != none and color-enabled {
          actor-colors.at(matched-actor)
        } else {
          none
        }
        if c != none {
          text(fill: c, tracking: 0.04em)[#smallcaps(lower(raw-text))]
        } else {
          text(tracking: 0.04em)[#smallcaps(lower(raw-text))]
        }
      }
      render-blocks(blocks)
    } else {
      render-blocks(blocks)
    }
  ]
  #v(0.8em)
]
