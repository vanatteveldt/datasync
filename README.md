Loading and rsyncing a Data folder 
---

This package assumes that you have a separate folder containing project data.
It provides a function `rsync` to synchronize that folder with a remote folder, 
and a function `data.load` to load data from the project folder.

The data folder is assumed to be in an environment variable `R_DATA_ROOT`, defaulting to `~/data`

Installing
---

The package can be directly installed using `devtools`:


```r
if (!require(devtools)) {install.packages("devtools"); library(devtools)}
install_github("vanatteveldt/datasync")
library(datasync)
```

Note: If `devtools` is not available, you can simple source the [data.r](R/data.r) file.

Loading and saving data
----

To demonstrate loading and saving data, let's setup a new folder in the temporary folder as data.folder (Normally, you would not call this function but either use the default location (~/data) or set the `R_DATA_ROOT` variable):


```r
set.data.folder(tempfile())
```


Now, we can save and load files to that folder, which will be created recursively:


```r
foo = "bar"
save.data(foo, file = "myproject/test.rdata")
rm("foo")
load.data("myproject/test.rdata")
foo
```

```
## [1] "bar"
```

Obviously, there is not a lot of magic going on here. 
The use of these functions is to be able to set a data folder as an environment variable, 
so the project source code does not contain the reference to the local file system

One other convenience feature is that you can pass an environment to `load.data`, 
and this environment is (invisibly) returned from the call.
This makes it easy to load files into a 'temporary' environment so variables are not overwritten:


```r
e = load.data("myproject/test.rdata", envir=new.env())
ls(e)
```

```
## [1] "foo"
```

```r
e$foo
```

```
## [1] "bar"
```

Synchronizing data
----

The `rsync` function calls the rsync command as a system call to synchronize the data folder with a remote folder.

To demonstrate this function, I will use `localhost` as the "remote" host and synchronize with a second temporary folder:


```r
remote = tempfile()
dir.create(file.path(remote, "myproject"), recursive=T)
save(foo, file=file.path(remote, "myproject/test2.rdata"))
list.files(file.path(remote, "myproject"))
```

```
## [1] "test2.rdata"
```

```r
list.files(file.path(get.data.folder(), "myproject"))
```

```
## [1] "test.rdata"
```

As you can see, the 'local' folder contains `test.rdata`, while the remote folder contains `test2.rdata`. 
To run the actual synchronization, call `rsync` with the remote host and remote folder, if it is different from the local folder:


```r
rsync(remote_host = "localhost", remote_folder = remote)
```

Let's inspect the folders:


```r
list.files(file.path(remote, "myproject"))
```

```
## [1] "test2.rdata" "test.rdata"
```

```r
list.files(file.path(get.data.folder(), "myproject"))
```

```
## [1] "test2.rdata" "test.rdata"
```

If we call rsync again, only new or changed files will synchronized. 
If a file is edited in both locations, the newer file will be kept. 
If a file is deleted in either location, it will be 'restored' from the other location.

<!--
library(knitr); knit("README.Rmd")
 -->
