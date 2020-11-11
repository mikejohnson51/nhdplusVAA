vaa_hydroshare <- 'https://www.hydroshare.org/resource/6092c8a62fac45be97a09bfd0b0bf726/data/contents/nhdplusVAA.fst'
vaa_path       <- function() rappdirs::user_cache_dir("nhdplus-vaa")

#' @title Available Variable Names
#' @return character vector
#' @export
get_vaa_names <- function(){ 
  nhdplusVAA::attributes 
}

#' @title Variable Subset
#' @description Return NHDPlus Attributes
#' @param vars The variable names you would like, always includes comid
#' @return data.frame
#' @export
#' @importFrom fst read.fst
get_vaa <- function(vars = NULL){
  
  if(!check_vaa()){
    stop("need to download data: run `download_vaa()`")
  }
  
  if(all(vars %in% get_vaa_names())){
    return(fst::read.fst(file.path(vaa_path(), 'nhdplusVAA.fst'), c('comid', vars)))
  }
}

#' @title See if nhdplusVAA data is cached
#' @description Checks computer for cached data
#' @return binary T/F
#' @export
#' 
check_vaa = function(){ file.exists(file.path(vaa_path(), 'nhdplusVAA.fst')) }

#' @title Download nhdplusVAA data from HydroShare
#' @description downloads and caches data on your computer
#' @param url Dont mess with this :)
#' @return path to cached data
#' @export
#' @importFrom httr GET progress write_disk

download_vaa <- function(url = vaa_hydroshare) {
  
  fpath = file.path(vaa_path(), 'nhdplusVAA.fst')
  
  if (check_vaa()) {
    message("File in already cached")
  } else {
   
    dir.create(dirname(fpath), showWarnings = FALSE, recursive = TRUE)
    
   resp <- httr::GET(url, 
              httr::write_disk(file.path(vaa_path(), 'nhdplusVAA.fst'), overwrite = TRUE), 
              httr::progress())

    if (resp$status_code != 200) { stop("Download unsuccessfull :(") }
  }
    # return file path
    return(fpath)
}

