Sub C3D_Ternary(condition, ByRef var, if_true, if_false)
	If condition Then
		var = if_true
	Else
		var = if_false
	End If
End Sub


Sub C3D_RotateVertex3D(vertex_x, vertex_y, vertex_z, center_x, center_y, center_z, angle_x, angle_y, angle_z, ByRef x_out, ByRef y_out, ByRef z_out)
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


SCREEN_GRAPH_OFFSET_X = 320
SCREEN_GRAPH_OFFSET_Y = 640

WindowOpen(0, "Test", WINDOWPOS_CENTERED, WINDOWPOS_CENTERED, 640, 480, WINDOW_VISIBLE, 1)
CanvasOpen(0, 640, 480, 0, 0, 640, 480, 1)
CanvasOpen(1, 640, 480, 0, 0, 640, 480, 1)
SetCanvasVisible(1, 0)

LoadImage(0, "grid.png")

Dim iw, ih
GetImageSize(0, iw, ih)

r=0

sub plane(near_x, near_y, far_x, far_y)
	n_min_x = -1 * abs(near_x)
	n_max_x = abs(near_x)
	
	
	f_min_x = -1 * abs(far_x)
	f_max_x = abs(far_x)
	
	h = abs(far_y - near_y)
	if h >= 480 then
		h = 480
	end if
	
	Canvas(1)
	
	ClearCanvas()
	DrawImage_Rotate(0,0,0,r)
	CanvasClip(1, 0, 0, iw, h, 1)
	
	GetImageSize(0, iw, ih)
	
	ClearCanvas()
	DrawImage_Blit_Ex(1, 0, 0, iw, h, 0, 0, iw, ih)
	DeleteImage(1)
	CanvasClip(1, 0, 0, iw, h, 1)
	
	Canvas(0)
	
	'print "dbg: ";near_x;", ";near_y;", ";far_x;", ";far_y
	
	SetColor(RGB(0,255,0))
	For y = near_y to far_y
		x = Interpolate(near_y, far_y, y, near_x, far_x)
		'print "x = "; x; ", "; y
		'PSet(x-5, y)
		w = (SCREEN_GRAPH_OFFSET_X - x)*2
		ny = y - near_y
		'print "n = "; x;", ";y;", ";w;", ";1
		DrawImage_Blit_Ex(1, x, y, w, 1, 0, ny, iw, 1)
	Next
	
	DeleteImage(1)
	
	Canvas(0)
	SetColor(RGB(255,255,255))
end sub


x = 0
y = 0
w = 640
h = 480

Dim p1[3], p2[3], p3[3], p4[3]

p1[0] = -200 : p1[1] = 500 : p1[2] = 1

p2[0] = -200 : p2[1] = 500 : p2[2] = -200

p3[0] = 200 : p3[1] = 500 : p3[2] = -200

p4[0] = 200 : p4[1] = 500 : p4[2] = 1

CAMERA_LENS = 500

angle = 0

While Not Key(K_ESCAPE)
	
	ClearCanvas()
	
	If Key(K_UP) Then
		angle = angle + 1
		'print "Angle = "; angle
	ElseIf Key(K_DOWN) Then
		angle = angle - 1
		'print "Angle = "; angle
	End If
	
	If Key(K_R) Then
		r = r + 1
	End If
	
	x_out = 0
	y_out = 0
	z_out = 0
	
	
	
	C3D_RotateVertex3D(p1[0], p1[1], p1[2], 0, 500, -100, angle, 0, 0, x_out, y_out, z_out)
	p1_x_out = x_out
	p1_y_out = y_out
	p1_z_out = z_out
	
	C3D_RotateVertex3D(p2[0], p2[1], p2[2], 0, 500, -100, angle, 0, 0, x_out, y_out, z_out)
	p2_x_out = x_out
	p2_y_out = y_out
	p2_z_out = z_out
	
	C3D_RotateVertex3D(p3[0], p3[1], p3[2], 0, 500, -100, angle, 0, 0, x_out, y_out, z_out)
	p3_x_out = x_out
	p3_y_out = y_out
	p3_z_out = z_out
	
	C3D_RotateVertex3D(p4[0], p4[1], p4[2], 0, 500, -100, angle, 0, 0, x_out, y_out, z_out)
	p4_x_out = x_out
	p4_y_out = y_out
	p4_z_out = z_out
	
	
	distance = CAMERA_LENS - p1_z_out
	C3D_Ternary(distance<=0, distance, 1, distance)
	cld = (CAMERA_LENS / distance)
	p1_x = (cld * p1_x_out) + SCREEN_GRAPH_OFFSET_X
	p1_y = SCREEN_GRAPH_OFFSET_Y - (cld * p1_y_out)


	distance = CAMERA_LENS - p2_z_out
	C3D_Ternary(distance<=0, distance, 1, distance)
	cld = (CAMERA_LENS / distance)
	p2_x = (cld * p2_x_out) + SCREEN_GRAPH_OFFSET_X
	p2_y = SCREEN_GRAPH_OFFSET_Y - (cld * p2_y_out)


	distance = CAMERA_LENS - p3_z_out
	C3D_Ternary(distance<=0, distance, 1, distance)
	cld = (CAMERA_LENS / distance)
	p3_x = (cld * p3_x_out) + SCREEN_GRAPH_OFFSET_X
	p3_y = SCREEN_GRAPH_OFFSET_Y - (cld * p3_y_out)


	distance = CAMERA_LENS - p4_z_out
	C3D_Ternary(distance<=0, distance, 1, distance)
	cld = (CAMERA_LENS / distance)
	p4_x = (cld * p4_x_out) + SCREEN_GRAPH_OFFSET_X
	p4_y = SCREEN_GRAPH_OFFSET_Y - (cld * p4_y_out)


	'Print "( ";p1_x;", ";p1_y;" )"
	'Print "( ";p2_x;", ";p2_y;" )"
	'Print "( ";p3_x;", ";p3_y;" )"
	'Print "( ";p4_x;", ";p4_y;" )"



	SetColor(RGB(255,255,255))
	
	if key(k_m) then
		plane(p1_x, p1_y, p2_x, p2_y)
		print "px,px = "; p1_x;", ";p2_x
	end if

	Line(p1_x, p1_y, p2_x, p2_y)
	Line(p2_x, p2_y, p3_x, p3_y)
	Line(p3_x, p3_y, p4_x, p4_y)
	Line(p4_x, p4_y, p1_x, p1_y)

	SetColor(RGB(255,0,0))
	RectFill(p2_x-2, p2_y-2, 4, 4)
	RectFill(p3_x-2, p3_y-2, 4, 4)


	Update()

Wend