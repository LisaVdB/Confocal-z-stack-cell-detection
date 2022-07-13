import cv2
import numpy as np
import imagej

def gc_blob_detector(lsm_input, gc_output, ch1i, ch1l, area = 12, th = 8):
  area = int(area)
  th = int(th)
  
  macro = """
  //@ String input
  //@ String output
  //@ Integer area
  //@ Integer th
  //@ String ch1i
  //@ String ch1l

  list = getFileList(input);
  for (i = 0; i < list.length; i++){{
        action(input, output, list[i]);
  }}

  function action(input, output, filename) {{
      open(input + filename);
      run("Split Channels");
      selectWindow("C2-"+filename);
      close();
      selectWindow("C3-"+filename);
      close();
      selectWindow("C1-"+filename);
      run("Z Project...", "projection=[Max Intensity]");
      selectWindow("MAX_C1-"+filename);
      run("Enhance Contrast", "saturated=0.35");

      blob_img = output + filename + "_FCh";
      run("Detect Particles", ch1i + " " + ch1l + " ch1a=" + area + " ch1s=" + th + " rois=Ovals add=Nothing summary=Append");
      saveAs("png", blob_img);
      close();
      selectWindow("C1-"+filename);
      close();
  }}

  selectWindow("Log");
  run("Close");
  selectWindow("Results");
  run("Close");
  selectWindow("Summary");
  saveAs("measurements", "Results.csv");
  run("Close");
  """
  args = {
    'input': lsm_input,
    'output': gc_output,
    'area': area,
    'th': th,
    'ch1i': ch1i,
    'ch1l': ch1l
  }
  ij.py.run_macro(macro, args)

def gc_blob_detector_2(lsm_input, gc_output, ch1i, ch1l, area = 12, th = 8):
  area = int(area)
  th = int(th)

  macro = """
  //@ String input
  //@ String output
  //@ Integer area
  //@ Integer th
  //@ String ch1i
  //@ String ch1l

  list = getFileList(input);
  for (i = 0; i < list.length; i++){{
        action(input, output, list[i]);
  }}

  function action(input, output, filename) {{
      open(input + filename);
      run("Split Channels");
      selectWindow("C2-"+filename);
      close();
      selectWindow("C3-"+filename);
      close();
      selectWindow("C1-"+filename);
      run("Z Project...", "projection=[Max Intensity]");
      selectWindow("MAX_C1-"+filename);
      run("Enhance Contrast", "saturated=0.35");

      blob_img = output + filename + "_FCh1";
      run("Detect Particles", ch1i + " " + ch1l + " ch1a=" + area + " ch1s=" + th + " rois=Ovals add=Nothing summary=Append");
      saveAs("png", blob_img);
      close();

      selectWindow("C1-"+filename);
      close();
  }}

  selectWindow("Log");
  run("Close");
  selectWindow("Results");
  run("Close");
  selectWindow("Summary");
  saveAs("measurements", "Results.csv");
  run("Close");
  """
  args = {
    'input': lsm_input,
    'output': gc_output,
    'area': area,
    'th': th,
    'ch1i': ch1i,
    'ch1l': ch1l
  }
  ij.py.run_macro(macro, args)

def gc_blob_detector_3(lsm_input, gc_output, ch1i2, ch1l2, area2 = 12, th2 = 8):
  area2 = int(area2)
  th2 = int(th2)

  macro = """
  //@ String input
  //@ String output
  //@ Integer area2
  //@ Integer th2
  //@ String ch1i2
  //@ String ch1l2

  list = getFileList(input);
  for (i = 0; i < list.length; i++){{
        action(input, output, list[i]);
  }}

  function action(input, output, filename) {{
      open(input + filename);
      run("Split Channels");
      selectWindow("C2-"+filename);
      close();
      selectWindow("C1-"+filename);
      close();

      selectWindow("C3-"+filename);
      run("Z Project...", "projection=[Max Intensity]");
      selectWindow("MAX_C3-"+filename);
      run("Enhance Contrast", "saturated=0.35");

      blob_img = output + filename + "_FCh2";
      run("Detect Particles", ch1i2 + " " + ch1l2 + " ch1a=" + area2 + " ch1s=" + th2 + " rois=Ovals add=Nothing summary=Append");
      saveAs("png", blob_img);
      close();

      selectWindow("C3-"+filename);
      close();
  }}

  selectWindow("Log");
  run("Close");
  selectWindow("Results");
  run("Close");
  selectWindow("Summary");
  saveAs("measurements", "Results.csv");
  run("Close");
  """
  args = {
    'input': lsm_input,
    'output': gc_output,
    'area2': area2,
    'th2': th2,
    'ch1i2': ch1i2,
    'ch1l2': ch1l2
  }
  ij.py.run_macro(macro, args)