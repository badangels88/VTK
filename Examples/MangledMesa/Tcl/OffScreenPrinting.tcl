package require vtktcl

# This script demonstrates the use of mangled Mesa to generate an 
# off-screen copy of the OpenGL render window. A cone is created
# and added to the OpenGL renderer. When the user press the Print
# button, a copy of the scene is rendered on the Mesa window
# (which is set to render in memory) and then the scene is save to
# a png file using the png writer.

# Create the pipeline
# Note that an equivalent Mesa object has to be created for each
# OpenGL object.

# The OpenGL render window
vtkRenderWindow rw
# The Mesa equivalent
vtkMesaRenderWindow mrw
mrw OffScreenRenderingOn

# OpenGL
vtkRenderer ren
rw AddRenderer ren
# Mesa
vtkMesaRenderer mren
mrw AddRenderer mren

vtkConeSource cone

# OpenGL
vtkPolyDataMapper map
map SetInput [cone GetOutput]
# Mesa
vtkMesaPolyDataMapper mmap
mmap SetInput [cone GetOutput]

# OpenGL
vtkActor actor
actor SetMapper map
# Mesa
vtkActor mactor
mactor SetMapper mmap

# Add the actor to the renderer
ren AddActor actor
mren AddActor mactor

# These are for creating an image from the Mesa render window
vtkWindowToImageFilter w2if
w2if SetInput mrw

vtkPNGWriter writer
writer SetInput [w2if GetOutput]
writer SetFileName "MesaPrintout.png"

set mesaCamera [mren GetActiveCamera]
set openGLCamera [ren GetActiveCamera]

proc PrintWithMesa {} {
    global mesaCamera openGLCamera
    eval $mesaCamera SetPosition [$openGLCamera GetPosition]
    eval $mesaCamera SetFocalPoint [$openGLCamera GetFocalPoint]
    eval $mesaCamera SetViewUp [$openGLCamera GetViewUp]
    eval $mesaCamera SetClippingRange [$openGLCamera GetClippingRange]

    mrw Render
    
    writer Write
}

# ------------------- Create the UI ---------------------
# prevent the tk window from showing up then start the event loop
wm withdraw .

# Create the toplevel window
toplevel .top
wm title .top {Printing with Mesa Offscreen Demo}

# Create two frames
frame .top.f1 
frame .top.f2
pack .top.f1 .top.f2 -side top -expand 1 -fill both

vtkTkRenderWidget .top.f1.rw -width 400 -height 400 -rw rw
BindTkRenderWidget .top.f1.rw
pack .top.f1.rw -expand 1 -fill both


button .top.f2.b0 -text "Print" -command {PrintWithMesa}
button .top.f2.b1 -text "Quit" -command {vtkCommand DeleteAllObjects; exit}
pack .top.f2.b0  -expand 1 -fill x
pack .top.f2.b1  -expand 1 -fill x




