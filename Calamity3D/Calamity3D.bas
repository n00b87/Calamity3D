Include Once

C3D_CAMERA_LENS = 270 'Distance from 0, facing down negative z-axis

C3D_MAX_Z_DEPTH = 5000

C3D_LLOD_DEPTH = 1000
C3D_MAX_LOD_DEPTH = 7000

C3D_GRAPH_LEFT = -20
C3D_GRAPH_RIGHT = 20
C3D_GRAPH_BOTTOM = 0
C3D_GRAPH_TOP = 40
C3D_GRAPH_NEARZ = 0.1
C3D_GRAPH_FARZ = 100

C3D_GRAPH_RANGE_LR = C3D_GRAPH_RIGHT - C3D_GRAPH_LEFT
C3D_GRAPH_RANGE_TB = C3D_GRAPH_TOP - C3D_GRAPH_BOTTOM

C3D_GRAPH_FOV = 45
C3D_GRAPH_ASPECT_RATIO = 640/480 'Default that will be changed when window is opened

C3D_SCREEN_WIDTH = 640
C3D_SCREEN_HEIGHT = 480

C3D_SCREEN_GRAPH_OFFSET_X = C3D_SCREEN_WIDTH / 2
C3D_SCREEN_GRAPH_OFFSET_Y = C3D_SCREEN_HEIGHT

Dim C3D_ZX_Range[C3D_MAX_Z_DEPTH, 2]
Dim C3D_ZY_Range[C3D_MAX_Z_DEPTH, 2]

C3D_TEXTURE_MAP = 0

C3D_TEXTURE_MAP_WIDTH = 2048
C3D_TEXTURE_MAP_HEIGHT = 2048

C3D_MAX_TEXTURE_MAP_DIV = 4
Dim C3D_TEXTURE_MAP_DIV[C3D_MAX_TEXTURE_MAP_DIV, 2] 'How many rows and columns are in each division
Dim C3D_TEXTURE_MAP_DIV_POS_X[C3D_MAX_TEXTURE_MAP_DIV, 4, 4] 'x ; max of 4 rows and 4 cols
Dim C3D_TEXTURE_MAP_DIV_POS_Y[C3D_MAX_TEXTURE_MAP_DIV, 4, 4] 'y ; max of 4 rows and 4 cols
Dim C3D_TEXTURE_MAP_DIV_UV_X[C3D_MAX_TEXTURE_MAP_DIV, 4, 4] 'x ; max of 4 rows and 4 cols
Dim C3D_TEXTURE_MAP_DIV_UV_Y[C3D_MAX_TEXTURE_MAP_DIV, 4, 4] 'y ; max of 4 rows and 4 cols
Dim C3D_TEXTURE_MAP_DIV_UV_WIDTH[C3D_MAX_TEXTURE_MAP_DIV]
Dim C3D_TEXTURE_MAP_DIV_UV_HEIGHT[C3D_MAX_TEXTURE_MAP_DIV]
Dim C3D_TEXTURE_MAP_DIV_WIDTH[C3D_MAX_TEXTURE_MAP_DIV]
Dim C3D_TEXTURE_MAP_DIV_HEIGHT[C3D_MAX_TEXTURE_MAP_DIV]
Dim C3D_TEXTURE_MAP_DIV_IMAGES[C3D_MAX_TEXTURE_MAP_DIV, 4, 4] 'Max of 16 images per division

ArrayFill(C3D_TEXTURE_MAP_DIV_IMAGES, -1)

C3D_WINDOW = 0
C3D_CANVAS_RENDER = 6
C3D_CANVAS_BACKBUFFER = 7


Sub C3D_UpdateGlobalParameters()
	C3D_GRAPH_RANGE_LR = C3D_GRAPH_RIGHT - C3D_GRAPH_LEFT
	C3D_GRAPH_RANGE_TB = C3D_GRAPH_TOP - C3D_GRAPH_BOTTOM

	C3D_GRAPH_ASPECT_RATIO = C3D_SCREEN_WIDTH/C3D_SCREEN_HEIGHT 'Default that will be changed when window is opened

	C3D_SCREEN_GRAPH_OFFSET_X = C3D_SCREEN_WIDTH / 2
	C3D_SCREEN_GRAPH_OFFSET_Y = C3D_SCREEN_HEIGHT
End Sub

Include "Calamity3D/C3D_Utility.bas"
Include "Calamity3D/C3D_Collision.bas"
Include "Calamity3D/C3D_Scene.bas"
Include "Calamity3D/C3D_Mesh.bas"
Include "Calamity3D/C3D_Image.bas"
Include "Calamity3D/C3D_Sprite.bas"
Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/C3D_Window.bas"



C3D_Camera_Matrix_T = C3D_CreateMatrix(4,4)
C3D_Camera_Matrix_RX = C3D_CreateMatrix(4,4)
C3D_Camera_Matrix_RY = C3D_CreateMatrix(4,4)
C3D_Camera_Matrix_RZ = C3D_CreateMatrix(4,4)