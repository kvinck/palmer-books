#import "lib.typ": *

#show: notebook.with(title: "Palmer Method Ruled Paper", numbered: false)

// Four pages fill both sides of an A4 sheet when printed two-up.
#for i in range(4) {
  if i > 0 { pagebreak() }
  baseline-page
}
