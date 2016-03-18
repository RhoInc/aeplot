.onLoad <- function(libname, pkgname) {
  op <- options()
  op.devtools <- list(
    devtools.path = "~/aeplot",
    devtools.install.args = "",
    devtools.name = "Jeremy Wildfire",
    devtools.desc.author = '"Jeremy Wildfire <jeremy_wildfire@rhoworld.com> [aut, cre]"',
    devtools.desc.license = "CC BY 4.0",
    devtools.desc.suggests = NULL,
    devtools.desc = list()
  )
  toset <- !(names(op.devtools) %in% names(op))
  if(any(toset)) options(op.devtools[toset])

  invisible()
}
