# Confocal-z-stack-cell-detection
To facilitate repeatable, robust, and rapid analysis of a large number of confocal images of cells, we generated an automated open source image analysis pipeline that can be run through an R Shiny graphical user interface (GUI) to detect and quantify cells in brightfield and/or fluorescence confocal z-stack images. The GUI runs two  in-house developed python scripts in the backend.

Content:
- [Publication](#Publication)
- [Requirements](#Requirements)
- [Folder structure to run Shiny](#Folder-structure-to-run-Shiny)
- [Installation](#Installation)
- [Workflow](#Workflow)
- [Parameter Description](#Parameter-Description)
- [Potential errors](#Potential-errors)

# Publication
Lisa Van den Broeck, Michael F Schwartz, Srikumar Krishnamoorthy, Maimouna Abderamane Tahir, Ryan Spurney, Imani Madison, Charles Melvin, Mariah Gobble, Thomas Nguyen, Rachel Peters, Aitch Hunt, Atiyya Muhammad, Baochun Li, Maarten Stuiver, Timothy Horn, Rosangela Sozzani (2022). Establishing a reproducible approach to study cellular functions of plants cells with 3D bioprinting. _Science Advances_ DOI: 10.1126/sciadv.abp9906

# Requirements
- Python 3.8.12
- Opencv 4.5.4
- Pyimagej 1.0.2
- Openjdk 11.0.9.1
- Reticulate 1.22
- R 4.1.2
- Shiny 1.6.0
- shinyWidgets 0.6.0

# Requirements images
The confocal images need to be z-stack images with the following channels:
- In case of 2 channels: channel 1 needs to be the fluorescent channel and channel 2 the brightfield
- In case of 3 channels: channel 1, 2, and 3 need to be the first fluorescent channel, the brightfield, and the second fluorescent channel, respectively

If the channel order is incorrect, the GUI will not work properly. It is however possible to adjust the channel order in the source code (BF_BlobDetector.py and GC_BlobDetector.py).

# Folder structure to run Shiny
When downloading the repository, unzip the files. Four main folders will store the input and output images:
1. ./in folder contains the confocal z-stack images to analyse. The images should have the .lsm extension.
2. ./out folder will contain the .png projections of the brightfield channel into a single plane.
3. ./bf folder will contain the .png images from the ./out folder marked with the detected cells in red circles.
4. ./gc folder will contain the .png projections of the fluorescent channel into a single plane.

Before running the Shiny application, please copy the .lsm images to the ./in folder. Once you have set the parameters and proceeded to run the analysis, the output images will appear in the abovementioned folders. **It is strongly advised to set the parameters in a trial and error fashion on a few images and then run the analysis on the entire image set.** Copy the results to your own local folders and restart the analysis with new images. The previous results will be overwritten. 

# Installation
Create an environment and install the following:

- Python == 3.8.12
- Python packages: opencv, openjdk and pyimagej

For example:

```bash
conda create -n r-reticulate python==3.8.12
conda activate r-reticulate
conda install opencv==4.5.4
conda install -c conda-forge pyimagej==1.0.2
conda install -c conda-forge openjdk==11.0.9.1
```

Install R (versio 4.1.2) and RStudio. Open the .Rprofile in RStudio and change the python path to your system. For example: 

```Sys.setenv(RETICULATE_PYTHON = 'C:/Users/name/AppData/Local/r-miniconda/envs/r-reticulate/python.exe')```

To discover the python path of your created conda environment, open the server or ui file in RStudio, load the reticulate package (```library(reticulate)```) and use ```conda_list()```. To confirm whether the correct python version is called within R, use ```py_config()```. To run the Shiny application press "Run App".

# Workflow
The GUI runs three in-house developed python scripts in the backend. The first python script separates the fluorescence and brightfield channels, performs a z-projection of the brightfield channel using minimum intensity, and saves the projections as .png files. This function relies on the ImageJ package. The second python script quantifies cells in the brightfield channel using the publicly available OpenCV Computer vision library for tracking and counting of cells that performs contrast limited adaptive histogram equalization on the brightfield images, and uses an edge detection algorithm to detect and count cells. The third script separates fluorescence and brightfield channels, performs z-projection of the fluorescence channel using maximum intensity, and detects and quantifies cells in the fluorescent channels with ComDet v 0.5.3, an open source plugin for ImageJ. 
![lisa_dataflow_diagrams_HHedits-02](https://user-images.githubusercontent.com/63100166/150310914-8dce3a6e-e10b-47d1-8ead-75680623aa68.png)
[@flavoraitch](https://www.flavoraitch.com) 

# Parameter description
After downloading the Github repository, the confocal images to be analyzed should be copied and pasted into the "in" file. The GUI can be launched by opening the "server" or "ui" folder in RStudio and clicking on "Run App" on the bar menu. The OpenCV built-in function used for the detection and quantification of cells in the brightfield channel is called SimpleBlobDetector. The SimpleBlobDetector function uses an algorithm to draw circles around detected cells within the image based on a number of parameters. These parameters allow us to alter the detection parameters and are defined as:
1. Minimum and maximum area: they set the minimum and maximum pixel area to detect a cell.
2. Minimum and maximum threshold: they determine the pixel intensity to start and stop generating binary images (i.e. images consisting of black and white pixels).
3. Minimum circularity: the minimum circularity value determines how circular the cells are. The maximum circularity is 1 and describes a perfect circle.
4. Minimum convexity: it determines the convexity value, which characterizes the shape of the cells, for cell detection. 
5. Color: it filters out cells whose color is different than the selected pixel intensity and can be set either to 0 or 1 to detect dark or light cells, respectively.

To analyze the fluorescent channel of the confocal images, the area and threshold parameters can be set from 0 to a certain value to determine the area of the detected cells or the intensity difference between the foreground and background of the binary images, respectively. The options “include large cells” and “split large cells” can be marked when it is necessary to quantify large particles and further split them into smaller ones, respectively.

# Potential errors

## JVM not found
Info about this error can be found at https://github.com/imagej/pyimagej/issues/176

To resolve the error, add JAVA_HOME to ImageJ.py file in the src folder by adding the following line of code prior to setting the ij variable:

```os.environ['JAVA_HOME'] = 'C:\\Users\\name\\AppData\\Local\\r-miniconda\\envs\\r-reticulate'```

Important, change the path to the JAVA_HOME path in your system, use double backslashes, and make sure the path refers immediately to your conda environment and not the library folder. To find out the JAVA_HOME path, type into python:

```bash
import os
print(os.environ['JAVA_HOME'])
```

## The handle is invalid
Locate the jgo.py file (most likely in your environment within the lib\site-packages\jgo folder). Locate the following piece of code

```bash
def run_and_combine_outputs(command, *args):
    try:
        command_string = (command,) + args
        _logger.debug(f"Executing: {command_string}")
        retrun subprocess.check_output(command_string, stderr=subprocess.STDOUT)
```

and add ```stdin=subprocess.DEVNULL``` as follow

```bash
def run_and_combine_outputs(command, *args):
    try:
        command_string = (command,) + args
        _logger.debug(f"Executing: {command_string}")
        retrun subprocess.check_output(command_string, stderr=subprocess.STDOUT, stdin=subprocess.DEVNULL)
```
