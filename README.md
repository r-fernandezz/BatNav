
BatNav
================

![GPL-3.0
License](https://img.shields.io/badge/License-GPL%20v3.0-blue.svg)
![WIP](https://www.repostatus.org/badges/latest/wip.svg)

BatNav is a Shiny application to perform spatial analyses using GPS points of flying foxes recorded by GCOI.

## How to launch BatNav?

:one: Clone this repository on your computer or download it as a ZIP file and unzip it.

:two: Add the "data" folder in BatNav folder. This folder contains SIG data used by BatNav during analysis. You can ask me for this folder if you don't have it (-> [r-fernandezz](https://github.com/r-fernandezz)).

:three: Last step depend to your operating system :
    - If you use windows :scream:... you can launch BatNav to run the command bellow, but first modify it to match the paths on your computer. Open Windows PowerShell in the BatNav folder to run the command.

    ```powershell
     & "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" "E:\Projets R\BatNav\app.R"
    ```

    - If you use MacOS or Linux :smirk:... you can launch BatNav to run the command bellow, but first modify it to match the paths on your computer. Open a terminal in the BatNav folder to run the command.

    ```bash
    Rscript app.R
    ```

