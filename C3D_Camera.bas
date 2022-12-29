Include Once
Include "Utility.bas"

C3D_CAMERA_LENS = 256 'Distance from 0, facing down negative z-axis

C3D_CAMERA_CENTER_X = 0
C3D_CAMERA_CENTER_Y = 0
C3D_CAMERA_CENTER_Z = C3D_CAMERA_LENS

Dim C3D_Camera_Position[3]
Dim C3D_Camera_Rotation[3]

C3D_Camera_Position[1] = -50
C3D_Camera_Position[2] = -10

Sub C3D_SetCameraPosition(x, y, z)

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