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
