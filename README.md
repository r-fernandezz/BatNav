
BatNav
================

![GPL-3.0
License](https://img.shields.io/badge/License-GPL%20v3.0-blue.svg)
![WIP](https://www.repostatus.org/badges/latest/wip.svg)

BatNav is a Shiny application to perform spatial analyses using GPS points of flying foxes recorded by GCOI.

## 🚀 How to launch BatNav?

:one: Clone this repository on your computer or download it as a ZIP file and unzip it.

:two: Add the "data" folder in BatNav folder. This folder contains SIG data used by BatNav during analysis. You can ask me for this folder if you don't have it (:email: [r-fernandezz](https://github.com/r-fernandezz)).

:three: Check if the compiler gfortran (or gcc-fortran) and the library udunits are installed on your computer.

:four: Open R terminal *into BatNav folder* and run this command to install the required packages (choose option 1.).

```r
install.packages(c("yaml", "renv"))
renv::activate()
renv::restore()
```

:five: Last step depend to your operating system :

- If you use windows :scream: You can launch BatNav to run the command bellow, but first modify it to match the paths on your computer. Open Windows PowerShell in the BatNav folder to run the command.

```powershell
    & "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" "E:\R_projects\BatNav\app.R"
```

- If you use MacOS or Linux :smirk: You can launch BatNav to run the command bellow, but first modify it to match the paths on your computer. Open a terminal in the BatNav folder to run the command.

```bash
Rscript /path/to/your/project/BatNav/app.R
```
:warning: If you choose option 2. to install the packages with renv::restore() it's possible that R doesn't find the packages. If it is the case, you can try to add your personal library path at the beginning of the script "global.R" (in the R folder) like this :

```r
.libPaths("/path/to/your/R/x86_64-pc-linux-gnu-library/")
```
