// Top spacing and centered title
#align(center)[
  #text(size: 15pt, style: "italic")[Contents]
]

#v(3.5em)

// Centered content block
#align(center)[
  #block(width: 82%)[
    #set text(size: 9.5pt)
    #grid(
      columns: (1.6em, 1fr, auto),
      row-gutter: 0.7em,
      align: (right + top, left + top, right + top),

      // Front Matter
      [], [_Acknowledgements_], [vi],
      [], [_Introduction_], [vii],

      // Gap between front matter and chapters
      grid.cell(colspan: 3)[#v(0.8em)],

      // Chapters
      [1.], [The Reach of Explanations], [1],
      [2.], [Closer to Reality], [34],
      [3.], [The Spark], [42],
      [4.], [Creation], [78],
      [5.], [The Reality of Abstractions], [107],
      [6.], [The Jump to Universality], [125],
      [7.], [Artificial Creativity], [148],
      [8.], [A Window on Infinity], [164],
      [9.], [Optimism], [196],
      [10.], [A Dream of Socrates], [223],
      [11.], [The Multiverse], [258],
      [12.], [A Physicist's History of Bad Philosophy], [305],
      [13.], [Choices], [326],
      [14.], [Why are Flowers Beautiful?], [353],
      [15.], [The Evolution of Culture], [369],
      [16.], [The Evolution of Creativity], [398],
      [17.], [Unsustainable], [418],
      [18.], [The Beginning], [443],

      // Gap between chapters and back matter
      grid.cell(colspan: 3)[#v(0.8em)],

      // Back Matter
      [], [_Bibliography_], [460],
      [], [_Index_], [463],
    )
  ]
]
