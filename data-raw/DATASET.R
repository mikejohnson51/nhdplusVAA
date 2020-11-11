##################################################
## Project: "no-spatial" NHD
## Script purpose: prepare `nhdplusVAA` dataset
## Date: 10-01-2020
## Author: Mike Johnson
##################################################

# NOTE: 7z must be installed locally!!!!
library(fs) # file system
library(foreign) # DBF reading
library(dplyr) # data manipulation
library(fst) # data manipulation

##################################################

base <- 'https://s3.amazonaws.com/edap-nhdplus/NHDPlusV21/Data/'

# There is no nice way to automate these (sad face) ...
ext  <- c(
  'NHDPlusNE/NHDPlusV21_NE_01_NHDPlusAttributes_09.7z',
  'NHDPlusMA/NHDPlusV21_MA_02_NHDPlusAttributes_09.7z',
  'NHDPlusSA/NHDPlus03N/NHDPlusV21_SA_03N_NHDPlusAttributes_07.7z',
  'NHDPlusSA/NHDPlus03S/NHDPlusV21_SA_03S_NHDPlusAttributes_07.7z',
  'NHDPlusSA/NHDPlus03W/NHDPlusV21_SA_03W_NHDPlusAttributes_07.7z',
  'NHDPlusGL/NHDPlusV21_GL_04_NHDPlusAttributes_14.7z',
  'NHDPlusMS/NHDPlus05/NHDPlusV21_MS_05_NHDPlusAttributes_09.7z',
  'NHDPlusMS/NHDPlus06/NHDPlusV21_MS_06_NHDPlusAttributes_10.7z',
  'NHDPlusMS/NHDPlus07/NHDPlusV21_MS_07_NHDPlusAttributes_10.7z',
  'NHDPlusMS/NHDPlus08/NHDPlusV21_MS_08_NHDPlusAttributes_09.7z',
  'NHDPlusSR/NHDPlusV21_SR_09_NHDPlusAttributes_07.7z',
  'NHDPlusMS/NHDPlus10U/NHDPlusV21_MS_10U_NHDPlusAttributes_10.7z',
  'NHDPlusMS/NHDPlus10L/NHDPlusV21_MS_10L_NHDPlusAttributes_12.7z',
  'NHDPlusMS/NHDPlus11/NHDPlusV21_MS_11_NHDPlusAttributes_08.7z',
  'NHDPlusTX/NHDPlusV21_TX_12_NHDPlusAttributes_09.7z',
  'NHDPlusRG/NHDPlusV21_RG_13_NHDPlusAttributes_07.7z',
  'NHDPlusCO/NHDPlus14/NHDPlusV21_CO_14_NHDPlusAttributes_10.7z',
  'NHDPlusCO/NHDPlus15/NHDPlusV21_CO_15_NHDPlusAttributes_09.7z',
  'NHDPlusGB/NHDPlusV21_GB_16_NHDPlusAttributes_06.7z',
  'NHDPlusPN/NHDPlusV21_PN_17_NHDPlusAttributes_10.7z',
  'NHDPlusCA/NHDPlusV21_CA_18_NHDPlusAttributes_08.7z')

##################################################
# Download & Unzip
##################################################

# There is a lot of data so we will clean up as we go ....

## Starting from a tmp dir
dest <- "data-raw/tmp/"
fs::dir_create(dest)

for (i in seq_along(ext)) {
  # define outfile name
  out <- paste0(dest, basename(ext[i]))
  # download the URL
  download.file(paste0(base, ext[i]), destfile =  out)
  # Unzip the downloaded file
  system(paste0("7z -o", path.expand(dest), " x ", out), 
         intern = TRUE)
  # Delete the zip file
  fs::file_delete(out)
}

##################################################
# Identify the PluFlowlineVAA dbf and elevslope dbf paths
##################################################

f  <-  list.files(dest,
                  recursive  =  TRUE,
                  pattern    =  'PlusFlowlineVAA.dbf',
                  full.names =  TRUE)

f2 <-  list.files(dest,
                  recursive  =  TRUE,
                  pattern    =  'elevslope.dbf',
                  full.names =  TRUE)

# Ingest data as list of data.frames
pVAA  <-  lapply(f,  foreign::read.dbf)
eVAA  <-  lapply(f2, foreign::read.dbf)

# Bind and fix names
pVAA        <-  dplyr::bind_rows(pVAA)
names(pVAA) <-  tolower(names(pVAA))
eVAA        <-  dplyr::bind_rows(eVAA)
names(eVAA) <-  tolower(names(eVAA))

# only available in TX, 0,1 (upu attrbs21 and 30 1s respectively)
vaa     <-  dplyr::select(pVAA, -travtime, -pathtime, -thinnercod, -outdiv, -diveffect, -totma)
elev    <-  dplyr::select(eVAA, comid, slope, slopelenkm)

nhdplus <-  dplyr::left_join(vaa, elev, by  =  "comid")

# I move this to HydroShare and dont check into GitHub ...
fst::write.fst(nhdplus, 
               path = "data/nhdplusVAA.fst",  
               compress =  100)

# Save names as RDA file, useful for fst subsetting ... 
usethis::use_data(names(nhdplus), overwrite =  TRUE)
