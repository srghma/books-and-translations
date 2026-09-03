#import "@preview/transl:0.2.1": transl

// Global Language Setup
#set text(lang: "en")
#transl(data: yaml("i18n.yml"))

// Typography
#let fonts = (
  "Noto Sans Khmer", // TODO: khmer fonts only if lang is khmer
  "Khmer OS",
  "Trebuchet MS",
  "Impact",
  "Liberation Sans",
  "Arial",
  "sans-serif",
)

// Render Cover (Page 1 is black)
// Page 1: Dark Cover (In Khmer, "THE" is empty and skipped automatically)
#import "cover.typ": cover-page
#cover-page(
  (
    (transl("THE"), 0.8),
    (transl("BEGINNING"), 1),
    (transl("OF"), 0.8),
    (transl("INFINITY"), 1),
    (transl("EXPLANATIONS_THAT_TRANSFORM_THE_WORLD"), 0.3),
    (transl("DAVID_DEUTSCH"), 0.9),
    (transl("AUTHOR_OF"), 0.3),
    (transl("THE_FABRIC_OF_REALITY"), 0.6),
  ),
  fonts,
)

#pagebreak()


// Front Matter / Title page
#align(center)[
  #v(20mm)
  #text(size: 18pt, weight: "bold")[DAVID DEUTSCH]

  #v(10mm)
  #text(size: 24pt, weight: "bold")[The Beginning of Infinity] \
  #v(2mm)
  #text(size: 14pt, style: "italic")[Explanations that Transform the World]

  #v(35mm)
  #smallcaps[Viking]
]

#pagebreak()

// Publication Details / Imprint
#align(bottom)[
  #set text(size: 8.5pt)
  VIKING Published by the Penguin Group \
  Penguin Group (USA) Inc., 375 Hudson Street, New York, New York 10014, U.S.A. \
  ...
]

#pagebreak()

// Table of Contents
== #emph[Contents] <contents>

#outline(indent: 1.5em)

#pagebreak()

// Chapters follow naturally with normal white styling
= 1 The Reach of Explanations <the-reach-of-explanations>

#quote(block: true)[
  #emph[Behind it all is surely an idea so simple, so beautiful...]
]

// #box(
//   image(
//     "page_000001_7bd4b17144abe628f736807cd0479caec5f0fa6c48f802391f34c00238e8aa9e.png",
//   ),
// )

#strong[EXPLANATIONS THAT TRANSFORM THE WORLD]

#strong[DAVID DEUTSCH]

#strong[AUTHOR OF]

#strong[THE FABRIC OF REALITY]

DAVID DEUTSCH

The Beginning of Infinity \
#emph[Explanations that Transform the World]

VIKING

=== The Beginning of Infinity
<the-beginning-of-infinity>
#box(image("_page_3_Picture_1.jpeg"))

DAVID DEUTSCH

The Beginning of Infinity \
#emph[Explanations that Transform the World]

VIKING

VIKING Published by the Penguin Group Penguin Group (USA) Inc., 375
Hudson Street, New York, New York 10014, U.S.A. Penguin Group (Canada),
90 Eglinton Avenue East, Suite 700, Toronto, Ontario, Canada M4P 2Y3 (a
division of Pearson Penguin Canada Inc.) Penguin Books Ltd, 80 Strand,
London WC2R 0RL, England Penguin Ireland, 25 St.~Stephen's Green, Dublin
2, Ireland (a division of Penguin Books Ltd) Penguin Books Australia
Ltd, 250 Camberwell Road, Camberwell, Victoria 3124, Australia (a
division of Pearson Australia Group Pty Ltd) Penguin Books India Pvt
Ltd, 11 Community Centre, Panchsheel Park, New Delhi -- 110 017, India
Penguin Group (NZ), 67 Apollo Drive, Rosedale, Auckland 0632, New
Zealand (a division of Pearson New Zealand Ltd) Penguin Books (South
Africa) (Pty) Ltd, 24 Sturdee Avenue, Rosebank, Johannesburg 2196, South
Africa Penguin Books Ltd, Registered Offices: 80 Strand, London WC2R
0RL, England Published in 2011 by Viking Penguin, a member of Penguin
Group (USA) Inc.

#quote(block: true)[
  Copyright © David Deutsch, 2011 All rights reserved
]

Excerpts from The World of Parmenides by Karl Popper, edited by Arne F.
Petersen (Routledge, 1998). Used by permission of the University of
Klagenfurt, Karl Popper Library.

Illustration on page 34: Starfield image from the Digitized Sky Survey
(© AURA) courtesy of the Palomar Observatory and Digitized Sky Survey,
created by the Space Telescope Science Institute, operated by AURA,
Inc.~for NASA. Reproduced with permission of AURA/STScI.

Illustration on page 426: © Bettmann/Corbis

LIBRARY OF CONGRESS CATALOGING IN PUBLICATION DATA

Deutsch, David. The beginning of infinity : explanations that transform
the world / David Deutsch. p.~cm. Includes bibliographical references
and index. 1. Explanation. 2. Infinite. 3. Science---Philosophy. I.
Title. Q175.32.E97D48 2011 501---dc22 2011004120 ISBN: 978-1-101-54944-5

Without limiting the rights under copyright reserved above, no part of
this publication may be reproduced, stored in or introduced into a
retrieval system, or transmitted, in any form or by any means
(electronic, mechanical, photocopying, recording or otherwise), without
the prior written permission of both the copyright owner and the above
publisher of this book.

The scanning, uploading, and distribution of this book via the Internet
or via any other means without the permission of the publisher is
illegal and punishable by law. Please purchase only authorized
electronic editions and do not participate in or encourage electronic
piracy of copyrightable materials. Your support of the author's rights
is appreciated.

=== #emph[Contents]
<contents>
#figure(
  align(center)[#table(
    columns: 2,
    align: (auto, auto),
    table.header([Acknowledgements], [vi]),
    table.hline(),
    [Introduction], [vii],
    [\1. The Reach of Explanations], [1],
    [\2. Closer to Reality], [34],
    [\3. The Spark], [42],
    [\4. Creation], [78],
    [\5. The Reality of Abstractions], [107],
    [\6. The Jump to Universality], [125],
    [\7. Artificial Creativity], [148],
    [\8. A Window on Infinity], [164],
    [\9. Optimism], [196],
    [\10. A Dream of Socrates], [223],
    [\11. The Multiverse], [258],
    [\12. A Physicist's History of Bad Philosophy], [305],
    [\13. Choices], [326],
    [\14. Why are Flowers Beautiful?], [353],
    [\15. The Evolution of Culture], [369],
    [\16. The Evolution of Creativity], [398],
    [\17. Unsustainable], [418],
    [\18. The Beginning], [443],
    [Bibliography], [460],
    [Index], [463],
  )],
  kind: table,
)
