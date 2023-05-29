Include Once

Include "Calamity3D/C3D_Matrix.bas"

Sub PrintMatrix(m)
	Dim r, c
	GetMatrixSize(m, r, c)
	
	For row = 0 to r-1
		Print "[ ";
		For col = 0 to c-1
			Print MatrixValue(m, row, col);
			If col <> c-1 Then
				Print ", ";
			End If
		Next
		Print "]"
	Next
End Sub

' Compute the intersection point between a ray and a plane
function C3D_IntersectRayPlane_M(ray_origin, ray_direction, planeNormal, planePoint, intersectionPoint)
	plane_minus_origin = C3D_CreateMatrix(2,2)
	SubtractMatrix(planePoint, ray_origin, plane_minus_origin)
	'print "dot(): "; dot(planeNormal, plane_minus_origin); "  /  "; dot(planeNormal, ray_direction)

	t = dot(planeNormal, plane_minus_origin) / dot(planeNormal, ray_direction)
	C3D_DeleteMatrix(plane_minus_origin)

	if t > 0 Then
		'intersectionPoint = ray.origin + ray.direction * t;
		ScalarMatrix(ray_direction, intersectionPoint, t)
		AddMatrix(ray_origin, intersectionPoint, intersectionPoint)
		return true
	End If

	return false
End Function

' Check if a point lies within a quad
Function C3D_PointInQuad_M(point, quad)
	v1 = C3D_CreateMatrix(2,2)
	v2 = C3D_CreateMatrix(2,2)
	v3 = C3D_CreateMatrix(2,2)
	v4 = C3D_CreateMatrix(2,2)
	cp1 = C3D_CreateMatrix(2,2)
	cp2 = C3D_CreateMatrix(2,2)
	cp3 = C3D_CreateMatrix(2,2)
	cp4 = C3D_CreateMatrix(2,2)
	
	p1 = C3D_CreateMatrix(2,2)
	p2 = C3D_CreateMatrix(2,2)
	p3 = C3D_CreateMatrix(2,2)
	p4 = C3D_CreateMatrix(2,2)
	
	tmp = C3D_CreateMatrix(2,2)
	
	CopyMatrixColumns(quad, p1, 0, 1)
	CopyMatrixColumns(quad, p2, 1, 1)
	CopyMatrixColumns(quad, p3, 2, 1)
	CopyMatrixColumns(quad, p4, 3, 1)
	
	SubtractMatrix(p2, p1, v1)
	SubtractMatrix(p3, p2, v2)
	SubtractMatrix(p4, p3, v3)
	SubtractMatrix(p1, p4, v4)

	SubtractMatrix(point, p1, tmp)
	crossProduct(tmp, v1, cp1)
	
	SubtractMatrix(point, p2, tmp)
	crossProduct(tmp, v2, cp2)
	
	SubtractMatrix(point, p3, tmp)
	crossProduct(tmp, v3, cp3)
	
	SubtractMatrix(point, p4, tmp)
	crossProduct(tmp, v4, cp4)
	
	ret_val = false

	If (dot(cp1, cp2) >= 0 And dot(cp2, cp3) >= 0 And dot(cp3, cp4) >= 0) Then
		ret_val = true
	End If
	
	C3D_DeleteMatrix(v1)
	C3D_DeleteMatrix(v2)
	C3D_DeleteMatrix(v3)
	C3D_DeleteMatrix(v4)
	C3D_DeleteMatrix(cp1)
	C3D_DeleteMatrix(cp2)
	C3D_DeleteMatrix(cp3)
	C3D_DeleteMatrix(cp4)
	
	C3D_DeleteMatrix(p1)
	C3D_DeleteMatrix(p2)
	C3D_DeleteMatrix(p3)
	C3D_DeleteMatrix(p4)
	
	C3D_DeleteMatrix(tmp)

	return ret_val
End Function

' Check if a line intersects a quad in 3D
Function C3D_IntersectLineQuad_M(ln, quad)

	p1 = C3D_CreateMatrix(2,2)
	p2 = C3D_CreateMatrix(2,2)
	p3 = C3D_CreateMatrix(2,2)
	p4 = C3D_CreateMatrix(2,2)
	
	intersectionPoint = C3D_CreateMatrix(2,2)
	planeNormal = C3D_CreateMatrix(2,2)
	
	tmp1 = C3D_CreateMatrix(2,2)
	tmp2 = C3D_CreateMatrix(2,2)
	
	ln_origin = C3D_CreateMatrix(2,2)
	ln_direction = C3D_CreateMatrix(2,2)
	
	CopyMatrixColumns(ln, ln_origin, 0, 1)
	CopyMatrixColumns(ln, ln_direction, 1, 1)
	
	CopyMatrixColumns(quad, p1, 0, 1)
	CopyMatrixColumns(quad, p2, 1, 1)
	CopyMatrixColumns(quad, p3, 2, 1)
	CopyMatrixColumns(quad, p4, 3, 1)
	
	SubtractMatrix(p2, p1, tmp1)
	SubtractMatrix(p3, p2, tmp2)
	
	crossProduct(tmp1, tmp2, planeNormal)
	
	ret_val = false

	If (C3D_IntersectRayPlane_M(ln_origin, ln_direction, planeNormal, p1, intersectionPoint)) Then
		If (C3D_PointInQuad_M(intersectionPoint, quad)) Then
			ret_val = true
		End If
	End If
	
	C3D_DeleteMatrix(p1)
	C3D_DeleteMatrix(p2)
	C3D_DeleteMatrix(p3)
	C3D_DeleteMatrix(p4)
	
	C3D_DeleteMatrix(intersectionPoint)
	C3D_DeleteMatrix(planeNormal)
	
	C3D_DeleteMatrix(tmp1)
	C3D_DeleteMatrix(tmp2)
	
	C3D_DeleteMatrix(ln_origin)
	C3D_DeleteMatrix(ln_direction)

	return ret_val
End Function


function C3D_DistanceToLine(A, B, C, x, y)
	'"""Calculate the distance between a point (x, y) and a line Ax + By + C = 0."""
	return abs(A * x + B * y + C) / sqrt(A * A + B * B)
end function

sub C3D_LineFromPoints(x1, y1, x2, y2, ByRef A, ByRef B, ByRef C)
	'"""Get the line equation Ax + By + C = 0 from two points (x1, y1) and (x2, y2)."""
	A = y2 - y1
	B = x1 - x2
	C = x2 * y1 - x1 * y2
end sub

function C3D_CircleLineIntersection(circle_x, circle_y, radius, x1, y1, x2, y2)
	'"""Check if a circle with center (circle_x, circle_y) and radius intersects a line defined by points (x1, y1) and (x2, y2)."""
	min_x = Min(x1, x2)
	min_y = Min(y1, y2)
	
	max_x = Max(x1, x2)
	max_y = Max(y1, y2)
	
	if (circle_x + radius) < min_x Or (circle_x - radius) > max_x Or (circle_y + radius) < min_y Or (circle_y - radius) > max_y then
		return false
	end if
	
	'# Get the line equation from the two points
	Dim A, B, C
	C3D_LineFromPoints(x1, y1, x2, y2, A, B, C)

	'# Calculate the distance between the circle's center and the line
	distance = C3D_DistanceToLine(A, B, C, circle_x, circle_y)
	
	'# If the distance is less than or equal to the radius, the circle and line intersect
	if distance <= radius then
		return True
	else
		return False
	end if
end function



function C3D_AngleOfLine(x1, y1, x2, y2)
	'"""Get the angle of a line defined by points (x1, y1) and (x2, y2) in degrees."""
	'# Calculate the difference in x and y coordinates
	dx = x2 - x1
	dy = y2 - y1

	'# Calculate the angle in radians using the arctan2 function
	angle_rad = ATan2(dy, dx)

	'# Convert the angle to degrees
	angle_deg = Degrees(angle_rad)

	'# Normalize the angle to the range [0, 180]
	if angle_deg < 0 then
		angle_deg = angle_deg + 180
	end if

	if angle_deg > 180 then
		angle_deg = angle_deg - 180
	end if
	
	return angle_deg
end function

function C3D_BetweenAngles(tgt_angle, angle1, angle2)
	tgt_angle = tgt_angle MOD 360
	angle1 = angle1 MOD 360
	angle2 = angle2 MOD 360
	
	if tgt_angle > 180 then
		tgt_angle = tgt_angle - 360
	elseif tgt_angle <= -180 then
		tgt_angle = tgt_angle + 360
	end if
	
	if angle1 > 180 then
		angle1 = angle1 - 360
	elseif angle1 <= -180 then
		angle1 = angle1 + 360
	end if
	
	if angle2 > 180 then
		angle2 = angle2 - 360
	elseif angle2 <= -180 then
		angle2 = angle2 + 360
	end if
	
	if tgt_angle < 0 then : tgt_angle = tgt_angle + 360 : end if
	if angle1 < 0 then : angle1 = angle1 + 360 : end if
	if angle2 < angle1 then : angle2 = angle2 + 360 : end if
	
	
	'Print "BA: [";tgt_angle;"]   [";angle1;"]   [";angle2;"]"  
	
	return (tgt_angle >= angle1 And tgt_angle <= angle2)
	
end function


sub C3D_ColDet_CircleLine(ByRef circle_old_x, ByRef circle_old_y, ByRef circle_new_x, ByRef circle_new_y, circle_radius, line_x1, line_y1, line_x2, line_y2, speed)
	
	angle_adjust = 0
	
	if line_x2 < line_x1 then
		Push_N(line_y1)
		Push_N(line_x1)
		
		line_x1 = line_x2
		line_y1 = line_y2
		line_x2 = Pop_N
		line_y2 = Pop_N
	end if
	
	if circle_old_x = circle_new_x And circle_old_y = circle_new_y then
		return 'there is no point in doing all these calculations when the object didn't move
	end if
	
	tl_br = ((line_x1 < line_x2) And (line_y1 < line_y2)) Or ((line_x2 < line_x1) And (line_y2 < line_y1))
	bl_tr = ((line_x1 < line_x2) And (line_y1 > line_y2)) Or ((line_x2 < line_x1) And (line_y2 > line_y1))
	
	flat = Not (tl_br Or bl_tr)
	
	ncx = circle_new_x
	ncy = circle_new_y
	
	if tl_br then
		'print "tl_br"
		'moving up
		if (circle_new_y - circle_old_y) < 0 then
			'moving left
			if circle_new_x <= circle_old_x then
				angle_adjust = radians(180)
			end if
		else
			if circle_new_x < circle_old_x then
				angle_adjust = radians(180)
			end if
		end if
	elseif bl_tr then
		'print "bl_tr"
		'moving up
		if (circle_new_y - circle_old_y) < 0 then
			'moving right
			if circle_old_x > circle_new_x then
				angle_adjust = radians(180)
			end if
		else
			if circle_old_x >= circle_new_x then
				angle_adjust = radians(180)
			end if
		end if
	end if
	
	displace = false
	
	do
		half_dist_x = (circle_new_x - circle_old_x)/2
		half_dist_y = (circle_new_y - circle_old_y)/2
		if not C3D_CircleLineIntersection(circle_new_x, circle_new_y, circle_radius, line_x1, line_y1, line_x2, line_y2) then
			exit do
		elseif (abs(half_dist_x) <= 1) And (abs(half_dist_y) <= 1) then
			circle_new_x = circle_old_x
			circle_new_y = circle_old_y
			displace = true
			exit do
		end if
		
		circle_new_x = circle_old_x + half_dist_x
		circle_new_y = circle_old_y + half_dist_y
		
		displace = true
		
		'print "loop: "; half_dist_x;", ";half_dist_y
		
	loop
	
	if flat then
		if line_y1 = line_y2 then
			if not C3D_CircleLineIntersection(ncx, circle_new_y, circle_radius, line_x1, line_y1, line_x2, line_y2) then
				circle_new_x = ncx
			end if
		else
			if not C3D_CircleLineIntersection(circle_new_x, ncy, circle_radius, line_x1, line_y1, line_x2, line_y2) then
				circle_new_y = ncy
			end if
		end if
	elseif displace then
		'print "val: ";tl_br;", ";bl_tr
		'print "line = ( ";line_x1;", ";line_y1;" ) ( ";line_x2;", ";line_y2;" )"
		'print "circle = ";circle_old_x;", ";circle_old_y;", ";ncx;", ";ncy
		
		'# Calculate the angle of the line in radians
		angle_rad = atan2(line_y2 - line_y1, line_x2 - line_x1)
		
		angle_out = degrees(angle_rad)
		angle_c = degrees(atan2(ncy-circle_old_y, ncx-circle_old_x))
		
		if angle_c > 180 then
			angle_c = angle_c - 360
		elseif angle_c <= -180 then
			angle_c = angle_c + 360
		end if
		
		if angle_out > 180 then
			angle_out = angle_out - 360
		elseif angle_out <= -180 then
			angle_out = angle_out + 360
		end if
		
		'print "New Angles: ";angle_c; ", ";angle_out
		
		angle_c_gt_angle_out = C3D_BetweenAngles(angle_c, angle_out + 90, angle_out + 270)
		
		'print "<--CONDITION-->"; angle_c_gt_angle_out
		
		if angle_c_gt_angle_out And ( Not C3D_BetweenAngles(angle_c, angle_out, angle_out + 90) ) then
			'print "yolo"
			angle_rad = angle_rad - radians(180)
		elseif C3D_BetweenAngles(angle_c+180, angle_out, angle_out + 90) then
			'print "balls"
			angle_rad = angle_rad - radians(180)
		end if

		'speed = 2'sqrt( (circle_new_x - circle_old_x)^2 + (circle_new_y - circle_old_y)^2 )
		
		'# Calculate the displacement in x and y coordinates
		dx = speed * cos(angle_rad)
		dy = speed * sin(angle_rad)
		
		if tl_br then
			if not C3D_CircleLineIntersection(circle_new_x+dx, circle_new_y+dy, circle_radius, line_x1, line_y1, line_x2, line_y2) then
				circle_new_x = circle_new_x + dx
				circle_new_y = circle_new_y + dy
				'print "tl_br = "; dx; ", "; dy; "  ---> degrees = ";angle_out; ", ";angle_c
				'print "cmp: "; between_angles(angle_c, angle_out, angle_out + 90)
			end if
		else
			if not C3D_CircleLineIntersection(circle_new_x+dx, circle_new_y+dy, circle_radius, line_x1, line_y1, line_x2, line_y2) then
				circle_new_x = circle_new_x + dx
				circle_new_y = circle_new_y + dy
				'print "bl_tr = "; dx; ", "; dy; "  ---> degrees = ";angle_out; ", ";angle_c
				'print "cmp: "; between_angles(angle_c, angle_out, angle_out + 90)
			end if
		end if
	end if
	
	circle_old_x = circle_new_x
	circle_old_y = circle_new_y
end sub

function C3D_PointInQuad(x, y, x1, y1, x2, y2, x3, y3, x4, y4)
	'"""
	'Check if a point (x, y) is inside a quadrilateral defined by its four vertices (x1, y1), (x2, y2), (x3, y3), and (x4, y4).
	'"""
	'# Compute the cross products of vectors from the point to each vertex of the quadrilateral.
	'# If all cross products have the same sign, the point is inside the quadrilateral.
	cross1 = (x - x1) * (y2 - y1) - (y - y1) * (x2 - x1)
	cross2 = (x - x2) * (y3 - y2) - (y - y2) * (x3 - x2)
	cross3 = (x - x3) * (y4 - y3) - (y - y3) * (x4 - x3)
	cross4 = (x - x4) * (y1 - y4) - (y - y4) * (x1 - x4)

	if cross1 >= 0 and cross2 >= 0 and cross3 >= 0 and cross4 >= 0 then
		return True
	elseif cross1 <= 0 and cross2 <= 0 and cross3 <= 0 and cross4 <= 0 then
		return True
	else
		return False
	end if
end function


function C3D_LinePlaneIntersection(ByRef line_point, ByRef line_direction, ByRef plane_point_1, ByRef plane_point_2, ByRef plane_point_3, ByRef intersection)
'    """
'    Calculates the intersection point of a line and a plane in 3D space.
'
'    Parameters:
'    line_point (tuple or list): a point on the line (x, y, z)
'    line_direction (tuple or list): the direction vector of the line (x, y, z)
'    plane_point_1 (tuple or list): one point on the plane (x, y, z)
'    plane_point_2 (tuple or list): another point on the plane (x, y, z)
'    plane_point_3 (tuple or list): a third point on the plane (x, y, z)
'
'    Returns:
'    intersection (tuple): the intersection point (x, y, z), or None if the line is parallel to the plane
'    """
'    # calculate the normal vector of the plane using the cross product of two vectors on the plane
	Dim plane_vector_1[3], plane_vector_2[3], plane_normal[3]
	
	plane_vector_1[0] = plane_point_2[0] - plane_point_1[0]
	plane_vector_1[1] = plane_point_2[1] - plane_point_1[1]
	plane_vector_1[2] = plane_point_2[2] - plane_point_1[2]
	
	plane_vector_2[0] = plane_point_3[0] - plane_point_1[0]
	plane_vector_2[1] = plane_point_3[1] - plane_point_1[1]
	plane_vector_2[2] = plane_point_3[2] - plane_point_1[2]
	
	plane_normal[0] = plane_vector_1[1] * plane_vector_2[2] - plane_vector_1[2] * plane_vector_2[1]
	plane_normal[1] = plane_vector_1[2] * plane_vector_2[0] - plane_vector_1[0] * plane_vector_2[2]
	plane_normal[2] = plane_vector_1[0] * plane_vector_2[1] - plane_vector_1[1] * plane_vector_2[0]

	'# calculate the scalar value of t using the line equation
	t = ((plane_point_1[0] - line_point[0]) * plane_normal[0] + (plane_point_1[1] - line_point[1]) * plane_normal[1] + (plane_point_1[2] - line_point[2]) * plane_normal[2]) 
	'print "t1 = ";t
	t = t / (line_direction[0] * plane_normal[0] + line_direction[1] * plane_normal[1] + line_direction[2] * plane_normal[2])
	'print "t2 = ";(line_direction[0] * plane_normal[0] + line_direction[1] * plane_normal[1] + line_direction[2] * plane_normal[2])

	'# calculate the intersection point using the line equation
	intersection[0] = line_point[0] + t * line_direction[0]
	intersection[1] = line_point[1] + t * line_direction[1]
	intersection[2] = line_point[2] + t * line_direction[2]

'# check if the intersection point is on the plane
	plane_distance = abs((intersection[0] - plane_point_1[0]) * plane_normal[0] + (intersection[1] - plane_point_1[1]) * plane_normal[1] + (intersection[2] - plane_point_1[2]) * plane_normal[2])
	if plane_distance < 10^-6 then
		return True
	else
		return False
	end if
end function