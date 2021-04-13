import vtk
import tkinter
import tkinter.filedialog
import os
import sys

# ask user to choose image using tkinter
print("Choose first image")
root = tkinter.Tk()
root.withdraw()
imageFile1 = tkinter.filedialog.askopenfilename()

# extract the file extension of the source file
ext = os.path.splitext(imageFile1)[1]
root.destroy()

# initiate source image reader
reader1 = vtk.vtkImageReader()

# check if source image is a dicom or NIFTI file
if (ext == ".dcm"):
    imagedir1 = os.path.dirname(imageFile1)
    reader1 = vtk.vtkDICOMImageReader()
    reader1.SetDirectoryName(imagedir1)

else:
    if (ext == ".nii" or ext == ".nifti"):
        reader1 = vtk.vtkNIFTIImageReader()
        reader1.SetFileName(imageFile1)
        reader1.SetDataScalarTypeToUnsignedInt()
    else:
        print(("ERROR: image format not recognized for " + sourceImageFile))
        sys.exit()

reader1.Update()

# change pixel intensity range of images to be in the same scale,
# otherwise cannot visualise together in the checkerboard due to different grey values
shiftScaleFilter1 = vtk.vtkImageShiftScale()
shiftScaleFilter1.SetOutputScalarTypeToUnsignedChar()

shiftScaleFilter1.SetInputData(reader1.GetOutput())

shiftScaleFilter1.SetShift(-1.0 * reader1.GetOutput().GetScalarRange()[0])

oldRange1 = reader1.GetOutput().GetScalarRange(
)[1] - reader1.GetOutput().GetScalarRange()[0]

newRange1 = 255

shiftScaleFilter1.SetScale(newRange1/oldRange1)
shiftScaleFilter1.Update()

# ask user to choose image using tkinter
print("Choose second image")
root = tkinter.Tk()
root.withdraw()
imageFile2 = tkinter.filedialog.askopenfilename()

# extract the file extension of the source file
ext = os.path.splitext(imageFile2)[1]
root.destroy()

# initiate source image reader
reader2 = vtk.vtkImageReader()

# check if source image is a dicom or NIFTI file
if (ext == ".dcm"):
    imagedir2 = os.path.dirname(imageFile2)
    reader2 = vtk.vtkDICOMImageReader()
    reader2.SetDirectoryName(imagedir2)

else:
    if (ext == ".nii" or ext == ".nifti"):
        reader2 = vtk.vtkNIFTIImageReader()
        reader2.SetFileName(imageFile2)
        reader2.SetDataScalarTypeToUnsignedInt()
    else:
        print(("ERROR: image format not recognized for " + sourceImageFile))
        sys.exit()

reader2.Update()

# change pixel intensity range of images to be in the same scale,
# otherwise cannot visualise together in the checkerboard due to different grey values
shiftScaleFilter2 = vtk.vtkImageShiftScale()
shiftScaleFilter2.SetOutputScalarTypeToUnsignedChar()

shiftScaleFilter2.SetInputData(reader2.GetOutput())

shiftScaleFilter2.SetShift(-1.0 * reader2.GetOutput().GetScalarRange()[0])

oldRange2 = reader2.GetOutput().GetScalarRange(
)[1] - reader2.GetOutput().GetScalarRange()[0]

newRange2 = 255

shiftScaleFilter2.SetScale(newRange2/oldRange2)
shiftScaleFilter2.Update()

# set up vtk checkerboard filter with 5 or 6 divisions
checkerboardFilter = vtk.vtkImageCheckerboard()
checkerboardFilter.SetInputConnection(0, shiftScaleFilter1.GetOutputPort())
checkerboardFilter.SetInputConnection(1, shiftScaleFilter2.GetOutputPort())
# checkerboardFilter.SetNumberOfDivisions(5, 5, 1)
checkerboardFilter.SetNumberOfDivisions(6, 6, 1)

# set up interactor and image viewer
renderWindowInteractor = vtk.vtkRenderWindowInteractor()

imageViewer = vtk.vtkImageViewer2()
imageViewer.SetInputConnection(checkerboardFilter.GetOutputPort())
imageViewer.SetupInteractor(renderWindowInteractor)
imageViewer.GetRenderer().ResetCamera()

# NIHPD to T1
imageViewer.SetSlice(140)

# T1 to FA
# imageViewer.SetSlice(50)

# imageViewer.SetColorLevel(45)
# imageViewer.SetColorWindow(90)

# initalise and start render window
renderWindowInteractor.Initialize()
renderWindowInteractor.Start()
