# PSoC5_VS_Creator
A Visual Studio Code 'project wrapper' for PSoC5 development using PSoC Creator for routing / system setup.
<br/><br/>
<em>For Windows, Linux, MacOs</em>

The example project is a 'Kitt Scanner' using only a handfull of magnificent UDB blocks. Just connect 8 LED's to Port2.<br/><br/>
![Kitt Scanner](../../../assets/blob/main/PSoC5_VS_Creator/Kitt_Scanner.png?raw=true)<br/>

Project structure:
|Visual Studio Code Project|||
|---|---|---|
||.vs|<em>visual studio code settings</em>|
||build|<em>the build output for the project (project.elf & project.hex will be here)</em>|
||config|<em>additional files for VS Code setup / configuration</em>|
||PSoC_Creator.cydsn|<em>PSoC Creator project</em>|
||source|<em>location of your source files (main.c etc.)</em>|

## Preparation
1. Most of the prerequisites are already bundled in the Onethinx Pack (GNU ARM tools, VS Code extensions etc.)
    - For Windows: [VSCode_OnethinxPack_Windows](https://github.com/onethinx/VSCode_OnethinxPack_Windows)
    - For Linux: [VSCode_OnethinxPack_Linux](https://github.com/onethinx/VSCode_OnethinxPack_Linux)
    - For MacOS: [VSCode_OnethinxPack_MacOS](https://github.com/onethinx/VSCode_OnethinxPack_MacOS)
1. Clone or download the project to your local machine.
## Start coding and debugging :-)
1. Start VS Code
1. Load the project: File >> Open (Folder) >> Select the folder of the project >> OK
1. Click "⚙︎ Build" in the status bar to build the project.
    * if it fails to build, try "Clean Reconfigure" + "Clean Rebuild" from the Cmake extension (left bar).
    * if it still fails, try deleting the contents of the 'build/' folder.
1. Debug the project using the (Cortex-) Debug extension from the left bar.
    * depending on your debug adapter select "Debug CMSIS-DAP (OpenOCD)", "Debug J-Link" or "Debug J-Link (OpenOCD)" and press 'start'.
## Notes
1. PSoC Creator is needed for the routing / system setup. A Windows environment is required to run PSoC Creator. PSoC Creator is only needed for the chip configuration (often a one-time setup).
1. OpenOCD and J-Link don't support programming of ECC memory. Make sure the 'Store configuration data in ECC memory' setting in the Design Wide Resources (.cydwr) is disabled.
1. The build process uses Cypress' cyelftool which is officialy built for Windows only. Included is a rebuilt version for MacOs, the binary for Linux can be built using the [C source files](https://www.cypress.com/documentation/software-and-drivers/elftool-open-source-foss-packages). Another possibility is to use Wine.
1. PSoC Creator uses CyComponentLibrary.a from the PSoC Creator application folder. The postbuild action copies CyComponentLibrary.a from the PSoC Creator application folder to the project folder.
<br/><br/>
![PSoC5_VS_Creator](../../../assets/blob/main/PSoC5_VS_Creator/VS_Code_Creator.png?raw=true)<br/>
