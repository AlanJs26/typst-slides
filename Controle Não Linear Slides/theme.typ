// University theme

// Originally contributed by Pol Dellaiera - https://github.com/drupol

#import "@preview/touying:0.6.1": *

#let theme = (
  heading: (
    font: "Barlow"
  )
)

#let slide(
  config: (:),
  repeat: auto,
  setting: body => body,
  composer: auto,
  align: auto,
  ..bodies,
) = touying-slide-wrapper(self => {
  if align != auto {
    self.store.align = align
  }
  let header(self) = {
    set std.align(top)
    grid(
      rows: (auto, auto),
      row-gutter: 5mm,
      if self.store.progress-bar {
        components.progress-bar(height: 2pt, self.colors.primary, self.colors.tertiary)
      },
      grid(
        inset: (x: .6em, y: .3em),
        row-gutter: 5pt,
        components.left-and-right(
          text(fill: self.colors.primary, weight: "bold", size: 1.6em, utils.call-or-display(self, self.store.header)),
          text(fill: self.colors.primary.lighten(65%), utils.call-or-display(self, self.store.header-right)),
        ),
        line(length: 100%)
      ),
    )
        place(right, dx: -1cm, dy: -0.5cm)[
      #set text(size: 20pt, self.colors.primary, weight: "regular")
      #context utils.slide-counter.display()
    ]
  }
  let footer(self) = {    
    set std.align(center + bottom)

    v(10pt)
  }
  let self = utils.merge-dicts(
    self,
    config-page(
      header: header,
      footer: footer,
    ),
  )
  let new-setting = body => {
    show: std.align.with(self.store.align)
    show: setting
    v(1.3em)

    body
  }
  touying-slide(self: self, config: config, repeat: repeat, setting: new-setting, composer: composer, ..bodies)
})

#let outline-slide(
  config: (:),
  title: "Tópicos",
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
  )
  self.page.margin = 0pt
  let body = {
    rect(height: 100%, width: 100%, fill: self.colors.primary, align(horizon+center, [
      #set text(fill: white)
      = #title
    ]))
  }
  let outline-body = box(inset: (top: 30pt, bottom: 30pt, right: 30pt), {
    outline(title: none)
  })
  touying-slide(self: self, composer: (1fr, 2fr), body, outline-body)
})

#let title-slide(
  config: (:),
  extra: none,
  ..args,
) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config,
    config-common(freeze-slide-counter: true),
  )
  let info = self.info + args.named()
  info.authors = {
    let authors = if "authors" in info {
      info.authors
    } else {
      info.author
    }
    if type(authors) == array {
      authors
    } else {
      (authors,)
    }
  }
  let authors = info.authors.map(it => (it, none))

  if self.store.nusp != none {
    if type(self.store.nusp) != array {
      self.store.nusp = (self.store.nusp,)
    }
    for (i,nusp) in self.store.nusp.enumerate() {
      authors.at(i).at(1) = nusp
    }
  }
  
  let body = {
    std.align(
      center + horizon,
      {
        block(
          inset: 0em,
          breakable: false,
          {
            text(size: 2em, fill: self.colors.primary, strong(info.title))
            if info.subtitle != none {
              parbreak()
              text(size: 1.2em, fill: self.colors.primary, info.subtitle)
            }
          },
        )
        v(1em)
        set text(size: .8em)
        grid(
          columns: (1fr,) * calc.min(info.authors.len(), 3),
          column-gutter: 1em,
          row-gutter: 1em,
          ..authors.map(((author, nusp),) => {
            if nusp != none [
              #text(fill: self.colors.neutral-darkest, author) \
              #text(size: 12pt)[
                #nusp
              ]
            ] else {
              text(fill: self.colors.neutral-darkest, author)
            }
          })
        )
        v(1em)
        if info.institution != none {
          parbreak()
          text(size: .9em, info.institution)
        }
        if info.date != none {
          parbreak()
          text(size: .8em, utils.display-info-date(self))
        }
      },
    )
  }
  touying-slide(self: self, body)
})

#let new-section-slide(config: (:), level: 1, numbered: true, body) = touying-slide-wrapper(self => {
  let slide-body = {
    set std.align(horizon)
    show: pad.with(20%)
    
    stack(
      dir: ttb,
      spacing: 5mm,
      text(size: 1.8em, fill: self.colors.primary, weight: "bold", font: self.store.header-font,
        utils.display-current-heading(level: level, numbered: numbered)
      ),
      block(
        height: 2pt,
        width: 100%,
        spacing: 0pt,
        components.progress-bar(height: 1mm, self.colors.primary, self.colors.primary-light),
      ),
    )
    body
  }
  touying-slide(self: self, config: config, slide-body)
})

#let focus-slide(config: (:), background-color: none, background-img: none, body) = touying-slide-wrapper(self => {
  let background-color = if background-img == none and background-color == none {
    rgb(self.colors.primary)
  } else {
    background-color
  }
  let args = (:)
  if background-color != none {
    args.fill = background-color
  }
  if background-img != none {
    args.background = {
      set image(fit: "stretch", width: 100%, height: 100%)
      background-img
    }
  }
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 1em, ..args),
  )
  set text(fill: self.colors.neutral-lightest, weight: "bold", size: 2em)
  touying-slide(self: self, std.align(horizon, body))
})

#let matrix-slide(config: (:), columns: none, rows: none, ..bodies) = touying-slide-wrapper(self => {
  self = utils.merge-dicts(
    self,
    config-common(freeze-slide-counter: true),
    config-page(margin: 0em),
  )
  touying-slide(self: self, config: config, composer: components.checkerboard.with(columns: columns, rows: rows), ..bodies)
})


#let university-theme(
  aspect-ratio: "16-9",
  align: top,
  progress-bar: true,
  header: utils.display-current-heading(level: 2, style: auto),
  header-right: self => [],
  nusp: none,
  ..args,
  body,
) = {
  show: touying-slides.with(
    config-page(
      paper: "presentation-" + aspect-ratio,
      header-ascent: 0em,
      footer-descent: 0em,
      margin: (top: 2em, bottom: 1.25em, x: 1em),
    ),
    config-common(
      slide-fn: slide,
      new-section-slide-fn: new-section-slide,
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt, font: "Noto Sans")
        show heading.where(level: 3): set text(fill: self.colors.primary)
        show heading.where(level: 4): set text(fill: self.colors.primary)
        show heading: set text(font: self.store.header-font)

        body
      },
      alert: utils.alert-with-primary-color,
    ),
    config-colors(
      primary: rgb("#131B47"),
      secondary: rgb("#F6E801"),
      tertiary: rgb("#448C95"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#000000"),
    ),
    // save the variables for later use
    config-store(
      align: align,
      progress-bar: progress-bar,
      header: header,
      header-right: header-right,
      header-font: "Barlow",
      text-font: "Barlow",
      nusp: nusp,
    ),
    ..args,
  )
  [
    #body
  ]

}