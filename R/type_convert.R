#' Function to quickly apply \code{type.convert} to objects. 
#' 
#' @author Stuart K. Grange
#' 
#' @return Variable return. 
#' 
#' @param df Data frame to apply \code{type.convert} to every variable/column. 
#' 
#' @export
type_convert <- function(x) {
  
  # Vector
  if (class(x)[1] == "character") x <- type_converter(x)
  
  # If data frame, vectorise over variables
  if (any(class(x) %in% "data.frame")) {
    
    # Drop tbl_df
    x <- base_df(x)
    
    # Type conversion
    x[] <- lapply(x, type_converter)
    
  }
  
  return(x)
  
}


#' @export
#' @rdname type_convert
type_converter <- function(x) type.convert(as.character(x), as.is = TRUE)
