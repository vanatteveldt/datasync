#' Get the data folder from the R_DATA_FOLDER environment variable, defaulting to ~/data
#' @export
get.data.folder <- function() {
  dataroot = Sys.getenv("R_DATA_FOLDER")
  ifelse(dataroot == "", "~/data", dataroot)
}

#' Set the data folder to use
#' 
#' @param data_folder: the name of the data folder
#' @export
set.data.folder <- function(data_folder) {
  Sys.setenv(R_DATA_FOLDER=data_folder)
}

#' Load a file from the data folder
#' 
#' @param file: the file name, including path (relative to data_folder)
#' @param data_folder: the data folder, defauts to get.data.folder()
#' @export
load.data <- function(file, data_folder=NULL) {
  if (is.null(data_folder)) data_folder = get.data.folder()
  load(file.path(data_folder, fn))
}

#' Save variables into a file in the data folder
#' 
#' @param ...: the variables to save
#' @param file: the file name to save (relative to data_folder)
#' @param data_folder: the data folder, defaults to get.data.folder()
save.data(..., file, data_folder=NULL) {
  
}

#' Conduct an rsync with a remote host
#' 
#' Uses a pair of system calls to rsync, so rsync needs to be installed and the current user 
#' needs to have credentials to login to the remote host automatically. 
#' 
#' @param remote_host: the hostname of the remote host to sync with
#' @param remote_folder: the remote folder to sync with (defaults to data.folder())
#' @param local_folder: the local folder to sync (defaults to data.folder())
#' @param dry_run: if TRUE, don't actually do the syncing, just check what would be done (i.e. rsync --dry-run)
#' @export
rsync <- function(remote_host, remote_folder=NULL, local_folder=NULL, dry_run=F) {
  trail <- function(p) paste(p, ifelse(grepl("/$", p), "", "/"), sep="")
  local = trail(ifelse(is.null(local_root), get.data.folder(), local_root))
  remote = trail(paste(remote_host, ifelse(is.null(remote_root), get.data.folder(), remote_root), sep=":"))
  cmd = "rsync -azuvve ssh"
  if (dry_run) cmd = paste(cmd, "--dry-run")
  system(paste(cmd, local, remote))
  system(paste(cmd, remote, local))
}
