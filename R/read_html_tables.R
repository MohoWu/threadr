#' Function to read HTML tables from an URL. 
#' 
#' @param url A URL which contains HTML tables. 
#' 
#' @author Stuart K. Grange
#' 
#' @return Named list containing data frames. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # A url
#' url <- "https://en.wikipedia.org/wiki/List_of_London_Underground_stations"
#' 
#' # A list
#' list_tables <- read_html_tables(url)
#' length(list_tables)
#' 
#' # Get a single data frame
#' data_stations <- list_tables[[1]]
#' 
#' # Cleaning needed...
#' 
#' }
#' 
#' @export 
read_html_tables <- function(url) {
  
  # Check if url is a url or an html document
  if (stringr::str_detect(url[1], "^http|^https")) {
    
    # Read page
    text <- tryCatch({
      
      suppressWarnings(
        read_lines(url)
      )
      
    }, error = function(e) {
      
      warning("Article not found, check `url`...", call. = FALSE)
      
      # Break and return here
      return(list())
      
    })
    
  } else {
    
    # Reassign
    text <- url
    
  }
  
  if (length(text) != 0) {
    
    # Parse html document
    xml <- XML::htmlTreeParse(
      text, 
      ignoreBlanks = FALSE, 
      useInternalNodes = TRUE, 
      trim = FALSE
    )
    
    # All tables as a list
    list_tables <- XML::readHTMLTable(
      xml, 
      ignoreBlanks = FALSE, 
      trim = FALSE,
      stringsAsFactors = FALSE
    )
    
    if (length(list_tables) != 0) {
      
      # If names are null, give names
      if (unique(names(list_tables))[1] == "NULL")
        names(list_tables) <- stringr::str_c("table_", 1:length(list_tables))
      
      # If a single table, return as data frame
      if (length(list_tables) == 1) list_tables <- list_tables[[1]]
      
    }
    
  } else {
    
    list_tables <- list()
    
  }
  
  return(list_tables)
  
}
