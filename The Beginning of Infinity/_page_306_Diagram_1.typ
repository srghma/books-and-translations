#let arrow-step(
  label,
  arrow: $arrow.r.double$,
  arrow-size: 1.3em,
) = align(center + horizon)[
  #text(style: "italic")[#label] \
  #v(-2pt)
  #text(size: arrow-size)[#arrow]
]

#import "i18n.typ": current-lang, load-i18n

// Initialize translator for this diagram
#let t = load-i18n("_page_14_Diagram_2.i18n.yml")

#let input = $X$
#let output = $f(X)$
#let step1 = t("splitting")
#let step2 = t("interference")
#let branches = ([$Y_1$], [$Y_2$])
#let last-branch = $Y(italic(#t("many")))$

// Pipeline diagram (no default content values; keyed arguments)
#let pipeline-diagram(
  show-dots: true,

  // Sizing & styling defaults
  box-size: (80pt, 80pt),
  arrow-widths: (85pt, 95pt),
  branch-width: 75pt,
  branch-row-height: 22pt,
  stroke: 0.8pt,
  arrow: $arrow.r.double$,
  column-gutter: 0pt,
) = {
  let (box-w, box-h) = box-size
  let (arrow-w1, arrow-w2) = arrow-widths

  align(center)[
    #grid(
      columns: (box-w, arrow-w1, branch-width, arrow-w2, box-w),
      column-gutter: column-gutter,
      align: center + horizon,

      // 1. Left Box (Input)
      rect(width: box-w, height: box-h, stroke: stroke)[
        #align(center + horizon)[#input]
      ],

      // 2. Arrow 1 (Step 1)
      arrow-step(step1, arrow: arrow),

      // 3. Middle Column (Branches)
      stack(
        spacing: 0pt,
        if branches.len() > 0 {
          table(
            columns: branch-width,
            rows: branches.len() * (branch-row-height,),
            stroke: stroke,
            align: center + horizon,
            ..branches,
          )
        },
        if show-dots {
          stack(
            v(4pt),
            $dots.v$,
            v(4pt),
          )
        },
        if last-branch != none {
          rect(width: branch-width, height: branch-row-height, stroke: stroke)[
            #align(center + horizon)[#last-branch]
          ]
        },
      ),

      // 4. Arrow 2 (Step 2)
      arrow-step(step2, arrow: arrow),

      // 5. Right Box (Output)
      rect(width: box-w, height: box-h, stroke: stroke)[
        #align(center + horizon)[#output]
      ],
    )
  ]
}
