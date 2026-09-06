#let extract-speaker-and-text(elements) = {
  // Strip leading spaces
  let items = ()
  let started = false
  for it in elements {
    if not started {
      if it.func() == [ ].func() { continue }
      if it.has("text") and it.text.trim() == "" { continue }
      started = true
    }
    items.push(it)
  }

  // Find colon ':'
  let colon-idx = -1
  let split-text-at = -1
  for (i, it) in items.enumerate() {
    if it.has("text") {
      let idx = it.text.position(":")
      if idx != none {
        colon-idx = i
        split-text-at = idx
        break
      }
    }
  }

  if colon-idx == -1 {
    // Fallback: no colon found, return all as text
    return ([], items.join())
  }

  let speaker-items = items.slice(0, colon-idx)
  let colon-elem = items.at(colon-idx)
  let text-items = ()

  let text-str = colon-elem.text
  let before-colon = text-str.slice(0, split-text-at + 1)
  let after-colon = text-str.slice(split-text-at + 1)

  speaker-items.push(before-colon)

  if after-colon.trim().len() > 0 {
    text-items.push(after-colon.trim-start())
  }

  let rest = items.slice(colon-idx + 1)
  // Strip leading space from rest
  let rest-started = false
  for it in rest {
    if not rest-started and text-items.len() == 0 {
      if it.func() == [ ].func() { continue }
      if it.has("text") and it.text.trim() == "" { continue }
      rest-started = true
    }
    text-items.push(it)
  }

  (speaker-items.join(), text-items.join())
}

#let split-by-parbreak(children) = {
  let pars = ()
  let current = ()
  for child in children {
    if child.func() == parbreak {
      if current.len() > 0 {
        pars.push(current)
        current = ()
      }
    } else {
      current.push(child)
    }
  }
  if current.len() > 0 {
    pars.push(current)
  }
  pars
}

#let simultaneous(speaker1, text1, speaker2, text2) = par(first-line-indent: 0pt, hanging-indent: 0pt)[
  #context {
    let brace = text(size: 2.2em, weight: "light")[}]
    
    // Calculate width so both names & the brace align perfectly
    let name-w = calc.max(measure(speaker1).width, measure(speaker2).width)
    let prefix-w = name-w + measure(brace).width + 0.6em

    // Line 1: First speaker + placed brace + dialogue
    box(width: prefix-w)[
      #speaker1
      #place(top + right, dx: -0.2em, dy: 0.15em, brace)
    ]
    text1
    linebreak()

    // Line 2+: Second speaker + dialogue (flows & overflows natively)
    box(width: prefix-w)[#speaker2]
    text2
  }
]

#let simultaneous-dialog2(attrs, body) = {
  if "speaker1" in attrs and "speaker2" in attrs {
    simultaneous(
      attrs.at("speaker1"),
      attrs.at("text1", default: []),
      attrs.at("speaker2"),
      attrs.at("text2", default: []),
    )
  } else if body != none {
    let children = if type(body) == content and body.has("children") {
      body.children
    } else {
      (body,)
    }
    let pars = split-by-parbreak(children)
    if pars.len() >= 2 {
      let (s1, t1) = extract-speaker-and-text(pars.at(0))
      let (s2, t2) = extract-speaker-and-text(pars.at(1))
      simultaneous(s1, t1, s2, t2)
    } else {
      body
    }
  }
}
