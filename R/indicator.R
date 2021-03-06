#' indicator function for window

as.function.owin <- function(x, ...) {
  W <- x
  g <- function(x, y=NULL) {
    xy <- xy.coords(x, y)
    inside.owin(xy$x, xy$y, W)
  }
  class(g) <- c("indicfun", class(g))
  return(g)
}

print.indicfun <- function(x, ...) {
  W <- get("W", envir=environment(x))
  nama <- names(formals(x))
  splat(paste0("function", paren(paste(nama, collapse=","))))
  splat("Indicator function (returns 1 inside window, 0 outside)")
  print(W)
  return(invisible(NULL))
}

plot.indicfun <- function(x, W, ..., main) {
  if(missing(main)) main <- short.deparse(substitute(x))
  if(missing(W) || is.null(W)) {
    w <- get("W", envir=environment(x))
    R <- Frame(w)
    W <- grow.rectangle(R, min(sidelengths(R))/5)
  }
  result <- do.as.im(x, plot, W=W, ..., main=main)
  return(invisible(result))
}
