Include "Calamity3D/Calamity3D.bas"


''---------------------
'ln = C3D_CreateMatrix(3,2)
'quad = C3D_CreateMatrix(3, 4)
'
''line.origin.x = 0;
''line.origin.y = 0;
''line.origin.z = 0;
'SetMatrixValue(ln, 0, 0, 0)
'SetMatrixValue(ln, 1, 0, 0)
'SetMatrixValue(ln, 2, 0, 0)
'
'
''line.direction.x = -5.1;
''line.direction.y = 5;
''line.direction.z = -40;
'SetMatrixValue(ln, 0, 1, -5)
'SetMatrixValue(ln, 1, 1, 5)
'SetMatrixValue(ln, 2, 1, -40)
'
'
''QUAD
'
''quad.p1.x = -5;
''quad.p1.y = 5;
''quad.p1.z = -40;
'SetMatrixValue(quad, 0, 0, -5)
'SetMatrixValue(quad, 1, 0, 5)
'SetMatrixValue(quad, 2, 0, -40)
'
'
''quad.p2.x = 5;
''quad.p2.y = 5;
''quad.p2.z = -40;
'SetMatrixValue(quad, 0, 1, 5)
'SetMatrixValue(quad, 1, 1, 5)
'SetMatrixValue(quad, 2, 1, -40)
'
''quad.p3.x = 5;
''quad.p3.y = -5;
''quad.p3.z = -40;
'SetMatrixValue(quad, 0, 2, 5)
'SetMatrixValue(quad, 1, 2, -5)
'SetMatrixValue(quad, 2, 2, -40)
'
''quad.p4.x = -5;
''quad.p4.y = -5;
''quad.p4.z = -40;
'SetMatrixValue(quad, 0, 3, -5)
'SetMatrixValue(quad, 1, 3, -5)
'SetMatrixValue(quad, 2, 3, -40)
'
'Print "Line Intersect: "; intersectLineQuad(ln, quad)
'
'end
''---------------------




C3D_Init("test", 640, 480, 0, 0)

LoadFont(0, "Fonts/FreeMono.ttf", 12)

test_level_map = C3D_LoadImage("Assets/mz_cube_map1.bmp")
squid_map = C3D_LoadImage("Assets/squid_map.bmp")

test_level_mesh = C3D_LoadMesh("Assets/test_hall5_mapped.obj")
test_level = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, test_level_mesh)
C3D_SetMeshTexture(test_level_mesh, test_level_map)

test_level_mesh_cd = C3D_LoadMesh("Assets/test_hall5_cd.obj")

C3D_AddCollisionMesh(test_level_mesh, test_level_mesh_cd)
'C3D_SetBaseCollisionMesh(test_level_mesh)

squid_mesh = C3D_LoadMesh("Assets/squid_mapped.obj")
squid = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, squid_mesh)
'squid = 99
C3D_SetMeshTexture(squid_mesh, squid_map)
'C3D_RotateActor(squid, 0, -45, 0)

'C3D_SetActorScale(test_level, 9)
'C3D_MoveActor(test_level, 0, 0, 430)
'C3D_SetActorRotation(test_level, 0, 55, 0)

C3D_SetCollisionMeshGeometry(test_level)
'waitkey

C3D_MoveActor(squid, 120, 100, -120)


cam_mesh = C3D_LoadMesh("Assets/cam_cd.obj")
'C3D_SetBaseCollisionMesh(cam_mesh)
cam_obj = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, cam_mesh)
'test_obj = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, cam_mesh)

C3D_MoveCamera(-120, -20, 0)
C3D_RotateCamera(0, 0, 0)

C3D_SetActorPosition(cam_obj, C3D_Camera_Position[0], C3D_Camera_Position[1], C3D_Camera_Position[2]-80)

C3D_EnableCollision(cam_obj)
C3D_SetCollisionParameters(cam_obj, 0, -9, 0, 0, 9, 0, 25)
C3D_EnableCollision(squid)
C3D_SetCollisionParameters(squid, 0, -9, 0, 0, 20, 0, 30)

C3D_SetCollisionType(cam_obj, C3D_COLLISION_TYPE_DYNAMIC)
C3D_SetCollisionType(squid, C3D_COLLISION_TYPE_DYNAMIC)

Sub rotate(actor, x, y, z)
	actor_x = C3D_ActorPositionX(actor)
	actor_y = C3D_ActorPositionY(actor)
	actor_z = C3D_ActorPositionZ(actor)
	
	dx = C3D_ActorPositionX(actor)
	dy = C3D_ActorPositionY(actor)
	dz = C3D_ActorPositionZ(actor)
	
	cx = C3D_Camera_Position[0]
	cy = C3D_Camera_Position[1]
	cz = C3D_Camera_Position[2]
	
	Print "DBG: ("; actor_x; ", "; actor_y; ", "; actor_z; ") ("; cx; ", "; cy; ", "; cz; ")"
	Print "  -- ACT_ROT=(";C3D_Actor_Rotation[actor, 0];", ";C3D_Actor_Rotation[actor, 1];", ";C3D_Actor_Rotation[actor, 2];") "
	Print "  -- CAM_ROT=(";C3D_Camera_Rotation[0];", ";C3D_Camera_Rotation[1];", ";C3D_Camera_Rotation[2];") "
	'Print ""
	
	Dim tx, ty, tz
	rotateVertex(dx, dy, dz, cx, cy, cz, x, y, z, tx, ty, tz)
	Print "New Angle = ";tx;", ";ty;", ";tz
	Print ""
	
	C3D_GetForwardVector(cx, cy, cz, C3D_Camera_Rotation[0], C3D_Camera_Rotation[1], C3D_Camera_Rotation[2], -80, tx, ty, tz)
	Print "Forward_A = ";tx;", ";ty;", ";tz
	Print ""
	
	Dim lx, ly, lz
	lookAt(cx, cy, cz, tx, ty, tz, lx, ly, lz)
	Print "Look At = ";lx;", ";ly;", ";lz
	Print ""
	
	'C3D_RotatePoint(dx, dz, cx, cz, y, dx, dz)
	'C3D_MoveActor(actor, dx-actor_x, 0, dz-actor_z)
	
	'C3D_RotatePoint(dy, dz, cy, cz, -x, dy, dz)
	'C3D_MoveActor(actor, 0, dy-actor_y, dz-actor_z)
	
	'C3D_RotatePoint(dx, dy, cx, cy, -z, dx, dy)
	'C3D_MoveActor(actor, dx-actor_x, dy-actor_y, 0)
	
	C3D_MoveActor(actor, tx-actor_x, ty-actor_y, tz-actor_z)
	
	'C3D_RotateActor(actor, 0, y, 0)
	'C3D_RotateActor(actor, x, 0, 0)
	'C3D_RotateActor(actor, 0, 0, z)
	
	C3D_SetActorRotation(actor, -lx, ly, 0)
	'C3D_SetActorRotation(actor, x, 0, 0)
	'C3D_SetActorRotation(actor, 0, 0, z)
End Sub


function C3D_CheckGeometryCollision(actor)
	rtn = False
	For i = 0 to C3D_Stage_Geometry_Count-1
		If C3D_Stage_Geometry_Actor_Collisions[i, actor] Then
			Return True
		End If
	Next
	
	Return False
end function

cam_height = 200

Sub MoveFPSCameraActor(actor, x, y, z)
	dx = C3D_Camera_Position[0]
	dy = C3D_Camera_Position[1]
	dz = C3D_Camera_Position[2]
	
	crx = C3D_Camera_Rotation[0]
	cry = C3D_Camera_Rotation[1]
	crz = C3D_Camera_Rotation[2]
	
	Dim n
	
	If y Then
		C3D_RotatePoint(dx, dy, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Y, -1*crz, n, dy)
		C3D_RotatePoint(dx, dy+y, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Y, crz, n, dy)
	End If
	
	If x Or z Then
		C3D_RotatePoint(dz, dx, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Z, -1*cry, dz, dx)
		C3D_RotatePoint(dz+z, dx+x, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Z, cry, dz, dx)
	End If
	
	delta_x = dx - C3D_Camera_Position[0]
	delta_y = dy - C3D_Camera_Position[1]
	delta_z = dz - C3D_Camera_Position[2]
	
	C3D_MoveActor(actor, delta_x, delta_y, delta_z)
	C3D_SetCameraPosition(C3D_ActorPositionX(actor), C3D_ActorPositionY(actor)+cam_height, C3D_ActorPositionZ(actor))
End Sub


C3D_SetActorPosition(squid, 4866.863997, 26.674, -3167.443156)

C3D_SetActorPosition(cam_obj, 265.691919, 188.847374, -1760.254808)
C3D_SetActorVisible(cam_obj, false)
C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
C3D_SetCameraRotation(29, -128, 0)


cam_speed = 40
cam_rot_speed = 4

gravity = 0 '24

mx = MouseX()
my = MouseY()

delta_mx = 0
delta_my = 0

mouse_center_x = 320
mouse_center_y = 240
sensitivity = 1

'Print "Start"

While Not Key(K_ESCAPE)
	ClearCanvas()
	
	
	'if C3D_CheckGeometryCollision(cam_obj) then
	'	C3D_LoadCameraState()
	'end if
	
	'C3D_StoreCameraState()

	If Key(K_LEFT) Then
		C3D_RotateCamera(0, -cam_rot_speed, 0)
		
		'rotate(cam_obj, 0, cam_speed, 0)
	ElseIf Key(K_RIGHT) Then
		C3D_RotateCamera(0, cam_rot_speed, 0)
		
		'rotate(cam_obj, 0, -cam_speed, 0)
	End If
	
	If Key(K_UP) Then
		C3D_RotateCamera(-cam_rot_speed, 0, 0)
		
		'rotate(cam_obj, cam_speed, 0, 0)
	ElseIf Key(K_DOWN) Then
		C3D_RotateCamera(cam_rot_speed, 0, 0)
		
		'rotate(cam_obj, -cam_speed, 0, 0)
	End If
	

	If Key(K_A) Then
		MoveFPSCameraActor(cam_obj, -cam_speed, 0, 0)
		'C3D_MoveCamera(-cam_speed, 0, 0)
		'C3D_MoveActor(cam_obj, -cam_speed, 0, 0)
		'C3D_MoveActorRelative(cam_obj, -cam_speed, 0, 0)
		'C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
	ElseIf Key(K_D) Then
		MoveFPSCameraActor(cam_obj, cam_speed, 0, 0)
		'C3D_MoveCamera(cam_speed, 0, 0)
		'C3D_MoveActor(cam_obj, cam_speed, 0, 0)
		'C3D_MoveActorRelative(cam_obj, cam_speed, 0, 0)
		'C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
	End If
	
	If Key(K_W) Then
		MoveFPSCameraActor(cam_obj, 0, 0, -cam_speed)
		'C3D_MoveCamera(0, 0, -cam_speed)
		'C3D_MoveActor(cam_obj, 0, 0, -cam_speed)
		'C3D_MoveActorRelative(cam_obj, 0, 0, -cam_speed)
		'C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
	ElseIf Key(K_S) Then
		MoveFPSCameraActor(cam_obj, 0, 0, cam_speed)
		'C3D_MoveCamera(0, 0, cam_speed)
		'C3D_MoveActor(cam_obj, 0, 0, cam_speed)
		'C3D_MoveActorRelative(cam_obj, 0, 0, cam_speed)
		'C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
	End If
	
	If Key(K_b) Then
		MoveFPSCameraActor(cam_obj, 0, 0, -100)
	end if
	
	If Key(K_R) Then
		MoveFPSCameraActor(cam_obj, 0, cam_speed, 0)
		'C3D_MoveActor(squid, 0, 1, 0)
		'C3D_MoveCamera(0, cam_speed, 0)
		'C3D_MoveActor(cam_obj, 0, cam_speed, 0)
		'C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
	ElseIf Key(K_F) Then
		MoveFPSCameraActor(cam_obj, 0, -cam_speed, 0)
		'C3D_MoveActor(squid, 0, -1, 0)
		'C3D_MoveCamera(0, -cam_speed, 0)
		'C3D_MoveActor(cam_obj, 0, -cam_speed, 0)
		'C3D_SetCameraPosition(C3D_ActorPositionX(cam_obj), C3D_ActorPositionY(cam_obj)+cam_height, C3D_ActorPositionZ(cam_obj))
	End If
	
	MoveFPSCameraActor(cam_obj, 0, -gravity, 0)
	
	If Key(K_1) Then
		C3D_RotateActor(squid, 0, 2, 0)
	ElseIf Key(K_2) Then
		C3D_RotateActor(squid, 2, 0, 0)
	ElseIf Key(K_3) Then
		C3D_RotateActor(squid, 0, 0, 2)
	End If
	
	If Key(K_P) Then
		actor = cam_obj
		actor_x = C3D_ActorPositionX(actor)
		actor_y = C3D_ActorPositionY(actor)
		actor_z = C3D_ActorPositionZ(actor)
		
		dx = C3D_ActorPositionX(actor)
		dy = C3D_ActorPositionY(actor)
		dz = C3D_ActorPositionZ(actor)
		
		cx = C3D_Camera_Position[0]
		cy = C3D_Camera_Position[1]
		cz = C3D_Camera_Position[2]
		
		Print "DBG: ("; actor_x; ", "; actor_y; ", "; actor_z; ") ("; cx; ", "; cy; ", "; cz; ")"
		Print "  -- ACT_ROT=(";C3D_Actor_Rotation[actor, 0];", ";C3D_Actor_Rotation[actor, 1];", ";C3D_Actor_Rotation[actor, 2];") "
		Print "  -- CAM_ROT=(";C3D_Camera_Rotation[0];", ";C3D_Camera_Rotation[1];", ";C3D_Camera_Rotation[2];") "
		'Print ""
		
		Dim tx, ty, tz
		rotateVertex(dx, dy, dz, cx, cy, cz, actor_x, actor_y, actor_z, tx, ty, tz)
		Print "New Angle = ";tx;", ";ty;", ";tz
		Print ""
		
		C3D_GetForwardVector(cx, cy, cz, C3D_Camera_Rotation[0], C3D_Camera_Rotation[1], C3D_Camera_Rotation[2], -80, tx, ty, tz)
		Print "Forward = ";tx;", ";ty;", ";tz
		Print ""
		
		'Dim lx, ly, lz
		'lookAt(cx, cy, cz, tx, ty, tz, lx, ly, lz)
		'Print "Look At = ";lx;", ";ly;", ";lz
		'Print ""
		
		'C3D_SetActorPosition(cam_obj, tx, ty, tz)
	End If
	
	
	
	'If C3D_CheckCollision(cam_obj, squid) then
	'	Print "The End"
	'End If
	
	C3D_DrawMiniMap()
	
	C3D_RenderScene()
	
	SetColor(RGB(255,255,255))
	'DrawText("FPS: " + Str$(FPS()), 10, 10)
	'DrawText("Faces: " + Str$(C3D_Rendered_Faces_Count), 10, 30)
	
	
	C3D_Update()
	
	
Wend

'ProcessWaitAll
'ProcessClose(0)

WaitKey