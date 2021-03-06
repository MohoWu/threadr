#' Function to download files from a remote system with \code{scp} (secure copy). 
#' 
#' \code{download_with_scp} offers an alternative to the \code{curl} based 
#' functions which can be troublesome to use with the \code{sftp} protocol on 
#' Ubuntu systems. \code{download_with_scp} needs the \code{sshpass} system 
#' programme to be installed. 
#' 
#' @param host Host name of remote system. 
#' 
#' @param file_remote A vector of remote files names to download. 
#' 
#' @param file_local A vector of file names which are the destination files for
#' \code{file_remote}. 
#' 
#' @param user User name for \code{scp}. 
#' 
#' @param password Password for the user for \code{scp}. 
#' 
#' @param compression Should the files be copied with compression on the fly? 
#' This can speed up copying time on slower networks but not always. 
#' 
#' @param print Should the file to be downloaded be printed to the console as a
#' message? 
#' 
#' @param progress Type of progress bar to display. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get a file
#' download_with_scp(
#'   host = "192.1.1.1",
#'   file_remote = "/network_storage/r_files/sock_data.rds", 
#'   file_local = "~/Desktop/sock_data_copied.rds",
#'   user = "username",
#'   password = "password_for_username"
#' )
#' 
#' }
#' 
#' @author Stuart K. Grange
#' 
#' @return Invisible.
#' 
#' @seealso \code{\link{list_files_scp}}, \href{https://gist.github.com/arunoda/7790979}{sshpass},
#' \code{\link{upload_with_scp}}
#' 
#' @export
download_with_scp <- function(host, file_remote, file_local, user, password,
                              compression = FALSE, print = FALSE, 
                              progress = "none") {
  
  # If nothing is passed, just skip
  if (!length(file_remote) == 0) {
    
    # Checks
    stopifnot(length(file_remote) == length(file_local))
    
    if (!sshpass_install_check()) 
      stop("`sshpass` system programme is not installed...", call. = FALSE)
    
    # Add host to file remote
    file_remote <- stringr::str_c(host, ":", file_remote)
    
    # Build mapping data frame
    df <- data.frame(
      file_remote,
      file_local, 
      stringsAsFactors = FALSE
    )
    
    # Do 
    plyr::a_ply(
      df, 
      .margins = 1,
      function(x) download_with_scp_worker(
        x,
        user = user,
        password = password,
        compression = compression,
        print = print
      ),
      .progress = progress
    )
    
  } else {
    
    message("`file_remote` has length of 0, nothing has been downloaded...")
    
  }
  
  # No return
  
}


download_with_scp_worker <- function(df, user, password, compression, print) {
  
  # Build system command
  command_prefix <- stringr::str_c("sshpass -p '", password, "' scp ", user, "@")
  
  # Add compression argument
  if (compression) 
    command_prefix <- stringr::str_replace(command_prefix, "\\bscp\\b", "scp -C")
  
  # And file
  command_files <- stringr::str_c(df$file_remote, df$file_local, sep = " ")
  
  # Combine commands
  command <- stringr::str_c(command_prefix, command_files)
  
  # A message to the user
  if (print) message(stringr::str_c("Copying: ", df$file_remote))
  
  # Do
  system(command)
  
}


# # Build system call command
# # if (cypher == "arcfour") {
#   
#   # # Fastest cypher in most cases
#   # command_prefix <- stringr::str_c(
#   #   "sshpass -p '", 
#   #   password, 
#   #   "' scp ", "Cipher=arcfour ", 
#   #   user, 
#   #   "@"
#   # )
#   
#   
# } else {
# 
#   # Default
#   
#   
# }


#' Function to list files and directories on a remote system with \code{scp} 
#' (secure copy). 
#' 
#' \code{list_files_scp} offers an alternative to the \code{curl} based 
#' functions which can be troublesome to use with the \code{sftp} protocol on 
#' Ubuntu systems. \code{download_with_scp} needs the \code{sshpass} system 
#' programme to be installed.  
#' 
#' @param host Host name of remote system. 
#' 
#' @param directory_remote A remote directory to list files from. 
#' 
#' @param user User name for \code{scp}. 
#' 
#' @param password Password for the user for \code{scp}. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # List contents of a directory
#' list_files_scp(
#'   host = "192.1.1.1", 
#'   directory_remote = "/network_storage/r_files/",
#'   user = "username",
#'   password = "password_for_username"
#' )
#' 
#' }
#' 
#' @author Stuart K. Grange
#' 
#' @return Character vector.
#' 
#' @seealso \code{\link{download_with_scp}}, \href{https://gist.github.com/arunoda/7790979}{sshpass},
#' \code{\link{upload_with_scp}}
#' 
#' @export
list_files_scp <- function(host, directory_remote, user, password) {
  
  if (!sshpass_install_check()) 
    stop("`sshpass` system programme is not installed...", call. = FALSE)
  
  # Ensure remote has a slash and a wild card
  directory_remote <- stringr::str_c(directory_remote, "/*")
  
  # Build system call command, ssh, not scp
  command <- stringr::str_c(
    "sshpass -p '", 
    password, 
    "' ssh ", 
    user, 
    "@", 
    host, 
    " ls -d -1 ", 
    directory_remote
  )
  
  # Do
  file_list <- system(command, intern = TRUE)
  
  return(file_list)
  
}


# Test if sshpass is installed
sshpass_install_check <- function() {
  
  # System call
  suppressWarnings(
    x <- system("which sshpass", intern = TRUE)
  )
  
  # Test
  x <- if (length(x) == 0) {
    
    x <- FALSE
    
  } else if (grepl("sshpass", x, ignore.case = TRUE)) {
    
    x <- TRUE
    
  } else {
    
    x <- FALSE
    
  }

  return(x)
  
}


#' Function to upload files locally to a remote system with \code{scp} (secure 
#' copy). 
#' 
#' \code{upload_with_scp} offers an alternative to the \code{curl} based 
#' functions which can be troublesome to use with the \code{sftp} protocol on 
#' Ubuntu systems. \code{upload_with_scp} needs the \code{sshpass} system 
#' programme to be installed. 
#' 
#' @param host Host name of remote system. 
#' 
#' @param file_local A vector of file names which are the destination files for
#' \code{file_remote}. 
#' 
#' @param file_remote A vector of remote files names to download. 
#' 
#' @param user User name for \code{scp}. 
#' 
#' @param password Password for the user for \code{scp}. 
#' 
#' @param compression Should the files be copied with compression on the fly? 
#' This can speed up copying time on slower networks but not always. 
#' 
#' @param print Should the file to be uploaded be printed to the console as a
#' message? 
#' 
#' @param progress Type of progress bar to display. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get a file
#' upload_with_scp(
#'   host = "192.1.1.1",
#'   file_local = "~/Desktop/sock_data_copied.rds",
#'   file_remote = "/network_storage/r_files/sock_data.rds", 
#'   user = "username",
#'   password = "password_for_username"
#' )
#' 
#' }
#' 
#' @author Stuart K. Grange
#' 
#' @return Invisible.
#' 
#' @seealso \code{\link{list_files_scp}}, \href{https://gist.github.com/arunoda/7790979}{sshpass},
#' \code{\link{download_with_scp}}
#' 
#' @export
upload_with_scp <- function(host, file_local, file_remote, user, password,
                            compression = FALSE, print = FALSE, 
                            progress = "none") {
  
  # If nothing is passed, just skip
  if (!length(file_local) == 0) {
    
    # Checks
    stopifnot(length(file_remote) == length(file_local))
    
    if (!sshpass_install_check()) 
      stop("`sshpass` system programme is not installed...", call. = FALSE)
    
    # Add user and host to file remote
    file_remote <- stringr::str_c(user, "@", host, ":", file_remote)
    
    # Build mapping data frame
    df <- data.frame(
      file_remote,
      file_local, 
      stringsAsFactors = FALSE
    )
    
    # Do 
    plyr::a_ply(
      df, 
      .margins = 1,
      function(x) upload_with_scp_worker(
        x,
        user = user,
        password = password,
        compression = compression,
        print = print
      ),
      .progress = progress
    )
    
  } else {
    
    message("`file_local` has length of 0, nothing has been uploaded...")
    
  }
  
  # No return
  
}


upload_with_scp_worker <- function(df, user, password, compression, print) {
  
  # Build system command
  command_prefix <- stringr::str_c("sshpass -p '", password, "' scp ")
  
  # Add compression argument
  if (compression) 
    command_prefix <- stringr::str_replace(command_prefix, "\\bscp\\b", "scp -C")
  
  # Add files, the local one
  command_files <- stringr::str_c(df$file_local, df$file_remote, sep = " ")
  
  # Combine commands
  command <- stringr::str_c(command_prefix, command_files)
  
  # A message to the user
  if (print) message(stringr::str_c("Copying: ", df$file_local))
  
  # Do
  system(command)
  
}
