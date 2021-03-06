#'
#'   Header for all (concatenated) test files
#'
#'   Require spatstat.
#'   Obtain environment variable controlling tests.
#'
#'   $Revision: 1.5 $ $Date: 2020/04/30 05:31:37 $

require(spatstat)
FULLTEST <- (nchar(Sys.getenv("SPATSTAT_TEST", unset="")) > 0)
ALWAYS   <- TRUE
cat(paste("--------- Executing",
          if(FULLTEST) "** ALL **" else "**RESTRICTED** subset of",
          "test code -----------\n"))
#'  tests/aucroc.R
#'
#'  AUC and ROC code
#'
#'  $Revision: 1.6 $ $Date: 2020/11/02 06:26:45 $

local({
  if(FULLTEST) {
#%^!ifdef CORE
    fit <- kppm(redwood ~ I(y-x))
    a <- roc(fit)
    b <- auc(fit)
    fet <- ppm(amacrine~x+y+marks)
    d <- roc(fet)
    e <- auc(fet)
#%^!endif
#%^!ifdef LINEARNETWORKS    
    A <- roc(spiders, "x")
    B <- auc(spiders, "y")
    fut <- lppm(spiders ~ I(y-x))
    f <- roc(fut)
    g <- auc(fut)
#%^!endif
  }
})
## badwindowcheck.R
## $Revision: 1.3 $  $Date: 2020/04/28 12:58:26 $
##

local({
  if(ALWAYS) {
    ## Simple example of self-crossing polygon
    x <- read.table("selfcross.txt", header=TRUE)
    ## Auto-repair
    w <- owin(poly=x)

    ## Real data involving various quirks
    b <- read.table("badwindow.txt", header=TRUE)
    b <- split(b, factor(b$i))
    b <- lapply(b, function(z) { as.list(z[,-3]) })
    ## make owin without checking
    W <- owin(poly=b, check=FALSE, fix=FALSE)
    ## Apply stringent checks
    owinpolycheck(W,verbose=FALSE)
    ## Auto-repair
    W2 <- owin(poly=b)
  }
})




## tests/cdf.test.R


local({
  NSIM <- 9
#%^!ifdef CORE  
  op <- spatstat.options(ndummy.min=16, npixel=32)
  AA <- split(ants, un=FALSE)
  AC <- AA[["Cataglyphis"]]
  AM <- AA[["Messor"]]
  DM <- distmap(AM)
  if(ALWAYS) {
    ## (1) check cdf.test with strange data
    ## Marked point patterns with some marks not represented
    ## should produce a warning, rather than a crash:
    cdf.test(AC, DM)
  }
  if(FULLTEST) {
    ## should be OK:
    cdf.test(unmark(AC), DM)
    cdf.test(unmark(AC), DM, "cvm")
    cdf.test(unmark(AC), DM, "ad")
    ## other code blocks
    cdf.test(finpines, "x")
  }
  if(FULLTEST) {
    ## (2) Monte Carlo test for Gibbs model
    fit <- ppm(cells ~ 1, Strauss(0.07))
    cdf.test(fit, "x", nsim=NSIM)

    ## cdf.test.slrm
    fut <- slrm(japanesepines ~ x + y)
    Z <- distmap(japanesepines)
    cdf.test(fut, Z)
  }
  reset.spatstat.options()
#%^!endif
#%^!ifdef LINEARNETWORKS  
  op <- spatstat.options(ndummy.min=16, npixel=32)
  if(ALWAYS) {
    ## (3) linear networks
    set.seed(42)
    X <- runiflpp(20, simplenet)
    cdf.test(X, "x")
    if(FULLTEST) {
      cdf.test(X, "x", "cvm")
      cdf.test(X %mark% runif(20), "x")
    }
    fit <- lppm(X ~1)
    cdf.test(fit, "y", "cvm", nsim=NSIM)
    if(FULLTEST) {
      cdf.test(fit, "y", nsim=NSIM)
      cdf.test(fit, "y", "ad", nsim=NSIM)
    }
    if(FULLTEST) {
      ## marked
      cdf.test(chicago, "y")
      cdf.test(subset(chicago, marks != "assault"), "y")
    }
  }
  reset.spatstat.options()
#%^!endif
})


#'    tests/circular.R
#'
#'    Circular data and periodic distributions
#'
#'    $Revision: 1.4 $  $Date: 2020/04/28 12:58:26 $


local({
  if(ALWAYS) {
    a <- pairorient(redwood, 0.05, 0.15, correction="none")
    rose(a)
  }
  if(FULLTEST) {
    b <- pairorient(redwood, 0.05, 0.15, correction="best")
    rose(b, start="N", clockwise=TRUE)
  }
  if(ALWAYS) {
    #' arcs on the circle 
    #'       (depends on numerical behaviour)
    set.seed(19171025)
    aa <- replicate(7, runif(1, 0, 2*pi) + c(0, runif(1, 0, pi)),
                    simplify=FALSE)
    bb <- circunion(aa)

    assertsingle <- function(x, a, id) {
      y <- circunion(x)
      if(length(y) != 1 || max(abs(y[[1]] - a)) > .Machine$double.eps)
        stop(paste("Incorrect result from circunion in case", id),
             call.=FALSE)
      invisible(NULL)
    }

    assertsingle(list(c(pi/3, pi), c(pi/2, 3*pi/2)),
                 c(pi/3, 3*pi/2),
                 1)
    assertsingle(list(c(0, pi/2), c(pi/4, pi)),
                 c(0,pi),
                 2)
    assertsingle(list(c(-pi/4, pi/2), c(pi/4, pi)),
                 c((2-1/4)*pi, pi),
                 3)
  }
})

  
#'
#'   tests/closecore.R
#'
#' check 'closepairs/crosspairs' code
#' invoked in core package
#'
#' $Revision: 1.1 $ $Date: 2020/12/03 02:04:00 $
#' 
#' ------- All this code must be run on every hardware -------
#'

local({
  #' weightedclosepairs is currently in strauss.R
  wi <- weightedclosepairs(redwood, 0.05, "isotropic")
  wt <- weightedclosepairs(redwood, 0.05, "translate")
  wp <- weightedclosepairs(redwood, 0.05, "periodic")
  #' markmarkscatter uses closepairs.pp3
  X <- runifpoint3(100)
  marks(X) <- runif(100)
  markmarkscatter(X, 0.2)
  markmarkscatter(X[FALSE], 0.2)
})

##  tests/closeshave.R
## check 'closepairs/crosspairs' code
## validity and memory allocation
## $Revision: 1.26 $ $Date: 2020/12/03 02:32:09 $

## ------- All this code must be run on every hardware -------
local({
  r <- 0.12
  close.all <- closepairs(redwood, r)
  close.ij <- closepairs(redwood, r, what="indices")
  close.ijd <- closepairs(redwood, r, what="ijd")
  close.every <- closepairs(redwood, r, what="all", distinct=FALSE)
  stopifnot(identical(close.ij, close.all[c("i","j")]))
  stopifnot(identical(close.ijd, close.all[c("i","j","d")]))

  #' test memory overflow code
  close.cigar <- closepairs(redwood, r, what="ijd", nsize=2)
  close.cigar <- closepairs(redwood, r, what="ijd", nsize=2, periodic=TRUE)
  
  Y <- split(amacrine)
  on <- Y$on
  off <- Y$off
  cross.all <- crosspairs(on, off, r)
  cross.ij <- crosspairs(on, off, r, what="indices")
  cross.ijd <- crosspairs(on, off, r, what="ijd")
  cross.every <- crosspairs(on, off, r, what="all", distinct=FALSE)
  stopifnot(identical(cross.ij, cross.all[c("i","j")]))
  stopifnot(identical(cross.ijd, cross.all[c("i","j","d")]))

  # closethresh vs closepairs: EXACT agreement
  thresh <- 0.08
  clt <- closethresh(redwood, r, thresh)
  cl <- with(closepairs(redwood, r),
             list(i=i, j=j, th = (d <= thresh)))
  if(!identical(cl, clt))
    stop("closepairs and closethresh disagree")

  reordered <- function(a) {
    o <- with(a, order(i,j))
    as.list(as.data.frame(a)[o,,drop=FALSE])
  }
  samesame <- function(a, b) {
    identical(reordered(a), reordered(b))
  }
  
  ## ...............................................
  #' compare with older, slower code
  op <- spatstat.options(closepairs.newcode=FALSE,
                         closepairs.altcode=FALSE,
                         crosspairs.newcode=FALSE)
  ## ...............................................
  old.close.ij <- closepairs(redwood, r, what="indices")
  old.cross.ij <- crosspairs(on, off, r, what="indices")
  stopifnot(samesame(close.ij, old.close.ij))
  stopifnot(samesame(cross.ij, old.cross.ij))
  # execute only:
  old.close.every <- closepairs(redwood, r, what="all", distinct=FALSE)
  old.close.once <- closepairs(redwood, r, what="all", twice=FALSE)
  #' test memory overflow code
  old.close.cigar <- closepairs(redwood, r, what="ijd", nsize=2)
  old.close.cigar <- closepairs(redwood, r, what="ijd", nsize=2, periodic=TRUE)
  
  ## ...............................................
  spatstat.options(op)
  ## ...............................................

  ## ...............................................
  #' alternative code - execution only
  op <- spatstat.options(closepairs.newcode=FALSE,
                         closepairs.altcode=TRUE)
  alt.close.ij <- closepairs(redwood, r, what="indices")
  alt.close.ijd <- closepairs(redwood, r, what="ijd")
  alt.close.all <- closepairs(redwood, r, what="all")
  #' test memory overflow code
  alt.close.cigar <- closepairs(redwood, r, what="ijd", nsize=2)
  alt.close.cigar <- closepairs(redwood, r, what="ijd", nsize=2, periodic=TRUE)
  spatstat.options(op)
  ## ...............................................
  
  # Rasmus' example
  R <- 0.04
  U <- as.ppp(gridcenters(owin(), 50, 50), W=owin())
  cp <- crosspairs(U, U, R)
  G <- matrix(0, npoints(U), npoints(U))
  G[cbind(cp$i, cp$j)] <- 1
  if(!isSymmetric(G))
    stop("crosspairs is not symmetric in Rasmus example")

  #' periodic distance
  pclose <- function(X, R, method=c("raw", "C")) {
    method <- match.arg(method)
    switch(method,
           raw = {
             D <- pairdist(X, periodic=TRUE)
             diag(D) <- Inf
             result <- which(D <= R, arr.ind=TRUE)
           },
           C = {
             result <- closepairs(X, R, periodic=TRUE, what="indices")
           })
    result <- as.data.frame(result)
    colnames(result) <- c("i","j")
    return(result)
  }
  #' pick a threshold value which avoids GCC bug 323
  RR <- 0.193
  A <- pclose(redwood, RR, "raw")
  B <- pclose(redwood, RR, "C")
  if(!samesame(A,B))
    stop("closepairs.ppp(periodic=TRUE) gives wrong answer")

  #' other functions that don't have a help file
  niets <- crosspairquad(quadscheme(cells), 0.1)

  #' other code blocks
  u <- closepairs(cells, 0.09, periodic=TRUE, what="all")
  v <- closepairs(cells, 0.07, twice=FALSE, neat=TRUE)
  #' tight cluster - guess count does not work
  Xc <- runifrect(100, square(0.01))
  Window(Xc) <- square(1)
  z <- closepairs(Xc, 0.02, what="indices", distinct=FALSE)
  z <- closepairs(Xc, 0.02, what="ijd",     distinct=FALSE)
  z <- closepairs(Xc, 0.02, what="all",     distinct=FALSE)
  #' same task, older code
  aop <- spatstat.options(closepairs.newcode=FALSE)
  z <- closepairs(Xc, 0.02, what="indices", distinct=FALSE)
  z <- closepairs(Xc, 0.02, what="ijd",     distinct=FALSE)
  z <- closepairs(Xc, 0.02, what="all",     distinct=FALSE)
  spatstat.options(aop)

  #' experimental
  r <- 0.08
  a <- closepairs(redwood, r)
  b <- tweak.closepairs(a, r, 26, 0.1, 0.1)
})

local({
  #' Three-dimensional
  ##          X <- runifpoint3(100)
  X <- pp3(runif(100), runif(100), runif(100), box3(c(0,1)))
  cl <- closepairs(X, 0.2, what="indices")
  cl <- closepairs(X, 0.2, what="ijd")
  cl <- closepairs(X, 0.2, distinct=FALSE)
  cl <- closepairs(X, 0.2, distinct=FALSE, what="indices")
  cl <- closepairs(X, 0.2, distinct=FALSE, what="ijd")
  cl <- closepairs(X, 0.2, twice=FALSE, neat=TRUE)
  #' Test memory overflow code
  cl <- closepairs(X, 0.2, what="ijd", nsize=2)
  #' trap obsolete usage
  cl <- closepairs(X, 0.2, ordered=FALSE)
  #' crosspairs
  ##      Y <- runifpoint3(100)
  Y <- pp3(runif(100), runif(100), runif(100), box3(c(0,1)))
  cr <- crosspairs(X, Y, 0.2, what="indices")
  cr <- crosspairs(X, Y, 0.2, what="ijd")
  #' Test memory overflow code
  cr <- crosspairs(X, Y, 0.2, what="ijd", nsize=2)
  #' experimental
  rr <- 0.2
  cl <- closepairs(X, rr)
  ii <- cl$i[[1]]
  xl <- tweak.closepairs(cl, rr, ii, 0.05, -0.05, 0.05)
})

reset.spatstat.options()
#'
#'   tests/cluck.R
#'
#'   Tests of "click*" functions
#'   using queueing feature of spatstatLocator
#'
#'   $Revision: 1.7 $ $Date: 2020/11/02 06:53:30 $

local({
#%^!ifdef CORE
  #' clickppp
  if(ALWAYS) {
    spatstat.utils::queueSpatstatLocator(runif(5), runif(5))
    XA <- clickppp(hook=square(0.5))
  }
  if(FULLTEST) {
    spatstat.utils::queueSpatstatLocator(runif(6), runif(6))
    XB <- clickppp(n=3, types=c("a", "b"))
  }
  if(ALWAYS) {
    #' clickbox
    spatstat.utils::queueSpatstatLocator(runif(2), runif(2))
    BB <- clickbox()
    #' clickdist
    spatstat.utils::queueSpatstatLocator(runif(2), runif(2))
    dd <- clickdist()
    #' clickpoly
    hex <- vertices(disc(radius=0.4, centre=c(0.5, 0.5), npoly=6))
    spatstat.utils::queueSpatstatLocator(hex)
    PA <- clickpoly()
  }
  if(FULLTEST) {
    holy <- vertices(disc(radius=0.2, centre=c(0.5, 0.5), npoly=6))
    holy <- lapply(holy, rev)
    spatstat.utils::queueSpatstatLocator(concatxy(hex, holy))
    PB <- clickpoly(np=2, nv=6)
  }
  if(ALWAYS) {
    #' identify.psp
    E <- edges(letterR)[c(FALSE, TRUE)]
    Z <- ppp(c(2.86, 3.65, 3.15), c(1.69, 1.98, 2.56), window=Frame(letterR))
    spatstat.utils::queueSpatstatLocator(Z)
    identify(E)
  }
  if(FULLTEST) {
    #' transect.im
    Z <- density(cells)
    spatstat.utils::queueSpatstatLocator(runifpoint(2, Window(cells)))
    TZ <- transect.im(Z, click=TRUE)
  }
#%^!endif
#%^!ifdef LINEARNETWORKS  
  Y <- coords(runiflpp(6, simplenet))
  if(FULLTEST) {
    #' clicklpp
    spatstat.utils::queueSpatstatLocator(Y)
    XL <- clicklpp(simplenet)
  }
  if(ALWAYS) {
    spatstat.utils::queueSpatstatLocator(Y)
    XM <- clicklpp(simplenet, n=3, types=c("a", "b"))
  }
  if(ALWAYS) {
    #' lineardisc
    plot(simplenet)
    spatstat.utils::queueSpatstatLocator(as.ppp(runiflpp(1, simplenet)))
    V <- lineardisc(simplenet, r=0.3)
  }
#%^!endif  
})
## tests/colour.R
##
##  Colour value manipulation and colour maps
##
## $Revision: 1.8 $ $Date: 2020/04/28 08:27:38 $
##

local({
  if(FULLTEST) {
    f <- function(n) grey(seq(0,1,length=n))
    z <- to.grey(f)

    h <- colourmap(rainbow(9), range=c(0.01, 0.1))
    plot(h, labelmap=100)
  }

  if(ALWAYS) {
    a <- colourmap(rainbow(12), range=as.Date(c("2018-01-01", "2018-12-31")))
    print(a)
    print(summary(a))
    a(as.Date("2018-06-15"))

    g <- colourmap(rainbow(4),
                   breaks=as.Date(c("2018-01-01", "2018-04-01",
                                    "2018-07-01", "2018-10-01", "2018-12-31")))
    print(g)
    print(summary(g))
    g(as.Date("2018-06-15"))
  }

  if(FULLTEST) {
    b <- colourmap(rainbow(12), inputs=month.name)
    print(b)
    print(summary(b))
    to.grey(b)
    to.grey(b, transparent=TRUE)
    plot(b, vertical=FALSE)
    plot(b, vertical=TRUE)
    plot(b, vertical=FALSE, gap=0)
    plot(b, vertical=TRUE, gap=0)
    plot(b, vertical=FALSE, xlim=c(0, 2))
    plot(b, vertical=TRUE, xlim=c(0,2))
    plot(b, vertical=FALSE, ylim=c(0, 2))
    plot(b, vertical=TRUE, ylim=c(0,2))

    argh <- list(a="iets", e="niets", col=b, f=42)
    arr <- col.args.to.grey(argh)
    rrgh <- col.args.to.grey(argh, transparent=TRUE)
  }

  if(ALWAYS) {
    #' constant colour map
    colourmap("grey", range=c(0.01, 0.1))
    colourmap("grey", range=as.Date(c("2018-01-01", "2018-12-31")))
    colourmap("grey",
              breaks=as.Date(c("2018-01-01", "2018-04-01",
                               "2018-07-01", "2018-10-01", "2018-12-31")))
    colourmap("grey", inputs=month.name)
  }

  if(FULLTEST) {
    #' empty colour map
    niets <- lut()
    print(niets)
    summary(niets)
    niets <- colourmap()
    print(niets)
    summary(niets)
    plot(niets)
  }

  if(ALWAYS) {
    #' interpolation - of transparent colours
    co <- colourmap(inputs=c(0, 0.5, 1),
                    rgb(red=c(1,0,0), green=c(0,1,0), blue=c(0,0,1),
                        alpha=c(0.3, 0.6, 0.9)))
    plot(interp.colourmap(co))
  }
})

#'
#'     contact.R
#'
#'   Check machinery for first contact distributions
#'
#'   $Revision: 1.6 $  $Date: 2020/04/28 12:58:26 $

local({
  if(ALWAYS) {
    #' reduce complexity
    Y <- as.mask(heather$coarse, dimyx=c(100, 50))
    
    X <- runifpoint(100, win = complement.owin(Y))
    G <- Gfox(X, Y)
    J <- Jfox(X, Y)

    Y <- as.polygonal(Y)
    X <- runifpoint(100, win = complement.owin(Y))
    G <- Gfox(X, Y)
    J <- Jfox(X, Y)

    op <- spatstat.options(exactdt.checks.data=TRUE)
    U <- exactdt(X)
    spatstat.options(op)
  }
})

reset.spatstat.options()
#'
#'   tests/contrib.R
#'
#'   Tests for user-contributed code in spatstat
#'
#'   $Revision: 1.2 $  $Date: 2020/04/28 12:58:26 $

local({
  #' Jinhom
  #' Marie-Colette van Lieshout and Ottmar Cronie
  X <- redwood3
  fit <- ppm(X ~ polynom(x,y,2))
  lam <- predict(fit)
  lamX <- fitted(fit, dataonly=TRUE)
  lmin <- 0.9 * min(lam)
  g1 <- Ginhom(X, lambda=fit, update=TRUE)
  if(FULLTEST) {
    g2 <- Ginhom(X, lambda=fit, update=FALSE, lmin = lmin)
    g3 <- Ginhom(X, lambda=lam,  lmin=lmin)
    g4 <- Ginhom(X, lambda=lamX, lmin=lmin)
  }
  if(ALWAYS) {
    f2 <- Finhom(X, lambda=fit, update=FALSE)
  }
  if(FULLTEST) {
    f1 <- Finhom(X, lambda=fit, update=TRUE)
    f3 <- Finhom(X, lambda=lam,  lmin=lmin)
  }
})
# tests/correctC.R
# check for agreement between C and interpreted code
# for interpoint distances etc.
# $Revision: 1.8 $ $Date: 2020/12/03 03:06:04 $

if(ALWAYS) { # depends on hardware
local({
  eps <- .Machine$double.eps * 4

  checkagree <- function(A, B, blurb) {
    maxerr <- max(abs(A-B))
    cat("Discrepancy", maxerr, "for", blurb, fill=TRUE)
    if(maxerr > eps) 
      stop(paste("Algorithms for", blurb, "disagree"))
    return(TRUE)
  }

  ## pairdist.ppp
  set.seed(190901)
  ## X <- rpoispp(42)
  X <- runifrect(max(2, rpois(1, 42)))
  dC <- pairdist(X, method="C")
  dR <- pairdist(X, method="interpreted")
  checkagree(dC, dR, "pairdist()")

  dCp <- pairdist(X, periodic=TRUE, method="C")
  dRp <- pairdist(X, periodic=TRUE, method="interpreted")
  checkagree(dCp, dRp, "pairdist(periodic=TRUE)")

  dCp2 <- pairdist(X, periodic=TRUE, squared=TRUE, method="C")
  dRp2 <- pairdist(X, periodic=TRUE, squared=TRUE, method="interpreted")
  checkagree(dCp2, dRp2, "pairdist(periodic=TRUE, squared=TRUE)")

  ## crossdist.ppp
  ## Y <- rpoispp(42)
  Y <- runifrect(max(2, rpois(1, 42)))
  dC <- crossdist(X, Y, method="C")
  dR <- crossdist(X, Y, method="interpreted")
  checkagree(dC, dR, "crossdist()")

  dC <- crossdist(X, Y, periodic=TRUE, method="C")
  dR <- crossdist(X, Y, periodic=TRUE, method="interpreted")
  checkagree(dC, dR, "crossdist(periodic=TRUE)")

  dC2 <- crossdist(X, Y, periodic=TRUE, squared=TRUE, method="C")
  dR2 <- crossdist(X, Y, periodic=TRUE, squared=TRUE, method="interpreted")
  checkagree(dC2, dR2, "crossdist(periodic=TRUE, squared=TRUE)")

  # nndist.ppp
  nnC <- nndist(X, method="C")
  nnI <- nndist(X, method="interpreted")
  checkagree(nnC, nnI, "nndist()")

  nn3C <- nndist(X, k=3, method="C")
  nn3I <- nndist(X, k=3, method="interpreted")
  checkagree(nn3C, nn3I, "nndist(k=3)")

  # nnwhich.ppp
  nwC <- nnwhich(X, method="C")
  nwI <- nnwhich(X, method="interpreted")
  checkagree(nwC, nwI, "nnwhich()")

  nw3C <- nnwhich(X, k=3, method="C")
  nw3I <- nnwhich(X, k=3, method="interpreted")
  checkagree(nw3C, nw3I, "nnwhich(k=3)")

  # whist
  set.seed(98123)
  x <- runif(1000)
  w <- sample(1:5, 1000, replace=TRUE)
  b <- seq(0,1,length=101)
  op <- spatstat.options(Cwhist=TRUE)
  aT <- whist(x,b,w)
  spatstat.options(Cwhist=FALSE)
  aF <- whist(x,b,w)
  if(!all(aT == aF))
    stop("Algorithms for whist disagree")
  spatstat.options(op)
})

reset.spatstat.options()
}
