import cv2
import os
import numpy as np
import glob
import imagej

def png_converter(lsm_input, png_output):
    macro = """
    input = \"{i}\";
    output = \"{o}\";
    list = getFileList(input);
    for (i = 0; i < list.length; i++){{
            action(input, output, list[i]);
    }}

    function action(input, output, filename) {{
        open(input + filename);
    run("Split Channels");
    selectWindow("C1-" + filename);
    close();
    selectWindow("C2-" + filename);
    run("Z Project...", "projection=[Min Intensity]");
    selectWindow("MIN_C2-" + filename);
    run("Apply LUT");
    saveAs("png", output + filename);
    close();
    selectWindow("C2-" + filename);
    close();
    }}
    """.format(i=lsm_input, o=png_output)

    ij.py.run_macro(macro)

def png_converter_2(lsm_input, png_output):
    macro = """
    input = \"{i}\";
    output = \"{o}\";
    list = getFileList(input);
    for (i = 0; i < list.length; i++){{
            action(input, output, list[i]);
    }}

    function action(input, output, filename) {{
        open(input + filename);
    run("Split Channels");
    selectWindow("C1-" + filename);
    close();
    selectWindow("C3-" + filename);
    close();
    selectWindow("C2-" + filename);
    run("Z Project...", "projection=[Min Intensity]");
    selectWindow("MIN_C2-" + filename);
    run("Apply LUT");
    saveAs("png", output + filename);
    close();
    selectWindow("C2-" + filename);
    close();
    }}
    """.format(i=lsm_input, o=png_output)

    ij.py.run_macro(macro)

def blob_detector(input_folder, output_folder, minThreshold = 70, maxThreshold = 255, thresholdStep = 2, \
    minArea = 90, maxArea = 1500, minCircularity = 0.20, minConvexity = 0.2, color = 0):

    input_folder = input_folder + "*.png"
    filenames = [img for img in glob.glob(input_folder)]
    filenames.sort() # This sorts the files - Note that the order is 1, 10,...2, 3
    #This sets the Equalization limits and grid size for adaptive thresholding- 
    clahe = cv2.createCLAHE(clipLimit=1.0, tileGridSize=(2,2))

    # Setup SimpleBlobDetector parameters.
    params = cv2.SimpleBlobDetector_Params()
    # Change thresholds
    params.minThreshold = minThreshold
    params.maxThreshold = maxThreshold
    params.thresholdStep = thresholdStep
    # Filter by Area
    params.filterByArea = True
    params.minArea = minArea
    params.maxArea = maxArea
    # Filter by Circularity
    params.filterByCircularity = True
    params.minCircularity = minCircularity
    # Filter by Convexity
    params.filterByConvexity = True
    params.minConvexity = minConvexity
    # Filter by Inertia
    # params.filterByInertia = False
    # params.minInertiaRatio = 0.15
    # Filter by Color
    params.filterByColor = True
    params.blobColor = color


    # Create a detector with the parameters
    detector = cv2.SimpleBlobDetector_create(params)
    images = []
    images_with_keypoints = []
    cell_counts = []

    for img in filenames:
        n= cv2.imread(img,0)
        n = clahe.apply(n)
        # Detect blobs.
        keypoints = detector.detect(n)
        # Draw detected blobs as red circles.
        detected_image = cv2.drawKeypoints(n, keypoints, np.array([]), (0,0,255), cv2.DRAW_MATCHES_FLAGS_DRAW_RICH_KEYPOINTS)
        #Two arrays - One without marked areas, and one with
        images.append(n)      
        images_with_keypoints.append(detected_image)
        total_count = 0
        for i in keypoints:
            total_count = total_count + 1
        cell_counts.append(total_count)

    #This saves the marked images 
    name = []
    names = []
    for i in filenames:
        name = os.path.basename(i)
        names.append(name)
    ctrmax = len(images_with_keypoints)
    for ctr in range(0, ctrmax):
        cv2.imwrite(os.path.join(output_folder, names[ctr]+'_'+str(ctr)+'.png'), images_with_keypoints[ctr])
        cv2.waitKey(0)
    
    results = zip(np.array([names]), np.array([cell_counts]))

    return (names, cell_counts)
