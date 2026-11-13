// Imposes an A5 document on A4 sheets (see impose.typ) as signatures of five
// sheets for sewn bookbinding. Keep the printed sheets in order, take them
// five at a time, and fold each group in half along the center marks with
// the first sheet outside: each group is then a signature of twenty pages in
// order. The last signature is filled out with blank pages.
//
// In a signature of n pages, its kth sheet from the outside carries pages
// n - 2k and 2k + 1 on the front, and 2k + 2 and n - 2k - 1 on the back.

#import "impose.typ": *

#let sheets-per-signature = 5
#let signature-pages = 4 * sheets-per-signature
#let signatures = calc.ceil(pages / signature-pages)

#show: sheet-setup

#for signature in range(signatures) {
  let first = signature * signature-pages
  for k in range(sheets-per-signature) {
    if signature > 0 or k > 0 { pagebreak() }
    center-marks
    a5(first + signature-pages - 2 * k)
    a5(first + 2 * k + 1)
    pagebreak()
    a5(first + 2 * k + 2)
    a5(first + signature-pages - 2 * k - 1)
  }
}
