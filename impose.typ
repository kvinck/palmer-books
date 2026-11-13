// Shared setup for imposing an A5 document (the `source` input, with
// `pages` pages) on A4 landscape sheets, two pages to a side. Print the
// result double-sided with short-edge binding (flip like a book page), which
// swaps left and right between a sheet's front and back.

#let source = sys.inputs.at("source")
#let pages = int(sys.inputs.at("pages"))

#let sheet-setup(body) = {
  set page(width: 297mm, height: 210mm, margin: 0pt)
  body
}

// A4 halves are 148.5 mm wide and A5 is 148 mm; centering splits the
// difference so each page's front and back stay registered after flipping.
// Numbers past the end of the document are blank pages.
#let a5(number) = box(width: 148.5mm, height: 210mm, align(center, {
  if number <= pages {
    image(source, page: number, width: 148mm, height: 210mm)
  }
}))

// Marks at the middle of the sheet, to cut or fold along.
#let center-marks = {
  let mark = 0.4pt + luma(120)
  place(dx: 148.5mm, dy: 3mm, line(angle: 90deg, length: 5mm, stroke: mark))
  place(dx: 148.5mm, dy: 202mm, line(angle: 90deg, length: 5mm, stroke: mark))
}
