# Create an ImageJ gateway with the newest available version of ImageJ.
import imagej
import os

# Add Plugings
cwd = os.getcwd()
imagej._set_ij_env(cwd)

ij = imagej.init('sc.fiji:fiji:2.3.0', headless=False)

