'System("clear")

Include "C3D_Mesh.bas"
Include "C3D_Image.bas"
Include "C3D_Sprite.bas"
Include "C3D_Camera.bas"
Include "C3D_Scene.bas"

WindowOpen(0, "test", WINDOWPOS_CENTERED, WINDOWPOS_CENTERED, 640, 480, WINDOW_VISIBLE, 1)
CanvasOpen(0, 640, 480, 0, 0, 640, 480, 0)


LoadImage(0, "house_map.bmp")

'DrawImage_Flip(0, 10, 10, 0, 1)
'Update
'Waitkey()
'End


actor = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, C3D_LoadMesh("house_mapped.obj"))

While Not Key(K_ESCAPE)
	ClearCanvas()

	If Key(K_LEFT) Then
		C3D_RotateCamera(0, -1, 0)
		Print "Camera: ";C3D_Camera_Rotation[1]
	ElseIf Key(K_RIGHT) Then
		C3D_RotateCamera(0, 1, 0)
		Print "Camera: ";C3D_Camera_Rotation[1]
	ElseIf Key(K_UP) Then
		'C3D_RotateActor(actor, 1, 0, 0)
		C3D_RotateCamera(1, 0, 0)
	ElseIf Key(K_DOWN) Then
		'C3D_RotateActor(actor, -1, 0, 0)
		C3D_RotateCamera(-1, 0, 0)
	End If
	
	If Key(K_A) Then
		C3D_MoveActor(actor, -1, 0, 0)
	ElseIf Key(K_D) Then
		C3D_MoveActor(actor, 1, 0, 0)
	ElseIf Key(K_W) Then
		C3D_MoveActor(actor, 0, 0, 1)
	ElseIf Key(K_S) Then
		C3D_MoveActor(actor, 0, 0, -1)
	End If
	
	If Key(K_R) Then
		C3D_MoveActor(actor, 0, 1, 0)
	ElseIf Key(K_F) Then
		C3D_MoveActor(actor, 0, -1, 0)
	End If
	
	C3D_RenderScene()
Wend

WaitKey