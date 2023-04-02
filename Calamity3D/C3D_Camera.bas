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

Dim C3D_Camera_Matrix_T '= C3D_CreateMatrix(4,4)
Dim C3D_Camera_Matrix_RX '= C3D_CreateMatrix(4,4)
Dim C3D_Camera_Matrix_RY '= C3D_CreateMatrix(4,4)
Dim C3D_Camera_Matrix_RZ '= C3D_CreateMatrix(4,4)

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
	C3D_Camera_Rotation[0] = (x MOD 360)
	C3D_Camera_Rotation[1] = (y MOD 360)
	C3D_Camera_Rotation[2] = (z MOD 360)
End Sub

Sub C3D_RotateCamera(x, y, z)
	C3D_Camera_Rotation[0] = (C3D_Camera_Rotation[0] + x) MOD 360
	C3D_Camera_Rotation[1] = (C3D_Camera_Rotation[1] + y) MOD 360
	C3D_Camera_Rotation[2] = (C3D_Camera_Rotation[2] + z) MOD 360
End Sub


cam_state_pos_x = C3D_Camera_Position[0]
cam_state_pos_y = C3D_Camera_Position[1]
cam_state_pos_z = C3D_Camera_Position[2]

cam_state_rot_x = C3D_Camera_Rotation[0]
cam_state_rot_y = C3D_Camera_Rotation[1]
cam_state_rot_z = C3D_Camera_Rotation[2]

Sub C3D_StoreCameraState()
	cam_state_pos_x = C3D_Camera_Position[0]
	cam_state_pos_y = C3D_Camera_Position[1]
	cam_state_pos_z = C3D_Camera_Position[2]

	cam_state_rot_x = C3D_Camera_Rotation[0]
	cam_state_rot_y = C3D_Camera_Rotation[1]
	cam_state_rot_z = C3D_Camera_Rotation[2]
End Sub

Sub C3D_LoadCameraState()
	C3D_Camera_Position[0] = cam_state_pos_x
	C3D_Camera_Position[1] = cam_state_pos_y
	C3D_Camera_Position[2] = cam_state_pos_z

	C3D_Camera_Rotation[0] = cam_state_rot_x
	C3D_Camera_Rotation[1] = cam_state_rot_y
	C3D_Camera_Rotation[2] = cam_state_rot_z
End Sub


' A function to rotate a point around the x axis by a given angle in degrees
Sub rotate_point_on_X(ByRef point_x, ByRef point_y, ByRef point_z, angle)
    angle = Radians(angle)
    x = point_x
    y = point_y * cos(angle) - point_z * sin(angle)
    z = point_y * sin(angle) + point_z * cos(angle)
    point_x = x
    point_y = y
    point_z = z
End Sub

' A function to rotate a point around the y axis by a given angle in degrees
Sub rotate_point_on_Y(ByRef point_x, ByRef point_y, ByRef point_z, angle)
    angle = Radians(angle)
    x = point_x * cos(angle) + point_z * sin(angle)
    y = point_y
    z = -point_x * sin(angle) + point_z * cos(angle)
    point_x = x
    point_y = y
    point_z = z
End Sub

' A function to rotate a point around the z axis by a given angle in degrees
Sub rotate_point_on_Z(ByRef point_x, ByRef point_y, ByRef point_z, angle)
    angle = Radians(angle)
    x = point_x * cos(angle) - point_y * sin(angle)
    y = point_x * sin(angle) + point_y * cos(angle)
    z = point_z
    point_x = x
    point_y = y
    point_z = z   
End Sub

' A function to move a point a given distance in the direction it is facing
Sub C3D_GetForwardVector(position_x, position_y, position_z, rotation_x, rotation_y, rotation_z, distance, ByRef x_out, ByRef y_out, ByRef z_out)
    ' Rotate the forward direction vector based on the rotation angles
    forward_x = 0
    forward_y = 0
    forward_z = 1
    'Print "IN[1]: ";position_x;", ";position_y;", ";position_z;", ";rotation_x;", ";rotation_y;", ";rotation_z;", ";distance
    rotate_point_on_X(forward_x, forward_y, forward_z, -rotation_x)
    rotate_point_on_Y(forward_x, forward_y, forward_z, -rotation_y)
    rotate_point_on_Z(forward_x, forward_y, forward_z, -rotation_z)
    'Print "FW: ";forward_x;", ";forward_y;", ";forward_z

    ' Calculate the new position by moving in the direction of the rotated forward vector
    x_out = position_x + distance * forward_x
    y_out = position_y + distance * forward_y
    z_out = position_z + distance * forward_z
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


'// Compute the rotation angles required to look at an object from a camera position
Sub lookAt(cameraPos_x, cameraPos_y, cameraPos_z, objectPos_x, objectPos_y, objectPos_z, ByRef x_angle, ByRef y_angle, ByRef z_angle)
  '// Compute the direction vector from the camera to the object
  Print "LOOK DATA = "; cameraPos_x;", ";cameraPos_y;", ";cameraPos_z;", ";objectPos_x;", ";objectPos_y;", ";objectPos_z
  mdir = C3D_CreateMatrix(3,1)
  world_up = C3D_CreateMatrix(3,1)
  cam_up = C3D_CreateMatrix(3,1)
  cam_right = C3D_CreateMatrix(3,1)
  
  cameraPos = C3D_CreateMatrix(3,1)
  objectPos = C3D_CreateMatrix(3,1)
  
  SetMatrixValue(cameraPos, 0, 0, cameraPos_x)
  SetMatrixValue(cameraPos, 1, 0, cameraPos_y)
  SetMatrixValue(cameraPos, 2, 0, cameraPos_z)
  
  SetMatrixValue(objectPos, 0, 0, objectPos_x)
  SetMatrixValue(objectPos, 1, 0, objectPos_y)
  SetMatrixValue(objectPos, 2, 0, objectPos_z)
  
  SubtractMatrix(objectPos, cameraPos, mdir)
  normalize(mdir, mdir)

  '// Compute the angle to rotate around the x-axis
  x_angle = Degrees(ASin(-1*MatrixValue(mdir,1,0)))

  '// Compute the angle to rotate around the y-axis
  y_angle = Degrees(ATan2(-1* MatrixValue(mdir,0,0), -1 * MatrixValue(mdir,2,0)))

  '// Compute the angle to rotate around the z-axis
  'Vector3 world_up(0, 1, 0);
  SetMatrixValue(world_up, 0, 0, 0)
  SetMatrixValue(world_up, 1, 0, 1)
  SetMatrixValue(world_up, 2, 0, 0)
  
  'Vector3 cam_right = world_up.cross(dir).normalize();
  crossProduct(world_up, mdir, cam_right)
  normalize(cam_right, cam_right)
  
  'Vector3 cam_up = dir.cross(cam_right);
  crossProduct(mdir, cam_right, cam_up)
  
  z_angle = Degrees(ATan2(MatrixValue(cam_up,0,0), MatrixValue(cam_up,1,0)))
  
  C3D_DeleteMatrix(mdir)
  C3D_DeleteMatrix(world_up)
  C3D_DeleteMatrix(cam_up)
  C3D_DeleteMatrix(cam_right)
  C3D_DeleteMatrix(cameraPos)
  C3D_DeleteMatrix(objectPos)
End Sub