Include Once

Include "Calamity3D/C3D_Mesh.bas"
Include "Calamity3D/C3D_Image.bas"
Include "Calamity3D/C3D_Sprite.bas"
Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/C3D_Utility.bas"
Include "Calamity3D/C3D_Window.bas"
Include "Calamity3D/C3D_Background.bas"

Dim c3d_vertex[ C3D_MAX_VERTICES, 8]
Dim c3d_index[ (C3D_MAX_VERTICES-3) * 3 + 3 + 12 ] 'After 3 vertices, every new vertex adds 3 indices

c3d_vi = 0
c3d_index_count = 0
c3d_vertex_count = 0

'Returns number of points in clipped triangle Or 0 if no clipping was done
Function C3D_ClipTriangle(ByRef tri, ByRef uv, ByRef clipped_tri, ByRef clipped_uv)
	
	clip_count = 0
	
	Dim lp[3], ld[3], p1[3], p2[3], p3[3], intersect[3]

	'vec(lp, 20, 30, 265)
	'vec(ld, 20 - lp[0], 20 - lp[1], 275 - lp[2])
	
	clip_dist = C3D_CAMERA_LENS-1

	vec3(p1, -1, -1, clip_dist)
	vec3(p2, 1, 1, clip_dist)
	vec3(p3, 1, -1, clip_dist)

	'C3D_LinePlaneIntersection(lp, ld, p1, p2, p3, intersect)
	
	Dim v1[3]
	Dim v2[3]
	Dim pt[9]
	Dim pt_uv[6]
	
	Dim nc[9]
	Dim nc_uv[6]
	non_clip_count = 0
	
	For i = 0 to 8 step 3
		If tri[i+2] >= clip_dist Then
			c_index = clip_count*3
			pt[c_index] = tri[i]
			pt[c_index+1] = tri[i+1]
			pt[c_index+2] = tri[i+2]
			
			pt_uv_index = clip_count*2
			uv_index = i/3*2
			pt_uv[pt_uv_index] = uv[uv_index]
			pt_uv[pt_uv_index+1] = uv[uv_index+1]
			
			clip_count = clip_count + 1
		Else
			c_index = non_clip_count*3
			nc[c_index] = tri[i]
			nc[c_index+1] = tri[i+1]
			nc[c_index+2] = tri[i+2]
			
			nc_uv_index = non_clip_count*2
			uv_index = i/3*2
			nc_uv[nc_uv_index] = uv[uv_index]
			nc_uv[nc_uv_index+1] = uv[uv_index+1]
			
			non_clip_count = non_clip_count + 1
		End If
	Next
	
	If clip_count = 0 Or clip_count = 3 Then
		Return 0
	End If
	
	Select Case clip_count
	Case 1
		vec3(lp, pt[0], pt[1], pt[2])
		
		vec3(ld, nc[0] - lp[0], nc[1] - lp[1], nc[2] - lp[2])
		C3D_LinePlaneIntersection(lp, ld, p1, p2, p3, intersect)
		
		'dim clipped_tri[3]
		
		AB_dist = C3D_Distance3D(pt[0], pt[1], pt[2], nc[0], nc[1], nc[2])
		AC_dist = C3D_Distance3D(pt[0], pt[1], pt[2], nc[3], nc[4], nc[5])
		
		'AB
		clipped_tri[0] = intersect[0]
		clipped_tri[1] = intersect[1]
		clipped_tri[2] = intersect[2]
		
		dist = C3D_Distance3D(pt[0], pt[1], pt[2], clipped_tri[0], clipped_tri[1], clipped_tri[2])
		clipped_uv[0] = C3D_Interpolate(0, AB_dist, dist, pt_uv[0], nc_uv[0])
		clipped_uv[1] = C3D_Interpolate(0, AB_dist, dist, pt_uv[1], nc_uv[1])
		
		'B
		clipped_tri[3] = nc[0]
		clipped_tri[4] = nc[1]
		clipped_tri[5] = nc[2]
		
		clipped_uv[2] = nc_uv[0]
		clipped_uv[3] = nc_uv[1]
		'print "TEST: ";clipped_uv[2];", ";clipped_uv[3]
		
		'C
		clipped_tri[6] = nc[3]
		clipped_tri[7] = nc[4]
		clipped_tri[8] = nc[5]
		
		clipped_uv[4] = nc_uv[2]
		clipped_uv[5] = nc_uv[3]
		
		'print "TEST(C): (";clipped_tri[6];", ";clipped_tri[7];", ";clipped_tri[8];") (";clipped_uv[4];", ";clipped_uv[5];")"
		
		'AB
		clipped_tri[9] = clipped_tri[0]
		clipped_tri[10] = clipped_tri[1]
		clipped_tri[11] = clipped_tri[2]
		
		clipped_uv[6] = clipped_uv[0]
		clipped_uv[7] = clipped_uv[1]
		
		'C
		clipped_tri[12] = nc[3]
		clipped_tri[13] = nc[4]
		clipped_tri[14] = nc[5]
		
		clipped_uv[8] = nc_uv[2]
		clipped_uv[9] = nc_uv[3]
		
		vec3(ld, nc[3] - lp[0], nc[4] - lp[1], nc[5] - lp[2])
		C3D_LinePlaneIntersection(lp, ld, p1, p2, p3, intersect)
		
		'AC
		clipped_tri[15] = intersect[0]
		clipped_tri[16] = intersect[1]
		clipped_tri[17] = intersect[2]
		
		dist = C3D_Distance3D(pt[0], pt[1], pt[2], clipped_tri[15], clipped_tri[16], clipped_tri[17])
		clipped_uv[10] = C3D_Interpolate(0, AC_dist, dist, pt_uv[0], nc_uv[2])
		clipped_uv[11] = C3D_Interpolate(0, AC_dist, dist, pt_uv[1], nc_uv[3])
		
		Return 6
	
	Case 2
		'A is the no clip
		vec3(lp, pt[0], pt[1], pt[2])
		
		vec3(ld, nc[0] - lp[0], nc[1] - lp[1], nc[2] - lp[2])
		C3D_LinePlaneIntersection(lp, ld, p1, p2, p3, intersect)
		
		AB_dist = C3D_Distance3D(pt[0], pt[1], pt[2], nc[0], nc[1], nc[2])
		AC_dist = C3D_Distance3D(pt[3], pt[4], pt[5], nc[0], nc[1], nc[2])
		
		'A
		clipped_tri[0] = nc[0]
		clipped_tri[1] = nc[1]
		clipped_tri[2] = nc[2]
		
		clipped_uv[0] = nc_uv[0]
		clipped_uv[1] = nc_uv[1]
		
		'AB
		clipped_tri[3] = intersect[0]
		clipped_tri[4] = intersect[1]
		clipped_tri[5] = intersect[2]
		
		dist = C3D_Distance3D(nc[0], nc[1], nc[2], clipped_tri[3], clipped_tri[4], clipped_tri[5])
		clipped_uv[2] = C3D_Interpolate(0, AB_dist, dist, nc_uv[0], pt_uv[0])
		clipped_uv[3] = C3D_Interpolate(0, AB_dist, dist, nc_uv[1], pt_uv[1])
		
		'AC
		vec3(lp, pt[3], pt[4], pt[5])
		vec3(ld, nc[0] - lp[0], nc[1] - lp[1], nc[2] - lp[2])
		
		C3D_LinePlaneIntersection(lp, ld, p1, p2, p3, intersect)
		
		clipped_tri[6] = intersect[0]
		clipped_tri[7] = intersect[1]
		clipped_tri[8] = intersect[2]
		
		dist = C3D_Distance3D(nc[0], nc[1], nc[2], clipped_tri[6], clipped_tri[7], clipped_tri[8])
		clipped_uv[4] = C3D_Interpolate(0, AC_dist, dist, nc_uv[0], pt_uv[2])
		clipped_uv[5] = C3D_Interpolate(0, AC_dist, dist, nc_uv[1], pt_uv[3])
		Return 3
	End Select

	Return 0

End Function


Sub C3D_DrawMeshFace(actor, face)
	If Not C3D_Actor_Visible[actor] then
		Return
	End If
	
	mesh = C3D_Actor_Source[actor]
	
	f_vertex_count = C3D_Mesh_Face_Vertex_Count[mesh, face]
	
	if f_vertex_count > 4 Then
		Return
	end if
	
	'c3d_vertex_count = c3d_vertex_count + f_vertex_count
	
	texture = C3D_Mesh_Texture[mesh]
	div = C3D_Image_TM_Div[texture, 0]
	div_row = C3D_Image_TM_Div[texture, 1]
	div_col = C3D_Image_TM_Div[texture, 2]
	
	uv_x = C3D_TEXTURE_MAP_DIV_UV_X[div, div_row, div_col]
	uv_y = C3D_TEXTURE_MAP_DIV_UV_Y[div, div_row, div_col]
	uv_w = C3D_TEXTURE_MAP_DIV_UV_WIDTH[div]
	uv_h = C3D_TEXTURE_MAP_DIV_UV_HEIGHT[div]
	
	Dim tri[12], uv[8], clipped_tri[18], clipped_uv[12]
	tri_index = 0
	uv_index = 0
	
	vi_zero = c3d_vi
	
	'vert_added = 0
	'Convert 3D coordinates into 2D screen location
	For i = 0 to f_vertex_count-1
		vert_num = C3D_Mesh_Face_Vertex[mesh, face, i] 'vertex number will be the same between Mesh and Actor Arrays
		
		vec3(tri[tri_index], MatrixValue(C3D_Actor_Matrix[actor, 0], 0, vert_num), MatrixValue(C3D_Actor_Matrix[actor, 0], 1, vert_num), MatrixValue(C3D_Actor_Matrix[actor, 0], 2, vert_num))
		vec2(uv[uv_index], uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]), uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]))
		tri_index = tri_index + 3
		uv_index = uv_index + 2
	Next
	
	Select Case f_vertex_count
	Case 3
		clip = C3D_ClipTriangle(tri, uv, clipped_tri, clipped_uv)
		If clip Then
			tri_index = 0
			uv_index = 0
			For i = 0 to clip-1
				distance = C3D_CAMERA_LENS - clipped_tri[tri_index+2]
				C3D_Ternary(distance<=0, distance, 1, distance)
				c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * clipped_tri[tri_index] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
				c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * clipped_tri[tri_index+1] / distance)
				c3d_vertex[ c3d_vi, 2 ] = 255
				c3d_vertex[ c3d_vi, 3 ] = 255
				c3d_vertex[ c3d_vi, 4 ] = 255
				c3d_vertex[ c3d_vi, 5 ] = 255
				c3d_vertex[ c3d_vi, 6 ] = clipped_uv[uv_index] ' uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
				c3d_vertex[ c3d_vi, 7 ] = clipped_uv[uv_index+1] 'uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
				
				actor_distance[ actor ] = min(distance, actor_distance[ actor ])
				actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
				actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
				actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
				actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
				
				c3d_index[c3d_index_count] = c3d_vi
				c3d_index_count = c3d_index_count + 1
				c3d_vi = c3d_vi + 1
				tri_index = tri_index + 3
				uv_index = uv_index + 2
			Next
		Else
			tri_index = 0
			uv_index = 0
			For i = 0 to 2
				distance = C3D_CAMERA_LENS - tri[tri_index+2]
				C3D_Ternary(distance<=0, distance, 1, distance)
				c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * tri[tri_index] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
				c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * tri[tri_index+1] / distance)
				c3d_vertex[ c3d_vi, 2 ] = 255
				c3d_vertex[ c3d_vi, 3 ] = 255
				c3d_vertex[ c3d_vi, 4 ] = 255
				c3d_vertex[ c3d_vi, 5 ] = 255
				c3d_vertex[ c3d_vi, 6 ] = uv[uv_index] ' uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
				c3d_vertex[ c3d_vi, 7 ] = uv[uv_index+1] 'uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
				
				actor_distance[ actor ] = min(distance, actor_distance[ actor ])
				actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
				actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
				actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
				actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
				
				c3d_vi = c3d_vi + 1
				tri_index = tri_index + 3
				uv_index = uv_index + 2
			Next
			
			A = vi_zero
			B = vi_zero+1
			C = vi_zero+2
			
			c3d_index[c3d_index_count] = A
			c3d_index[c3d_index_count+1] = B
			c3d_index[c3d_index_count+2] = C
			c3d_index_count = c3d_index_count + 3
		End If
		
	Case 4
		clip = C3D_ClipTriangle(tri, uv, clipped_tri, clipped_uv)
		If clip Then
			tri_index = 0
			uv_index = 0
			For i = 0 to clip-1
				distance = C3D_CAMERA_LENS - clipped_tri[tri_index+2]
				C3D_Ternary(distance<=0, distance, 1, distance)
				c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * clipped_tri[tri_index] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
				c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * clipped_tri[tri_index+1] / distance)
				c3d_vertex[ c3d_vi, 2 ] = 255
				c3d_vertex[ c3d_vi, 3 ] = 255
				c3d_vertex[ c3d_vi, 4 ] = 255
				c3d_vertex[ c3d_vi, 5 ] = 255
				c3d_vertex[ c3d_vi, 6 ] = clipped_uv[uv_index] ' uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
				c3d_vertex[ c3d_vi, 7 ] = clipped_uv[uv_index+1] 'uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
				
				actor_distance[ actor ] = min(distance, actor_distance[ actor ])
				actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
				actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
				actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
				actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
				
				c3d_index[c3d_index_count] = c3d_vi
				c3d_index_count = c3d_index_count + 1
				c3d_vi = c3d_vi + 1
				tri_index = tri_index + 3
				uv_index = uv_index + 2
			Next
		Else
			tri_index = 0
			uv_index = 0
			For i = 0 to 2
				distance = C3D_CAMERA_LENS - tri[tri_index+2]
				C3D_Ternary(distance<=0, distance, 1, distance)
				c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * tri[tri_index] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
				c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * tri[tri_index+1] / distance)
				c3d_vertex[ c3d_vi, 2 ] = 255
				c3d_vertex[ c3d_vi, 3 ] = 255
				c3d_vertex[ c3d_vi, 4 ] = 255
				c3d_vertex[ c3d_vi, 5 ] = 255
				c3d_vertex[ c3d_vi, 6 ] = uv[uv_index] ' uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
				c3d_vertex[ c3d_vi, 7 ] = uv[uv_index+1] 'uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
				
				actor_distance[ actor ] = min(distance, actor_distance[ actor ])
				actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
				actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
				actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
				actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
				
				c3d_vi = c3d_vi + 1
				tri_index = tri_index + 3
				uv_index = uv_index + 2
			Next
			
			A = vi_zero
			B = vi_zero+1
			C = vi_zero+2
			
			c3d_index[c3d_index_count] = A
			c3d_index[c3d_index_count+1] = B
			c3d_index[c3d_index_count+2] = C
			c3d_index_count = c3d_index_count + 3
		End If
		
		vec3(tri[3], tri[0], tri[1], tri[2])
		vec2(uv[2], uv[0], uv[1])
		clip = C3D_ClipTriangle(tri[3], uv[2], clipped_tri, clipped_uv)
		
		If clip Then
			tri_index = 0
			uv_index = 0
			For i = 0 to clip-1
				distance = C3D_CAMERA_LENS - clipped_tri[tri_index+2]
				C3D_Ternary(distance<=0, distance, 1, distance)
				c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * clipped_tri[tri_index] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
				c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * clipped_tri[tri_index+1] / distance)
				c3d_vertex[ c3d_vi, 2 ] = 255
				c3d_vertex[ c3d_vi, 3 ] = 255
				c3d_vertex[ c3d_vi, 4 ] = 255
				c3d_vertex[ c3d_vi, 5 ] = 255
				c3d_vertex[ c3d_vi, 6 ] = clipped_uv[uv_index] ' uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
				c3d_vertex[ c3d_vi, 7 ] = clipped_uv[uv_index+1] 'uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
				
				actor_distance[ actor ] = min(distance, actor_distance[ actor ])
				actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
				actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
				actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
				actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
				
				c3d_index[c3d_index_count] = c3d_vi
				c3d_index_count = c3d_index_count + 1
				
				c3d_vi = c3d_vi + 1
				
				tri_index = tri_index + 3
				uv_index = uv_index + 2
			Next
		Else
			tri_index = 3
			uv_index = 2
			For i = 0 to 2
				distance = C3D_CAMERA_LENS - tri[tri_index+2]
				C3D_Ternary(distance<=0, distance, 1, distance)
				c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * tri[tri_index] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
				c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * tri[tri_index+1] / distance)
				c3d_vertex[ c3d_vi, 2 ] = 255
				c3d_vertex[ c3d_vi, 3 ] = 255
				c3d_vertex[ c3d_vi, 4 ] = 255
				c3d_vertex[ c3d_vi, 5 ] = 255
				c3d_vertex[ c3d_vi, 6 ] = uv[uv_index] ' uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
				c3d_vertex[ c3d_vi, 7 ] = uv[uv_index+1] 'uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
				
				actor_distance[ actor ] = min(distance, actor_distance[ actor ])
				actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
				actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
				actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
				actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
				
				c3d_index[c3d_index_count] = c3d_vi 'They will already be in the right order here
				c3d_index_count = c3d_index_count + 1
				c3d_vi = c3d_vi + 1
				tri_index = tri_index + 3
				uv_index = uv_index + 2
			Next
			
		End If
		
	End Select
		
'		z = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, vert_num)
'		distance = C3D_CAMERA_LENS - z
'		
'			
'		if distance < 0 Then
'			cd = 2
'			cx = (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 0, vert_num) / cd) + C3D_SCREEN_GRAPH_OFFSET_X
'			cy = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 1, vert_num) / cd)
'			dd = 1
'			dx = (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 0, vert_num) / dd) + C3D_SCREEN_GRAPH_OFFSET_X
'			dy = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 1, vert_num) / dd)
'			point_on_line(cx, cy, dx, dy, 2 - distance, c3d_vertex[ c3d_vi, 0 ], c3d_vertex[ c3d_vi, 1 ])
'		
'		else
'			C3D_Ternary(distance=0, distance, 1, distance)
'			c3d_vertex[ c3d_vi, 0 ] = (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 0, vert_num) / distance) + C3D_SCREEN_GRAPH_OFFSET_X
'			c3d_vertex[ c3d_vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 1, vert_num) / distance)
'			
'			actor_distance[ actor ] = min(distance, actor_distance[ actor ])
'			actor_min_screen_x[ actor ] = min(c3d_vertex[ c3d_vi, 0], actor_min_screen_x[ actor ])
'			actor_min_screen_y[ actor ] = min(c3d_vertex[ c3d_vi, 1], actor_min_screen_y[ actor ])
'			actor_max_screen_x[ actor ] = max(c3d_vertex[ c3d_vi, 0], actor_max_screen_x[ actor ])
'			actor_max_screen_y[ actor ] = max(c3d_vertex[ c3d_vi, 1], actor_max_screen_y[ actor ])
'		end if
'		c3d_vertex[ c3d_vi, 2 ] = 255
'		c3d_vertex[ c3d_vi, 3 ] = 255
'		c3d_vertex[ c3d_vi, 4 ] = 255
'		c3d_vertex[ c3d_vi, 5 ] = 255
'		c3d_vertex[ c3d_vi, 6 ] = uv_x + (uv_w * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0]) 'u
'		c3d_vertex[ c3d_vi, 7 ] = uv_y + (uv_h * C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1]) 'v
'		
'		
'		If f_vertex_count > 3 Then
'			If i >= 2 Then
'				c3d_index[c3d_index_count] = vi_zero
'				c3d_index[c3d_index_count+1] = c3d_vi-1
'				c3d_index[c3d_index_count+2] = c3d_vi
'				c3d_index_count = c3d_index_count + 3
'			End If
'		Else
'			c3d_index[c3d_index_count] = c3d_vi
'			c3d_index_count = c3d_index_count + 1
'		End If
'		c3d_vi = c3d_vi + 1
'	Next
End Sub


C3D_RENDER_TYPE_NONE = 0
C3D_RENDER_TYPE_WIREFRAME = 1
C3D_RENDER_TYPE_SOLID = 2
C3D_RENDER_TYPE_TEXTURED = 3

C3D_Render_Type = C3D_RENDER_TYPE_TEXTURED



Sub C3D_SetRenderType(render_type)
	Select Case render_type
	Case C3D_RENDER_TYPE_WIREFRAME
		C3D_Render_Type = C3D_RENDER_TYPE_WIREFRAME
	Case C3D_RENDER_TYPE_SOLID
		C3D_Render_Type = C3D_RENDER_TYPE_SOLID
	Case C3D_RENDER_TYPE_TEXTURED
		C3D_Render_Type = C3D_RENDER_TYPE_TEXTURED
	Default
		C3D_Render_Type = C3D_RENDER_TYPE_NONE
	End Select
End Sub

Function C3D_GetRenderType()
	Return C3D_Render_Type
End Function

sub sort(ByRef arr, n)
	For i = 0 to n-1
		For j = i to n-1
			If arr[j] < arr[i] Then
				Push_N(arr[i])
				arr[i] = arr[j]
				arr[j] = Pop_N()
			End If
		Next
	Next			
end sub

sub sortJoinColumn(ByRef arr1, ByRef arr2, c, n_items, d2)
	MAX_I = (c*d2+n_items)-1
	Dim tmp
	For i = (c*d2) to MAX_I
		'print "n = ";arr[i]
		For j = i to MAX_I
			If arr1[j] < arr1[i] Then
				tmp = arr1[i]
				arr1[i] = arr1[j]
				arr1[j] = tmp
				
				tmp = arr2[i]
				arr2[i] = arr2[j]
				arr2[j] = tmp
				
			End If
		Next
	Next			
end sub

C3D_Rendered_Faces_Count = 0

dbg = 0

Sub C3D_RenderScene()
	
	ArrayFill(actor_distance, 9999)
	ArrayFill(actor_min_screen_x, 9999)
	ArrayFill(actor_min_screen_y, 9999)
	ArrayFill(actor_max_screen_x, -1)
	ArrayFill(actor_max_screen_y, -1)
	
	ArrayFill(C3D_Actor_Collisions, 0)
	ArrayFill(C3D_Stage_Geometry_Actor_Collisions, 0)
	ArrayFill(C3D_Actor_InViewRange, False)
	
	cam_x = C3D_Camera_Position[0]
	cam_y = C3D_Camera_Position[1]
	cam_z = C3D_Camera_Position[2]
	
	C3D_inZone_Actors_Count = 0
	
	For i = 0 to C3D_MAX_ACTORS-1
		If Not C3D_Actor_Active[i] then
			continue
		End if
		
		x = C3D_Actor_Position[i,0]
		y = C3D_Actor_Position[i,1]
		z = C3D_Actor_Position[i,2]
		
		If C3D_Distance3D(cam_x, cam_y, cam_z, x, y, z) <= C3D_MAX_Z_DEPTH Then
			C3D_inZone_Actors[C3D_inZone_Actors_Count] = i
			C3D_inZone_Actors_Count = C3D_inZone_Actors_Count + 1
		End If
	Next
		
	ArrayFill(C3D_Actor_Stage_Collision_Count, 0)
	
	For i = 0 to C3D_inZone_Actors_Count - 1
		setCollisionData(C3D_inZone_Actors[i])
	Next
	
	C3D_ComputeTransforms()
	C3D_ComputeVisibleFaces()
	
	C3D_Rendered_Faces_Count = 0
	
	c3d_vi = 0
	c3d_index_count = 0
	c3d_vertex_count = 0
	
	For z = (C3D_MAX_Z_DEPTH-1) to 1 step -1
		If C3D_ZSort_Faces_Count[z] > 0 Then
			sortJoinColumn(C3D_ZSort_Faces_Distance, C3D_ZSort_Faces, z, C3D_ZSort_Faces_Count[z], C3D_MAX_SCENE_FACES)
			For i = 0 to C3D_ZSort_Faces_Count[z]-1
				visible_face_index = C3D_ZSort_Faces[z, i]
				actor = C3D_Visible_Faces[visible_face_index, 0]
				
				If Not C3D_Actor_InViewRange[actor] Then
					Continue
				End If
				
				face = C3D_Visible_Faces[visible_face_index, 1]
				face_type = C3D_Visible_Faces_Type[visible_face_index]
				
				Select Case face_type
				Case C3D_ACTOR_TYPE_MESH
					'Draw Face
					C3D_DrawMeshFace(actor, face)
					C3D_Rendered_Faces_Count = C3D_Rendered_Faces_Count + 1
				Case C3D_ACTOR_TYPE_SPRITE
					'Do nothing for now
					C3D_DrawMeshFace(actor, face)
					C3D_Rendered_Faces_Count = C3D_Rendered_Faces_Count + 1
				End Select
			Next
		End If
	Next
	
	if C3D_Render_Type = C3D_RENDER_TYPE_WIREFRAME then
		if c3d_index_count > 0 then
			Canvas(C3D_CANVAS_RENDER)
			SetClearColor(0)
			ClearCanvas
			SetColor(RGB(255,255,255))
			for a = 0 to c3d_index_count-1 step 3
				'Print index[a]
				Line(c3d_vertex[c3d_index[a], 0], c3d_vertex[c3d_index[a], 1], c3d_vertex[c3d_index[a+1], 0], c3d_vertex[c3d_index[a+1], 1])
				Line(c3d_vertex[c3d_index[a+1], 0], c3d_vertex[c3d_index[a+1], 1], c3d_vertex[c3d_index[a+2], 0], c3d_vertex[c3d_index[a+2], 1])
				Line(c3d_vertex[c3d_index[a+2], 0], c3d_vertex[c3d_index[a+2], 1], c3d_vertex[c3d_index[a], 0], c3d_vertex[c3d_index[a], 1])
			Next
		end if
		return
	end if
	
	If c3d_index_count < 3 Then
		Canvas(C3D_CANVAS_RENDER)
		setclearcolor(RGB(153,217,234))
		ClearCanvas()
		C3D_RenderBackground()
		Return
	End If
	
	Canvas(C3D_CANVAS_BACKBUFFER)
	ClearCanvas()
	
	Dim w, h
	
	For div = 0 to C3D_MAX_TEXTURE_MAP_DIV-1
		w = C3D_TEXTURE_MAP_DIV_WIDTH[div]
		h = C3D_TEXTURE_MAP_DIV_HEIGHT[div]
		For r = 0 to 3
			For c = 0 to 3
				texture = C3D_TEXTURE_MAP_DIV_IMAGES[div, r, c]
				If texture <> -1 Then			
					x = C3D_TEXTURE_MAP_DIV_POS_X[div, r, c]
					y = C3D_TEXTURE_MAP_DIV_POS_Y[div, r, c]
					src_w = C3D_Image_Width[texture]
					src_h = C3D_Image_Height[texture]
					DrawImage_Blit_Ex(texture, x, y, w, h, 0, 0, src_w, src_h)
				End If
			Next 'c
		Next 'r
	Next 'div
	
	If ImageExists(C3D_TEXTURE_MAP) Then
		DeleteImage(C3D_TEXTURE_MAP)
	End If
	
	CanvasClip(C3D_TEXTURE_MAP, 0, 0, C3D_TEXTURE_MAP_WIDTH, C3D_TEXTURE_MAP_HEIGHT, 1)
	
	Canvas(C3D_CANVAS_RENDER)
	SetClearColor(C3D_CLEAR_COLOR)
	'setclearcolor(RGB(153,217,234))
	ClearCanvas()
	
	C3D_RenderBackground()
	
	'drawimage_blit_ex(C3D_TEXTURE_MAP, 0, 0, 128, 128, 0, 0, 512, 512)
	'DrawImage_Blit_Ex(C3D_TEXTURE_MAP, 0, 0, 640, 480, 0, 0, C3D_TEXTURE_MAP_WIDTH, C3D_TEXTURE_MAP_HEIGHT)
	DrawGeometry(C3D_TEXTURE_MAP, c3d_vi, c3d_vertex, c3d_index_count, c3d_index)
	
End Sub
