Include Once

Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/C3D_Image.bas"


Function C3D_SetTextureMapDivision(div, rows, cols)
	If div >= C3D_MAX_TEXTURE_MAP_DIV Then
		Print "C3D_SetTextureMapDivision Error: Division is out of Range"
		Return False
	End If
	
	If rows > 4 Or cols > 4 Or rows < 1 Or cols < 1 then
		Print "C3D_SetTextureMapDivision Error: Rows/Cols must be in range 1 to 4"
		Return False
	End If
	
	C3D_TEXTURE_MAP_DIV[div, 0] = rows
	C3D_TEXTURE_MAP_DIV[div, 1] = cols
	C3D_TEXTURE_MAP_DIV_WIDTH[div] = (C3D_TEXTURE_MAP_WIDTH / (C3D_MAX_TEXTURE_MAP_DIV/2)) / cols
	C3D_TEXTURE_MAP_DIV_HEIGHT[div] = (C3D_TEXTURE_MAP_HEIGHT / (C3D_MAX_TEXTURE_MAP_DIV/2)) / rows
	
	'Print ""
	'Print "C3D_SetTextureMapDivision Info:"
	'Print "div = "; div; " rows = "; rows; " cols = "; cols
	'Print "TM_DIV_WIDTH = "; C3D_TEXTURE_MAP_DIV_WIDTH[div]
	'Print "TM_DIV_HEIGHT = "; C3D_TEXTURE_MAP_DIV_HEIGHT[div]
	'Print ""
	
	C3D_TEXTURE_MAP_DIV_UV_WIDTH[div] = C3D_TEXTURE_MAP_DIV_WIDTH[div] / C3D_TEXTURE_MAP_WIDTH
	C3D_TEXTURE_MAP_DIV_UV_HEIGHT[div] = C3D_TEXTURE_MAP_DIV_HEIGHT[div] / C3D_TEXTURE_MAP_HEIGHT
	
	'Print "TX UV SIZE = "; C3D_TEXTURE_MAP_DIV_UV_WIDTH[div]; " x "; C3D_TEXTURE_MAP_DIV_UV_HEIGHT[div]
	'Print ""
	
	For r = 0 to rows - 1
		For c = 0 to cols - 1
			div_w = (C3D_TEXTURE_MAP_WIDTH / (C3D_MAX_TEXTURE_MAP_DIV/2))
			div_h = (C3D_TEXTURE_MAP_HEIGHT / (C3D_MAX_TEXTURE_MAP_DIV/2))
			C3D_TEXTURE_MAP_DIV_POS_X[div, r, c] = (div mod 2) * div_w + (c * C3D_TEXTURE_MAP_DIV_WIDTH[div])
			C3D_TEXTURE_MAP_DIV_POS_Y[div, r, c] = int(div / 2) * div_h + (r * C3D_TEXTURE_MAP_DIV_HEIGHT[div])
			
			C3D_TEXTURE_MAP_DIV_UV_X[div, r, c] = C3D_TEXTURE_MAP_DIV_POS_X[div, r, c] / C3D_TEXTURE_MAP_WIDTH
			C3D_TEXTURE_MAP_DIV_UV_Y[div, r, c] = C3D_TEXTURE_MAP_DIV_POS_Y[div, r, c] / C3D_TEXTURE_MAP_HEIGHT
			
			'Print "POS[";r;", ";c;"] = "; C3D_TEXTURE_MAP_DIV_POS_X[div, r, c];", ";C3D_TEXTURE_MAP_DIV_POS_Y[div, r, c]
		Next
	Next
	
	'Print "-----------------------------------"
	
	Return True
End function

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
	CanvasOpen(C3D_CANVAS_BACKBUFFER, C3D_TEXTURE_MAP_WIDTH, C3D_TEXTURE_MAP_HEIGHT, 0, 0, 256, 256, 0) ' Back Buffer
	SetCanvasVisible(C3D_CANVAS_BACKBUFFER, false)
	setclearcolor(RGB(153,217,234))
	
	C3D_SetTextureMapDivision(0, 2, 2) 'Default Terrain Division
	C3D_SetTextureMapDivision(1, 2, 2)
	C3D_SetTextureMapDivision(2, 2, 2)
	C3D_SetTextureMapDivision(3, 2, 2)
	
	C3D_SCREEN_WIDTH = w
	C3D_SCREEN_HEIGHT = h
	C3D_UpdateGlobalParameters()
	C3D_SetScreenOcclusionRange()
End Sub

Sub C3D_Init_CurrentWindow(w, h)
	CanvasClose(C3D_CANVAS_RENDER)
	CanvasClose(C3D_CANVAS_BACKBUFFER)
	
	CanvasOpen(6, w, h, 0, 0, w, h, 0) ' Render View
	CanvasOpen(C3D_CANVAS_BACKBUFFER, C3D_TEXTURE_MAP_WIDTH, C3D_TEXTURE_MAP_HEIGHT, 0, 0, 256, 256, 0) ' Back Buffer
	SetCanvasVisible(C3D_CANVAS_BACKBUFFER, false)
	setclearcolor(RGB(153,217,234))
	
	C3D_SetTextureMapDivision(0, 2, 2) 'Default Terrain Division
	C3D_SetTextureMapDivision(1, 2, 2)
	C3D_SetTextureMapDivision(2, 2, 2)
	C3D_SetTextureMapDivision(3, 2, 2)
	
	C3D_SCREEN_WIDTH = w
	C3D_SCREEN_HEIGHT = h
	C3D_UpdateGlobalParameters()
	C3D_SetScreenOcclusionRange()
End Sub

C3D_Update_Timer = 0
C3D_FPS_CAP = 60

Sub C3D_Update()
	t = timer
	wait_time = (1000/C3D_FPS_CAP) - (t-C3D_Update_Timer)
	if wait_time > 0 then
		wait(wait_time)
	end if
	Update()
	C3D_Update_Timer = timer
End Sub