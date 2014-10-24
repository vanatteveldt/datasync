#' Get the data folder from the R_DATA_FOLDER environment variable, defaulting to ~/data
#' @export
get.data.folder <- function() {
  dataroot = Sys.getenv("R_DATA_FOLDER")
  if (dataroot == "") dataroot = "~/data"
  dir.create(dataroot, showWarnings=F, recursive=T)
  dataroot
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
#' @param envir: the environment to load the data into, defaults to the global environment
#' @export
load.data <- function(file, data_folder=NULL, envir=.GlobalEnv) {
  if (is.null(data_folder)) data_folder = get.data.folder()
  load(file.path(data_folder, file), envir=envir)
  invisible(envir)
}

#' Save variables into a file in the data folder
#' 
#' @param ...: the variables to save
#' @param file: the file name to save (relative to data_folder)
#' @param data_folder: the data folder, defaults to get.data.folder()
#' @export
save.data <- function(..., file, data_folder=NULL) {
  if (is.null(data_folder)) data_folder = get.data.folder() 
  file = file.path(data_folder, file)
  dir.create(dirname(file), showWarnings=F, recursive=T)
  save(..., file=file)
}

#' Check whether a file exists in the data folder
#' 
#' @param file: the file name to save (relative to data_folder)
#' @param data_folder: the data folder, defaults to get.data.folder()
#' @export
data.file.exists <- function(file, data_folder=NULL) {
  if (is.null(data_folder)) data_folder = get.data.folder() 
  file = file.path(data_folder, file)
  file.exists(file)
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
  local = trail(ifelse(is.null(local_folder), get.data.folder(), local_folder))
  remote = trail(paste(remote_host, ifelse(is.null(remote_folder), get.data.folder(), remote_folder), sep=":"))
  cmd = "rsync -azuvve ssh"
  if (dry_run) cmd = paste(cmd, "--dry-run")
  system(paste(cmd, local, remote))
  system(paste(cmd, remote, local))
}
