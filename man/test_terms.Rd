% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/test_terms.R
\name{test_terms}
\alias{test_terms}
\title{Testing Model Terms via Nested Models}
\usage{
test_terms(formula, data, extra_formula, est_fun, arg_est = list(),
  test_fun = anova_df, arg_test = list(), type = 3,
  test_intercept = FALSE, na.action)
}
\arguments{
\item{formula}{Two-sided formula. Separate formulas (i.e., nested models) will be created for each model term on right side of this formula. For example, for mixed-effects models this should be the response (i.e., dependent) variable plus the fixed-effects.}

\item{data}{\code{data.frame} passed to \code{model.frame} holding the variables in \code{formula} and \code{extra_formula}.}

\item{extra_formula}{Optional one-sided formula that will be added to the resulting formulas. No separate formulas will be built based on this formula. For example, for mixed-effects model this should contain the random-effects.}

\item{est_fun}{Estimation/fitting function. For example, \code{lm}, \code{lmer}, ...}

\item{arg_est}{\code{list} of additional argments passed to \code{arg_est}.}

\item{test_fun}{Function comparing two models. Needs to return a
\code{data.frame} with one row and the last two columns
need to be the test statistics (e.g., \code{F}, \code{Chisq}) and the
corresponding p-value (e.g., \code{Pr(>F)}, \code{Pr(>Chisq)}). Default is
\code{\link{anova_df}} which is a wrapper for the generic \code{anova}
function that autodetects relevant columns.}

\item{arg_test}{additional argument passed to \code{test_fun}. See examples
for how to use it with the default \code{test_fun}.}

\item{type}{Type of sums of squares. Currently only Type III (i.e., \code{3} or \code{"III"}) are supported.}

\item{test_intercept}{Logical. Should test for intercept be included in output? Default is \code{FALSE}}

\item{na.action}{how \code{NA}s are treated. Passed to \code{\link{model.frame}}.}
}
\description{
Generic interfaces that allows Type III tests of model terms (i.e., main
  effects and interactions) via nested model comparisons using a
  user-supplied estimation/fitting function and user-supplied function for
  comparing two models. The default function for testing model terms is
  \code{\link{anova}} which returns likelihood-ratio tests.
}
\examples{

set_sum_contrasts() ## quite important, currently coding is not checked

data("Machines", package = "MEMSS")

# ignoring repeated-measures
m1 <- test_terms(score ~ Machine, data=Machines,
                 est_fun = lm)
m1
nice(m1)
anova(m1)

## fixed-effects model
m2 <- test_terms(score ~ Machine*Worker, data=Machines,
                 est_fun = lm)
m2


# simple model with random-slopes for repeated-measures factor
m3 <- test_terms(score ~ Machine, data=Machines,
                 extra_formula = ~ (Machine|Worker),
                 est_fun = lme4::lmer, arg_est = list(REML = FALSE),
                 arg_test = list(model.names=c("f", "r")))
m3
anova(m3)

## specify colnames in anova() output by hand instead of automatically:
m3b <- test_terms(score ~ Machine, data=Machines,
                 extra_formula = ~ (Machine|Worker),
                 est_fun = lme4::lmer, arg_est = list(REML = FALSE),
                 arg_test = list(model.names=c("f", "r"),
                                 colnames = list("Chi Df", "Chisq", "Pr(>Chisq)")))
m3b


\dontrun{
# using an example from afex
data("sk2011.2", package = "afex")
# use only affirmation problems (S&K also splitted the data like this)
sk2_aff <- droplevels(sk2011.2[sk2011.2$what == "affirmation",])

library("lme4")
# not a particularly reasonable non-maximal model
sk_m1 <- test_terms(response ~ instruction*inference*type,
                             sk2_aff,
                             extra_formula = ~(inference|id),
                    est_fun = lmer, arg_est = list(REML = FALSE),
                    arg_test = list(model.names=c("f", "r")))

nice(sk_m1)
anova(sk_m1)

### matches:
afex::mixed(response ~ instruction*inference*type + (inference|id),
                             sk2_aff, method = "LRT")

}
}
