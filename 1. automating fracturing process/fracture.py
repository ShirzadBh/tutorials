import pymxs
from pymxs import runtime as mxs


# Execute
def execute():
    # Define the target object
    my_target = mxs.selection[0]

    # Reset the pivot
    my_target.pivot = my_target.center

    # Define the grid object
    my_grid = mxs.grid()

    # Define the vector
    vector = my_target.transform.position - mxs.inverse(mxs.viewport.getTM()).position

    # Define the length of the target
    distance = (mxs.length(my_target.min - my_target.max) / 2)

    # Normalize + UP vector (Z)
    X = mxs.normalize(vector)
    Z = mxs.point3(0, 0, 1)
    Y = mxs.normalize(mxs.cross(Z, X))
    Z = mxs.normalize(mxs.cross(X, Y))

    # Define a new transform based on vector
    my_transform = mxs.matrix3(Z, Y, X, my_target.transform.position)

    # Edit the position of the transform
    new_position = my_transform.position - (X * distance)
    my_transform = mxs.matrix3(Z, Y, X, new_position)

    # Assign the transform to the grid
    my_grid.transform = my_transform

    # Activate the grid
    mxs.activegrid = my_grid

    # Define spline method
    def setMode(name):
        name.curveType = 1

    # Set iso view
    mxs.execute("max vpt iso user")

    # Define user draw curves
    curves = mxs.startObjectCreation(mxs.FreehandSpline, returnNewNodes=True, newNodeCallback=setMode)

    # Define modifiers
    noise_mod = mxs.Noisemodifier()
    quad_mod = mxs.Quadify_Mesh()
    extrude_mod = mxs.Extrude()

    # Change the parameters
    extrude_mod.amount = distance * 2
    quad_mod.quadsize = 2
    noise_mod.scale = 10
    noise_mod.fractal = True
    noise_mod.strength = mxs.point3(5, 5, 5)

    # Add the modifiers
    mxs.addmodifier(curves, extrude_mod)
    mxs.addmodifier(curves, quad_mod)
    mxs.addmodifier(curves, noise_mod)

    # Define cutter splines
    mxs.ProCutter.CreateCutter(curves, 1, True, True, False, True, True)

    # Define stock object
    mxs.ProCutter.AddStocks(curves[0], my_target, 1, 1)

    # Set perspective view
    mxs.execute("max vpt persp user")

    # Deactivate and delete the grid
    mxs.activegrid = None
    mxs.delete(my_grid)


if (mxs.selection.count != 0):

    execute()

else:
    print("Please select an object")
