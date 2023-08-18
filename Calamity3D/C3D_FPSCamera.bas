Include Once
Include "Calamity3D/C3D_Mesh.bas"
Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/C3D_Utility.bas"

CAM_OBJ_FILE_CONTENS$ = ""
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv -9.02419 -9.25558 -9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv -9.02419 -9.25558 9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv -9.02419 9.25558 -9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv -9.02419 9.25558 9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv 9.02419 -9.25558 -9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv 9.02419 -9.25558 9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv 9.02419 9.25558 -9.02419"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nv 9.02419 9.25558 9.02419"

CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 0 0"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 0 0"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 0 1"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 0 1"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 1 0"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 1 0"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 1 1"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nvt 1 1"

CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nf 3/3/13 7/7/25 5/5/19 1/1/7"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nf 6/6/22 8/8/28 4/4/16 2/2/10"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nf 2/2/12 4/4/18 3/3/15 1/1/9"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nf 7/7/27 8/8/30 6/6/24 5/5/21"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nf 4/4/17 8/8/29 7/7/26 3/3/14"
CAM_OBJ_FILE_CONTENS$ = CAM_OBJ_FILE_CONTENS$ + "\nf 5/5/20 6/6/23 2/2/11 1/1/8"



Sub C3D_MoveFPSCameraActor(actor, x, y, z)
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


Sub C3D_MoveFPSCamera(x, y, z)
	C3D_MoveFPSCameraActor(cam_obj, x, y, z)
End Sub


Dim c3d_mx, c3d_my, c3d_prev_mx, c3d_prev_my, c3d_mb1, c3d_mb2, c3d_mb3

Sub C3D_MouseDelta_FPS(ByRef dx, ByRef dy)
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


Sub C3D_EnableFPSCamera()
	c3d_mouse_fps_flag = True
	c3d_mouse_visible = MouseIsVisible()
	GrabInput(1)
	WarpMouse(C3D_SCREEN_WIDTH/2, C3D_SCREEN_HEIGHT/2)
	HideMouse()
	
	cam_mesh = C3D_LoadMeshFromString(CAM_OBJ_FILE_CONTENS$)
	cam_obj = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, cam_mesh)
	C3D_SetActorPosition(cam_obj, 400, 100, 1870)
	'C3D_SetCameraRotation(0, 240, 0)

	C3D_EnableCollision(cam_obj)
	C3D_SetCollisionParameters(cam_obj, 0, -9, 0, 0, 9, 0, 50)
	C3D_SetCollisionType(cam_obj, C3D_COLLISION_TYPE_DYNAMIC)
	C3D_SetActorVisible(cam_obj, false)
End Sub


Sub C3D_DisableFPSCamera()
	c3d_mouse_fps_flag = False
	ShowMouse()
	GrabInput(0)
	
	C3D_DeleteMesh(cam_mesh)
	C3D_DisableCollision(cam_obj)
	C3D_DeleteActor(cam_obj)
	cam_obj = -1
	cam_mesh = -1
End Sub


Function C3D_CameraOnFloor()
	Return C3D_ActorOnFloor(cam_obj)
End Function

Sub C3D_FPSControl()
	'RSHIFT NEEDS TO BE ADDED
	
	Dim dx, dy
	C3D_MouseDelta_FPS(dx, dy)
	
	dx = dx * sensitivity
	dy = dy * sensitivity
	
	C3D_RotateCamera(0, dx, 0)
	
	dim xr,yr,zr
	C3D_GetCameraRotation(xr,yr,zr)
	
	new_y = xr + dy
	If dy < 0 And (new_y < -25) Then
		dy = 0
	ElseIf dy > 0 And (new_y > 90) Then
		dy = 0
	End If
	
	C3D_RotateCamera(dy, 0, 0)
	
	If Key(K_A) Then
		C3D_MoveFPSCameraActor(cam_obj, -cam_speed, 0, 0)
		'C3D_MoveCameraRelative(-cam_speed, 0, 0)
	ElseIf Key(K_D) Then
		C3D_MoveFPSCameraActor(cam_obj, cam_speed, 0, 0)
		'C3D_MoveCameraRelative(cam_speed, 0, 0)
	End If
	
	If Key(K_W) Then
		C3D_MoveFPSCameraActor(cam_obj, 0, 0, -cam_speed)
		'C3D_MoveCameraRelative(0, 0, -cam_speed)
	ElseIf Key(K_S) Then
		C3D_MoveFPSCameraActor(cam_obj, 0, 0, cam_speed)
		'C3D_MoveCameraRelative(0, 0, cam_speed)
	End If
	
	If Key(K_R) Then
		C3D_MoveFPSCameraActor(cam_obj, 0, cam_speed, 0)
		'C3D_MoveCamera(0, cam_speed, 0)
	ElseIf Key(K_F) Then
		C3D_MoveFPSCameraActor(cam_obj, 0, -cam_speed, 0)
		'C3D_MoveCamera(0, -cam_speed, 0)
	End If

End Sub


Function C3D_CameraActor()
	Return cam_obj
End Function


Function C3D_CameraMesh()
	Return cam_mesh
End Function