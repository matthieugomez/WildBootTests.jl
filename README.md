# WildBootTests.jl

This package performs wild bootstrap-based hypothesis tests in Julia at extreme speed. It is intended mainly for linear models: ordinary least squares (OLS) and instrumental variables/two-stage least squares (IV/2SLS). For an introduction to the wild bootstrap and the algorithms deployed here, see [Roodman et al. (2019)](https://journals.sagepub.com/doi/abs/10.1177/1536867X19830877?journalCode=stja).

The package offers and supports:
* Confidence intervals as well as p values.
* Multiway clustering of standard errors.
* Arbitrary and multiple linear hypotheses in the parameters.
* Generation of data for plotting of confidence curves or surfaces after one- and two-dimensional.
* The wild bootstrap ([Wu 1986](https://doi.org/10.1214/aos/1176350142)) for OLS.
* The Wild Restricted Efficient (WRE) bootstrap of [Davidson and MacKinnon (2010)](https://doi.org/10.1198/jbes.2009.07221) for IV/2SLS.
* The subcluster bootstrap of [MacKinnon and Webb (2018)]( https://doi.org/10.1111/ectj.12107).

WildBootTests.jl incorporates order-of-magnitude algorithmic speed-ups developed since [Roodman et al. (2019)](https://journals.sagepub.com/doi/abs/10.1177/1536867X19830877?journalCode=stja) for both [OLS](https://www.statalist.org/forums/forum/general-stata-discussion/general/1586107-boottest-just-as-wild-10x-faster) and [IV/2SLS](https://www.statalist.org/forums/forum/general-stata-discussion/general/1597888-boottest-~100x-faster-after-iv-gmm). And it exploits the efficiency of Julia, such as by offering single-precision (Float32) computation.

The interface is low-level: the exported function `wildboottest()` accepts scalars, vectors, and matrices, not [DataFrame](https://github.com/JuliaData/DataFrames.jl)s or results from estimation functions such as [lm()](https://juliastats.org/GLM.jl/v1.5/). This design minimizes the package's dependency footprint while making the core functionality available to multiple programming environments, including Julia, R (through [JuliaCall](https://cran.r-project.org/web/packages/JuliaCall/index.html) and [wildboottestjlr](https://github.com/s3alfisc/wildboottestjlr)), and Python (through [PyJulia](https://github.com/JuliaPy/pyjulia)). A separate package will provide a higher-level Julia interface.

wildboottest() accepts many optional arguments. Most correspond to boottest options, which are documented in [Roodman et al. (2019)](https://journals.sagepub.com/doi/abs/10.1177/1536867X19830877?journalCode=stja). Novel additions include an optional first argument `T`, which may be `Float32` or `Float64` and specifies the precision of computation; and `rng`, which takes a random number generator such as `MersenneTwister(2302394)`.

# Examples

```
using WildBootTests, CSV, DataFrames, Plots, GLM

df = CSV.read(download("https://raw.github.com/vincentarelbundock/Rdatasets/master/csv/sandwich/PetersenCL.csv"), DataFrame)
f = @formula(y ~ 1 + x)
f = apply_schema(f, schema(f, df))
lm(f, df)  # run OLS for illustration; not needed for following lines

resp, predexog = modelcols(f, df)  # extract data matrices for response & (exogenous) predictor variables
R = [0 1.]; r = [0]  # express hypothesis that coeffecient on x is 1 as Rβ = r, where β is the parameter vector

test = wildboottest((R, r); resp=resp, predexog=predexog, clustid=df.firm, reps=99999)  # run test clustering by firm

p(test)  # get p value
CI(test)  # get confidence interval
plot(plotpoints(test)...)  # plot confidence curve
```
