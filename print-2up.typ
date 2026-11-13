// Imposes an A5 document two-up on A4 sheets (see impose.typ). Cut the
// printed stack down the middle and put the pile of left halves on top of
// the pile of right halves: the leaves are then in order.
//
// The left halves carry the first half of the leaves and the right halves the
// second, so sheet n carries leaves n and sheets + n. Flipping on the short
// edge swaps left and right, so the back side lists the versos in reverse.

#import "impose.typ": *

#let leaves = calc.ceil(pages / 2)
#let sheets = calc.ceil(leaves / 2)

#show: sheet-setup

#for sheet in range(sheets) {
  let left-leaf = sheet
  let right-leaf = sheets + sheet
  center-marks
  a5(2 * left-leaf + 1)
  a5(2 * right-leaf + 1)
  pagebreak()
  a5(2 * right-leaf + 2)
  a5(2 * left-leaf + 2)
  if sheet < sheets - 1 { pagebreak() }
}
