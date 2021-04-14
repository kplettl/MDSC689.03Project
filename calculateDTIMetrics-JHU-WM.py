import vtk
import os
import numpy as np
import glob
from vtk.util.numpy_support import vtk_to_numpy
import csv


def defineRegions(segmentation, image):

    # create lists for each segmented region and means and medians that are one longer than the number of labels (label 0 is not used, will be empty)
    segmentations = [0] * (int(np.max(segmentation))+1)
    mean_values = [0] * (int(np.max(segmentation))+1)
    median_values = [0] * (int(np.max(segmentation))+1)

    # for each label in the atlas, the brain region atlas (segmentation) and input image (DTI map) are compared
    # where the segmentation equals the given label number, the voxel values of image are stored in foreground, and any other voxels are stored as 0
    # foreground is flattened to form a list and zeros are removed, followed by storing in segmentations and calculating mean and median values
    for i in range(1, int(np.max(segmentation))+1):

        foreground = np.where(segmentation == i, image, 0)
        foreground = foreground.flatten()
        foreground = foreground[foreground != 0]

        segmentations[i] = foreground
        mean_values[i] = np.mean(foreground)
        median_values[i] = np.median(foreground)

    return mean_values, median_values


def createNumpyFromVTK(input):
    scalars = input.GetPointData().GetScalars()
    imageArray = vtk_to_numpy(scalars).reshape(
        input.GetDimensions(), order='F')

    return imageArray


# paths to access DTI maps
DTIPaths = {'FA': '/Users/kiraplettl/Desktop/NIHPD_V1_Images/FAReoriented/',
            'AD': '/Users/kiraplettl/Desktop/NIHPD_V1_Images/ADImages/',
            'RD': '/Users/kiraplettl/Desktop/NIHPD_V1_Images/RDImages/',
            'MD': '/Users/kiraplettl/Desktop/NIHPD_V1_Images/MDImages/'}

# paths to access transformed jhu atlases
JHUAtlasPaths = {'AD': '/Users/kiraplettl/Desktop/regResults/JHU_WM/AD/',
                 'FA': '/Users/kiraplettl/Desktop/regResults/JHU_WM/FA/',
                 'MD': '/Users/kiraplettl/Desktop/regResults/JHU_WM/MD/',
                 'RD': '/Users/kiraplettl/Desktop/regResults/JHU_WM/RD/'}

# sorting images by ID number to ensure that the images for one participant are compared and not mixed between participants
FAImages = sorted(glob.glob(DTIPaths['FA'] + '*'))
ADImages = sorted(glob.glob(DTIPaths['AD'] + '*'))
RDImages = sorted(glob.glob(DTIPaths['RD'] + '*'))
MDImages = sorted(glob.glob(DTIPaths['MD'] + '*'))

JHUToFA = sorted(glob.glob(JHUAtlasPaths['FA'] + '*'))
JHUToAD = sorted(glob.glob(JHUAtlasPaths['AD'] + '*'))
JHUToRD = sorted(glob.glob(JHUAtlasPaths['RD'] + '*'))
JHUToMD = sorted(glob.glob(JHUAtlasPaths['MD'] + '*'))

# open csv file to save features for weka pipeline
with open('JHU-WMFeatures.csv', 'a') as csvfile:

    writer = csv.writer(csvfile, delimiter=',')

    for i in range(len(JHUToFA)):
        features = []
        flatlist = []
        # get patient ID from filename
        id = FAImages[i].split('/')[-1].split('_')[0]
        print(id)

        # read in FA image file
        FAReader = vtk.vtkImageReader()
        FAImageFile = os.path.abspath(FAImages[i])
        print(FAImageFile)
        FAReader = vtk.vtkNIFTIImageReader()
        FAReader.SetFileName(FAImageFile)
        FAReader.Update()

        # read in jhu atlas image file
        JHUToFAFile = os.path.abspath(JHUToFA[i])
        atlasReader = vtk.vtkNIFTIImageReader()
        atlasReader.SetFileName(JHUToFAFile)
        atlasReader.Update()

        # generate numpy arrays for FA image and atlas image
        FAArray = createNumpyFromVTK(FAReader.GetOutput())
        JHUFAArray = createNumpyFromVTK(atlasReader.GetOutput())

        # get mean, median values
        mean_values_JHU, median_values_JHU = defineRegions(
            JHUFAArray, FAArray)

        # append the median values to a list for later printing to csv (mean values not included here)
        features.append(median_values_JHU)

        # same process as above repeated for AD and atlas images
        ADImageFile = os.path.abspath(ADImages[i])
        ADReader = vtk.vtkNIFTIImageReader()
        ADReader.SetFileName(ADImageFile)
        ADReader.Update()

        JHUToADFile = os.path.abspath(JHUToAD[i])
        atlasReader = vtk.vtkNIFTIImageReader()
        atlasReader.SetFileName(JHUToADFile)
        atlasReader.Update()

        ADArray = createNumpyFromVTK(ADReader.GetOutput())
        JHUADArray = createNumpyFromVTK(atlasReader.GetOutput())

        mean_values_JHU, median_values_JHU2 = defineRegions(
            JHUADArray, ADArray)

        features.append(median_values_JHU2)

        # same process as above repeated for RD and atlas images
        RDImageFile = os.path.abspath(RDImages[i])
        RDReader = vtk.vtkNIFTIImageReader()
        RDReader.SetFileName(RDImageFile)
        RDReader.Update()

        JHUToRDFile = os.path.abspath(JHUToRD[i])
        atlasReader = vtk.vtkNIFTIImageReader()
        atlasReader.SetFileName(JHUToRDFile)
        atlasReader.Update()

        RDArray = createNumpyFromVTK(RDReader.GetOutput())
        JHURDArray = createNumpyFromVTK(atlasReader.GetOutput())

        mean_values_JHU, median_values_JHU3 = defineRegions(
            JHURDArray, RDArray)

        features.append(median_values_JHU3)

        # same process as above repeated for MD and atlas images
        MDImageFile = os.path.abspath(MDImages[i])
        MDReader = vtk.vtkNIFTIImageReader()
        MDReader.SetFileName(MDImageFile)
        MDReader.Update()

        JHUToMDFile = os.path.abspath(JHUToMD[i])
        atlasReader = vtk.vtkNIFTIImageReader()
        atlasReader.SetFileName(JHUToMDFile)
        atlasReader.Update()

        MDArray = createNumpyFromVTK(MDReader.GetOutput())
        JHUMDArray = createNumpyFromVTK(atlasReader.GetOutput())

        mean_values_JHU, median_values_JHU4 = defineRegions(
            JHUMDArray, MDArray)

        features.append(median_values_JHU4)

        # concatenating all lists together and flattening to form one long list
        flatlist = list(np.concatenate(features).flat)
        # writing all dti features for one participant to one row - one loop through the for loop writes one row, then repeats for the next participant
        writer.writerow(flatlist)
