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

Function C3D_Distance(x1, y1, x2, y2)
	Return Sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
End Function

Sub C3D_Ternary(condition, ByRef var, if_true, if_false)
	If condition Then
		var = if_true
	Else
		var = if_false
	End If
End Sub




'WindowOpen(0, "test", WINDOWPOS_CENTERED, WINDOWPOS_CENTERED, 640, 480, WINDOW_VISIBLE, 1)
'CanvasOpen(0, 640, 480, 0, 0, 640, 480, 0)
'
'dim x, y
'ang = 0
'x = 0
'y = 30
'
'
'Dim origin_loc_x[4], origin_loc_y[4]
'
'origin_loc_x[0] = 0
'origin_loc_y[0] = 30
'
'origin_loc_x[1] = origin_loc_x[0]
'origin_loc_y[1] = origin_loc_y[0]+20
'
'origin_loc_x[2] = origin_loc_x[0]+20
'origin_loc_y[2] = origin_loc_y[0]+20
'
'origin_loc_x[3] = origin_loc_x[0]+20
'origin_loc_y[3] = origin_loc_y[0]
'
'Dim loc_x[4], loc_y[4]
'
'loc_x[0] = 320
'loc_y[0] = 210
'
'loc_x[1] = loc_x[0]
'loc_y[1] = loc_y[0]-20
'
'loc_x[2] = loc_x[0]+20
'loc_y[2] = loc_y[0]-20
'
'loc_x[3] = loc_x[0]+20
'loc_y[3] = loc_y[0]
'
'While Not Key(K_ESCAPE)
'	ClearCanvas()
'	
'	If Key(K_LEFT) Then
'		ang = ang - 1
'		For i = 0 to 3
'			C3D_RotatePoint(origin_loc_x[i], origin_loc_y[i], 0, 0, ang, loc_x[i], loc_y[i])
'			loc_x[i] = loc_x[i] + 320
'			loc_y[i] = 240 - loc_y[i]
'		Next
'	ElseIf Key(K_RIGHT) Then
'		ang = ang + 1
'		For i = 0 to 3
'			C3D_RotatePoint(origin_loc_x[i], origin_loc_y[i], 0, 0, ang, loc_x[i], loc_y[i])
'			loc_x[i] = loc_x[i] + 320
'			loc_y[i] = 240 - loc_y[i]
'		Next
'	End If
'	
'	SetColor(RGB(255,255,255))
'	Circle(320, 240, 30)
'	SetColor(RGB(255,0,0))
'	Rect(318, 238, 4, 4)
'	
'	'Box
'	Rect(loc_x[0], loc_y[0], 4, 4)
'	Rect(loc_x[1], loc_y[1], 4, 4)
'	Rect(loc_x[2], loc_y[2], 4, 4)
'	Rect(loc_x[3], loc_y[3], 4, 4)
'	
'	Update()
'Wend
'
'print x;", ";y
'print C3D_GetDistance(0, 0, 3.6, 3.6)
