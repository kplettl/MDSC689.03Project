# importing packages
import vtk

# read in warped T1 image
reader = vtk.vtkNIFTIImageReader()
reader.SetFileName(
    '/Users/kiraplettl/Desktop/transformations/T1ToFA_1008_Warped.nii')
reader.Update()

# read in transformed harvard oxford subcortical atlas
reader2 = vtk.vtkNIFTIImageReader()
reader2.SetFileName(
    '/Users/kiraplettl/Desktop/regResults/HarvardSub/FA/1008_HarvardSubcortTransformedtoFA.nii')
reader2.Update()

# read in transformed johns hopkins white matter atlas
reader3 = vtk.vtkNIFTIImageReader()
reader3.SetFileName(
    '/Users/kiraplettl/Desktop/regResults/JHU_WM/FA/1008_JHUTransformedtoFA.nii')
reader3.Update()

# read in transformed harvard oxford cortical atlas
reader4 = vtk.vtkNIFTIImageReader()
reader4.SetFileName(
    '/Users/kiraplettl/Desktop/regResults/HarvardCort/FA/1008_HarvardCortTransformedtoFA.nii')
reader4.Update()

# ================= define colour points, opacity, and opacity gradient for T1 image =================
colourFunc = vtk.vtkColorTransferFunction()
colourFunc.AddRGBPoint(5, 1, 1, 1)
colourFunc.AddRGBPoint(7, 1, 1, 1)

opacityFunc = vtk.vtkPiecewiseFunction()
opacityFunc.AddPoint(0, 0.0)
opacityFunc.AddPoint(6, 1.0)
opacityFunc.AddPoint(7, 1.0)

funcOpacityGradient = vtk.vtkPiecewiseFunction()
funcOpacityGradient.AddPoint(0,   0.0)
funcOpacityGradient.AddPoint(5,   0.1)
funcOpacityGradient.AddPoint(100,   0.7)

# ================= define colour points and opacity for harvard oxford subcortical atlas =================
colourFunc2 = vtk.vtkColorTransferFunction()
colourFunc2.AddRGBPoint(0, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(1, 0, 0, 0)
colourFunc2.AddRGBPoint(2, 0, 0, 0)
colourFunc2.AddRGBPoint(3, 0, 0, 0)
colourFunc2.AddRGBPoint(4, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(5, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(6, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(7, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(8, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(9, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(10, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(11, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(12, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(13, 0, 0, 0)
colourFunc2.AddRGBPoint(14, 0, 0, 0)
colourFunc2.AddRGBPoint(15, 0.4, 0.8, 0.66)
colourFunc2.AddRGBPoint(16, 0, 0, 0)
colourFunc2.AddRGBPoint(17, 0.0, 0.0, 0.0)
colourFunc2.AddRGBPoint(18, 0.78, 0.84, 0.9)
colourFunc2.AddRGBPoint(19, 0, 0, 0)
colourFunc2.AddRGBPoint(20, 0, 0, 0)
colourFunc2.AddRGBPoint(21, 0, 0, 0)

opacityFunc2 = vtk.vtkPiecewiseFunction()
opacityFunc2.AddPoint(0, 0.0)
opacityFunc2.AddPoint(1, 0.0)
opacityFunc2.AddPoint(2, 0.0)
opacityFunc2.AddPoint(3, 0.0)
opacityFunc2.AddPoint(4, 0.0)
opacityFunc2.AddPoint(5, 0.0)
opacityFunc2.AddPoint(6, 0.0)
opacityFunc2.AddPoint(7, 0.0)
opacityFunc2.AddPoint(8, 0.0)
opacityFunc2.AddPoint(9, 0.0)
opacityFunc2.AddPoint(10, 0.0)
opacityFunc2.AddPoint(11, 0.0)
opacityFunc2.AddPoint(12, 0.0)
opacityFunc2.AddPoint(13, 0.0)
opacityFunc2.AddPoint(14, 0.0)
opacityFunc2.AddPoint(15, 1.0)
opacityFunc2.AddPoint(16, 0.0)
opacityFunc2.AddPoint(17, 0.0)
opacityFunc2.AddPoint(18, 1.0)
opacityFunc2.AddPoint(19, 0.0)
opacityFunc2.AddPoint(20, 0.0)
opacityFunc2.AddPoint(21, 0.0)

# ================= define colour points and opacity for johns hopkins white matter atlas =================
colourFunc3 = vtk.vtkColorTransferFunction()
colourFunc3.AddRGBPoint(0, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(1, 0, 0, 0)
colourFunc3.AddRGBPoint(2, 0, 0, 0)
colourFunc3.AddRGBPoint(3, 0, 0, 0)
colourFunc3.AddRGBPoint(4, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(5, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(6, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(7, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(8, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(9, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(10, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(11, 0.0, 0.0, 0.0)
colourFunc3.AddRGBPoint(12, 1.0, 0.5, 1)
colourFunc3.AddRGBPoint(13, 0, 0, 0)
colourFunc3.AddRGBPoint(14, 0, 0, 0)
colourFunc3.AddRGBPoint(15, 0, 0, 0)
colourFunc3.AddRGBPoint(16, 0, 0, 0)
colourFunc3.AddRGBPoint(17, 0, 0, 0)
colourFunc3.AddRGBPoint(18, 1.0, 0.7, 0.75)
colourFunc3.AddRGBPoint(19, 0, 0, 0)
colourFunc3.AddRGBPoint(20, 0, 0, 0)

opacityFunc3 = vtk.vtkPiecewiseFunction()
opacityFunc3.AddPoint(0, 0.0)
opacityFunc3.AddPoint(1, 0.0)
opacityFunc3.AddPoint(2, 0.0)
opacityFunc3.AddPoint(3, 0.0)
opacityFunc3.AddPoint(4, 0.0)
opacityFunc3.AddPoint(5, 0.0)
opacityFunc3.AddPoint(6, 0.0)
opacityFunc3.AddPoint(7, 0.0)
opacityFunc3.AddPoint(8, 0.0)
opacityFunc3.AddPoint(9, 0.0)
opacityFunc3.AddPoint(10, 0.0)
opacityFunc3.AddPoint(11, 0.0)
opacityFunc3.AddPoint(12, 1.0)
opacityFunc3.AddPoint(13, 0.0)
opacityFunc3.AddPoint(14, 0.0)
opacityFunc3.AddPoint(15, 0.0)
opacityFunc3.AddPoint(16, 0.0)
opacityFunc3.AddPoint(17, 0.0)
opacityFunc3.AddPoint(18, 1.0)
opacityFunc3.AddPoint(19, 0.0)
opacityFunc3.AddPoint(20, 0.0)

# ================= define colour points and opacity for harvard oxford cortical atlas =================
colourFunc4 = vtk.vtkColorTransferFunction()
colourFunc4.AddRGBPoint(0, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(1, 0, 0, 0)
colourFunc4.AddRGBPoint(2, 0, 0, 0)
colourFunc4.AddRGBPoint(3, 0, 0, 0)
colourFunc4.AddRGBPoint(4, 0.5, 0.0, 0.0)
colourFunc4.AddRGBPoint(5, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(6, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(7, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(8, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(9, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(10, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(11, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(12, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(13, 0, 0, 0)
colourFunc4.AddRGBPoint(14, 0, 0, 0)
colourFunc4.AddRGBPoint(15, 0, 0, 0)
colourFunc4.AddRGBPoint(16, 0, 0, 0)
colourFunc4.AddRGBPoint(17, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(18, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(19, 0.13, 0.55, 0.13)
colourFunc4.AddRGBPoint(20, 0, 0, 0)
colourFunc4.AddRGBPoint(21, 0.8, 0.52, 0.25)
colourFunc4.AddRGBPoint(22, 0, 0, 0)
colourFunc4.AddRGBPoint(23, 0.0, 0, 0)
colourFunc4.AddRGBPoint(24, 0, 0, 0)
colourFunc4.AddRGBPoint(25, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(26, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(27, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(28, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(29, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(30, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(31, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(32, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(33, 0, 0, 0)
colourFunc4.AddRGBPoint(34, 0, 0, 0)
colourFunc4.AddRGBPoint(35, 0, 0, 0)
colourFunc4.AddRGBPoint(36, 0, 0, 0)
colourFunc4.AddRGBPoint(37, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(38, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(39, 0, 0, 0)
colourFunc4.AddRGBPoint(40, 0, 0.0, 0)
colourFunc4.AddRGBPoint(41, 1.0, 0, 0.5)
colourFunc4.AddRGBPoint(42, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(43, 0, 0, 0)
colourFunc4.AddRGBPoint(44, 0, 0, 0)
colourFunc4.AddRGBPoint(45, 0, 0, 0)
colourFunc4.AddRGBPoint(46, 0, 0, 0)
colourFunc4.AddRGBPoint(47, 0.0, 0.0, 0.0)
colourFunc4.AddRGBPoint(48, 0.0, 0.0, 0.0)

opacityFunc4 = vtk.vtkPiecewiseFunction()
opacityFunc4.AddPoint(0, 0.0)
opacityFunc4.AddPoint(1, 0.0)
opacityFunc4.AddPoint(2, 0.0)
opacityFunc4.AddPoint(3, 0.0)
opacityFunc4.AddPoint(4, 1.0)
opacityFunc4.AddPoint(5, 0.0)
opacityFunc4.AddPoint(6, 0.0)
opacityFunc4.AddPoint(7, 0.0)
opacityFunc4.AddPoint(8, 0.0)
opacityFunc4.AddPoint(9, 0.0)
opacityFunc4.AddPoint(10, 0.0)
opacityFunc4.AddPoint(11, 0.0)
opacityFunc4.AddPoint(12, 0.0)
opacityFunc4.AddPoint(13, 0.0)
opacityFunc4.AddPoint(14, 0.0)
opacityFunc4.AddPoint(15, 0.0)
opacityFunc4.AddPoint(16, 0.0)
opacityFunc4.AddPoint(17, 0.0)
opacityFunc4.AddPoint(18, 0.0)
opacityFunc4.AddPoint(19, 1.0)
opacityFunc4.AddPoint(20, 0.0)
opacityFunc4.AddPoint(21, 1.0)
opacityFunc4.AddPoint(22, 0.0)
opacityFunc4.AddPoint(23, 0.0)
opacityFunc4.AddPoint(24, 0.0)
opacityFunc4.AddPoint(25, 0.0)
opacityFunc4.AddPoint(26, 0.0)
opacityFunc4.AddPoint(27, 0.0)
opacityFunc4.AddPoint(28, 0.0)
opacityFunc4.AddPoint(29, 0.0)
opacityFunc4.AddPoint(30, 0.0)
opacityFunc4.AddPoint(31, 0.0)
opacityFunc4.AddPoint(32, 0.0)
opacityFunc4.AddPoint(33, 0.0)
opacityFunc4.AddPoint(34, 0.0)
opacityFunc4.AddPoint(35, 0.0)
opacityFunc4.AddPoint(36, 0.0)
opacityFunc4.AddPoint(37, 0.0)
opacityFunc4.AddPoint(38, 0.0)
opacityFunc4.AddPoint(39, 0.0)
opacityFunc4.AddPoint(40, 0.0)
opacityFunc4.AddPoint(41, 1.0)
opacityFunc4.AddPoint(42, 0.0)
opacityFunc4.AddPoint(43, 0.0)
opacityFunc4.AddPoint(44, 0.0)
opacityFunc4.AddPoint(45, 0.0)
opacityFunc4.AddPoint(46, 0.0)
opacityFunc4.AddPoint(47, 0.0)
opacityFunc4.AddPoint(48, 0.0)

# ================= defining properties for volume rendering of T1 image =================
volumeProp = vtk.vtkVolumeProperty()
volumeProp.ShadeOn()
volumeProp.SetColor(colourFunc)
volumeProp.SetScalarOpacity(opacityFunc)
volumeProp.SetGradientOpacity(funcOpacityGradient)
volumeProp.SetInterpolationTypeToLinear()
volumeProp.SetAmbient(0.3)
volumeProp.SetDiffuse(0.7)
volumeProp.SetSpecular(0.8)

# ================= defining properties for volume rendering of harvard oxford subcortical atlas =================
atlasProp = vtk.vtkVolumeProperty()
atlasProp.ShadeOn()
atlasProp.SetColor(colourFunc2)
atlasProp.SetScalarOpacity(opacityFunc2)
atlasProp.SetInterpolationTypeToNearest()

# ================= defining properties for volume rendering of johns hopkins white matter atlas =================
atlas2Prop = vtk.vtkVolumeProperty()
atlas2Prop.ShadeOn()
atlas2Prop.SetColor(colourFunc3)
atlas2Prop.SetScalarOpacity(opacityFunc3)
atlas2Prop.SetInterpolationTypeToNearest()

# ================= defining properties for volume rendering of harvard oxford cortical atlas =================
atlas3Prop = vtk.vtkVolumeProperty()
atlas3Prop.ShadeOn()
atlas3Prop.SetColor(colourFunc4)
atlas3Prop.SetScalarOpacity(opacityFunc4)
atlas3Prop.SetInterpolationTypeToNearest()

# ================= creating a mapper for the volume rendering of the T1 image =================
volMapper = vtk.vtkSmartVolumeMapper()
volMapper.SetInputConnection(reader.GetOutputPort())
volMapper.Update()

# ================= creating a mapper for the volume rendering of the harvard oxford subcortical atlas =================
atlasMapper = vtk.vtkSmartVolumeMapper()
atlasMapper.SetInputConnection(reader2.GetOutputPort())
atlasMapper.Update()

# ================= creating a mapper for the volume rendering of the harvard oxford subcortical atlas =================
atlas2Mapper = vtk.vtkSmartVolumeMapper()
atlas2Mapper.SetInputConnection(reader3.GetOutputPort())
atlas2Mapper.Update()

# ================= creating a mapper for the volume rendering of the harvard oxford subcortical atlas =================
atlas3Mapper = vtk.vtkSmartVolumeMapper()
atlas3Mapper.SetInputConnection(reader4.GetOutputPort())
atlas3Mapper.Update()

# ================= creating volume actor and applying previously defined properties for T1 image =================
volActor = vtk.vtkVolume()
volActor.SetMapper(volMapper)
volActor.SetProperty(volumeProp)

# ================= creating volume actor and applying previously defined properties for harvard oxford subcortical atlas =================
atlasActor = vtk.vtkVolume()
atlasActor.SetMapper(atlasMapper)
atlasActor.SetProperty(atlasProp)

# ================= creating volume actor and applying previously defined properties for johns hopkins atlas =================
atlas2Actor = vtk.vtkVolume()
atlas2Actor.SetMapper(atlas2Mapper)
atlas2Actor.SetProperty(atlas2Prop)

# ================= creating volume actor and applying previously defined properties for harvard oxford cortical atlas =================
atlas3Actor = vtk.vtkVolume()
atlas3Actor.SetMapper(atlas3Mapper)
atlas3Actor.SetProperty(atlas3Prop)

# ================= defining top and bottom viewports and renderers to visualise two views of brain =================
topViewport = [0.0, 0.0, 1.0, 0.5]
bottomViewport = [0.0, 0.5, 1.0, 1.0]

topRenderer = vtk.vtkRenderer()
topRenderer.SetViewport(topViewport)
topRenderer.SetBackground(1, 1, 1)

bottomRenderer = vtk.vtkRenderer()
bottomRenderer.SetViewport(bottomViewport)
bottomRenderer.SetBackground(1, 1, 1)

# ================= adding actors to top and bottom renderers =================
topRenderer.AddVolume(volActor)
topRenderer.AddVolume(atlasActor)
topRenderer.AddVolume(atlas2Actor)
topRenderer.AddVolume(atlas3Actor)

bottomRenderer.AddVolume(volActor)
bottomRenderer.AddVolume(atlasActor)
bottomRenderer.AddVolume(atlas2Actor)
bottomRenderer.AddVolume(atlas3Actor)

# ================= creating render window, adding top and bottom renderers and resizing =================
window = vtk.vtkRenderWindow()
window.AddRenderer(topRenderer)
window.AddRenderer(bottomRenderer)

window.SetSize(reader.GetOutput().GetDimensions()[
               0]*5, reader.GetOutput().GetDimensions()[1]*10)

# ================= setting up interactor =================
iren = vtk.vtkRenderWindowInteractor()
iren.SetRenderWindow(window)

# ================= setting camera views for top and bottom renderers =================
topCamera = vtk.vtkCamera()
topCamera.SetPosition(0.0, -1.0, 0.0)
topCamera.SetViewUp(0, 0, 1)

topRenderer.SetActiveCamera(topCamera)
topRenderer.ResetCamera()

bottomCamera = vtk.vtkCamera()
bottomCamera.SetPosition(1, -0.75, 0.0)
bottomCamera.SetViewUp(0, 0, 1)

bottomRenderer.SetActiveCamera(bottomCamera)
bottomRenderer.ResetCamera()

# render window
window.Render()

# initialise interactor
iren.Initialize()

# start interactor
iren.Start()
