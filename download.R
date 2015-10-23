download <- function(url) {
  
  ## Establish destinations for zip and data files.
  dataDirPath <- "data"
  datasetDirPath <- file.path(dataDirPath, "yelp")
  zipFileName <- "yelp.zip"
  zipPath <- file.path(dataDirPath, zipFileName)
  
  ## Downloading/Unzipping data *iff* data doesn't already exist
  if(!file.exists(dataDirPath)){ 
    dir.create(dataDirPath) 
  }
  
  ## Validate whether compressed file already exists.
  if(!file.exists(zipPath)){ 
    download.file(url, zipPath, mode="wb")
  }
  
  ## Validate whether decompressed file exists in dir.
  if(!file.exists(datasetDirPath)) { 
    unzip(zipPath, exdir=dataDirPath)
  }
  
  #   return(datasetDirPath)
  
}