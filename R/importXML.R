#' importXML
#' 
#' Import an Blast XML file
#' 
#' This function imports XML files as provided as Blast output, it is mainly aimied to import the output of the hoardeR package
#' @param folder Character, folder path
#' @param seqNames Names of sequences
#' @param which Which sequences to import
#' @param idTH Use the threshold as cut-off
#' @param verbose Logical, verbose output
#' 
#' @return An XML object
#' 
#' @author Daniel Fischer
#' 
#' @export


importXML <- function(folder, seqNames=NULL, which=NULL, idTH = 0.8, verbose=TRUE){
  # Get the filenames and statistics about how many XML files we have
    fileList <- list.files(folder)
    fileList <- fileList[substrRight(fileList,3)=="xml"]
    seqNamesFolder <- unlist(strsplit(fileList,".xml"))
    if(is.null(seqNames)) seqNames <- unlist(strsplit(fileList,".xml"))
    foundNames <- sum(is.element(seqNames,seqNamesFolder))
    foundNames2 <- sum(is.element(seqNamesFolder,seqNames))
    if(verbose==TRUE){
      cat("Given amount of sequences:", length(seqNames),"\n")
      cat("XML files in folder:", length(seqNamesFolder),"\n")
      cat("Folder Files in requested list:", foundNames,"(",foundNames/length(seqNamesFolder)*100,"%)\n")  
      cat("Requested list in folder:", foundNames2,"(",foundNames2/length(seqNames)*100,"%)\n")  
    }
  # Adjust the importable files to the available ones
  # ADJUST THE CODE HERE THAT EVERYTHING GOES SMOOTH AND THE WARNING IS OBSOLENT!!!!
  if(sum(is.element(seqNamesFolder,seqNames))!=length(seqNamesFolder)) warning("Please check the which settings, due to missing files the wrong
                                                                               ones might have been imported!") 
  seqNamesFolder <- seqNamesFolder[is.element(seqNamesFolder,seqNames)]
  result <- list()
  # Set which XML files we want to import
  if(is.null(which)){
    which <- 1:length(seqNamesFolder)
  } 
  # Go one by one through the XML files and write the results into the list results
  runningIndex <- 1
  for(i in which){
    # Read in the XML file line by line
    res <- readLines(file.path(folder,fileList[i]))
    # Extract the necessary information
    queryLength <- res[grepl("<BlastOutput_query-len>",res)]
    queryLength <- as.numeric(strsplit(strsplit(queryLength,"-len>")[[1]][2],"</Blast")[[1]][1])
    hitOpen <- which(grepl("<Hit>",res)==TRUE)
    hitClose <- which(grepl("</Hit>",res)==TRUE)
    # Set the temporary variables
    underTH <- TRUE
    hitNo <- 1
    hitDev <- NULL
    hitID <- NULL
    hitLen <- NULL
    hitStart <- NULL
    hitEnd <- NULL
    hitChr <- NULL
    # Extract the information as long as we are below the predefined threshold
    while(underTH & hitNo <= length(hitOpen)){
      tempHit <- res[(hitOpen[hitNo]):(hitClose[hitNo])]
      hitDev.temp <- tempHit[grepl("<Hit_def>",tempHit)]
      hitDev.temp <- strsplit(strsplit(hitDev.temp,"<Hit_def>")[[1]][[2]],"</Hit_def>")[[1]][1]
      hitID.temp <- tempHit[grepl("<Hsp_identity>",tempHit)]
      hitID.temp <- as.numeric(strsplit(strsplit(hitID.temp,"<Hsp_identity>")[[1]][[2]],"</Hsp_identity>")[[1]][1])
      hitLen.temp <- tempHit[grepl("<Hsp_align-len>",tempHit)]
      hitLen.temp <- as.numeric(strsplit(strsplit(hitLen.temp,"<Hsp_align-len>")[[1]][[2]],"</Hsp_align-len>")[[1]][1])
      hitStart.temp <- tempHit[grepl("<Hsp_hit-from>",tempHit)]
      hitStart.temp <- as.numeric(strsplit(strsplit(hitStart.temp,"<Hsp_hit-from>")[[1]][[2]],"</Hsp_hit-from>")[[1]][1])
      hitEnd.temp <- tempHit[grepl("<Hsp_hit-to>",tempHit)]
      hitEnd.temp <- as.numeric(strsplit(strsplit(hitEnd.temp,"<Hsp_hit-to>")[[1]][[2]],"</Hsp_hit-to>")[[1]][1])
      
      
      idRatio <- hitID.temp/queryLength
      lenRatio <- hitLen.temp/queryLength
      
      if(idRatio < idTH) underTH <- FALSE
      
      if(underTH){
        hitDev[hitNo] <- hitDev.temp
        hitID[hitNo] <- hitID.temp
        hitLen[hitNo] <- hitLen.temp
        hitChr[hitNo] <- strsplit(strsplit(hitDev.temp,"chromosome ")[[1]][2],",")[[1]][1]
        hitStart[hitNo] <- hitStart.temp
        hitEnd[hitNo] <- hitEnd.temp
      }
      hitNo <- hitNo + 1
    }
    result[[runningIndex]] <- data.frame(Organism = hitDev,
                                         hitID = hitID,
                                         hitLen = hitLen,
                                         hitChr = hitChr,
                                         hitStart = hitStart,
                                         hitEnd = hitEnd, stringsAsFactors=FALSE)
    # Increment the running index
    runningIndex <- runningIndex + 1
    if(verbose) if(runningIndex%%10==0) cat(runningIndex,"XML files processed.\n")
  }
  useTheseNames <- paste(">",seqNamesFolder[which],sep="")
  useTheseNames <- gsub("\\.",":",useTheseNames)
  names(result) <- useTheseNames
  class(result) <- "xml"
  result
}