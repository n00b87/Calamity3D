Include Once

PI = 3.14159265359

Sub C3D_RotatePoint(pt_x, pt_y, center_x, center_y, angleDeg, ByRef x, Byref y)

    angleRad = Radians(-angleDeg)
    cosAngle = Cos(angleRad)
    sinAngle = Sin(angleRad)
    dx = (pt_x-center_x)
    dy = (pt_y-center_y)

    x = center_x + (dx*cosAngle-dy*sinAngle)
    y = center_y + (dx*sinAngle+dy*cosAngle)
End Sub

Sub rotateVertex(vertex_x, vertex_y, vertex_z, center_x, center_y, center_z, angle_x, angle_y, angle_z, ByRef x_out, ByRef y_out, ByRef z_out)
  '// Convert angles from degrees to radians
  theta_x = Radians(angle_x)
  theta_y = Radians(angle_y)
  theta_z = Radians(angle_z)

  '// Translate the vertex to be relative to the camera
  vx = vertex_x - center_x
  vy = vertex_y - center_y
  vz = vertex_z - center_z

  '// Apply rotations around the x, y, and z axes
  new_vx = vx
  new_vy = vy * Cos(theta_x) - vz * Sin(theta_x)
  new_vz = vy * Sin(theta_x) + vz * Cos(theta_x)

  temp_vx = new_vx * Cos(theta_y) + new_vz * Sin(theta_y)
  temp_vy = new_vy
  temp_vz = -new_vx * Sin(theta_y) + new_vz * Cos(theta_y)

  new_vx = temp_vx * Cos(theta_z) - temp_vy * Sin(theta_z)
  new_vy = temp_vx * Sin(theta_z) + temp_vy * Cos(theta_z)
  new_vz = temp_vz

  '// Translate the vertex back to its original position relative to the camera
  x_out = new_vx + center_x
  y_out = new_vy + center_y
  z_out = new_vz + center_z
End Sub

Function C3D_LineAngle(x1, y1, x2, y2)
	Return Degrees(ATan((y2-y1)/(x2-x1)))
End Function

Function C3D_Distance2D(x1, y1, x2, y2)
	Return Sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
End Function

Function C3D_Distance3D(x1, y1, z1, x2, y2, z2)
	Return Sqrt( (x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2 )
End Function

Sub C3D_Ternary(condition, ByRef var, if_true, if_false)
	If condition Then
		var = if_true
	Else
		var = if_false
	End If
End Sub

Sub C3D_MovePointFromOrigin(angle, origin_x, origin_y, ByRef x, ByRef y)
	angle = Radians(angle)
	distance = C3D_Distance2D(origin_x, origin_y, x, y)
	
	'print "distance = ";distance
	
	v_sin = Sin(angle) * distance
	v_cos = Cos(angle) * distance
	
	x = v_cos
	y = v_sin
End Sub


Function n_ATan2(y, x)
	'"""Returns the arctangent of y/x in radians."""
	If x > 0 Then
		Return ATan(y/x)
	ElseIf x < 0 And y >= 0 Then
		Return ATan(y/x) + PI
	ElseIf x < 0 And y < 0 Then
		Return ATan(y/x) - PI
	ElseIf x = 0 And y > 0 Then
		Return PI/2
	ElseIf x = 0 And y < 0 Then
		Return -PI/2
	ElseIf x = 0 And y = 0 Then
		Return 0
	End If
End Function

const ATan2 = n_ATan2


'x = 1
'y = 2
'z = 3
'C3D_RotatePoint(z, y, 0, 0, -44, z, y)

'print "Rotation = "; y; ", ";z