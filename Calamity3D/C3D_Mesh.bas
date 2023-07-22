Include Once
Include "Calamity3D/C3D_Image.bas"
Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/strings.bas"
Include "Calamity3D/C3D_Utility.bas"
Include "Calamity3D/C3D_Matrix.bas"

C3D_MAX_MESH = 100
C3D_MAX_VERTICES = 5000
C3D_MAX_FACES = 4000

C3D_MAX_CUTS = C3D_MAX_MESH - 1

Dim C3D_Mesh_Active[C3D_MAX_MESH]
Dim C3D_Mesh_Parent[C3D_MAX_MESH]

Dim C3D_Mesh_HDMesh[C3D_MAX_MESH]
Dim C3D_Mesh_HD_Distance[C3D_MAX_MESH]

Dim C3D_Mesh_TMP_Vertex[C3D_MAX_VERTICES, 4] 'x, y, z, w = 1.0
Dim C3D_Mesh_Vertex_Matrix[C3D_MAX_MESH] 'x, y, and z
Dim C3D_Mesh_Vertex_Count[C3D_MAX_MESH]

Dim C3D_Mesh_Origin[C3D_MAX_MESH, 3]

Dim C3D_Mesh_TCoord[C3D_MAX_MESH, C3D_MAX_VERTICES, 2] 'u and v
Dim C3D_Mesh_TCoord_Count[C3D_MAX_MESH]

Dim C3D_Mesh_Face_Vertex[C3D_MAX_MESH, C3D_MAX_FACES, 4] 'references a point in C3D_Mesh_Vertex
Dim C3D_Mesh_Face_TCoord[C3D_MAX_MESH, C3D_MAX_FACES, 4] 'references a point in C3D_Mesh_TCoord
Dim C3D_Mesh_Face_Div_TCoord[C3D_MAX_MESH, C3D_MAX_FACES, 4]
Dim C3D_Mesh_Face_Vertex_Count[C3D_MAX_MESH, C3D_MAX_FACES]
Dim C3D_Mesh_Face_TCoord_Count[C3D_MAX_MESH, C3D_MAX_FACES]
Dim C3D_Mesh_Face_Count[C3D_MAX_MESH]

Dim C3D_Mesh_HasCollisionMesh[C3D_MAX_MESH]
Dim C3D_Mesh_CollisionMesh[C3D_MAX_MESH]

Dim C3D_Mesh_Texture[C3D_MAX_MESH] 'references an index in C3D_Images
Dim C3D_Mesh_Texture_Div_Parameters[C3D_MAX_MESH, 3] '0 - DIV, 1 - ROW, 2 - COL
Dim C3D_Mesh_Texture_Div_Set[C3D_MAX_MESH]

Dim C3D_Mesh_Radius[C3D_MAX_MESH] 'Used to determine if actor should be transformed
Dim C3D_Mesh_MinX[C3D_MAX_MESH]
Dim C3D_Mesh_MinZ[C3D_MAX_MESH]
Dim C3D_Mesh_MaxX[C3D_MAX_MESH]
Dim C3D_Mesh_MaxZ[C3D_MAX_MESH]

Dim C3D_Mesh_Cuts[C3D_MAX_CUTS]
Dim C3D_Mesh_Cut_Count

Function C3D_GetVector(vector_size, vector_string$, delimeter$, ByRef vector_out)
	Dim v[3]
	v[0] = 0
	v[1] = 0
	v[2] = 0
	
	
	vector_string$ = Trim$(vector_string$) + delimeter$
	
	arg$ = ""
	arg_num = 0
	
	For i = 0 to Len(vector_string$)-1
		c$ = Mid(vector_string$, i, 1)
		
		If c$ = delimeter$ Then
			v[arg_num] = Val(arg$)
			arg_num = arg_num + 1
			
			If arg_num = vector_size Then
				Exit For
			End If
			
			arg$ = ""
		Else
			arg$ = arg$ + c$
		End If
		
	Next
	
	For i = 0 to vector_size-1
		vector_out[i] = v[i]
	Next
	
	Return arg_num
End Function

Function C3D_CreateMesh()
	For i = 0 to C3D_MAX_MESH-1
		If Not C3D_Mesh_Active[i] Then
			C3D_Mesh_Active[i] = True
			C3D_Mesh_Vertex_Matrix[i] = C3D_CreateMatrix(2,2)
			C3D_Mesh_Vertex_Count[i] = 0
			C3D_Mesh_TCoord_Count[i] = 0
			C3D_Mesh_Face_Count[i] = 0
			C3D_Mesh_Texture[i] = 0
			C3D_Mesh_HasCollisionMesh[i] = False
			C3D_Mesh_MinX[i] = 0
			C3D_Mesh_MinZ[i] = 0
			C3D_Mesh_HDMesh[i] = -1
			C3D_Mesh_HD_Distance[i] = -C3D_CAMERA_LENS
			return i
		End If
	Next
	return -1
End Function

Sub C3D_DeleteMesh(mesh)
	If mesh >= 0 And mesh < C3D_MAX_MESH Then
		C3D_Mesh_Active[mesh] = False
	End If
End Sub

Sub C3D_SetHDMesh(mesh, hd_mesh)
	C3D_Mesh_HDMesh[mesh] = hd_mesh
End Sub

Sub C3D_SetMeshHDDistance(mesh, distance)
	C3D_Mesh_HD_Distance[mesh] = distance
End Sub

Sub C3D_ScaleMesh(mesh, scale)
	ScalarMatrix(C3D_Mesh_Vertex_Matrix[mesh], C3D_Mesh_Vertex_Matrix[mesh], scale)
	C3D_Mesh_Radius[mesh] = C3D_Mesh_Radius[mesh] * scale
	C3D_Mesh_MinX[mesh] = C3D_Mesh_MinX[mesh] * scale
	C3D_Mesh_MinZ[mesh] = C3D_Mesh_MinZ[mesh] * scale
	C3D_Mesh_MaxX[mesh] = C3D_Mesh_MaxX[mesh] * scale
	C3D_Mesh_MaxZ[mesh] = C3D_Mesh_MaxZ[mesh] * scale
End Sub

Sub C3D_GetMeshCuts(ByRef buffer)
	For i = 0 to C3D_Mesh_Cut_Count-1
		buffer[i] = C3D_Mesh_Cuts[i]
	Next
End Sub


Function C3D_CutMesh(mesh, cell_size)
	
	v_offset = 0
	t_offset = 0
	set_offset = false
	'Print "MESH LOAD"
	
	C3D_Mesh_Cut_Count = 0
	
	width = Abs(C3D_Mesh_MaxX[mesh] - C3D_Mesh_MinX[mesh])
	depth = Abs(C3D_Mesh_MaxZ[mesh] - C3D_Mesh_MinZ[mesh])
	
	rows = int(width/cell_size)+1
	cols = int(depth/cell_size)+1
	
	Dim mesh_face_remap[C3D_MAX_FACES]
	Dim mesh_vertex_remap[C3D_MAX_VERTICES]
	
	face_remap_count = 0
	vertex_remap_count = 0
	
	ArrayFill(mesh_face_remap, false)
	
	Dim cell[rows*cols]
	Dim vx[4], vy[4], vz[4], vi[4], tu[4], tv[4]
	
	ci = 0
	
	num_cuts = 0
	
	'print "W/h = ";width;", ";depth
	
	Dim min_x, min_y, min_z
	Dim max_x, max_y, max_z
	
	For cx = C3D_Mesh_MinX[mesh] to (C3D_Mesh_MinX[mesh] + width) Step cell_size
	For cz = C3D_Mesh_MinZ[mesh] to (C3D_Mesh_MinZ[mesh] + depth) Step cell_size
		'Print "CXZ = "; cx;", ";cz
		
		cell[ci] = C3D_CreateMesh()
		
		ArrayFill(mesh_vertex_remap, -1)
		
		min_x = 9999999
		min_y = 9999999
		min_z = 9999999
		
		max_x = -9999999
		max_y = -9999999
		max_z = -9999999
		
		
		For face = 0 to C3D_Mesh_Face_Count[mesh]-1
			store_face = false
		
			For vertex = 0 to C3D_Mesh_Face_Vertex_Count[mesh, face]-1 'Vertex and TCoord count will be the same
			
				vx[vertex] = MatrixValue(C3D_Mesh_Vertex_Matrix[mesh], 0, C3D_Mesh_Face_Vertex[mesh, face, vertex])
				vy[vertex] = MatrixValue(C3D_Mesh_Vertex_Matrix[mesh], 1, C3D_Mesh_Face_Vertex[mesh, face, vertex])
				vz[vertex] = MatrixValue(C3D_Mesh_Vertex_Matrix[mesh], 2, C3D_Mesh_Face_Vertex[mesh, face, vertex])
				vi[vertex] = C3D_Mesh_Face_Vertex[mesh, face, vertex]
				
				tu[vertex] = C3D_Mesh_TCoord[mesh, vi[vertex], 0]
				tv[vertex] = C3D_Mesh_TCoord[mesh, vi[vertex], 1]
				
				If vx[vertex] < (cx + cell_size) And vz[vertex] < (cz + cell_size) Then
					store_face = true
				End If
				
			Next
			
			If store_face And (Not mesh_face_remap[face]) Then
				mesh_face_remap[face] = true
				
				c_mesh = cell[ci]
				mesh_face_num = C3D_Mesh_Face_Count[c_mesh]
				C3D_Mesh_Face_Count[c_mesh] = C3D_Mesh_Face_Count[c_mesh] + 1
				
				mesh_vert_num = C3D_Mesh_Vertex_Count[c_mesh]
				
				
				C3D_Mesh_Face_Vertex_Count[c_mesh, mesh_face_num] = C3D_Mesh_Face_Vertex_Count[mesh, face]
				
				
				For i = 0 to C3D_Mesh_Face_Vertex_Count[mesh, face]-1
					If mesh_vertex_remap[vi[i]] >= 0 Then
						C3D_Mesh_Face_Vertex[c_mesh, mesh_face_num, i] = mesh_vertex_remap[vi[i]]
						C3D_Mesh_Face_TCoord[c_mesh, mesh_face_num, i] = mesh_vertex_remap[vi[i]]
					Else
						mesh_vert_num = C3D_Mesh_Vertex_Count[c_mesh]
						
						C3D_Mesh_TMP_Vertex[mesh_vert_num, 0] = vx[i]
						C3D_Mesh_TMP_Vertex[mesh_vert_num, 1] = vy[i]
						C3D_Mesh_TMP_Vertex[mesh_vert_num, 2] = vz[i]
						C3D_Mesh_TMP_Vertex[mesh_vert_num, 3] = 1.0
						
						
						
						min_x = Min(min_x, vx[i])
						min_y = Min(min_y, vy[i])
						min_z = Min(min_z, vz[i])
						
						max_x = Max(max_x, vx[i])
						max_y = Max(max_y, vy[i])
						max_z = Max(max_z, vz[i])
						
						
						C3D_Mesh_TCoord[c_mesh, mesh_vert_num, 0] = tu[i]
						C3D_Mesh_TCoord[c_mesh, mesh_vert_num, 1] = tv[i]
						
						mesh_vertex_remap[vi[i]] = mesh_vert_num
						
						C3D_Mesh_Face_Vertex[c_mesh, mesh_face_num, i] = C3D_Mesh_Vertex_Count[c_mesh]
						C3D_Mesh_Face_TCoord[c_mesh, mesh_face_num, i] = C3D_Mesh_TCoord_Count[c_mesh]
						
						C3D_Mesh_TCoord_Count[c_mesh] = C3D_Mesh_TCoord_Count[c_mesh] + 1
						C3D_Mesh_Vertex_Count[c_mesh] = C3D_Mesh_Vertex_Count[c_mesh] + 1
					End If
				Next
				
			End If
			
		Next
		
		c_mesh = cell[ci]
		
		If C3D_Mesh_Vertex_Count[c_mesh] <= 0 Then
			C3D_Mesh_Active[c_mesh] = False
			'Print "false: "; ci
		Else
			'Print "Count = "; C3D_Mesh_Vertex_Count[c_mesh]
			C3D_Mesh_Cuts[num_cuts] = cell[ci]
			tmp_matrix = C3D_CreateMatrix(2,2)
			MatrixFromBuffer(tmp_matrix, C3D_Mesh_Vertex_Count[c_mesh], 4, C3D_Mesh_TMP_Vertex)
			TransposeMatrix(tmp_matrix, C3D_Mesh_Vertex_Matrix[c_mesh])
			C3D_DeleteMatrix(tmp_matrix)
			
			C3D_Mesh_Parent[c_mesh] = mesh
			
			C3D_Mesh_Origin[c_mesh, 0] = (min_x + max_x)/2
			C3D_Mesh_Origin[c_mesh, 1] = (min_y + max_y)/2
			C3D_Mesh_Origin[c_mesh, 2] = (min_z + max_z)/2
			
			C3D_Mesh_MinX[c_mesh] = min_x
			C3D_Mesh_MinZ[c_mesh] = min_z
			
			C3D_Mesh_MaxX[c_mesh] = max_x
			C3D_Mesh_MaxZ[c_mesh] = max_z
			
			r = abs(max_x - min_x)
			r = Max(r, abs(max_y - min_y))
			r = Max(r, abs(max_z - min_z))
			
			C3D_Mesh_Radius[c_mesh] = r+1
			
			ci = ci + 1
			num_cuts = num_cuts + 1
		End If
		
		If num_cuts >= C3D_MAX_CUTS Then
			C3D_Mesh_Cut_Count = num_cuts
			return num_cuts
		End If
	
	Next
	Next
	
	C3D_Mesh_Cut_Count = num_cuts
	Return num_cuts
End Function



Function C3D_LoadMesh(obj_file$)
	f = FreeFile
	
	If Not FileOpen(f, obj_file$, TEXT_INPUT) Then
		Return -1
	End If
	
	mesh_num = C3D_CreateMesh()
	
	If mesh_num = -1 Then
		FileClose(f)
		Return -1
	End If
	
	C3D_Mesh_HasCollisionMesh[mesh_num] = False
	
	Dim min_x, min_y, min_z, max_x, max_y, max_z, min_max_init
	
	min_max_init = False
	
	
	v_offset = 0
	t_offset = 0
	set_offset = false
	'Print "MESH LOAD"
	While Not EOF(f)
		f_line$ = ReadLine$(f)
		
		line_type$ = Left(f_line$, FindFirstOf(" ", f_line$))
		
		Select Case line_type$
		Case "v"
			
			if set_offset then
				v_offset = v_offset + C3D_Mesh_Vertex_Count[mesh_num]
				t_offset = t_offset + C3D_Mesh_TCoord_Count[mesh_num]
				set_offset = false
			end if
			
			Dim vec[3]
			v_count = C3D_GetVector(3, Replace(f_line$, "v", ""), " ", vec)
			mesh_vert_num = C3D_Mesh_Vertex_Count[mesh_num]
			C3D_Mesh_TMP_Vertex[mesh_vert_num, 0] = vec[0]
			C3D_Mesh_TMP_Vertex[mesh_vert_num, 1] = vec[1]
			C3D_Mesh_TMP_Vertex[mesh_vert_num, 2] = vec[2]
			C3D_Mesh_TMP_Vertex[mesh_vert_num, 3] = 1.0
			C3D_Mesh_Vertex_Count[mesh_num] = mesh_vert_num + 1
			
			
			If Not min_max_init Then
				min_max_init = True
				min_x = vec[0]
				min_y = vec[1]
				min_z = vec[2]
				max_x = vec[0]
				max_y = vec[1]
				max_z = vec[2]
			Else
				min_x = Min(min_x, vec[0])
				min_y = Min(min_y, vec[1])
				min_z = Min(min_z, vec[2])
				max_x = Max(max_x, vec[0])
				max_y = Max(max_y, vec[1])
				max_z = Max(max_z, vec[2])
			End If
			'Print "Vertex["; v_count ;"]  "; vec[0]; ", "; vec[1]; ", "; vec[2]
		Case "vt"
			Dim tc[2]
			t_count = C3D_GetVector(2, Replace(f_line$, "vt", ""), " ", tc)
			mesh_tc_num = C3D_Mesh_TCoord_Count[mesh_num]
			C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 0] = tc[0]
			C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 1] = 1-tc[1]
			C3D_Mesh_TCoord_Count[mesh_num] = mesh_tc_num + 1
			'Print "TexCoord: ";  tc[0]; ", "; tc[1]
			
		Case "f"
			Dim face$[32]
			f_count = Split(Replace(f_line$, "f", ""), " ", face)
			mesh_face_num = C3D_Mesh_Face_Count[mesh_num]
			'Print "Face["; f_count; "]"
			
			C3D_Mesh_Face_Vertex_Count[mesh_num, mesh_face_num] = f_count
			C3D_Mesh_Face_TCoord_Count[mesh_num, mesh_face_num] = f_count
			
			Dim f_arg[3]
			
			For i = 0 to f_count-1
				'Print "-- Point ["; i; "] --"
				'Print "FDATA = "; face[i]
				f_arg_count = C3D_GetVector(3, face$[i], "/", f_arg)
				For j = 0 to f_arg_count-1
					Select Case j
					Case 0: C3D_Mesh_Face_Vertex[mesh_num, mesh_face_num, i] = v_offset + (f_arg[j]-1) ': Print " Vertex = ";
					Case 1: C3D_Mesh_Face_TCoord[mesh_num, mesh_face_num, i] = t_offset + (f_arg[j]-1) ': Print ", UV = ";
					Default : Exit For
					End Select
					
					'Print f_arg[j];
				Next
				'Print ""
			Next
			
			C3D_Mesh_Face_Count[mesh_num] = mesh_face_num + 1
			
			'Print "offset = ";v_offset;", ";t_offset
			'Print ""
			
		End Select
		
	Wend
	
	FileClose(f)
	'Print "MESH END"
	C3D_Mesh_Origin[mesh_num, 0] = (min_x + max_x)/2
	C3D_Mesh_Origin[mesh_num, 1] = (min_y + max_y)/2
	C3D_Mesh_Origin[mesh_num, 2] = (min_z + max_z)/2
	
	C3D_Mesh_MinX[mesh_num] = min_x
	C3D_Mesh_MinZ[mesh_num] = min_z
	C3D_Mesh_MaxX[mesh_num] = max_x
	C3D_Mesh_MaxZ[mesh_num] = max_z
	
	r = abs(max_x - min_x)
	r = Max(r, abs(max_y - min_y))
	r = Max(r, abs(max_z - min_z))
	
	C3D_Mesh_Radius[mesh_num] = r+1
	
	tmp_matrix = C3D_CreateMatrix(2,2)
	MatrixFromBuffer(tmp_matrix, C3D_Mesh_Vertex_Count[mesh_num], 4, C3D_Mesh_TMP_Vertex)
	TransposeMatrix(tmp_matrix, C3D_Mesh_Vertex_Matrix[mesh_num])
	C3D_DeleteMatrix(tmp_matrix)
	
	Return mesh_num
End Function


Function C3D_DefineMesh(m_vert_count, ByRef m_vert, m_index_count, ByRef m_ind, m_tex_count, ByRef m_tex)
	mesh_num = C3D_CreateMesh()
	C3D_Mesh_HasCollisionMesh[mesh_num] = False
	
	Dim min_x, min_y, min_z, max_x, max_y, max_z, min_max_init
	
	min_max_init = False
	
	
	v_offset = 0
	t_offset = 0
	set_offset = false
	For i = 0 to (m_vert_count*3)-1 Step 3
		
		if set_offset then
			v_offset = v_offset + C3D_Mesh_Vertex_Count[mesh_num]
			t_offset = t_offset + C3D_Mesh_TCoord_Count[mesh_num]
			set_offset = false
		end if
			
		mesh_vert_num = C3D_Mesh_Vertex_Count[mesh_num]
		C3D_Mesh_TMP_Vertex[mesh_vert_num, 0] = m_vert[i]
		C3D_Mesh_TMP_Vertex[mesh_vert_num, 1] = m_vert[i+1]
		C3D_Mesh_TMP_Vertex[mesh_vert_num, 2] = m_vert[i+2]
		C3D_Mesh_TMP_Vertex[mesh_vert_num, 3] = 1.0
		C3D_Mesh_Vertex_Count[mesh_num] = mesh_vert_num + 1
		
		
		If Not min_max_init Then
			min_max_init = True
			min_x = m_vert[i]
			min_y = m_vert[i+1]
			min_z = m_vert[i+2]
			max_x = m_vert[i]
			max_y = m_vert[i+1]
			max_z = m_vert[i+2]
		Else
			min_x = Min(min_x, m_vert[i])
			min_y = Min(min_y, m_vert[i+1])
			min_z = Min(min_z, m_vert[i+2])
			max_x = Max(max_x, m_vert[i])
			max_y = Max(max_y, m_vert[i+1])
			max_z = Max(max_z, m_vert[i+2])
		End If
	Next
		
		
	For i = 0 to (m_tex_count*2)-1 Step 2
		mesh_tc_num = C3D_Mesh_TCoord_Count[mesh_num]
		C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 0] = m_tex[i]
		C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 1] = 1-m_tex[i+1]
		C3D_Mesh_TCoord_Count[mesh_num] = mesh_tc_num + 1
	Next
		
	
	For n = 0 to m_index_count-1 Step 3
		
		mesh_face_num = C3D_Mesh_Face_Count[mesh_num]
			
		C3D_Mesh_Face_Vertex_Count[mesh_num, mesh_face_num] = 3
		C3D_Mesh_Face_TCoord_Count[mesh_num, mesh_face_num] = 3
			
		For i = 0 to 2
			C3D_Mesh_Face_Vertex[mesh_num, mesh_face_num, i] = m_ind[n+i]
			C3D_Mesh_Face_TCoord[mesh_num, mesh_face_num, i] = m_ind[n+i]
			'print "i = "; m_ind[i]
		Next
		
		C3D_Mesh_Face_Count[mesh_num] = mesh_face_num + 1
		
	Next
	
	
	C3D_Mesh_Origin[mesh_num, 0] = (min_x + max_x)/2
	C3D_Mesh_Origin[mesh_num, 1] = (min_y + max_y)/2
	C3D_Mesh_Origin[mesh_num, 2] = (min_z + max_z)/2
	
	C3D_Mesh_MinX[mesh_num] = min_x
	C3D_Mesh_MinZ[mesh_num] = min_z
	C3D_Mesh_MaxX[mesh_num] = max_x
	C3D_Mesh_MaxZ[mesh_num] = max_z
	
	r = abs(max_x - min_x)
	r = Max(r, abs(max_y - min_y))
	r = Max(r, abs(max_z - min_z))
	
	C3D_Mesh_Radius[mesh_num] = r+1
	
	tmp_matrix = C3D_CreateMatrix(2,2)
	MatrixFromBuffer(tmp_matrix, C3D_Mesh_Vertex_Count[mesh_num], 4, C3D_Mesh_TMP_Vertex)
	TransposeMatrix(tmp_matrix, C3D_Mesh_Vertex_Matrix[mesh_num])
	'PrintMatrix(C3D_Mesh_Vertex_Matrix[mesh_num])
	C3D_DeleteMatrix(tmp_matrix)
	
	Return mesh_num
End Function


Sub C3D_AddCollisionMesh(base_mesh, collision_mesh)
	C3D_Mesh_HasCollisionMesh[base_mesh] = True
	C3D_Mesh_CollisionMesh[base_mesh] = collision_mesh
	
End Sub


Sub C3D_SetMeshTexture(mesh, img)
	C3D_Mesh_Texture[mesh] = C3D_Image[img]
End Sub


Function C3D_GetMeshTexture(mesh)
	Return C3D_Mesh_Texture[mesh]
End Function



C3D_MAX_ACTORS = 100

Dim actor_distance[ C3D_MAX_ACTORS ]
Dim actor_min_screen_x[ C3D_MAX_ACTORS ]
Dim actor_min_screen_y[ C3D_MAX_ACTORS ]
Dim actor_max_screen_x[ C3D_MAX_ACTORS ]
Dim actor_max_screen_y[ C3D_MAX_ACTORS ]

Dim C3D_Actor_Active[C3D_MAX_ACTORS]

Dim C3D_Actor_Visible[C3D_MAX_ACTORS]

Dim C3D_Actor_CamDistance[C3D_MAX_ACTORS]
Dim C3D_Actor_isPickable[C3D_MAX_ACTORS]

Dim C3D_Actor_Position[C3D_MAX_ACTORS, 3]
Dim C3D_Actor_Rotation[C3D_MAX_ACTORS, 3]
Dim C3D_Actor_Scale[C3D_MAX_ACTORS]

C3D_ACTOR_TYPE_SPRITE = 1
C3D_ACTOR_TYPE_MESH = 2

Dim C3D_Actor_Type[C3D_MAX_ACTORS]

Dim C3D_Actor_Source[C3D_MAX_ACTORS] 'Image or Mesh

Dim C3D_Actor_Base_Source[C3D_MAX_ACTORS]

C3D_ACTOR_MATRIX_T = 1
C3D_ACTOR_MATRIX_RX = 2
C3D_ACTOR_MATRIX_RY = 3
C3D_ACTOR_MATRIX_RZ = 4
C3D_ACTOR_MATRIX_COLLIDE_ORIGIN = 5
C3D_ACTOR_MATRIX_COLLIDE_DIRECTION = 6

C3D_MAX_SCENE_FACES = 4000
Dim C3D_Visible_Faces[C3D_MAX_SCENE_FACES, 2] '0 is actor, 1 is face
Dim C3D_ZSort_Faces[C3D_MAX_Z_DEPTH, C3D_MAX_SCENE_FACES] 'reference item in C3D_Visible_Faces, 500 is max Z depth (I will probably change it later)
Dim C3D_ZSort_Faces_Distance[C3D_MAX_Z_DEPTH, C3D_MAX_SCENE_FACES]
Dim C3D_ZSort_Faces_Count[C3D_MAX_Z_DEPTH]
Dim C3D_Actor_Face_ZOrder[C3D_MAX_ACTORS, C3D_MAX_FACES]


Dim C3D_Visible_Faces_Type[C3D_MAX_SCENE_FACES]
C3D_Visible_Faces_Count = 0


Dim C3D_Actor_Matrix[C3D_MAX_ACTORS, 7] 'Output, Translation, and Rotation

Dim C3D_inSite_Actors[C3D_MAX_ACTORS]
Dim C3D_inSite_Actors_Count
Dim C3D_Actor_inSite[C3D_MAX_ACTORS] 'Whether or not an actor is visible in the current view
Dim C3D_Actor_Face_inSite[C3D_MAX_ACTORS, C3D_MAX_FACES]
Dim C3D_Actor_Face_inSite_Count[C3D_MAX_ACTORS]

Dim C3D_inZone_Actors[C3D_MAX_ACTORS]
Dim C3D_Actors_inZone[C3D_MAX_ACTORS]
Dim C3D_inZone_Actors_Count

Dim C3D_Visible_Init
Dim C3D_Visible_Min_X
Dim C3D_Visible_Min_Y
Dim C3D_Visible_Max_X
Dim C3D_Visible_Max_Y


C3D_MAX_COLLISION_MESH = 100
C3D_MAX_OBJECT_COLLISIONS = 50

Dim C3D_Actor_Collision_Enabled[C3D_MAX_ACTORS]
Dim C3D_Actor_Collision_Checked[C3D_MAX_ACTORS]

C3D_COLLISION_SHAPE_CAPSULE = 0
C3D_COLLISION_SHAPE_BOX = 1
C3D_COLLISION_SHAPE_PLANE = 2
C3D_COLLISION_SHAPE_CYLINDER = 3

Dim C3D_Actor_Collision_Shape[C3D_MAX_ACTORS, 9]
'CAPSULE PARAMETERS(9): TYPE, SPHERE_1(CX, CY, CZ, R), SPHERE_2(CX, CY, CZ, R)  'cx,cy,cz is offset from actor position
'BOX PARAMETERS(7): TYPE, X, Y, Z, W, H, D
'PLANE PARAMETERS(2): TYPE, MESH_FACE
'CYLINDER PARAMETERS(6): TYPE, CX, CY, CZ, R, H

C3D_COLLISION_TYPE_NONE = 0
C3D_COLLISION_TYPE_STATIC = 1
C3D_COLLISION_TYPE_DYNAMIC = 2

Dim C3D_Actor_Collision_Type[C3D_MAX_ACTORS] 'DYNAMIC OR STATIC
Dim C3D_Actor_Collisions[C3D_MAX_ACTORS, C3D_MAX_ACTORS]

C3D_MAX_STAGE_GEOMETRY = 300

C3D_MAX_ACTOR_STAGE_COLLISIONS = 20
Dim C3D_Actor_Stage_Collision[C3D_MAX_ACTORS, C3D_MAX_ACTOR_STAGE_COLLISIONS]
Dim C3D_Actor_Stage_Collision_Count[C3D_MAX_ACTORS]

Dim C3D_Stage_Geometry[C3D_MAX_STAGE_GEOMETRY, 13]
Dim C3D_Stage_Geometry_Actor_Collisions[C3D_MAX_STAGE_GEOMETRY, C3D_MAX_ACTORS]
C3D_Stage_Geometry_Count = 0
'GEOMETRY PARAMETERS: TYPE (C3D_GEOMETRY_TYPE_FLOOR | C3D_GEOMETRY_TYPE_WALL), X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3, X4, Y4, Z4
C3D_STAGE_GEOMETRY_TYPE_FLOOR = 0
C3D_STAGE_GEOMETRY_TYPE_WALL = 1

Sub C3D_ClearStageGeometry()
	C3D_Stage_Geometry_Count = 0
End Sub

Sub C3D_AddStageGeometry(type, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4) 'MUST BE SPECIFIED CLOCKWISE
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 0] = type
	
	min_x = min(min(x1, x2), min(x3, x4))
	min_y = min(min(y1, y2), min(y3, y4))
	min_z = min(min(z1, z2), min(z3, z4))
	
	max_x = max(max(x1, x2), max(x3, x4))
	max_y = max(max(y1, y2), max(y3, y4))
	max_z = max(max(z1, z2), max(z3, z4))
	
	if type = C3D_STAGE_GEOMETRY_TYPE_WALL then
		
		'x1 = min_x : y1 = max_y : z1 = max_z
		'x2 = max_x : y2 = max_y : z2 = min_z
		'x3 = max_x : y3 = min_y : z3 = min_z
		'x4 = min_x : y4 = min_y : z4 = max_z
		
	end if
	
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 1] = x1
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 2] = y1
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 3] = z1
	
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 4] = x2
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 5] = y2
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 6] = z2
	
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 7] = x3
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 8] = y3
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 9] = z3
	
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 10] = x4
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 11] = y4
	C3D_Stage_Geometry[C3D_Stage_Geometry_Count, 12] = z4
	
	C3D_Stage_Geometry_Count = C3D_Stage_Geometry_Count + 1
End Sub


Sub C3D_RefreshActorMatrix(actor)
	actor_source = C3D_Actor_Source[actor]
	
	x = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0)
	y = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0)
	z = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0)
	
	DimMatrix(C3D_Actor_Matrix[actor, 0], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM OUTPUT MATRIX
	DimMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM TRANSLATION MATRIX
	
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, x)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, y)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, z)
	
End Sub

function inTol(a, b, tol)
	return (b >= (a-tol)) and (b <= (a+tol))
end function

Sub C3D_AddStageGeometryFromActor(actor)
	mesh = C3D_Actor_Source[actor]
	
	tol = 0.5
	
	If Not C3D_Mesh_HasCollisionMesh[mesh] Then
		return
	End If
	
	mesh = C3D_Mesh_CollisionMesh[mesh]
	'print "Collision Mesh = ";mesh
	
	c_vert_offset = 0 'C3D_Mesh_Collision_Vertex_Offset[mesh]
	c_vert_count = C3D_Mesh_Vertex_Count[mesh] 'C3D_Mesh_Collision_Vertex_Count[mesh] 
	c_face_count = C3D_Mesh_Face_Count[mesh] 'C3D_Mesh_Collision_Face_Count[mesh]
	c_face_offset = 0 'C3D_Mesh_Collision_Face_Offset[mesh]
	
	
	tmp_matrix1 = C3D_CreateMatrix(2,2)
	tmp_matrix2 = C3D_CreateMatrix(2,2)
	
	C3D_RefreshActorMatrix(actor)
	'Scale (Note: Camera does not have a scale. The scene can be scales by changing the left, right, top, and bottom values)
	scale = C3D_Actor_Scale[actor]
	
	'Moves the vertices based on the actors local rotation
	MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], C3D_Mesh_Vertex_Matrix[mesh], tmp_matrix1)
	MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], tmp_matrix1, tmp_matrix2)
	MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], tmp_matrix2, tmp_matrix1)
		
	ScalarMatrix(tmp_matrix1, tmp_matrix1, scale)
	
	'Create Translation matrix from actor position
	Dim r, c
	GetMatrixSize(C3D_Mesh_Vertex_Matrix[mesh], r, c)
	tmp_trans_matrix = C3D_CreateMatrix(r, c)
	
	ZeroMatrix(tmp_trans_matrix)
	
	ax = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0)
	ay = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0)
	az = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0)
	
	FillMatrixRows(tmp_trans_matrix, 0, 1, ax)
	FillMatrixRows(tmp_trans_matrix, 1, 1, ay)
	FillMatrixRows(tmp_trans_matrix, 2, 1, az)
	
	'print "debug info: (";ax;", ";ay;", ";az;")  scale = ";scale
	
	C3D_DeleteMatrix(tmp_trans_matrix)
	
	AddMatrix(tmp_trans_matrix, tmp_matrix1, tmp_matrix2)
	
	geo_matrix = tmp_matrix2
	
	type = C3D_STAGE_GEOMETRY_TYPE_FLOOR
	
	For face = 0 To c_face_count - 1
	
		v1 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 0] + c_vert_offset
		v2 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 1] + c_vert_offset
		v3 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 2] + c_vert_offset
		v4 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 3] + c_vert_offset
		
		f_vert_count = C3D_Mesh_Face_Vertex_Count[mesh, face + c_face_offset]
		
		x1 = MatrixValue(geo_matrix, 0, v1)
		y1 = MatrixValue(geo_matrix, 1, v1)
		z1 = MatrixValue(geo_matrix, 2, v1)
		
		x2 = MatrixValue(geo_matrix, 0, v2)
		y2 = MatrixValue(geo_matrix, 1, v2)
		z2 = MatrixValue(geo_matrix, 2, v2)
		
		x3 = MatrixValue(geo_matrix, 0, v3)
		y3 = MatrixValue(geo_matrix, 1, v3)
		z3 = MatrixValue(geo_matrix, 2, v3)
		
		x4 = MatrixValue(geo_matrix, 0, v4)
		y4 = MatrixValue(geo_matrix, 1, v4)
		z4 = MatrixValue(geo_matrix, 2, v4)
		
		min_x = min(min(x1, x2), min(x3, x4))
		min_y = min(min(y1, y2), min(y3, y4))
		min_z = min(min(z1, z2), min(z3, z4))
		
		max_x = max(max(x1, x2), max(x3, x4))
		max_y = max(max(y1, y2), max(y3, y4))
		max_z = max(max(z1, z2), max(z3, z4))
		
		cmp_1 = ( inTol(x1, min_x, tol) And inTol(z1, min_z, tol) ) + ( inTol(x2, min_x, tol) And inTol(z2, min_z, tol) ) + ( inTol(x3, min_x, tol) And inTol(z3, min_z, tol) ) + ( inTol(x4, min_x, tol) And inTol(z4, min_z, tol) )
		dbg1 = cmp_1
		if cmp_1 <> 2 then
			cmp_1 = ( inTol(x1, min_x, tol) And inTol(z1, max_z, tol) ) + ( inTol(x2, min_x, tol) And inTol(z2, max_z, tol) ) + ( inTol(x3, min_x, tol) And inTol(z3, max_z, tol) ) + ( inTol(x4, min_x, tol) And inTol(z4, max_z, tol) )
		end if
		
		cmp_2 = ( inTol(x1, max_x, tol) And inTol(z1, max_z, tol) ) + ( inTol(x2, max_x, tol) And inTol(z2, max_z, tol) ) + ( inTol(x3, max_x, tol) And inTol(z3, max_z, tol) ) + ( inTol(x4, max_x, tol) And inTol(z4, max_z, tol) )
		dbg2 = cmp_2
		if cmp_2 <> 2 then
			cmp_2 = ( inTol(x1, max_x, tol) And inTol(z1, min_z, tol) ) + ( inTol(x2, max_x, tol) And inTol(z2, min_z, tol) ) + ( inTol(x3, max_x, tol) And inTol(z3, min_z, tol) ) + ( inTol(x4, max_x, tol) And inTol(z4, min_z, tol) )
		end if
		
		
		if cmp_1 = 2 And cmp_2 = 2 Then
			type = C3D_STAGE_GEOMETRY_TYPE_WALL
		else
			type = C3D_STAGE_GEOMETRY_TYPE_FLOOR
		end if
		
		C3D_AddStageGeometry(type, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
		'print "dbg: ";x1;","; y1;","; z1;","; x2;","; y2;","; z2;","; x3;","; y3;","; z3;","; x4;","; y4;","; z4
	Next
	
	C3D_DeleteMatrix(tmp_matrix1)
	C3D_DeleteMatrix(tmp_matrix2)
	
	
End Sub


Sub C3D_AddStageGeometryFromMesh(mesh)
	
	tol = 0.5
	
	c_vert_offset = 0 'C3D_Mesh_Collision_Vertex_Offset[mesh]
	c_vert_count = C3D_Mesh_Vertex_Count[mesh] 'C3D_Mesh_Collision_Vertex_Count[mesh] 
	c_face_count = C3D_Mesh_Face_Count[mesh] 'C3D_Mesh_Collision_Face_Count[mesh]
	c_face_offset = 0 'C3D_Mesh_Collision_Face_Offset[mesh]
	
	geo_matrix = C3D_Mesh_Vertex_Matrix[mesh]
	
	type = C3D_STAGE_GEOMETRY_TYPE_FLOOR
	
	For face = 0 To c_face_count - 1
	
		v1 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 0] + c_vert_offset
		v2 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 1] + c_vert_offset
		v3 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 2] + c_vert_offset
		v4 = C3D_Mesh_Face_Vertex[mesh, face + c_face_offset, 3] + c_vert_offset
		
		f_vert_count = C3D_Mesh_Face_Vertex_Count[mesh, face + c_face_offset]
		
		x1 = MatrixValue(geo_matrix, 0, v1)
		y1 = MatrixValue(geo_matrix, 1, v1)
		z1 = MatrixValue(geo_matrix, 2, v1)
		
		x2 = MatrixValue(geo_matrix, 0, v2)
		y2 = MatrixValue(geo_matrix, 1, v2)
		z2 = MatrixValue(geo_matrix, 2, v2)
		
		x3 = MatrixValue(geo_matrix, 0, v3)
		y3 = MatrixValue(geo_matrix, 1, v3)
		z3 = MatrixValue(geo_matrix, 2, v3)
		
		x4 = MatrixValue(geo_matrix, 0, v4)
		y4 = MatrixValue(geo_matrix, 1, v4)
		z4 = MatrixValue(geo_matrix, 2, v4)
		
		min_x = min(min(x1, x2), min(x3, x4))
		min_y = min(min(y1, y2), min(y3, y4))
		min_z = min(min(z1, z2), min(z3, z4))
		
		max_x = max(max(x1, x2), max(x3, x4))
		max_y = max(max(y1, y2), max(y3, y4))
		max_z = max(max(z1, z2), max(z3, z4))
		
		cmp_1 = ( inTol(x1, min_x, tol) And inTol(z1, min_z, tol) ) + ( inTol(x2, min_x, tol) And inTol(z2, min_z, tol) ) + ( inTol(x3, min_x, tol) And inTol(z3, min_z, tol) ) + ( inTol(x4, min_x, tol) And inTol(z4, min_z, tol) )
		dbg1 = cmp_1
		if cmp_1 <> 2 then
			cmp_1 = ( inTol(x1, min_x, tol) And inTol(z1, max_z, tol) ) + ( inTol(x2, min_x, tol) And inTol(z2, max_z, tol) ) + ( inTol(x3, min_x, tol) And inTol(z3, max_z, tol) ) + ( inTol(x4, min_x, tol) And inTol(z4, max_z, tol) )
		end if
		
		cmp_2 = ( inTol(x1, max_x, tol) And inTol(z1, max_z, tol) ) + ( inTol(x2, max_x, tol) And inTol(z2, max_z, tol) ) + ( inTol(x3, max_x, tol) And inTol(z3, max_z, tol) ) + ( inTol(x4, max_x, tol) And inTol(z4, max_z, tol) )
		dbg2 = cmp_2
		if cmp_2 <> 2 then
			cmp_2 = ( inTol(x1, max_x, tol) And inTol(z1, min_z, tol) ) + ( inTol(x2, max_x, tol) And inTol(z2, min_z, tol) ) + ( inTol(x3, max_x, tol) And inTol(z3, min_z, tol) ) + ( inTol(x4, max_x, tol) And inTol(z4, min_z, tol) )
		end if
		
		
		if cmp_1 = 2 And cmp_2 = 2 Then
			type = C3D_STAGE_GEOMETRY_TYPE_WALL
		else
			type = C3D_STAGE_GEOMETRY_TYPE_FLOOR
		end if
		
		C3D_AddStageGeometry(type, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)
		'print "dbg: ";x1;","; y1;","; z1;","; x2;","; y2;","; z2;","; x3;","; y3;","; z3;","; x4;","; y4;","; z4
	Next
	
	
End Sub


Sub C3D_SetCollisionParameters(actor, CX1, CY1, CZ1, CX2, CY2, CZ2, R)
	C3D_Actor_Collision_Shape[actor, 0] = C3D_COLLISION_SHAPE_CAPSULE
	C3D_Actor_Collision_Shape[actor, 1] = CX1
	C3D_Actor_Collision_Shape[actor, 2] = CY1
	C3D_Actor_Collision_Shape[actor, 3] = CZ1
	C3D_Actor_Collision_Shape[actor, 4] = R
	C3D_Actor_Collision_Shape[actor, 5] = CX2
	C3D_Actor_Collision_Shape[actor, 6] = CY2
	C3D_Actor_Collision_Shape[actor, 7] = CZ2
	C3D_Actor_Collision_Shape[actor, 8] = R
End Sub

Sub C3D_SetCollisionType(actor, TYPE)
	C3D_Actor_Collision_Type[actor] = TYPE
End Sub

Sub setCollisionData(actor)
	
	if C3D_inZone_Actors_Count <= 0 Or C3D_Actor_Collision_Type[actor] = C3D_COLLISION_TYPE_NONE then
		return
	end if
	
	mesh = C3D_Actor_Source[actor]
	
	ocx = C3D_Actor_Position[actor, 0] + C3D_Mesh_Origin[mesh,0]
	ocy = C3D_Actor_Position[actor, 1] + C3D_Mesh_Origin[mesh,1]
	ocz = C3D_Actor_Position[actor, 2] + C3D_Mesh_Origin[mesh,2]
	
	ncx = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0) + C3D_Mesh_Origin[mesh,0]
	ncy = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0) + C3D_Mesh_Origin[mesh,1]
	ncz = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0) + C3D_Mesh_Origin[mesh,2]
	
	
	actor_cx1 = ncx + C3D_Actor_Collision_Shape[actor, 1]
	actor_cy1 = ncy + C3D_Actor_Collision_Shape[actor, 2]
	actor_cz1 = ncz + C3D_Actor_Collision_Shape[actor, 3]
		
	actor_cx2 = ncx + C3D_Actor_Collision_Shape[actor, 5]
	actor_cy2 = ncy + C3D_Actor_Collision_Shape[actor, 6]
	actor_cz2 = ncz + C3D_Actor_Collision_Shape[actor, 7]
	
	old_cx1 = ocx + C3D_Actor_Collision_Shape[actor, 1]
	old_cy1 = ocy + C3D_Actor_Collision_Shape[actor, 2]
	old_cz1 = ocz + C3D_Actor_Collision_Shape[actor, 3]
		
	old_cx2 = ocx + C3D_Actor_Collision_Shape[actor, 5]
	old_cy2 = ocy + C3D_Actor_Collision_Shape[actor, 6]
	old_cz2 = ocz + C3D_Actor_Collision_Shape[actor, 7]
	
	
	min_y = min(actor_cy1, actor_cy2)
	max_y = max(actor_cy1, actor_cy2)
	
	actor_cr = C3D_Actor_Collision_Shape[actor, 4]
	
	speed = C3D_Distance2D(ocx, ocz, ncx, ncz)
	
	h_diff = ocy - ncy
	
	Dim line_point[3], line_dir[3]
	
	line_dir[0] = 0
	line_dir[1] = 1
	line_dir[2] = 0
	
	Dim plane_p1[3], plane_p2[3], plane_p3[3]
	Dim intersect[3]
	
	
	'World Collisions
	if C3D_Actor_Collision_Type[actor] = C3D_COLLISION_TYPE_DYNAMIC then

		
		For i = 0 to C3D_Stage_Geometry_Count-1
			
			
			Select Case C3D_Stage_Geometry[i, 0]
			Case C3D_STAGE_GEOMETRY_TYPE_WALL
				
				ly1 = C3D_Stage_Geometry[i, 2] 'y1
				ly3 = C3D_Stage_Geometry[i, 8] 'y3
				
				n_min_y = min(ly1, ly3)
				n_max_y = max(ly1, ly3)
				
				in_y_range = ((min_y >= n_min_y) And (min_y <= n_max_y)) Or ((n_min_y >= min_y) And (n_min_y <= max_y))
				in_y_range = in_y_range Or ((max_y >= n_min_y) And (max_y <= n_max_y)) Or ((n_max_y >= min_y) And (n_max_y <= max_y))
				
				if not in_y_range then
					continue
				end if
				
				n_min_x = min(min(C3D_Stage_Geometry[i, 1], C3D_Stage_Geometry[i, 4]), C3D_Stage_Geometry[i, 7])
				n_min_z = min(min(C3D_Stage_Geometry[i, 3], C3D_Stage_Geometry[i, 6]), C3D_Stage_Geometry[i, 9])
				
				n_max_x = max(max(C3D_Stage_Geometry[i, 1], C3D_Stage_Geometry[i, 4]), C3D_Stage_Geometry[i, 7])
				n_max_z = max(max(C3D_Stage_Geometry[i, 3], C3D_Stage_Geometry[i, 6]), C3D_Stage_Geometry[i, 9])
				
				
				lx1 = C3D_Stage_Geometry[i, 1] - C3D_Actor_Collision_Shape[actor, 1]
				ly1 = C3D_Stage_Geometry[i, 2] - C3D_Actor_Collision_Shape[actor, 2]
				lz1 = C3D_Stage_Geometry[i, 3] - C3D_Actor_Collision_Shape[actor, 3]
				
				lx2 = C3D_Stage_Geometry[i, 4] - C3D_Actor_Collision_Shape[actor, 1]
				ly2 = C3D_Stage_Geometry[i, 5] - C3D_Actor_Collision_Shape[actor, 2]
				lz2 = C3D_Stage_Geometry[i, 6] - C3D_Actor_Collision_Shape[actor, 3]
				
				lx3 = C3D_Stage_Geometry[i, 7] - C3D_Actor_Collision_Shape[actor, 1]
				ly3 = C3D_Stage_Geometry[i, 8] - C3D_Actor_Collision_Shape[actor, 2]
				lz3 = C3D_Stage_Geometry[i, 9] - C3D_Actor_Collision_Shape[actor, 3]
				
				lx4 = C3D_Stage_Geometry[i, 10] - C3D_Actor_Collision_Shape[actor, 1]
				ly4 = C3D_Stage_Geometry[i, 11] - C3D_Actor_Collision_Shape[actor, 2]
				lz4 = C3D_Stage_Geometry[i, 12] - C3D_Actor_Collision_Shape[actor, 3]
				
				'debug
				tx = actor_cx1
				tz = actor_cz1
				
				tmp_x = old_cx1
				tmp_z = old_cz1
				
				If speed > actor_cr And (tmp_x <> actor_cx1 And tmp_z <> actor_cz1)  Then
					
					plane_p1[0] = lx1
					plane_p1[1] = ly1
					plane_p1[2] = lz1
					
					plane_p2[0] = lx2
					plane_p2[1] = ly2
					plane_p2[2] = lz2
					
					plane_p3[0] = lx3
					plane_p3[1] = ly3
					plane_p3[2] = lz3
					
					line_point[0] = actor_cx1
					line_point[1] = actor_cy1
					line_point[2] = actor_cz1
					
					line_dir[0] = actor_cx1 - old_cx1
					line_dir[1] = actor_cy1 - old_cy1
					line_dir[2] = actor_cz1 - old_cz1
				
					C3D_linePlaneIntersection(line_point, line_dir, plane_p1, plane_p2, plane_p3, intersect)
					
					min_x = min(actor_cx1, old_cx1)
					max_x = max(actor_cx1, old_cx1)
					
					min_z = min(actor_cz1, old_cz1)
					max_z = max(actor_cz1, old_cz1)
					
					If (min_x < intersect[0] And max_x > intersect[0]) Then
						If actor_cx1 = min_x then
							actor_cx1 = intersect[0]
						else
							actor_cx1 = intersect[0]
						end if
					End If
					
					If (min_z < intersect[2] And max_z > intersect[2]) Then
						If actor_cz1 = min_z then
							actor_cz1 = intersect[2]
						else
							actor_cz1 = intersect[2]
						end if
					End If
					
				End If
				
				C3D_ColDet_CircleLine(tmp_x, tmp_z, actor_cx1, actor_cz1, actor_cr, lx1, lz1, lx3, lz3, speed)
				
				'debug
				if not (tx = actor_cx1 and tz = actor_cz1) then
					C3D_Stage_Geometry_Actor_Collisions[i, actor] = True
					C3D_Actor_Stage_Collision[actor, C3D_Actor_Stage_Collision_Count[actor]] = i
					C3D_Actor_Stage_Collision_Count[actor] = C3D_Actor_Stage_Collision_Count[actor] + 1
				end if
			Case C3D_STAGE_GEOMETRY_TYPE_FLOOR
				
				
				lx1 = C3D_Stage_Geometry[i, 1] - C3D_Actor_Collision_Shape[actor, 1]
				ly1 = C3D_Stage_Geometry[i, 2] - C3D_Actor_Collision_Shape[actor, 2]
				lz1 = C3D_Stage_Geometry[i, 3] - C3D_Actor_Collision_Shape[actor, 3]
				
				lx2 = C3D_Stage_Geometry[i, 4] - C3D_Actor_Collision_Shape[actor, 1]
				ly2 = C3D_Stage_Geometry[i, 5] - C3D_Actor_Collision_Shape[actor, 2]
				lz2 = C3D_Stage_Geometry[i, 6] - C3D_Actor_Collision_Shape[actor, 3]
				
				lx3 = C3D_Stage_Geometry[i, 7] - C3D_Actor_Collision_Shape[actor, 1]
				ly3 = C3D_Stage_Geometry[i, 8] - C3D_Actor_Collision_Shape[actor, 2]
				lz3 = C3D_Stage_Geometry[i, 9] - C3D_Actor_Collision_Shape[actor, 3]
				
				lx4 = C3D_Stage_Geometry[i, 10] - C3D_Actor_Collision_Shape[actor, 1]
				ly4 = C3D_Stage_Geometry[i, 11] - C3D_Actor_Collision_Shape[actor, 2]
				lz4 = C3D_Stage_Geometry[i, 12] - C3D_Actor_Collision_Shape[actor, 3]
				
				'Check from top
				top_check = C3D_pointInQuad(actor_cx1, actor_cz1, lx1, lz1, lx2, lz2, lx3, lz3, lx4, lz4)
				
				If not top_check then
					continue
				End If
				
				
				plane_p1[0] = lx1
				plane_p1[1] = ly1
				plane_p1[2] = lz1
				
				plane_p2[0] = lx2
				plane_p2[1] = ly2
				plane_p2[2] = lz2
				
				plane_p3[0] = lx3
				plane_p3[1] = ly3
				plane_p3[2] = lz3
				
				line_point[0] = actor_cx1
				line_point[1] = actor_cy1
				line_point[2] = actor_cz1
				
				line_dir[0] = 0
				line_dir[1] = 1
				line_dir[2] = 0
				
				if C3D_linePlaneIntersection(line_point, line_dir, plane_p1, plane_p2, plane_p3, intersect) then
					
					min_y = min(actor_cy1, actor_cy2)
					max_y = max(actor_cy1, actor_cy2)
					
					distance_min = C3D_Distance2D(line_point[0], min_y, intersect[0], intersect[1])
					distance_max = C3D_Distance2D(line_point[0], max_y, intersect[0], intersect[1])
					
					if (min_y >= intersect[1] And distance_min <= actor_cr) Or (ocy >= intersect[1] And min_y <= intersect[1]) then
						diff_y = min_y - (intersect[1] + actor_cr)
						actor_cy1 = intersect[1] + actor_cr + 1
						actor_cy2 = actor_cy1 + (max_y-min_y)
						C3D_Stage_Geometry_Actor_Collisions[i, actor] = True
						
						C3D_Actor_Stage_Collision[actor, C3D_Actor_Stage_Collision_Count[actor]] = i
						C3D_Actor_Stage_Collision_Count[actor] = C3D_Actor_Stage_Collision_Count[actor] + 1
					elseif max_y <= intersect[1] And distance_max <= actor_cr Or (ocy <= intersect[1] And max_y >= intersect[1]) then
						diff_y = max_y - (intersect[1] + actor_cr)
						actor_cy1 = actor_cy1 + diff_y
						actor_cy2 = actor_cy2 + diff_y
						C3D_Stage_Geometry_Actor_Collisions[i, actor] = True
						
						C3D_Actor_Stage_Collision[actor, C3D_Actor_Stage_Collision_Count[actor]] = i
						C3D_Actor_Stage_Collision_Count[actor] = C3D_Actor_Stage_Collision_Count[actor] + 1
					end if
					
				
				end if
				
				
			End Select
		Next
		
		
		C3D_Actor_Position[actor, 0] = (actor_cx1 - C3D_Mesh_Origin[mesh,0]) - C3D_Actor_Collision_Shape[actor, 1]
		C3D_Actor_Position[actor, 1] = (actor_cy1 - C3D_Mesh_Origin[mesh,1]) - C3D_Actor_Collision_Shape[actor, 2]
		C3D_Actor_Position[actor, 2] = (actor_cz1 - C3D_Mesh_Origin[mesh,2]) - C3D_Actor_Collision_Shape[actor, 3]
		
		FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, C3D_Actor_Position[actor, 0])
		FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, C3D_Actor_Position[actor, 1])
		FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, C3D_Actor_Position[actor, 2])
	end if
	
	actor_cx1 = ncx + C3D_Actor_Collision_Shape[actor, 1]
	actor_cy1 = ncy + C3D_Actor_Collision_Shape[actor, 2]
	actor_cz1 = ncz + C3D_Actor_Collision_Shape[actor, 3]
		
	actor_cx2 = ncx + C3D_Actor_Collision_Shape[actor, 5]
	actor_cy2 = ncy + C3D_Actor_Collision_Shape[actor, 6]
	actor_cz2 = ncz + C3D_Actor_Collision_Shape[actor, 7]
		
		
	min_y = min(actor_cy1, actor_cy2)
	max_y = max(actor_cy1, actor_cy2)
	
	
	For i = (actor + 1) to C3D_inZone_Actors_Count-1
		n_actor = C3D_inSite_Actors[i]
		If C3D_Actor_Collision_Type[n_actor] = C3D_COLLISION_TYPE_NONE then
			continue
		end if
		
		'CAPSULE PARAMETERS(9): TYPE, SPHERE_1(CX, CY, CZ, R), SPHERE_2(CX, CY, CZ, R)  'cx,cy,cz is offset from actor position
		n_mesh = C3D_Actor_Source[actor]
		
		nx = MatrixValue(C3D_Actor_Matrix[n_actor, C3D_ACTOR_MATRIX_T], 0, 0) + C3D_Mesh_Origin[n_mesh, 0]
		ny = MatrixValue(C3D_Actor_Matrix[n_actor, C3D_ACTOR_MATRIX_T], 1, 0) + C3D_Mesh_Origin[n_mesh, 1]
		nz = MatrixValue(C3D_Actor_Matrix[n_actor, C3D_ACTOR_MATRIX_T], 2, 0) + C3D_Mesh_Origin[n_mesh, 2]
	
		n_actor_cx1 = nx + C3D_Actor_Collision_Shape[n_actor, 1]
		n_actor_cy1 = ny + C3D_Actor_Collision_Shape[n_actor, 2]
		n_actor_cz1 = nz + C3D_Actor_Collision_Shape[n_actor, 3]
		
		n_actor_cr = C3D_Actor_Collision_Shape[n_actor, 4]
		
		n_actor_cx2 = nx + C3D_Actor_Collision_Shape[n_actor, 5]
		n_actor_cy2 = ny + C3D_Actor_Collision_Shape[n_actor, 6]
		n_actor_cz2 = nz + C3D_Actor_Collision_Shape[n_actor, 7]
		
		n_min_y = min(n_actor_cy1, n_actor_cy2)
		n_max_y = max(n_actor_cy1, n_actor_cy2)
		
		in_y_range = ((min_y >= n_min_y) And (min_y <= n_max_y)) Or ((n_min_y >= min_y) And (n_min_y <= max_y))
		
		if not in_y_range then
			continue
		end if
		
		distance = C3D_Distance2D(actor_cx1, actor_cz1, n_actor_cx1, n_actor_cz1)
		
		if distance <= (actor_cr + n_actor_cr) then
			C3D_Actor_Collisions[actor, n_actor] = true
			C3D_Actor_Collisions[n_actor, actor] = true
		end if
		
	Next
	
End Sub

Function C3D_CheckCollision(actor1, actor2)
	Return C3D_Actor_Collisions[actor1, actor2]
End Function

Sub C3D_EnableCollision(actor)
	C3D_Actor_Collision_Enabled[actor] = True
End Sub

Sub C3D_DisableCollision(actor)
	C3D_Actor_Collision_Enabled[actor] = False
End Sub


Function C3D_CreateActor(actor_type, actor_source)
	For i = 0 to C3D_MAX_ACTORS-1
		If Not C3D_Actor_Active[i] Then
			C3D_Actor_Active[i] = True
			C3D_Actor_Visible[i] = True
			C3D_Actor_Type[i] = actor_type
			C3D_Actor_Source[i] = actor_source
			
			C3D_Actor_Base_Source[i] = actor_source
			
			C3D_Actor_CamDistance[i] = 0
			C3D_Actor_isPickable[i] = False
			
			'Defaults
			C3D_Actor_Position[i, 0] = 0
			C3D_Actor_Position[i, 1] = 0
			C3D_Actor_Position[i, 2] = 0
			
			C3D_Actor_Rotation[i, 0] = 0
			C3D_Actor_Rotation[i, 1] = 0
			C3D_Actor_Rotation[i, 2] = 0
			
			C3D_Actor_Scale[i] = 1
			
			C3D_Actor_Matrix[i, 0] = C3D_CreateMatrix(2,2) 'OUTPUT MATRIX
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T] = C3D_CreateMatrix(2,2) 'TRANSLATE MATRIX
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RX] = C3D_CreateMatrix(2,2) 'ROTATE X
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RY] = C3D_CreateMatrix(2,2) 'ROTATE Y
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RZ] = C3D_CreateMatrix(2,2) 'ROTATE Z
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_COLLIDE_ORIGIN] = C3D_CreateMatrix(2,2) 'ORIGIN MATRIX
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_COLLIDE_DIRECTION] = C3D_CreateMatrix(2,2) 'DIRECTION MATRIX
			
			C3D_SetRotationMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RX], C3D_AXIS_X, 0)
			C3D_SetRotationMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RY], C3D_AXIS_Y, 0)
			C3D_SetRotationMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RZ], C3D_AXIS_Z, 0)
			
			Select Case actor_type
				Case C3D_ACTOR_TYPE_MESH
					DimMatrix(C3D_Actor_Matrix[i, 0], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM OUTPUT MATRIX
					DimMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM TRANSLATION MATRIX
					ZeroMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T])
				Case C3D_ACTOR_TYPE_SPRITE
					Dim vert[12]
					Dim ind[6]
					Dim tex[12]
					Dim w, h
					If ImageExists(C3D_Image[actor_source]) Then
						GetImageSize(C3D_Image[actor_source], w, h)
					Else
						w = 2
						h = 2
					End If
					w = C3D_Image_Width[actor_source]
					h = C3D_Image_Height[actor_source]
					nw = w/2
					vert[0] = -nw : vert[1] = h : vert[2] = 0
					vert[3] = nw : vert[4] = h : vert[5] = 0
					vert[6] = nw : vert[7] = 0 : vert[8] = 0
					vert[9] = -nw : vert[10] = 0 : vert[11] = 0
					
					ind[0] = 0 : ind[1] = 1 : ind[2] = 2
					ind[3] = 0 : ind[4] = 2 : ind[5] = 3
					
					tex[0] = 0 : tex[1] = 1
					tex[2] = 1 : tex[3] = 1
					tex[4] = 1 : tex[5] = 0
					tex[6] = 0 : tex[7] = 0
					
					mesh = C3D_DefineMesh(4, vert, 6, ind, 4, tex)
					
					C3D_SetMeshTexture(mesh, actor_source)
					C3D_Actor_Source[i] = mesh
					actor_source = mesh
					C3D_Actor_Base_Source[i] = mesh
					'print "**Mesh = "; mesh; ", "; C3D_Actor_Base_Source[i]; ", "; C3D_Actor_Source[i]
					DimMatrix(C3D_Actor_Matrix[i, 0], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM OUTPUT MATRIX
					DimMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM TRANSLATION MATRIX
					ZeroMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T])
			End Select
			Return i
		End If
	Next
	Return -1
End Function

Sub C3D_SetActorPickable(actor, flag)
	C3D_Actor_isPickable[actor] = flag
End Sub

Sub C3D_SetActorVisible(actor, flag)
	C3D_Actor_Visible[actor] = flag
End Sub

Function C3D_GetActorMesh(actor)
	Return C3D_Actor_Source[actor]
End Function

Sub C3D_DeleteActor(actor)
	C3D_Actor_Active[actor] = False
End Sub

Sub C3D_SetActorPosition(actor, x, y, z)
	C3D_Actor_Position[actor, 0] = x
	C3D_Actor_Position[actor, 1] = y
	C3D_Actor_Position[actor, 2] = z
	
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, x)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, y)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, z)
End Sub

Sub C3D_GetActorPosition(actor, ByRef x, ByRef y, ByRef z)
	x = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0)
	y = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0)
	z = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0)
End Sub

Function C3D_ActorPositionX(actor)
	Return MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0)
End Function

Function C3D_ActorPositionY(actor)
	Return MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0)
End Function

Function C3D_ActorPositionZ(actor)
	Return MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0)
End Function

Sub C3D_MoveActor(actor, x, y, z)
	tx = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0) + x
	ty = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0) + y
	tz = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0) + z
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, tx)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, ty)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, tz)
End Sub

Sub C3D_MoveActorRelative(actor, x, y, z)
	cx = C3D_Camera_Position[0]
	cy = C3D_Camera_Position[1]
	cz = C3D_Camera_Position[2]
	
	rx = C3D_Camera_Rotation[0]
	ry = C3D_Camera_Rotation[1]
	rz = C3D_Camera_Rotation[2]
	
	Dim tx, ty, tz
	
	distance = -80 '-1 * C3D_Distance3D(0, 0, 0, x, y, z)
	'distance = C3D_Distance3D(C3D_ActorPositionX(actor), C3D_ActorPositionY(actor), C3D_ActorPositionZ(actor), cx, cy, cz)
	
	C3D_GetForwardVector(cx, cy, cz, rx, ry, rz, distance, tx, ty, tz)
	C3D_MoveActor(actor, tx-C3D_ActorPositionX(actor), ty-C3D_ActorPositionY(actor), tz-C3D_ActorPositionZ(actor))
	
	return
	
'	Calculate new x and z coordinates based on rotation and distance
	y_angle = Radians(C3D_Actor_Rotation[actor, 1])

	pos_x = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0)
	pos_z = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0)
	distance = z

	tx = pos_x + distance * sin(y_angle)
	tz = pos_z + distance * cos(y_angle)
	
	y_angle = Radians(C3D_Actor_Rotation[actor, 1]+90)
	distance = x
	
	tx = tx + distance * sin(y_angle)
	tz = tz + distance * cos(y_angle)
	

	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, tx)
	'FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, ty)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, tz)
End Sub

Sub C3D_SetActorRotation(actor, x, y, z)
	C3D_Actor_Rotation[actor, 0] = x MOD 360
	C3D_Actor_Rotation[actor, 1] = y MOD 360
	C3D_Actor_Rotation[actor, 2] = z MOD 360
	
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], C3D_AXIS_X, x)
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], C3D_AXIS_Y, y)
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], C3D_AXIS_Z, z)
End Sub

Sub C3D_GetActorRotation(actor, ByRef x, ByRef y, ByRef z)
	x = C3D_Actor_Rotation[actor, 0] = x
	y = C3D_Actor_Rotation[actor, 1] = y
	z = C3D_Actor_Rotation[actor, 2] = z
End Sub

Sub C3D_RotateActor(actor, x, y, z)
	If x Then
		C3D_Actor_Rotation[actor, 0] = ((C3D_Actor_Rotation[actor, 0] + x) MOD 360)
		C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], C3D_AXIS_X, C3D_Actor_Rotation[actor, 0])
	End If
	
	If y Then
		C3D_Actor_Rotation[actor, 1] = ((C3D_Actor_Rotation[actor, 1] + y) MOD 360)
		C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], C3D_AXIS_Y, C3D_Actor_Rotation[actor, 1])
	End If
	If z Then
		C3D_Actor_Rotation[actor, 2] = ((C3D_Actor_Rotation[actor, 2] + z) MOD 360)
		C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], C3D_AXIS_Z, C3D_Actor_Rotation[actor, 2])
	End If
	
	'Print "Rotation = ";C3D_Actor_Rotation[actor, 0];", ";C3D_Actor_Rotation[actor, 1];", ";C3D_Actor_Rotation[actor, 2]
End Sub

Sub C3D_SetActorScale(actor, s_value)
	C3D_Actor_Scale[actor] = s_value
End Sub

Sub C3D_GetActorScale(actor, ByRef s_value)
	s_value = C3D_Actor_Scale[actor]
End Sub

Sub C3D_ScaleActor(actor, s_value)
	C3D_Actor_Scale[actor] = C3D_Actor_Scale[actor] * s_value
End Sub

Function SetFaceZ(actor, face_num, ByRef z_avg)
	mesh = C3D_Actor_Source[actor]
	
	If C3D_Mesh_Face_Vertex_Count[mesh, face_num] > 4 Then
		Return -1
	End if
	
	Dim vx
	Dim vy
	Dim vz[4]
	oi_count = 0
	
	
	Dim vertex_x, vertex_y, vertex_z
	
	face_min_z = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, 0)
	face_max_z = face_min_z
	
	If C3D_Actor_Type[actor] = C3D_ACTOR_TYPE_MESH Then
		face_min_z = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, C3D_Mesh_Face_Vertex[mesh, face_num, 0])
	End If
	
	face_max_z = face_min_z
	
	vcount = C3D_Mesh_Face_Vertex_Count[mesh, face_num]
	
	in_zx_range = false
	in_zy_range = false
	
	For i = 0 to vcount-1
		vz[i] = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, C3D_Mesh_Face_Vertex[mesh, face_num, i])
		vx = MatrixValue(C3D_Actor_Matrix[actor, 0], 0, C3D_Mesh_Face_Vertex[mesh, face_num, i])
		vy = MatrixValue(C3D_Actor_Matrix[actor, 0], 1, C3D_Mesh_Face_Vertex[mesh, face_num, i])
		
		distance = -1*vz[i]
		
		If distance >= 0 And distance < C3D_MAX_Z_DEPTH Then
			in_zx_range = in_zx_range Or (vx >= C3D_ZX_Range[distance, 0] And vx < C3D_ZX_Range[distance, 1])
			in_zy_range = in_zy_range Or (vy >= C3D_ZY_Range[distance, 0] And vy < C3D_ZY_Range[distance, 1])			
		ElseIf vz[i] >= 0 And vz[i] < C3D_MAX_Z_DEPTH Then
			in_zx_range = in_zx_range Or (vx >= C3D_ZX_Range[vz[i], 0] And vx < C3D_ZX_Range[vz[i], 1])
			in_zy_range = in_zy_range Or (vy >= C3D_ZY_Range[vz[i], 0] And vy < C3D_ZY_Range[vz[i], 1])
		End If
		
		face_min_z = Min(face_min_z, vz[i])
		face_max_z = Max(face_max_z, vz[i])
	Next
	
	If (Not in_zx_range) Or (Not in_zy_range) Then
		return -1
	End If
	
	z_avg = (face_min_z+face_max_z) /2 'This is some bullshit math to order the faces with out checking if they are obscured
	
	C3D_Actor_Face_ZOrder[actor, face_num] = face_min_z
	
	
	If face_min_z >= C3D_CAMERA_LENS Then
		Return -1
	Else
		Return (C3D_CAMERA_LENS - face_min_z)
	End If
	
End Function

Dim C3D_Actor_InViewRange[C3D_MAX_ACTORS]

Sub C3D_ComputeVisibleFaces()
	C3D_Visible_Init = False
	z_avg = 0
	
	C3D_Visible_Faces_Count = 0
	C3D_inSite_Actors_Count = 0
	
	
	ArrayFill(C3D_ZSort_Faces_Count, 0)
	ArrayFill(C3D_Actor_inSite, 0)
	
	
	ArrayFill(C3D_Image_TM_Div, -1)
	ArrayFill(C3D_TEXTURE_MAP_DIV_IMAGES, -1)
	
	div = 0
	div_row = 0
	div_col = 0
	
	For actor = 0 to C3D_MAX_ACTORS-1
		
		C3D_Actor_Face_inSite_Count[actor] = 0
		
		If Not (C3D_Actor_Active[actor] And C3D_Actor_InViewRange[actor]) Then
			Continue
		End If
		
		mesh = C3D_Actor_Source[actor]
	
		For face = 0 to C3D_Mesh_Face_Count[mesh]-1
			C3D_Visible_Faces[C3D_Visible_Faces_Count, 0] = actor
			C3D_Visible_Faces[C3D_Visible_Faces_Count, 1] = face
			C3D_Visible_Faces_Type[C3D_Visible_Faces_Count] = C3D_Actor_Type[actor]
			face_min_z = SetFaceZ(actor, face, z_avg)
			
			'If C3D_Actor_Type[actor] = C3D_ACTOR_TYPE_SPRITE Then
			'	print "face_min_z["; face;"] = ";face_min_z
			'End If
			
			If face_min_z >= 0 And face_min_z < C3D_MAX_Z_DEPTH Then
				C3D_Actor_inSite[actor] = True
				C3D_Actor_Face_inSite[actor, C3D_Actor_Face_inSite_Count[actor]] = face
				C3D_Actor_Face_inSite_Count[actor] = C3D_Actor_Face_inSite_Count[actor] + 1
				C3D_ZSort_Faces[face_min_z, C3D_ZSort_Faces_Count[face_min_z]] = C3D_Visible_Faces_Count
				C3D_ZSort_Faces_Distance[face_min_z, C3D_ZSort_Faces_Count[face_min_z]] = z_avg
				C3D_ZSort_Faces_Count[face_min_z] = C3D_ZSort_Faces_Count[face_min_z] + 1
				
				texture = C3D_Mesh_Texture[mesh]
				If C3D_Image_TM_Div[texture, 0] < 0 And div < C3D_MAX_TEXTURE_MAP_DIV Then
					C3D_Image_TM_Div[texture, 0] = div
					C3D_Image_TM_Div[texture, 1] = div_row
					C3D_Image_TM_Div[texture, 2] = div_col
					
					C3D_TEXTURE_MAP_DIV_IMAGES[div, div_row, div_col] = texture
					
					'debug
					'if actor = 9 then : print "texture = "; texture : print "div = ";div;", ";div_row;", ";div_col : end if
					
					div_col = div_col + 1
					If div_col >= C3D_TEXTURE_MAP_DIV[div, 1] Then
						div_col = 0
						div_row = div_row + 1
					End If
					
					If div_row >= C3D_TEXTURE_MAP_DIV[div, 0] Then
						div_row = 0
						div_col = 0
						div = div + 1
					End If
					
				End If
			End If
			C3D_Visible_Faces_Count = C3D_Visible_Faces_Count + 1
		Next
		
		If C3D_Actor_inSite[actor] Then
			C3D_inSite_Actors[C3D_inSite_Actors_Count] = actor
			C3D_inSite_Actors_Count = C3D_inSite_Actors_Count + 1
		End If
		
	Next
	'Print ""
End Sub


Function C3D_UpdateActorInViewRange(actor)
	If Not C3D_Actor_Active[actor] Then
		Return False
	End If
	
	scale = C3D_Actor_Scale[actor]
	
	r = C3D_Mesh_Radius[ C3D_Actor_Source[actor] ]
	mesh = C3D_Actor_Source[actor]
	nx = C3D_ActorPositionX(actor) + C3D_Mesh_Origin[mesh, 0]
	ny = C3D_ActorPositionY(actor) + C3D_Mesh_Origin[mesh, 1]
	nz = C3D_ActorPositionZ(actor) + C3D_Mesh_Origin[mesh, 2]
	C3D_Actor_CamDistance[actor] = C3D_Distance3D(C3D_Camera_Position[0], C3D_Camera_Position[1], C3D_Camera_Position[2], nx, ny, nz)-(r*scale)
	'If C3D_Distance2D(C3D_Camera_Position[0], C3D_Camera_Position[2], nx, nz)-(r*scale) > C3D_MAX_Z_DEPTH+50 Then
	If C3D_Actor_CamDistance[actor] > C3D_MAX_Z_DEPTH+50 Then
		C3D_Actor_InViewRange[actor] = False
	Else
		C3D_Actor_InViewRange[actor] = True
	End If
	
	'if key(k_i) and actor = 1 then
	'	print "Camera: "; C3D_Camera_Position[0]; ", "; C3D_Camera_Position[1]; ", "; C3D_Camera_Position[2]
	'	print "Actor: "; nx; ", "; ny; ", "; nz; "  --- "; C3D_Mesh_Origin[mesh, 0]; ", "; C3D_Mesh_Origin[mesh, 1]; ", "; C3D_Mesh_Origin[mesh, 2]
	'	print "Min: "; C3D_Mesh_MinX[mesh]; ", "; C3D_Mesh_MaxX[mesh]
	'	print "Distance: "; C3D_Distance3D(C3D_Camera_Position[0], C3D_Camera_Position[1], C3D_Camera_Position[2], nx, ny, nz)
	'	print ""
	'end if
	
	Return C3D_Actor_InViewRange[actor]
End Function

'Returns the closest actor at x,y position on screen
Function C3D_PickActor(x, y)
	pick_actor = -1
	
	pick_dist = C3D_MAX_Z_DEPTH
	
	For actor = 0 to C3D_MAX_ACTORS-1
	
		If Not (C3D_Actor_InViewRange[actor] And C3D_Actor_isPickable[actor]) Then
			Continue
		End If
	
		d = actor_distance[ actor ]
		min_x = actor_min_screen_x[ actor ]
		min_y = actor_min_screen_y[ actor ]
		max_x = actor_max_screen_x[ actor ]
		max_y = actor_max_screen_y[ actor ]
		
		If x >= min_x And x <= max_x Then
			If y >= min_y And y <= max_y Then
				If d > 0 And d < pick_dist Then
					pick_actor = actor
					pick_dist = d
				End If
			End If
		End If
	
	Next
	
	Return pick_actor
	
End Function


Sub C3D_ComputeTransforms()
	Dim tmp_matrix1, tmp_matrix2, camera_matrix_t
	
	tmp_matrix1 = C3D_CreateMatrix(2,2)
	tmp_matrix2 = C3D_CreateMatrix(2,2)
	camera_matrix_t = C3D_CreateMatrix(2,2)
	
	vx = C3D_CreateMatrix(4,4)
	vy = C3D_CreateMatrix(4,4)
	vz = C3D_CreateMatrix(4,4)
	view_matrix = C3D_CreateMatrix(4,4)
	
	calculateViewMatrix(vx, vy, vz)
	
	MultiplyMatrix(vx, vy, tmp_matrix1)
	MultiplyMatrix(tmp_matrix1, vz, view_matrix)
	
	ArrayFill(C3D_Actor_InViewRange, 0)
	
	
	'Reverse Camera Rotation for Sprites
	rev_x = -C3D_Camera_Rotation[0]
	rev_y = -C3D_Camera_Rotation[1]
	rev_z = -C3D_Camera_Rotation[2]
	
	LENS_X2 = C3D_CAMERA_LENS*2
	
	For actor = 0 to C3D_MAX_ACTORS-1
		
		'If the actor isn't part of the scene then check the next one
		If Not C3D_Actor_Active[actor] Then
			Continue
		ElseIf Not C3D_UpdateActorInViewRange(actor) Then
			Continue
		End If
		
		
		'Get the mesh for the actor
		
		C3D_Actor_Source[actor] = C3D_Actor_Base_Source[actor]
		mesh = C3D_Actor_Source[actor]
		If C3D_Actor_CamDistance[actor] <= C3D_Mesh_HD_Distance[mesh] Then
			If C3D_Mesh_HDMesh[mesh] >= 0 Then
				C3D_Actor_Source[actor] = C3D_Mesh_HDMesh[mesh]
				mesh = C3D_Actor_Source[actor]
			End If
		End If
		
		'Scale (Note: Camera does not have a scale. The scene can be scales by changing the left, right, top, and bottom values)
		scale = C3D_Actor_Scale[actor]
		
		C3D_RefreshActorMatrix(actor)
		
		C3D_Actor_Position[actor, 0] = C3D_ActorPositionX(actor)
		C3D_Actor_Position[actor, 1] = C3D_ActorPositionY(actor)
		C3D_Actor_Position[actor, 2] = C3D_ActorPositionZ(actor)
		
		If C3D_Actor_Type[actor] = C3D_ACTOR_TYPE_SPRITE Then
			C3D_SetActorRotation(actor, rev_x, rev_y, rev_z)
		End If
		
		'Moves the vertices based on the actors local rotation
		MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], tmp_matrix1)
		MultiplyMatrix(tmp_matrix1, C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], tmp_matrix2)
		MultiplyMatrix(tmp_matrix2, C3D_Mesh_Vertex_Matrix[mesh], tmp_matrix1)
		
		
		ScalarMatrix(tmp_matrix1, tmp_matrix1, scale)
		
		
		DimMatrix(camera_matrix_t, 4, C3D_Mesh_Vertex_Count[mesh], 0)
		
		'Create a Translation Matrix For the Camera
		FillMatrixRows(camera_matrix_t, 0, 1, C3D_Camera_Position[0])
		FillMatrixRows(camera_matrix_t, 1, 1, C3D_Camera_Position[1])
		FillMatrixRows(camera_matrix_t, 2, 1, C3D_Camera_Position[2])
		FillMatrixRows(camera_matrix_t, 3, 1, 0)
		
		'Add the Actors Translation Matrix to its rotated vertices (ie. Move the actor to its position that is set with C3D_SetActorPosition or C3D_MoveActor)
		AddMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], tmp_matrix1, tmp_matrix2)
		
		'If actor = 9 Then
		'	dim w, h
		'	GetMatrixSize(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], w, h)
		'	Print "Trans Mat: "; w;" x ";h
		'	
		'	GetMatrixSize(tmp_matrix1, w, h)
		'	Print "Tmp Mat: "; w;" x ";h
		'End If
		
		'Move the actor based on its Position to the Camera (ie. If an actor is in the center of the view and the camera moves left then the actor should move right)
		SubtractMatrix(tmp_matrix2, camera_matrix_t, tmp_matrix1)
		
		'Apply orientation in view space
		MultiplyMatrix(view_matrix, tmp_matrix1, C3D_Actor_Matrix[actor, 0])
		
		FillMatrixRows(camera_matrix_t, 0, 1, C3D_CAMERA_CENTER_X)
		FillMatrixRows(camera_matrix_t, 1, 1, C3D_CAMERA_CENTER_Y)
		FillMatrixRows(camera_matrix_t, 2, 1, C3D_CAMERA_CENTER_Z)
		AddMatrix(C3D_Actor_Matrix[actor, 0], camera_matrix_t, C3D_Actor_Matrix[actor, 0])
		
	Next
	
	'Set all the matrices we used for transforming the scene to inactive so that they can be reassigned
	C3D_DeleteMatrix(tmp_matrix1)
	C3D_DeleteMatrix(tmp_matrix2)
	C3D_DeleteMatrix(camera_matrix_t)
	C3D_DeleteMatrix(vx)
	C3D_DeleteMatrix(vy)
	C3D_DeleteMatrix(vz)	
	C3D_DeleteMatrix(view_matrix)
End Sub



'This is not important
Sub C3D_DrawMiniMap()
	return
	bx = 500
	by = 10
	bw = 100
	bh = 100
	SetColor(RGB(255,255,255))
	Rect(bx, by, bw, bh)
	
	cam_x = bx + (bw/2) - 5
	cam_y = by + bh - 10
	SetColor(RGB(255,0,0))
	Rect(cam_x, cam_y, 10, 10)
	Line(cam_x+5, by, cam_x+5, cam_y)
	
	scale_factor = bw/C3D_SCREEN_WIDTH
	
	cam_lens = by + C3D_CAMERA_LENS*scale_factor + bh
	Rect(cam_x, cam_lens-5, 10, 10)
	
	'print "SF = ";scale_factor
	
	SetColor(RGB(0,255,0))
	
	For actor = 0 to C3D_MAX_ACTORS-1
		
		If Not C3D_Actor_Active[actor] Then
			Continue
		End If
		'Print "Found Actor"
		mesh = C3D_Actor_Source[actor]
		
		
		'Don't need to worry about faces here since these transforms have to be applied to every vertex
		For vertex = 0 to C3D_Mesh_Vertex_Count[mesh]-1
		
				'vx = C3D_Actor_Vertex[actor, vertex, 0] * scale_factor + (cam_x+5) 
				'vy = C3D_Actor_Vertex[actor, vertex, 1]
				'vz = C3D_Actor_Vertex[actor, vertex, 2] * scale_factor + bh
				
				'RectFill(vx-1, vz-1, 3, 3)
				
		Next
	Next
End Sub