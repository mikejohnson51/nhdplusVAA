
<!-- README.md is generated from README.Rmd. Please edit that file -->

# nhdplusVAA

<!-- badges: start -->

<!-- badges: end -->

`nhdplusVAA` allows researchers to use the NHD Attribute Data without
the heavy geometry files.

## Installation

You can install the development version from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("mikejohnson51/nhdplusVAA")
```

## Example

``` r
library(dplyr)
library(nhdplusVAA)
```

If this is your first time using `nhdplusVAA` you’ll need to download
the archived data:

``` r
download_vaa()
```

All internal functions will check if the data is local but you can check
yourself too:

``` r
check_vaa()
#> [1] TRUE
```

Ok\! We have the data, lets see whats available in it:

``` r
get_vaa_names()
#>  [1] "comid"      "fdate"      "streamleve" "streamorde" "streamcalc"
#>  [6] "fromnode"   "tonode"     "hydroseq"   "levelpathi" "pathlength"
#> [11] "terminalpa" "arbolatesu" "divergence" "startflag"  "terminalfl"
#> [16] "dnlevel"    "thinnercod" "uplevelpat" "uphydroseq" "dnlevelpat"
#> [21] "dnminorhyd" "dndraincou" "dnhydroseq" "frommeas"   "tomeas"    
#> [26] "reachcode"  "lengthkm"   "fcode"      "rtndiv"     "outdiv"    
#> [31] "diveffect"  "areasqkm"   "totdasqkm"  "divdasqkm"  "tidal"     
#> [36] "totma"      "wbareatype" "pathtimema" "slope"      "slopelenkm"
```

And lets actually query the attribute data, for example lets get slope
and slope length and use it to determine a mean slope:

``` r
system.time({
x = get_vaa(c("slope", "lengthkm" , 'slopelenkm')) %>% 
  mutate(meanS = (slope*slopelenkm) / lengthkm)
})
#>    user  system elapsed 
#>   0.584   0.164   1.819
```

``` r
head(x)
#>     comid      slope lengthkm slopelenkm      meanS
#> 1 8318793 0.06083397    1.295      1.295 0.06083397
#> 2 8318787 0.09534391    1.323      1.323 0.09534391
#> 3 8318775 0.11273792    2.883      2.732 0.10683316
#> 4 8318785 0.15142342    2.370      2.220 0.14183966
#> 5 8318789 0.16246142    1.511      1.361 0.14633355
#> 6 8318801 0.10504926    0.406      0.406 0.10504926

dim(x)
#> [1] 2691339       5
```
