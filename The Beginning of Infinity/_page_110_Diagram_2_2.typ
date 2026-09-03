#set page(width: auto, height: auto, margin: 1cm)
#import "@preview/maquette:0.1.3": render-obj

#let scene = read("_page_110_Diagram_2.obj", encoding: none)

#align(center, render-obj(
  scene,
  up: (0, 0, 0.1),
  azimuth: -34,
  elevation: 1,
  distance: 5.2,
  background: none,
  shading: "flat",
  materials: (
    inner_cube: "#7c8186",
    outer_frame: "#000000",
    arrow: "#111111",
  ),
  highlight: (
    inner_cube: "#7c8186",
    outer_frame: "#000000",
    arrow: "#111111",
  ),
  lights: (
    (
      type: "directional",
      vector: (-0.9, -1.4, 1.8),
      color: "#ffffff",
      intensity: 1.15,
      cast_shadow: false,
    ),
    (
      type: "ambient",
      color: "#ffffff",
      intensity: 0.55,
    ),
  ),
  antialias: 4,
  width: 9cm,
))
