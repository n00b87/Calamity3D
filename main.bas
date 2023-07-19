Include "Calamity3D/Calamity3D.bas"


'Setting the Clear color for the renderer
C3D_CLEAR_COLOR = RGB(153,217,234)

'Initialize Engine and open a window
C3D_Init("test", 640, 480, 0, 1)

'Opening Canvas 0 and setting it on top of the rendered display
'NOTE: Canvas 0 is where the weapon sprite will be drawn
CanvasOpen(0, 640, 480, 0, 0, 640, 480, 1)
SetCanvasZ(0, 0)


cam_mesh = C3D_LoadMesh("Assets/cam_cd.obj")
cam_obj = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, cam_mesh)
C3D_SetActorPosition(cam_obj, 315, 50, -1652)

'C3D_EnableCollision(cam_obj)
'C3D_SetCollisionParameters(cam_obj, 0, -9, 0, 0, 9, 0, 25)
'C3D_SetCollisionType(cam_obj, C3D_COLLISION_TYPE_DYNAMIC)
C3D_SetActorVisible(cam_obj, false)


cam_height = 100

Sub MoveFPSCameraActor(actor, x, y, z)
	dx = C3D_Camera_Position[0]
	dy = C3D_Camera_Position[1]
	dz = C3D_Camera_Position[2]
	
	crx = C3D_Camera_Rotation[0]
	cry = C3D_Camera_Rotation[1]
	crz = C3D_Camera_Rotation[2]
	
	Dim n
	
	If y Then
		C3D_RotateVertex2D(dx, dy, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Y, -1*crz, n, dy)
		C3D_RotateVertex2D(dx, dy+y, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Y, crz, n, dy)
	End If
	
	If x Or z Then
		C3D_RotateVertex2D(dz, dx, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Z, -1*cry, dz, dx)
		C3D_RotateVertex2D(dz+z, dx+x, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Z, cry, dz, dx)
	End If
	
	delta_x = dx - C3D_Camera_Position[0]
	delta_y = dy - C3D_Camera_Position[1]
	delta_z = dz - C3D_Camera_Position[2]
	
	C3D_MoveActor(actor, delta_x, delta_y, delta_z)
	C3D_SetCameraPosition(C3D_ActorPositionX(actor), C3D_ActorPositionY(actor)+cam_height, C3D_ActorPositionZ(actor))
End Sub


'C3D_SetRenderType(C3D_RENDER_TYPE_WIREFRAME)


'corridor1_mesh = C3D_LoadMesh("Assets/terrain2.obj")
'corridor1_texture = C3D_LoadImage("Assets/terrain1.png")
corridor1_mesh = C3D_LoadMesh("Assets/large_level.obj")
corridor1_texture = C3D_LoadImage("Assets/plane1.bmp")
C3D_SetMeshTexture(corridor1_mesh, corridor1_texture)

c = C3D_CutMesh(corridor1_mesh, 4000)
Print "Cuts = "; c

For i = 0 to C3D_Mesh_Cut_Count-1
	'Print "Test: "; dbg_cuts[i]
	C3D_SetMeshTexture(C3D_Mesh_Cuts[i], corridor1_texture)
	C3D_CreateActor(C3D_ACTOR_TYPE_MESH, C3D_Mesh_Cuts[i])
Next

'corridor1 = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, corridor1_mesh)
'C3D_SetActorScale(corridor1, 2)


house_mesh = C3D_LoadMesh("Assets/house4.obj")
house_texture = C3D_LoadImage("Assets/house_tex.png")
C3D_SetMeshTexture(house_mesh, house_texture)
house1 = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, house_mesh)
'C3D_SetActorScale(corridor1, 4)
C3D_MoveActor(house1, 0, 10, 0)

mg_texture = C3D_LoadImage("Assets/mg-sheet.png")
mg = C3D_CreateActor(C3D_ACTOR_TYPE_SPRITE, mg_texture)
C3D_SetActorPosition(mg, 0, 80, 0)

'corridor1_mesh_cd = C3D_LoadMesh("Assets/corridor1_cd.obj")
'C3D_AddCollisionMesh(corridor1_mesh, corridor1_mesh_cd)
'C3D_SetCollisionMeshGeometry(corridor1)


'spc_mod1_mesh = C3D_LoadMesh("Assets/space_module1.obj")
'spc_mod1_texture = C3D_LoadImage("Assets/space_module1.bmp")
'C3D_SetMeshTexture(spc_mod1_mesh, spc_mod1_texture)
'spc_mod1 = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, spc_mod1_mesh)
'C3D_SetActorScale(spc_mod1, 4)
'C3D_SetActorPosition(spc_mod1, 0, 0, -307*4)

'spc_mod1_mesh_cd = C3D_LoadMesh("Assets/space_module1_cd.obj")
'C3D_AddCollisionMesh(spc_mod1_mesh, spc_mod1_mesh_cd)
'C3D_SetCollisionMeshGeometry(spc_mod1)


'plane1_mesh = C3D_LoadMesh("Assets/plane1.obj")
'plane1_texture = C3D_LoadImage("Assets/plane1.bmp")
'C3D_SetMeshTexture(plane1_mesh, plane1_texture)
'plane1 = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, plane1_mesh)
'C3D_SetActorScale(plane1, 4)
'C3D_SetActorPosition(plane1, 0, -300, -307*4)

'plane1_mesh_cd = C3D_LoadMesh("Assets/plane1_cd.obj")
'C3D_AddCollisionMesh(plane1_mesh, plane1_mesh_cd)
'C3D_SetCollisionMeshGeometry(plane1)


'stairs1_mesh = C3D_LoadMesh("Assets/stairs1.obj")
'stairs1_texture = C3D_LoadImage("Assets/stairs1.bmp")
'C3D_SetMeshTexture(stairs1_mesh, stairs1_texture)
'stairs1 = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, stairs1_mesh)
'C3D_SetActorScale(stairs1, 4)
'C3D_SetActorPosition(stairs1, -200, -70, -2000)

'stairs1_mesh_cd = C3D_LoadMesh("Assets/stairs1_cd.obj")
'C3D_AddCollisionMesh(stairs1_mesh, stairs1_mesh_cd)
'C3D_SetCollisionMeshGeometry(stairs1)

 
cam_rot_speed = 2
cam_speed = 36



Dim c3d_mx, c3d_my, c3d_prev_mx, c3d_prev_my, c3d_mb1, c3d_mb2, c3d_mb3

Sub MouseDelta_FPS(ByRef dx, ByRef dy)
	move_mouse = false
	
	c3d_prev_mx = c3d_mx
	c3d_prev_my = c3d_my
	
	GetMouse(c3d_mx, c3d_my, c3d_mb1, c3d_mb2, c3d_mb3)
	
	w = C3D_SCREEN_WIDTH-1
	h = C3D_SCREEN_HEIGHT-1
	
	If c3d_mx <= 0 And c3d_prev_mx > 0 Then
		c3d_mx = w
		move_mouse = True
	ElseIf c3d_mx >= w And c3d_prev_mx < w Then
		c3d_mx = 0
		move_mouse = True
	End If
    
  If c3d_my <= 0 And c3d_prev_my > 0 Then
		c3d_my = h
		move_mouse = True
	ElseIf c3d_my >= h And c3d_prev_my < h Then
		c3d_my = 0
		move_mouse = True
	End If
	
	If move_mouse Then
		WarpMouse(c3d_mx, c3d_my)
		dx = 0
		dy = 0
	Else
		dx = c3d_mx - c3d_prev_mx
		dy = c3d_my - c3d_prev_my
	End If

End Sub

c3d_mouse_fps_flag = True
GrabInput(1)
WarpMouse(C3D_SCREEN_WIDTH/2, C3D_SCREEN_HEIGHT/2)
HideMouse()


weapon_sprite = C3D_GetFreeImageSlot()
LoadImage(weapon_sprite, "Assets/mg-sheet.png")
weapon_frame_w = 144
weapon_frame_h = 176

weapon_frame_current_time = timer()
weapon_frame_time_limit = 20

weapon_current_frame = 0
weapon_frame_count = 3

jump_force = 0

Function ActorOnFloor(actor)
	If C3D_Actor_Stage_Collision_Count[actor] <= 0 Then
		Return False
	End If
	
	For i = 0 to C3D_Actor_Stage_Collision_Count[actor]-1
		geo = C3D_Actor_Stage_Collision[actor, i]
		type = C3D_Stage_Geometry[geo, 0]
		If type = C3D_STAGE_GEOMETRY_TYPE_FLOOR Then
			Return True
		End IF
	Next
	Return False
End Function

Sub FPSControl()
	'RSHIFT NEEDS TO BE ADDED
	
	cam_speed = 48 '24
	sensitivity = 0.5
	gravity = 0 '12
	
	If jump_force > 0 Then
		MoveFPSCameraActor(cam_obj, 0, cam_speed, 0)
		jump_force = jump_force - 1
	Else
		MoveFPSCameraActor(cam_obj, 0, -gravity, 0)
	End If
	
	
	Dim dx, dy
	MouseDelta_FPS(dx, dy)
	
	dx = dx * sensitivity
	dy = dy * sensitivity
	
	C3D_RotateCamera(0, dx, 0)
	
	dim xr,yr,zr
	C3D_GetCameraRotation(xr,yr,zr)
	
	new_y = xr + dy
	If dy < 0 And (new_y < -90) Then
		dy = 0
	ElseIf dy > 0 And (new_y > 90) Then
		dy = 0
	End If
	
	C3D_RotateCamera(dy, 0, 0)
	
	if key(k_space) And ActorOnFloor(cam_obj) Then
		jump_force = 5
	end if
	
	If Key(K_A) Then
		MoveFPSCameraActor(cam_obj, -cam_speed, 0, 0)
		'C3D_MoveCameraRelative(-cam_speed, 0, 0)
	ElseIf Key(K_D) Then
		MoveFPSCameraActor(cam_obj, cam_speed, 0, 0)
		'C3D_MoveCameraRelative(cam_speed, 0, 0)
	End If
	
	If Key(K_W) Then
		MoveFPSCameraActor(cam_obj, 0, 0, -cam_speed)
		'C3D_MoveCameraRelative(0, 0, -cam_speed)
	ElseIf Key(K_S) Then
		MoveFPSCameraActor(cam_obj, 0, 0, cam_speed)
		'C3D_MoveCameraRelative(0, 0, cam_speed)
	End If
	
	If Key(K_R) Then
		MoveFPSCameraActor(cam_obj, 0, cam_speed, 0)
		'C3D_MoveCamera(0, cam_speed, 0)
	ElseIf Key(K_F) Then
		MoveFPSCameraActor(cam_obj, 0, -cam_speed, 0)
		'C3D_MoveCamera(0, -cam_speed, 0)
	End If
	
	If c3d_mb1 Then
		If weapon_frame_current_time > weapon_frame_time_limit Then
			weapon_current_frame = weapon_current_frame + 1
			If weapon_current_frame >= weapon_frame_count Then
				weapon_current_frame = 1
			End If
		End If
		weapon_frame_current_time = timer()
	Else
		weapon_current_frame = 0
	End If
	
'	If key(k_m) Then
'		dim x, y, z, rx, ry, rz
'		C3D_GetCameraRotation(rx, ry, rz)
'		C3D_GetActorPosition(cam_obj, x, y, z)
'		Print "cam = ";rx;", ";ry;", ";rz
'		Print "obj = ";x;", ";y;", ";z
'		print ""
'	end if
End Sub


Sub DrawUI()
	Canvas(0)
	SetClearColor(0)
	ClearCanvas()
	
	x = 320-(weapon_frame_w/2)
	y = 480-weapon_frame_h
	sx = weapon_current_frame*weapon_frame_w
	sy = 0
	sw = weapon_frame_w
	sh = weapon_frame_h
	DrawImage_Blit(weapon_sprite, x, y, sx, sy, sw, sh)
	
End Sub


m = false
Update()
MoveFPSCameraActor(cam_obj, -1, 0, 0)
C3D_SetCameraRotation(24, 3, 0)

While Not Key(K_ESCAPE)
	'Viewport_Control()
	FPSControl()
	DrawUI()
	
	If key(k_m) Then
		Print FPS()
	End If
	
	C3D_RenderScene()
	C3D_Update()
Wend
