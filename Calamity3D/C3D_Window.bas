Include Once

Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/C3D_Image.bas"

C3D_TEXTURE_MAP = 0
C3D_Image_Loaded[0] = TRUE 'Render Texture Map

C3D_TEXTURE_MAP_WIDTH = 2048
C3D_TEXTURE_MAP_HEIGHT = 2048

C3D_MAX_TEXTURE_MAP_DIV = 4
Dim C3D_TEXTURE_MAP_DIV[4, 2] 'How many rows and columns are in each division
Dim C3D_TEXTURE_MAP_DIV_WIDTH[4]
Dim C3D_TEXTURE_MAP_DIV_HEIGHT[4]

C3D_WINDOW = 0
C3D_CANVAS_RENDER = 6
C3D_CANVAS_BACKBUFFER = 7


Sub C3D_SetTextureMapDivision(div, rows, cols)
	If div >= C3D_MAX_TEXTURE_MAP_DIV Then
		Print "C3D_SetTextureMapDivision Error: Division is out of Range"
		Return
	End If
	
	C3D_TEXTURE_MAP_DIV[div, 0] = rows
	C3D_TEXTURE_MAP_DIV[div, 0] = cols
	C3D_TEXTURE_MAP_DIV_WIDTH[div] = (C3D_TEXTURE_MAP_WIDTH / 4) / cols
	C3D_TEXTURE_MAP_DIV_HEIGHT[div] = (C3D_TEXTURE_MAP_HEIGHT / 4) / rows
End Sub

Sub C3D_SetScreenOcclusionRange()
	sx = C3D_SCREEN_WIDTH
	sy = C3D_SCREEN_HEIGHT
	For z = 0 to -1 * (C3D_MAX_Z_DEPTH-1) Step -1
		distance = C3D_CAMERA_LENS - z
		min_x = (0 - C3D_SCREEN_GRAPH_OFFSET_X) * distance / 	C3D_CAMERA_LENS
		min_y = (sy - C3D_SCREEN_GRAPH_OFFSET_Y) * distance / C3D_CAMERA_LENS * -1
		max_x = (sx - C3D_SCREEN_GRAPH_OFFSET_X) * distance / 	C3D_CAMERA_LENS
		max_y = (0 - C3D_SCREEN_GRAPH_OFFSET_Y) * distance / C3D_CAMERA_LENS * -1
		
		C3D_ZX_Range[-1*z, 0] = min_x
		C3D_ZX_Range[-1*z, 1] = max_x
		
		C3D_ZY_Range[-1*z, 0] = min_y
		C3D_ZY_Range[-1*z, 1] = max_y
		
		'Print "pp = ";(-1*z);" --> ";C3D_ZX_Range[-1*z, 0];", ";C3D_ZX_Range[-1*z, 1]
	Next
	'WaitKey
	'end 
End Sub

Sub C3D_Init(title$, w, h, fullscreen, vsync)
	WindowOpen(0, title$, WINDOWPOS_CENTERED, WINDOWPOS_CENTERED, w, h, WindowMode(1, fullscreen, 0, 0, 0) , vsync)
	CanvasOpen(6, w, h, 0, 0, w, h, 0) ' Render View
	CanvasOpen(7, 1024, 1024, 0, 0, 1024, 1024, 0) ' Back Buffer
	
	C3D_SetTextureMapDivision(0, 1, 1) 'Default Terrain Division
	C3D_SetTextureMapDivision(1, 1, 4)
	C3D_SetTextureMapDivision(2, 1, 4)
	C3D_SetTextureMapDivision(3, 1, 4)
	
	C3D_SCREEN_WIDTH = w
	C3D_SCREEN_HEIGHT = h
	C3D_UpdateGlobalParameters()
	C3D_SetScreenOcclusionRange()
End Sub