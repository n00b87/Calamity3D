Include Once
Include "Calamity3D/C3D_Utility.bas"
Include "Calamity3D/C3D_Matrix.bas"

C3D_CAMERA_CENTER_X = 0
C3D_CAMERA_CENTER_Y = 0
C3D_CAMERA_CENTER_Z = C3D_CAMERA_LENS

Dim C3D_Camera_Position[3]
Dim C3D_Camera_Rotation[3]

Dim C3D_Camera_AbsolutePosition_Delta[3]
Dim C3D_Camera_AbsoluteRotation_Delta[3]

C3D_Camera_Position[1] = -50
C3D_Camera_Position[2] = -10

C3D_Camera_Matrix_T = C3D_CreateMatrix(4,4)
C3D_Camera_Matrix_RX = C3D_CreateMatrix(4,4)
C3D_Camera_Matrix_RY = C3D_CreateMatrix(4,4)
C3D_Camera_Matrix_RZ = C3D_CreateMatrix(4,4)

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


Sub computeCameraRotationMatrix(cr_matrix, ByRef position, ByRef target, ByRef up)
    'compute the camera's view direction
    Dim forward[3]
    forward[0] = target[0] - position[0]
    forward[1] = target[1] - position[1]
    forward[2] = target[2] - position[2]
    
    forwardNorm = sqrt(forward[0]^2 + forward[1]^2 + forward[2]^2)

    forward[0] = forward[0] / forwardNorm
    forward[1] = forward[1] / forwardNorm
    forward[2] = forward[2] / forwardNorm
    
    'compute the camera's right direction
    Dim right_v[3]
    right_v[0] = up[1] * forward[2] - up[2] * forward[1]
    right_v[1] = up[2] * forward[0] - up[0] * forward[2]
    right_v[2] = up[0] * forward[1] - up[1] * forward[0]


    rightNorm = sqrt(right_v[0]^2 + right_v[1]^2 + right_v[2]^2)
    right_v[0] = right_v[0] / rightNorm
    right_v[1] = right_v[1] / rightNorm
    right_v[2] = right_v[2] / rightNorm
    
    'compute the camera's up direction
    Dim newUp[3]
    newUp[0] = forward[1] * right_v[2] - forward[2] * right_v[1]
    newUp[1] = forward[2] * right_v[0] - forward[0] * right_v[2]
    newUp[2] = forward[0] * right_v[1] - forward[1] * right_v[0]
    
    'construct the rotation matrix
    'cr_mat = C3D_CreateMatrix(3, 3)
    DimMatrix(cr_matrix, 3, 3, 0)
    SetMatrixValue(cr_matrix, 0, 0, right_v[0]) : SetMatrixValue(cr_matrix, 0, 1, newUp[0]) : SetMatrixValue(cr_matrix, 0, 2, -forward[0]) 
    SetMatrixValue(cr_matrix, 1, 0, right_v[1]) : SetMatrixValue(cr_matrix, 1, 1, newUp[2]) : SetMatrixValue(cr_matrix, 1, 2, -forward[1])
    SetMatrixValue(cr_matrix, 2, 0, right_v[2]) : SetMatrixValue(cr_matrix, 2, 1, newUp[2]) : SetMatrixValue(cr_matrix, 2, 2, -forward[2])
End Sub

sub calculateTargetVector(target, cameraPosition, axis, rotationAngle)
    ' Step 1: Define the axis of rotation
    'Dim axis[3] = rotationAxis.normalized(); pass it normalized ie. 0, 1, 0

    ' Step 2: Construct the rotation matrix
    rotationMatrix = C3D_CreateMatrix(3,3)
    C3D_SetRotationMatrix(rotationMatrix, axis, rotationAngle)

    ' Step 3: Create the forward vector
    forward = C3D_CreateMatrix(3, 1)
    SetMatrixValue(forward, 0, 0, 0)
    SetMatrixValue(forward, 1, 0, 0)
    SetMatrixValue(forward, 2, 0, -1)

    ' Step 4: Transform the forward vector by the rotation matrix
    newForward = C3D_CreateMatrix(3, 3)
    MultiplyMatrix(rotationMatrix, forward, newForward)

    ' Step 5: Add the transformed forward vector to the camera position to get the new target position
    AddMatrix(cameraPosition, newForward, target)
    
    C3D_DeleteMatrix(rotationMatrix)
    C3D_DeleteMatrix(forward)
    C3D_DeleteMatrix(newForward)
end sub

sub normalize(m, m_out)
	ln = Sqrt( MatrixValue(m, 0, 0)^2 + MatrixValue(m, 1, 0)^2 + MatrixValue(m, 2, 0)^2 )
	ScalarMatrix(m, m_out, 1/ln)
end sub

Sub crossProduct(v1, v2, result)
    DimMatrix(result, 3, 1, 0)
    SetMatrixValue(result, 0, 0, MatrixValue(v1, 1, 0) * MatrixValue(v2, 2, 0) - MatrixValue(v1, 2, 0) * MatrixValue(v2, 1, 0))
    SetMatrixValue(result, 1, 0, MatrixValue(v1, 2, 0) * MatrixValue(v2, 0, 0) - MatrixValue(v1, 0, 0) * MatrixValue(v2, 2, 0))
    SetMatrixValue(result, 2, 0, MatrixValue(v1, 0, 0) * MatrixValue(v2, 1, 0) - MatrixValue(v1, 1, 0) * MatrixValue(v2, 0, 0))
End Sub

sub calculateUpVector(up, cameraPosition, target)
    ' Step 1: Calculate the forward vector
    forward = C3D_CreateMatrix(3,1)
    
    SubtractMatrix(target, cameraPosition, forward)
    normalize(forward, forward)

    ' Step 2: Define a temporary up vector
    tempUp = C3D_CreateMatrix(3,1)
    SetMatrixValue(tempUp, 0, 0, 0)
    SetMatrixValue(tempUp, 1, 0, 1)
    SetMatrixValue(tempUp, 2, 0, 0)

    ' Step 3: Calculate the right vector
    right_v = C3D_CreateMatrix(3,1)
    crossProduct(forward, tempUp, right_v)
    normalize(right_v, right_v)

    ' Step 4: Calculate the new up vector
    DimMatrix(up, 3, 1, 0)
    crossProduct(right_v, forward, up)

    ' Step 5: Normalize the up vector
    normalize(up, up)
    
    C3D_DeleteMatrix(forward)
    C3D_DeleteMatrix(tempUp)
    C3D_DeleteMatrix(right_v)
End Sub


sub calculateViewMatrix(vrx, vry, vrz)
	tmpx = C3D_CreateMatrix(4,4)
	tmpy = C3D_CreateMatrix(4,4)
	tmpz = C3D_CreateMatrix(4,4)
	tmpt = C3D_CreateMatrix(4,4)
	IdentityMatrix(tmpt, 4)
	
	rotateX(tmpx, C3D_Camera_Rotation[0])
	rotateY(tmpy, C3D_Camera_Rotation[1])
	rotateZ(tmpz, C3D_Camera_Rotation[2])
	
	C3D_DeleteMatrix(tmpx)
	C3D_DeleteMatrix(tmpy)
	C3D_DeleteMatrix(tmpz)
	C3D_DeleteMatrix(tmpt)
	
	CopyMatrix(tmpx, vrx)
	CopyMatrix(tmpy, vry)
	CopyMatrix(tmpz, vrz)
	return

	' Translate matrix to move the camera to its position
	SetMatrixValue(tmpt, 0, 3, -1*C3D_Camera_Position[0])
	SetMatrixValue(tmpt, 1, 3, -1*C3D_Camera_Position[1])
	SetMatrixValue(tmpt, 2, 3, -1*C3D_Camera_Position[2])

	' Combine the translation and rotation matrices
	MultiplyMatrix(tmpx, tmpt, vrx)
	MultiplyMatrix(tmpy, tmpt, vry)
	MultiplyMatrix(tmpz, tmpt, vrz)
	
	C3D_DeleteMatrix(tmpx)
	C3D_DeleteMatrix(tmpy)
	C3D_DeleteMatrix(tmpz)
	C3D_DeleteMatrix(tmpt)

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