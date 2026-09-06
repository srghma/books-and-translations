#import "i18n.typ": current-lang, fonts-for-current-lang, load-i18n
#let t = load-i18n("_page_295_Diagram_3.i18n.yml")

#let obj-w = 30pt
#let left-rest-w = 52pt
#let right-rest-w = 132pt
#let row-h = 16pt
#let box-h = 2 * row-h
#let header-h = 16pt
#let stroke-val = 0.6pt

#let sans-fonts = fonts-for-current-lang.sans

#v(0.6em)
#align(center)[
  #grid(
    columns: (obj-w + left-rest-w, 48pt, obj-w + right-rest-w),
    column-gutter: 0pt,
    row-gutter: 0pt,
    align: (top + center, top + center, top + center),

    // --- Left Box & Header ---
    stack(
      spacing: 0pt,
      box(width: obj-w + left-rest-w, height: header-h)[
        #grid(
          columns: (obj-w, left-rest-w),
          align: (center + bottom, center + bottom),
          text(font: sans-fonts, size: 8pt)[#t("Object")], [],
        )
      ],
      v(1pt),
      table(
        columns: (obj-w, left-rest-w),
        rows: box-h,
        align: center + horizon,
        stroke: stroke-val,
        [$X$],
        [
          #set text(font: sans-fonts, size: 7.5pt)
          #set par(leading: 0.3em)
          #t("Rest of\nworld")
        ],
      ),
    ),

    // --- Arrow 1 (splitting) ---
    box(height: header-h + 1pt + box-h)[
      #align(center + bottom)[
        #pad(bottom: 6pt)[
          #text(font: sans-fonts, style: "italic", size: 8pt)[#t("splitting")]\
          #text(size: 2em)[$arrow.r.double$]
        ]
      ]
    ],

    // --- Right Box with Arrow & Bottom Box ---
    stack(
      spacing: 0pt,
      // Top labels
      box(width: obj-w + right-rest-w, height: header-h)[
        #grid(
          columns: (obj-w, right-rest-w),
          align: (center + bottom, center + bottom),
          text(font: sans-fonts, size: 8pt)[#t("Object")], text(font: sans-fonts, size: 8pt)[#t("Rest of world")],
        )
      ],
      v(1pt),
      // Split box
      table(
        columns: (obj-w, right-rest-w),
        rows: (row-h, row-h),
        align: center + horizon,
        stroke: stroke-val,
        [$X$],
        table.cell(rowspan: 2)[
          #set text(font: sans-fonts, size: 7.5pt)
          #set par(leading: 0.3em)
          #t("Not differentially\naffected by X and Y")
        ],
        [$Y$],
      ),
      // Arrow 2 (interference) under Object column
      box(width: obj-w + right-rest-w, height: 38pt)[
        #place(top + left, dx: obj-w / 2 - 35pt)[
          #box(width: 70pt)[
            #align(center)[
              #v(2pt)
              #text(font: sans-fonts, style: "italic", size: 8pt)[#t("interference")]\
              #text(size: 1.8em)[$arrow.b.double$]
            ]
          ]
        ]
      ],
      // Bottom box
      table(
        columns: (obj-w, right-rest-w),
        rows: box-h,
        align: center + horizon,
        stroke: stroke-val,
        [$X$],
        [
          #set text(font: sans-fonts, size: 7.5pt)
          #set par(leading: 0.3em)
          #t("Not differentially\naffected by X and Y")
        ],
      ),
    ),
  )
]
#v(0.6em)
