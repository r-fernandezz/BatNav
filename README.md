
BatNav
================

![GPL-3.0
License](https://img.shields.io/badge/License-GPL%20v3.0-blue.svg)
![WIP](https://www.repostatus.org/badges/latest/wip.svg)

BatNav is a Shiny application to perform spatial analyses using GPS points of flying foxes recorded by GCOI.

## 🚀 How to launch BatNav?

:one: Clone this repository on your computer or download it as a ZIP file (green '*code*' button) and unzip it.

:two: Add the "data" folder in BatNav folder. This folder contains SIG data used by BatNav during analysis. You can ask me for this folder if you don't have it (:email: [r-fernandezz](https://github.com/r-fernandezz)).

:three: Check if the compiler '*gfortran*' (or '*gcc-fortran*') and the library '*udunits*' are installed on your computer.

:four: Open R terminal **into BatNav folder** 

- If you use windows :scream: Open windows power shell in the BatNav folder (Shift+Right Click on the folder) and launch R terminal with this command :

```powershell
& "C:\Program Files\R\R-4.5.1\bin\Rscript.exe"
```

- If you use MacOS or Linux :smirk: Open bash terminal into the BatNav folder (Right Click in the folder) and launch R terminal with this command :

```bash
R
```

:five: Launch command below in the same R terminal to install the packages required by BatNav.

```r
install.packages(c("yaml", "renv"))
renv::activate()
renv::restore()
```

:six: Launch shiny application with this command in the same R terminal:

```r
shiny::runApp("app.r")
```