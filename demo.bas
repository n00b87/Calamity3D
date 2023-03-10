Include "Calamity3D/Calamity3D.bas"

C3D_Init("test", 640, 480, 0, 0)

LoadFont(0, "Fonts/FreeMono.ttf", 12)

test_level_map = C3D_LoadImage("Assets/geo.bmp")
squid_map = C3D_LoadImage("Assets/squid_map.bmp")

test_level_mesh = C3D_LoadMesh("Assets/test_geo_mapped2.obj")
test_level = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, test_level_mesh)
C3D_SetMeshTexture(test_level_mesh, test_level_map)

squid_mesh = C3D_LoadMesh("Assets/squid_mapped.obj")
squid = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, squid_mesh)
'squid = 99
C3D_SetMeshTexture(squid_mesh, squid_map)
C3D_RotateActor(squid, 0, -45, 0)

C3D_SetActorScale(test_level, 3)

C3D_MoveActor(squid, 120, 100, -120)


cam_speed = 4

C3D_MoveCamera(0, -50, 0)
C3D_RotateCamera(10, 0, 0)

While Not Key(K_ESCAPE)
	ClearCanvas()

	If Key(K_LEFT) Then
		C3D_RotateCamera(0, -cam_speed, 0)
	ElseIf Key(K_RIGHT) Then
		C3D_RotateCamera(0, cam_speed, 0)
	ElseIf Key(K_UP) Then
		C3D_RotateCamera(-cam_speed, 0, 0)
	ElseIf Key(K_DOWN) Then
		C3D_RotateCamera(cam_speed, 0, 0)
	End If
	

	If Key(K_A) Then
		C3D_MoveCamera(-cam_speed, 0, 0)
	ElseIf Key(K_D) Then
		C3D_MoveCamera(cam_speed, 0, 0)
	ElseIf Key(K_W) Then
		C3D_MoveCamera(0, 0, -cam_speed)
	ElseIf Key(K_S) Then
		C3D_MoveCamera(0, 0, cam_speed)
	End If
	
	If Key(K_R) Then
		'C3D_MoveActor(squid, 0, 1, 0)
		C3D_MoveCamera(0, cam_speed, 0)
	ElseIf Key(K_F) Then
		'C3D_MoveActor(squid, 0, -1, 0)
		C3D_MoveCamera(0, -cam_speed, 0)
		FlashWindow(0)
	End If
	
	C3D_DrawMiniMap()
	
	C3D_RenderScene()
	
	SetColor(RGB(255,255,255))
	DrawText("FPS: " + Str$(FPS()), 10, 10)
	DrawText("Faces: " + Str$(C3D_Rendered_Faces_Count), 10, 30)
	
	
	Update()
	
	
Wend

'ProcessWaitAll
'ProcessClose(0)

WaitKey