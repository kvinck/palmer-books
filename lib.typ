// Shared page setup and ruling for the A5 Palmer notebook.
//
// All sizes derive from Palmer's "space": the height of a minimum letter
// (a, c, e, i, m, n, o, u, v, w, x), one-sixteenth of an inch. Ruled
// baselines are 3/8 in (six spaces) apart, as in Palmer's practice paper.

#import "@preview/droplet:0.3.1": dropcap

#let space = 1in / 16
#let pitch = 6 * space
// Room above the first baseline of a block: a full line, since capitals,
// loops, and the oval drills reach five or six spaces.
#let head = 6 * space
// Room below the last baseline: g descends three spaces.
#let tail = 3 * space
#let slant = 55deg
#let slant-gap = 10mm

#let page-width = 148mm
#let page-height = 210mm
// The inside margin leaves room for 6-ring holes punched 19-19-70-19-19 mm.
#let margin = (inside: 18mm, outside: 10mm, top: 10mm, bottom: 14mm)
#let body-width = page-width - margin.inside - margin.outside
#let body-height = page-height - margin.top - margin.bottom

#let strokes = (
  baseline: 0.5pt + luma(95),
  // Lines one, two, and three spaces above the baseline.
  space: 0.35pt + luma(155),
  loop: (paint: luma(165), thickness: 0.35pt, dash: "dashed"),
  slant: 0.3pt + luma(205),
  slot: (paint: luma(120), thickness: 0.45pt, dash: "dotted"),
)

// A prepared image rendered by tools/prepare_examples.py. Its recorded
// resolution makes its natural size its printed size.
#let image-path(name) = "images/" + name + ".png"

// Shift along the slant for a vertical rise of `rise`.
#let run(rise) = rise / calc.tan(slant)

// Draw a scanned example on the ruling. The prepared image is scaled so its
// measured space is exactly one space here, and its straightened baseline is
// its vertical center.
#let place-example(name, baseline-y) = context {
  let example = image(image-path(name))
  place(dy: baseline-y - measure(example).height / 2, example)
}

// A ruled block of `lines` writing lines. `examples` lists, line by line
// from the top, the name of the example whose baseline sits on that line, or
// `none` for a line without one; an example taller than a line (a two-line
// oval plate) sits on its lowest line. Lines without an example are divided
// into `slots` equal writing slots when `slots` is set. Without `guides`,
// only the baselines are drawn.
#let ruled(lines: 1, slots: none, examples: (), guides: true) = {
  let height = head + (lines - 1) * pitch + tail
  let baseline(k) = head + k * pitch
  block(width: 100%, height: height, clip: true, breakable: false, layout(size => {
    let width = size.width

    let x = -run(height)
    while guides and x < width {
      place(line(start: (x, height), end: (x + run(height), 0pt), stroke: strokes.slant))
      x += slant-gap
    }

    for k in range(lines) {
      let y = baseline(k)
      if guides {
        place(line(start: (0pt, y - 4 * space), length: width, stroke: strokes.loop))
        for n in range(1, 4) {
          place(line(start: (0pt, y - n * space), length: width, stroke: strokes.space))
        }
      }
      place(line(start: (0pt, y), length: width, stroke: strokes.baseline))
      if slots != none and examples.at(k, default: none) == none {
        for i in range(1, slots) {
          let sx = i * width / slots
          place(line(
            start: (sx, y),
            end: (sx + run(4 * space), y - 4 * space),
            stroke: strokes.slot,
          ))
        }
      }
    }

    for (k, name) in examples.enumerate() {
      if name != none { place-example(name, baseline(k)) }
    }
  }))
}

// A scanned plate shown at true size without ruling, for drills whose rows
// do not fall on 3/8 in ruling (the cross-line drills).
#let plate(name) = align(center, image(image-path(name)))

// As many blank practice lines as fit in `room`, if any.
#let fill-lines(room, guides: true) = {
  let lines = calc.floor((room - head - tail) / pitch) + 1
  if lines >= 1 { ruled(lines: lines, guides: guides) }
}

// Blank practice lines filling a whole page.
#let practice-page = fill-lines(body-height)

// Baselines alone, at the practice-line pitch, filling a whole page.
#let baseline-page = fill-lines(body-height, guides: false)

// A drill exercise: `top` (heading, prose, instruction) followed by a ruled
// block, as in `ruled`. A section keeps it whole on one page and may add
// practice lines to its ruled block to fill the page, or remove practice
// lines (never example lines) when it is taller than a page.
#let exercise(top, lines: 1, slots: none, examples: ()) = (
  top: top,
  lines: lines,
  slots: slots,
  examples: examples,
)

#let show-unit(unit, extra: 0) = block(width: 100%, if type(unit) == dictionary {
  unit.top
  ruled(lines: unit.lines + extra, slots: unit.slots, examples: unit.examples)
} else {
  unit
})

// Lays out a section's `units` (exercises, or other content kept whole on one
// page) from the top of a new page. A unit that does not fit in the room left
// on a page starts the next page. The room left on each page is filled with
// practice lines: shared evenly by the page's exercises, or as a block of
// blank lines on a page without one.
//
// Pagination is computed here from measured heights rather than from layout
// introspection, which would need one layout pass per page decision.
#let section(..units) = context {
  let gap = 4mm
  let pages = ((),)
  let used = 0pt
  let fill-page(items, used) = {
    let room = body-height - used
    let exercises = range(items.len()).filter(i => type(items.at(i).unit) == dictionary)
    if exercises.len() == 0 {
      // An empty filler would still take up a gap and overflow the page.
      let filler = fill-lines(room - gap)
      if filler != none { items.push((unit: filler, extra: 0)) }
    } else {
      // The small margin keeps rounding from pushing the last line over.
      let extra = calc.floor((room - 0.5pt) / pitch)
      for (j, i) in exercises.enumerate() {
        let share = calc.floor(extra / exercises.len())
        if j < calc.rem(extra, exercises.len()) { share += 1 }
        items.at(i).extra = share
      }
    }
    items
  }
  // An exercise whose text leaves no room for its examples puts the text on
  // a page of its own; the examples then start the next page.
  let flat = ()
  for unit in units.pos() {
    if type(unit) == dictionary {
      let least = measure(block(width: body-width, show-unit(
        (..unit, lines: calc.max(unit.examples.len(), 1)),
      ))).height
      if least > body-height {
        flat.push(unit.top)
        unit.top = none
      }
    }
    flat.push(unit)
  }
  for unit in flat {
    let height = measure(block(width: body-width, show-unit(unit))).height
    if type(unit) == dictionary and height > body-height {
      let cut = calc.ceil((height - body-height) / pitch)
      unit.lines -= cut
      height -= cut * pitch
      assert(
        unit.lines >= unit.examples.len(),
        message: "an exercise's examples do not fit on one page",
      )
    }
    assert(height <= body-height, message: "a section unit is taller than a page")
    let start = if pages.last() == () { 0pt } else { used + gap }
    if start + height > body-height {
      pages.last() = fill-page(pages.last(), used)
      pages.push(())
      start = 0pt
    }
    pages.last().push((unit: unit, extra: 0))
    used = start + height
  }
  pages.last() = fill-page(pages.last(), used)
  for (i, items) in pages.enumerate() {
    if i > 0 { pagebreak() }
    stack(spacing: gap, ..items.map(item => show-unit(item.unit, extra: item.extra)))
  }
}

// A prepared figure at the given width.
#let figure-image(name, width) = image(image-path(name), width: width)

// A figure from the original at its printed size, narrowed to fit its
// container, with a caption when the crop does not include its own.
#let illustration(name, caption: none) = {
  block(width: 100%, above: 1.2em, below: 1.2em, breakable: false, layout(size => align(center, {
    let printed = measure(image(image-path(name))).width
    figure-image(name, calc.min(printed, size.width))
    if caption != none { block(above: 0.4em, text(size: 7pt, caption)) }
  })))
}

// A drill's examples without ruling, as a reference in the lesson book: all
// at one width, except that plates of many rows are kept to a height.
#let drill-plate(number) = {
  let path = image-path("plate-drill-" + str(number))
  block(width: 100%, above: 0.8em, below: 1em, breakable: false, align(center, context {
    let natural = measure(image(path))
    image(path, width: calc.min(78mm, 45mm * (natural.width / natural.height)))
    block(above: 0.4em, text(size: 7pt)[Drill #number])
  }))
}

// Content laid out across the page's long side, turned so its top faces
// the binding; the page itself stays portrait for imposition and punching.
#let sideways(body) = rotate(-90deg, reflow: true, block(
  width: body-height,
  height: body-width,
  body,
))

#let section-heading(title, subtitle) = {
  set align(center)
  block(below: 0.4em, text(font: "Hoefler Text", weight: "black", size: 15pt, upper(title)))
  block(below: 1em, text(size: 8.5pt, subtitle))
}

// A paragraph opening with a large initial capital, as in the original. Give
// the opening word or words in capitals: `initial[#upper[No] progress ...]`.
#let initial(body) = dropcap(height: 2, gap: 2pt, font: "Hoefler Text", weight: "black", body)

// A title page for one of the books made from Palmer's.
#let title-page(book, description) = page(footer: none, {
  set align(center)
  set par(justify: false)
  v(1fr)
  stack(
    spacing: 3mm,
    text(weight: "black", size: 22pt, upper[The Palmer Method]),
    text(size: 14pt, style: "italic")[of],
    text(weight: "black", size: 22pt, upper[Business Writing]),
  )
  v(6mm)
  line(length: 30%, stroke: 0.5pt)
  v(6mm)
  text(weight: "black", size: 16pt, upper(book))
  v(2mm)
  block(width: 80%, text(size: 9.5pt, description))
  v(2fr)
  text(size: 11pt)[By A. N. Palmer]
  v(1mm)
  text(size: 8.5pt, style: "italic")[From the 1920 edition]
  v(1fr)
  text(size: 8.5pt, style: "italic")[Layout and typeset by Kevin Vinck]
})

// The metadata marks where the drill starts, for `index-columns`.
#let drill-heading(number, star: false) = {
  set text(font: "Hoefler Text", weight: "black", size: 15pt)
  block(below: 0.6em, [#upper[Drill #number#if star [\*]]#metadata((name: "Drill", first: number, last: number))<drill>])
}

// The entries with the given label, each a dictionary with the entry's
// `name` and the `first` and `last` numbers it covers, in balanced columns
// with their page numbers. Consecutive entries starting on the same page
// share one line, as in "Lesson 54–61".
#let index-columns(target) = context {
  let groups = ()
  for entry in query(target) {
    let location = entry.location()
    if groups.len() > 0 and groups.last().location.page() == location.page() {
      groups.last().last = entry.value.last
    } else {
      groups.push((..entry.value, location: location))
    }
  }
  let entries = groups.map(group => {
    let location = group.location
    let page = numbering(location.page-numbering(), ..counter(page).at(location))
    let label = if group.first == group.last [#group.name #group.first] else [#(group.name)s #group.first–#group.last]
    link(location)[#label #box(width: 1fr, repeat[.~]) #page]
  })
  let per-column = calc.ceil(entries.len() / 3)
  set par(justify: false)
  grid(
    columns: (1fr,) * 3,
    column-gutter: 6mm,
    ..entries.chunks(per-column).map(column => stack(spacing: 0.62em, ..column)),
  )
}

// Marks the start of a lesson for `index-columns`.
#let lesson-mark(first, last: none) = {
  let last = if last == none { first } else { last }
  [#metadata((name: "Lesson", first: first, last: last))<lesson>]
}

// "Drill 4", "Drills 4 and 5", or "Drills 4, 5, and 6".
#let drill-list(drills) = {
  let numbers = drills.map(str)
  if numbers.len() == 1 {
    [Drill #numbers.first()]
  } else if numbers.len() == 2 {
    [Drills #numbers.join(" and ")]
  } else {
    [Drills #numbers.join(", ", last: ", and ")]
  }
}

// A lesson in the lesson list: its number (or `last` for a run of review
// lessons) and drills on one line, the instructions for the lesson, and the
// drills' plates (`plates`, when they are not all of `drills`).
#let lesson(first, last: none, drills: (), plates: auto, body) = {
  let name = if last == none [Lesson #first] else [Lessons #first–#last]
  block(above: 1.3em, below: 0.6em, sticky: true, {
    text(weight: "black", name)
    lesson-mark(first, last: last)
    if drills.len() > 0 {
      [ #box(width: 1fr, repeat[.~]) #drill-list(drills)]
    }
  })
  body
  let plates = if plates == auto { drills } else { plates }
  for number in plates { drill-plate(number) }
}

#let instruction(body) = block(above: 1.1em, below: 0.35em, text(
  font: "Helvetica Neue",
  size: 6pt,
  tracking: 0.04em,
  upper(body),
))

// A 50 mm bar for checking with a ruler that the printer did not rescale.
#let calibration-bar = {
  set text(font: "Helvetica Neue", size: 5pt, fill: luma(110))
  box(baseline: 0.4mm, {
    box(width: 50mm, height: 1.2mm, stroke: 0.4pt + luma(110), {
      for i in range(1, 5) {
        place(dx: i * 10mm, line(angle: 90deg, length: 1.2mm, stroke: 0.3pt + luma(110)))
      }
    })
  })
  h(1.5mm)
  [50 mm]
}

#let notebook(title: "Palmer Method Drills", numbered: true, calibrated: true, body) = {
  set document(title: title)
  set page(
    width: page-width,
    height: page-height,
    binding: left,
    margin: margin,
    footer: context {
      set text(font: "Helvetica Neue", size: 6pt, fill: luma(110))
      let number = if numbered { counter(page).display() }
      let bar = if calibrated { calibration-bar }
      if calc.odd(here().page()) {
        bar
        h(1fr)
        number
      } else {
        number
        h(1fr)
        bar
      }
    },
  )
  set text(font: "Hoefler Text", size: 8.5pt, lang: "en", region: "us")
  set par(justify: true, leading: 0.45em, spacing: 0.8em)
  show heading: set text(weight: "black", hyphenate: false)
  show heading.where(level: 1): set text(size: 15pt)
  show heading.where(level: 1): set block(above: 1.6em, below: 0.8em)
  show heading.where(level: 1): it => block(sticky: true, upper(it.body))
  // Subheadings are centered capitals, as in the original.
  show heading.where(level: 2): set align(center)
  show heading.where(level: 2): set text(size: 9pt, tracking: 0.04em)
  show heading.where(level: 2): set block(above: 1.4em, below: 0.6em)
  show heading.where(level: 2): it => block(sticky: true, upper(it.body))
  body
  // The number of physical pages, read by `typst query` for imposing.
  context [#metadata(here().page())<page-count>]
}
