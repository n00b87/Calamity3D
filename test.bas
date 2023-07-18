Include "Calamity3D/Calamity3D.bas"


VIEW_3D = 0
Viewport_CurrentView = VIEW_3D

cam_rot_speed = 2
cam_speed = 2

v_scale = 1

Sub Viewport_Control(obj1)
	Select Case Viewport_CurrentView
	Case VIEW_3D
		If Key(K_LEFT) Then
			C3D_RotateCamera(0, -cam_rot_speed, 0)
		ElseIf Key(K_RIGHT) Then
			C3D_RotateCamera(0, cam_rot_speed, 0)
		End If
		
		If Key(K_UP) Then
			C3D_RotateCamera(-cam_rot_speed, 0, 0)
		ElseIf Key(K_DOWN) Then
			C3D_RotateCamera(cam_rot_speed, 0, 0)
		End If
		
		If Key(K_A) Then
			C3D_MoveCamera(-cam_speed, 0, 0)
		ElseIf Key(K_D) Then
			C3D_MoveCamera(cam_speed, 0, 0)
		End If
		
		If Key(K_W) Then
			C3D_MoveCamera(0, 0, -cam_speed)
			'C3D_MoveActor(v_obj, 0, 0, -cam_speed)
			'C3D_MoveActor(h_obj, 0, 0, -cam_speed)
		ElseIf Key(K_S) Then
			C3D_MoveCamera(0, 0, cam_speed)
			'C3D_MoveActor(v_obj, 0, 0, cam_speed)
			'C3D_MoveActor(h_obj, 0, 0, cam_speed)
		End If
		
		If Key(K_R) Then
			C3D_MoveCamera(0, cam_speed, 0)
		ElseIf Key(K_F) Then
			C3D_MoveCamera(0, -cam_speed, 0)
		End If
		
		If Key(K_1) Then
			C3D_MoveActor(obj1, 0, -4, 0)
			'v_scale = v_scale - 0.01
			'C3D_SetActorScale(h_obj, v_scale)
		ElseIf Key(K_2) Then
			C3D_MoveActor(obj1, 0, 4, 0)
			'v_scale = v_scale + 0.01
			'C3D_SetActorScale(h_obj, v_scale)
		End If
		
		If Key(K_3) Then
			C3D_MoveActor(obj1, -4, 0, 0)
			'v_scale = v_scale - 0.01
			'C3D_SetActorScale(h_obj, v_scale)
		ElseIf Key(K_4) Then
			C3D_MoveActor(obj1, 4, 0, 0)
			'v_scale = v_scale + 0.01
			'C3D_SetActorScale(h_obj, v_scale)
		End If
		
		If Key(K_5) Then
			C3D_MoveActor(obj1, 0, 0, -4)
			'v_scale = v_scale - 0.01
			'C3D_SetActorScale(h_obj, v_scale)
		ElseIf Key(K_6) Then
			C3D_MoveActor(obj1, 0, 0, 4)
			'v_scale = v_scale + 0.01
			'C3D_SetActorScale(h_obj, v_scale)
		End If
		
		
		
		If Key(K_M) Then
			Dim x, y, z, rx, ry, rz
			Dim scale
			
			C3D_GetActorPosition(obj1, x, y, z)
			Print "Object: "; x;", ";y;", ";z
			
			
			'Print ""
			'Print ""
		End If
		
		
	End Select
End Sub


'Setting the Clear color for the renderer
C3D_CLEAR_COLOR = RGB(153,217,234)

'Initialize Engine and open a window
C3D_Init("test", 640, 480, 0, 1)

'Opening Canvas 0 and setting it on top of the rendered display
'NOTE: Canvas 0 is where the weapon sprite will be drawn
'CanvasOpen(0, 640, 480, 0, 0, 640, 480, 1)
'SetCanvasZ(0, 0)

'C3D_SetCameraPosition(0, 20, 0)
'C3D_SetCameraRotation(30, 0, 0)


pillar_mesh = C3D_LoadMesh("Assets/pillar.obj")
pillar_texture = C3D_LoadImage("Assets/stairs1.bmp")
C3D_SetMeshTexture(pillar_mesh, pillar_texture)
pillar_obj = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, pillar_mesh)
C3D_SetActorScale(pillar_obj, 5)


floor_mesh = C3D_LoadMesh("Assets/slice.obj")
floor_obj = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, floor_mesh)
floor_texture = C3D_LoadImage("Assets/slice.png")
C3D_SetMeshTexture(floor_mesh, floor_texture)
C3D_SetActorScale(floor_obj, 1)


C3D_SetCameraPosition(0, 10, 250)
C3D_SetCameraRotation(20, 0, 0)


While Not Key(K_ESCAPE)
	Viewport_Control(pillar_obj)
	C3D_RenderScene()
	C3D_Update()
Wend
