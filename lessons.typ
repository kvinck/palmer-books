#import "lib.typ": *

#show: notebook.with(title: "Palmer Method Lessons", calibrated: false)
#set page(margin: (inside: 20mm, outside: 16mm, top: 10mm, bottom: 14mm))

#set page(numbering: "i")
#include "sections/front-lessons.typ"
#pagebreak(to: "odd")
#set page(numbering: "1")
#counter(page).update(1)

#include "sections/lessons-front.typ"
#pagebreak()
#include "sections/lessons-list.typ"
