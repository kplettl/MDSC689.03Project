import vtk
import argparse
import sys
import os
import numpy as np
from vtk.util.numpy_support import vtk_to_numpy, numpy_to_vtk
import tkinter
import tkinter.filedialog
import pandas as pd
import csv


def KeyPress(obj, event):
    key = obj.GetKeySym()
    global zSlice

    if key == 'Up' or key == 'Right':
        # slice number increased by one if up/right arrow key pressed
        zSlice = zSlice + 1

    if key == "Down" or key == "Left":
        # slice number decreased by one if left/down arrow key pressed
        zSlice = zSlice - 1

    # updating mappers for image and segmentation for new slice + rendering
    originalMapper.SetZSlice(zSlice)
    segMapper.SetZSlice(zSlice)
    window.Render()


def defineRegions(segmentation, image):

    segmentations = [0] * (int(np.max(segmentation))+1)
    mean_values = [0] * (int(np.max(segmentation))+1)
    median_values = [0] * (int(np.max(segmentation))+1)

    for i in range(1, int(np.max(segmentation))+1):

        foreground = np.where(segmentation == i, image, 0)
        foreground = foreground.flatten()
        foreground = foreground[foreground != 0]

        segmentations[i] = foreground
        mean_values[i] = np.mean(foreground)
        median_values[i] = np.median(foreground)

    # print(foreground1.shape)
    # print(len(segmentations))
    # print(segmentations[1])

    # print(np.mean(segmentations[1]))
    # print(mean_values)

    # print(segmentations)
    # print(len(foreground))

    return mean_values, median_values


def createNumpyFromVTK(input):
    scalars = input.GetPointData().GetScalars()
    imageArray = vtk_to_numpy(scalars).reshape(
        input.GetDimensions(), order='F')

    return imageArray


print("Choose region segmentation image")
# taking input image for SNR calculation
root = tkinter.Tk()
root.withdraw()
segFile = tkinter.filedialog.askopenfilename()


# extract the file extension of the source file
ext = os.path.splitext(segFile)[1]
root.destroy()

# initiate source image reader
segReader = vtk.vtkImageReader()

# check if source image is a dicom or NIFTI file
if (ext == ".dcm"):
    imagedir = os.path.dirname(segFile)
    segReader = vtk.vtkDICOMImageReader()
    segReader.SetDirectoryName(imagedir)

else:
    if (ext == ".nii" or ext == ".nifti"):
        imageName = os.path.splitext(os.path.basename(segFile))[0]
        segReader = vtk.vtkNIFTIImageReader()
        segReader.SetFileName(segFile)
    else:
        print(("ERROR: image format not recognized for " + segFile))
        sys.exit()

segReader.Update()

print("Choose DT image")
# taking input image for SNR calculation
root = tkinter.Tk()
root.withdraw()
DTIFile = tkinter.filedialog.askopenfilename()


# extract the file extension of the source file
ext = os.path.splitext(DTIFile)[1]
root.destroy()

# initiate source image reader
DTIReader = vtk.vtkImageReader()

# check if source image is a dicom or NIFTI file
if (ext == ".dcm"):
    imagedir = os.path.dirname(DTIFile)
    DTIReader = vtk.vtkDICOMImageReader()
    DTIReader.SetDirectoryName(imagedir)

else:
    if (ext == ".nii" or ext == ".nifti"):
        imageName = os.path.splitext(os.path.basename(DTIFile))[0]
        DTIReader = vtk.vtkNIFTIImageReader()
        DTIReader.SetFileName(DTIFile)
    else:
        print(("ERROR: image format not recognized for " + DTIFile))
        sys.exit()

DTIReader.Update()

segArray = createNumpyFromVTK(segReader.GetOutput())

DTIArray = createNumpyFromVTK(DTIReader.GetOutput())

mean_values_harvardSubcort, median_values_harvardSubcort = defineRegions(
    segArray, DTIArray)

print('means', mean_values_harvardSubcort)
print('medians', median_values_harvardSubcort)

# with open('HarvardSubCort-labels.csv', newline='', encoding='utf-8-sig') as f:
#     reader = csv.reader(f)
#     labels = list(reader)

# np.savetxt('medians.csv', np.array(median_values_harvardSubcort).reshape(
#     1, np.array(median_values_harvardSubcort).shape[0]), header=",".join(map(str, labels)), delimiter=',', comments='')

# df = pd.read_csv('HarvardSubCort-labels.csv', header=None,
#                  index_col=0, names=('Intensity', 'Region'))
# print(df)
# HOSubCortDict = df.to_dict(orient='index')
# print(HOSubCortDict)

# to_csv = np.asarray(mean_values_harvardSubcort)
# # print(to_csv)


# for i in range(0, 20):
#     np.savetxt("file.csv", HOSubCortDict[i], to_csv[i], delimiter=",")

# print(region1)
# print(np.mean(region1))
# print(np.median(region1))
# print(np.std(region1))
