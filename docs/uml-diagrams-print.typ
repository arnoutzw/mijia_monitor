// Mijia Monitor — UML Diagrams Print
// Auto-generated Typst document for full-page UML diagram printing

#set text(font: "Helvetica", size: 12pt)

// ── Title Page (portrait) ──
#page(paper: "a4", margin: 1cm)[
  #align(center + horizon)[
    #text(size: 28pt, weight: "bold")[Mijia Monitor]
    #v(0.5cm)
    #text(size: 18pt)[UML Diagrams]
    #v(1cm)
    #text(size: 12pt, fill: luma(100))[Black Sphere Industries]
    #v(0.3cm)
    #text(size: 10pt, fill: luma(140))[Generated #datetime.today().display()]
  ]
]

// ── Architecture Diagram (landscape: 5551x2134) ──
#page(paper: "a4", margin: 1cm, flipped: true)[
  #text(size: 9pt, fill: luma(100))[Architecture Diagram]
  #v(0.15cm)
  #block(width: 100%, height: 1fr)[
    #image("uml-architecture.svg", fit: "contain", width: 100%, height: 100%)
  ]
]

// ── Class Diagram (landscape: 3829x2618) ──
#page(paper: "a4", margin: 1cm, flipped: true)[
  #text(size: 9pt, fill: luma(100))[Class Diagram]
  #v(0.15cm)
  #block(width: 100%, height: 1fr)[
    #image("uml-class-diagram.svg", fit: "contain", width: 100%, height: 100%)
  ]
]

// ── All Diagrams Overview (landscape: 16151x4221) ──
#page(paper: "a4", margin: 1cm, flipped: true)[
  #text(size: 9pt, fill: luma(100))[All Diagrams Overview]
  #v(0.15cm)
  #block(width: 100%, height: 1fr)[
    #image("uml-diagrams.svg", fit: "contain", width: 100%, height: 100%)
  ]
]

// ── Sequence — Main (portrait: 2731x3851) ──
#page(paper: "a4", margin: 1cm, flipped: false)[
  #text(size: 9pt, fill: luma(100))[Sequence Diagram — Main]
  #v(0.15cm)
  #block(width: 100%, height: 1fr)[
    #image("uml-seq-main.svg", fit: "contain", width: 100%, height: 100%)
  ]
]

// ── Sequence — Secondary (portrait: 1913x4041) ──
#page(paper: "a4", margin: 1cm, flipped: false)[
  #text(size: 9pt, fill: luma(100))[Sequence Diagram — Secondary]
  #v(0.15cm)
  #block(width: 100%, height: 1fr)[
    #image("uml-seq-secondary.svg", fit: "contain", width: 100%, height: 100%)
  ]
]

// ── State Diagram (landscape: 1952x1223) ──
#page(paper: "a4", margin: 1cm, flipped: true)[
  #text(size: 9pt, fill: luma(100))[State Diagram]
  #v(0.15cm)
  #block(width: 100%, height: 1fr)[
    #image("uml-states.svg", fit: "contain", width: 100%, height: 100%)
  ]
]
