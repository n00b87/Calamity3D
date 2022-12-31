Include Once
Include "Utility.bas"

C3D_CAMERA_LENS = 270 'Distance from 0, facing down negative z-axis

C3D_MAX_Z_DEPTH = 700

C3D_CAMERA_CENTER_X = 0
C3D_CAMERA_CENTER_Y = 0
C3D_CAMERA_CENTER_Z = C3D_CAMERA_LENS

Dim C3D_Camera_Position[3]
Dim C3D_Camera_Rotation[3]

Dim C3D_Camera_AbsolutePosition_Delta[3]
Dim C3D_Camera_AbsoluteRotation_Delta[3]

C3D_Camera_Position[1] = -50
C3D_Camera_Position[2] = -10

Sub C3D_SetCameraPosition(x, y, z)
	C3D_Camera_Position[0] = x
	C3D_Camera_Position[1] = y
	C3D_Camera_Position[2] = z
End Sub

Sub C3D_MoveCamera(x, y, z)
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
	
	C3D_Camera_Position[0] = dx
	C3D_Camera_Position[1] = dy
	C3D_Camera_Position[2] = dz
End Sub

Sub C3D_SetCameraRotation(x, y, z)
	C3D_Camera_Rotation[0] = x
	C3D_Camera_Rotation[1] = y
	C3D_Camera_Rotation[2] = z
End Sub

Sub C3D_RotateCamera(x, y, z)
	C3D_Camera_Rotation[0] = C3D_Camera_Rotation[0] + x
	C3D_Camera_Rotation[1] = C3D_Camera_Rotation[1] + y
	C3D_Camera_Rotation[2] = C3D_Camera_Rotation[2] + z
End Sub


Dim C3D_Prev_MouseX
Dim C3D_Prev_MouseY

Dim C3D_MouseX
Dim C3D_MouseY

Dim C3D_Prev_MouseButton[3]
Dim C3D_MouseButton[3]

C3D_Mouse_Sensitivity = 0.3

Sub C3D_UpdateMouseState()
	C3D_Prev_MouseX = C3D_MouseX
	C3D_Prev_MouseY = C3D_MouseY
	C3D_Prev_MouseButton[0] = C3D_MouseButton[0]
	C3D_Prev_MouseButton[1] = C3D_MouseButton[1]
	C3D_Prev_MouseButton[2] = C3D_MouseButton[2]
	GetMouse(C3D_MouseX, C3D_MouseY, C3D_MouseButton[0], C3D_MouseButton[1], C3D_MouseButton[2])
End Sub


'This Does not currently work
Sub C3D_SetFPSCamera()
	C3D_UpdateMouseState()
	
	Dim mx_delta, my_delta
	
	If C3D_MouseButton[0] Then
		mx_delta = (C3D_MouseX - C3D_Prev_MouseX) * C3D_Mouse_Sensitivity
		my_delta = (C3D_MouseY - C3D_Prev_MouseY) * C3D_Mouse_Sensitivity
	End If
	
	C3D_RotateCamera(0, mx_delta, 0)
	C3D_RotateCamera(my_delta, 0, 0)
	
	If Key(K_A) Then
		C3D_MoveCamera(-1, 0, 0)
	ElseIf Key(K_D) Then
		C3D_MoveCamera(1, 0, 0)
	End If
	
	If Key(K_W) Then
		C3D_MoveCamera(0, 0, -1)
	ElseIf Key(K_S) Then
		C3D_MoveCamera(0, 0, 1)
	End If
	
	If Key(K_R) Then
		C3D_MoveCamera(0, 1, 0)
	ElseIf Key(K_F) Then
		C3D_MoveCamera(0, -1, 0)
	End If

End Sub