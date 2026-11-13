# Palmer Method books

A5 handwriting books built from A. N. Palmer's *The Palmer Method of
Business Writing*:

- **Drills**: the 172 drills, set as a practice notebook. Scanned
  examples sit on the same ruling as the practice lines, so letter
  heights can be read directly off the guides.
- **Lessons**: Palmer's opening instructions, with their photographs and
  diagrams, and the drills to practice in each lesson.
- **Daily drills**: the drills to practice before every session.
- **Practice paper**: blank pages with the full practice ruling (lined)
  or with baselines only.

## Download

| Book                     | A5                                                 | A4, two-up                                                       | A4, signatures                                             |
| ------------------------ | -------------------------------------------------- | ---------------------------------------------------------------- | ---------------------------------------------------------- |
| Drills                   | [drills.pdf](pdf/drills.pdf)                       | [drills-2up-a4.pdf](pdf/drills-2up-a4.pdf)                       | [drills-signatures-a4.pdf](pdf/drills-signatures-a4.pdf)   |
| Lessons                  | [lessons.pdf](pdf/lessons.pdf)                     | [lessons-2up-a4.pdf](pdf/lessons-2up-a4.pdf)                     | [lessons-signatures-a4.pdf](pdf/lessons-signatures-a4.pdf) |
| Daily drills             | [daily.pdf](pdf/daily.pdf)                         | [daily-2up-a4.pdf](pdf/daily-2up-a4.pdf)                         |                                                            |
| Practice paper, lined    | [practice-lined.pdf](pdf/practice-lined.pdf)       | [practice-lined-2up-a4.pdf](pdf/practice-lined-2up-a4.pdf)       |                                                            |
| Practice paper, baseline | [practice-baseline.pdf](pdf/practice-baseline.pdf) | [practice-baseline-2up-a4.pdf](pdf/practice-baseline-2up-a4.pdf) |                                                            |

## Printing

Always print at 100% (actual size), never "fit to page": the ruling is
set to Palmer's letter sizes. The 50 mm bar in each footer (absent from
the lesson book) checks the scale with a ruler.

- **A5**: one book page per side of an A5 sheet. Print double-sided on
  A5 paper, flipping on the long edge. Use this on printers that take A5
  paper, or to read on screen.
- **A4, two-up**: two book pages on each side of an A4 sheet. Print
  double-sided with short-edge binding. Cut the stack down the middle,
  then put the pile of left halves on top of the pile of right halves:
  the pages are then in order. The inside margin leaves room for 6-ring
  A5 binder holes.
- **A4, signatures**: for sewn bookbinding. Print double-sided with
  short-edge binding and keep the sheets in order. Take them five at a
  time and fold each group in half along the center marks, keeping the
  first sheet outside: each group is a signature of twenty pages, ready
  to sew.

Print the practice paper as many times as you need.

## Building

The PDFs above are built from the Typst sources here.

### Requirements

- [Typst](https://typst.app) 0.15.1 or later.
- The Hoefler Text and Helvetica Neue fonts, which ship with macOS. On
  other systems, install them or Typst falls back to its default fonts
  and the layout will shift.
- Network access on the first build, which downloads the `droplet`
  Typst package.

### Commands

Compile any book from the repository root:

```sh
typst compile drills.typ
typst compile lessons.typ
```

Each command writes a PDF of the same name beside its source.

To impose a compiled book on A4, two-up (`print-2up.typ`) or in
signatures (`print-signatures.typ`), pass the PDF and its page count,
which Typst reads from the book's source:

```sh
pages=$(typst eval 'query(<page-count>).first().value' --in drills.typ)
typst compile --input source=drills.pdf --input pages=$pages print-2up.typ drills-2up-a4.pdf
typst compile --input source=drills.pdf --input pages=$pages print-signatures.typ drills-signatures-a4.pdf
```

In a shell without `$(...)`, run the `typst eval` command alone and pass
the number it prints as `pages`.

## License

Everything here is in the public domain; see `LICENSE`.
