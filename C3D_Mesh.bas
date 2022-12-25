Include Once

Include "strings.bas"

C3D_MAX_MESH = 5
C3D_MAX_VERTICES = 99
C3D_MAX_FACES = 99
C3D_MAX_TEXTURES = 5

Dim C3D_Mesh_Active[C3D_MAX_MESH]

Dim C3D_Mesh_Vertex[C3D_MAX_MESH, C3D_MAX_VERTICES, 3]
Dim C3D_Mesh_Vertex_Count[C3D_MAX_MESH]

Dim C3D_Mesh_TCoord[C3D_MAX_MESH, C3D_MAX_VERTICES, 3]
Dim C3D_Mesh_TCoord_Count[C3D_MAX_MESH]

Dim C3D_Mesh_Face_Vertex[C3D_MAX_MESH, C3D_MAX_FACES, 4]
Dim C3D_Mesh_Face_TCoord[C3D_MAX_MESH, C3D_MAX_FACES, 4]
Dim C3D_Mesh_Face_Vertex_Count[C3D_MAX_MESH, C3D_MAX_FACES]
Dim C3D_Mesh_Face_TCoord_Count[C3D_MAX_MESH, C3D_MAX_FACES]
Dim C3D_Mesh_Face_Count[C3D_MAX_MESH]

Dim C3D_Texture[C3D_MAX_MESH, C3D_MAX_TEXTURES]
Dim C3D_Mesh_Texture_Count[C3D_MAX_MESH]


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
			C3D_Mesh_Vertex_Count[i] = 0
			C3D_Mesh_TCoord_Count[i] = 0
			C3D_Mesh_Face_Count[i] = 0
			C3D_Mesh_Texture_Count[i] = 0
			return i
		End If
	Next
	return -1
End Function


Function C3D_LoadMesh(obj_file$)
	f = FreeFile
	
	If Not FileOpen(f, obj_file$, TEXT_INPUT) Then
		Return -1
	End If
	
	mesh_num = C3D_CreateMesh()
	
	While Not EOF(f)
		f_line$ = ReadLine$(f)
		
		line_type$ = Left(f_line$, FindFirstOf(" ", f_line$))
		
		Select Case line_type$
		Case "v"
			Dim vec[3]
			v_count = C3D_GetVector(3, Replace(f_line$, "v", ""), " ", vec)
			mesh_vert_num = C3D_Mesh_Vertex_Count[mesh_num]
			C3D_Mesh_Vertex[mesh_num, mesh_vert_num, 0] = vec[0]
			C3D_Mesh_Vertex[mesh_num, mesh_vert_num, 1] = vec[1]
			C3D_Mesh_Vertex[mesh_num, mesh_vert_num, 2] = vec[2]
			C3D_Mesh_Vertex_Count[mesh_num] = mesh_vert_num + 1
			'Print "Vertex["; v_count ;"]  "; vec[0]; ", "; vec[1]; ", "; vec[2]
		Case "vt"
			Dim tc[2]
			t_count = C3D_GetVector(2, Replace(f_line$, "vt", ""), " ", tc)
			mesh_tc_num = C3D_Mesh_TCoord_Count[mesh_num]
			C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 0] = tc[0]
			C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 1] = tc[1]
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
				f_arg_count = C3D_GetVector(3, face$[i], "/", f_arg)
				For j = 0 to f_arg_count-1
					Select Case j
					Case 0: C3D_Mesh_Face_Vertex[mesh_num, mesh_face_num, i] = f_arg[j]
					Case 1: C3D_Mesh_Face_TCoord[mesh_num, mesh_face_num, i] = f_arg[j]
					End Select
					
					'Print f_arg[j]
				Next
				'Print ""
			Next
			
			C3D_Mesh_Face_Count[mesh_num] = mesh_face_num + 1
			
			'Print ""
			
		End Select
		
	Wend
	
	FileClose(f)
	
	Return mesh_num
End Function




C3D_MAX_ACTORS = 5

Dim C3D_Actor_Active[C3D_MAX_ACTORS]

Dim C3D_Actor_Position[C3D_MAX_ACTORS, 3]
Dim C3D_Actor_Rotation[C3D_MAX_ACTORS, 3]
Dim C3D_Actor_Scale[C3D_MAX_ACTORS, 3]

C3D_ACTOR_TYPE_SPRITE_2D = 1
C3D_ACTOR_TYPE_SPRITE_3D = 2
C3D_ACTOR_TYPE_MESH = 3

Dim C3D_Actor_Type[C3D_MAX_ACTORS]

Dim C3D_Actor_Source[C3D_MAX_ACTORS] 'Image or Mesh 


Function C3D_CreateActor(actor_type, actor_source)
	For i = 0 to C3D_MAX_ACTORS-1
		If Not C3D_Actor_Active[i] Then
			C3D_Actor_Active[i] = True
			C3D_Actor_Type[i] = actor_type
			C3D_Actor_Source[i] = actor_source
			Return i
		End If
	Next
	Return -1
End Function

Sub C3D_SetActorPosition(actor, x, y, z)

End Sub

Sub C3D_MoveActor(actor, x, y, z)

End Sub

Sub C3D_SetActorRotation(actor, x, y, z)

End Sub

Sub C3D_RotateActor(actor, x, y, z)

End Sub

Sub C3D_SetActorScale(actor, x, y, z)

End Sub

Sub C3D_ScaleActor(actor, x, y, z)

End Sub





C3D_MAX_SCENE_FACES = 400
Dim C3D_Visible_Faces[C3D_MAX_SCENE_FACES, 2] '0 is actor, 1 is face
C3D_Visible_Faces_Count = 0


Dim C3D_Actor_Vertex[C3D_MAX_ACTORS, C3D_MAX_VERTICES, 3]
Dim C3D_Actor_Vertex_Count[C3D_MAX_ACTORS]

Dim C3D_Actor_TCoord[C3D_MAX_ACTORS, C3D_MAX_VERTICES, 3]
Dim C3D_Actor_TCoord_Count[C3D_MAX_ACTORS]

Dim C3D_Actor_Face_Vertex[C3D_MAX_ACTORS, C3D_MAX_FACES, 4]
Dim C3D_Actor_Face_TCoord[C3D_MAX_ACTORS, C3D_MAX_FACES, 4]
Dim C3D_Actor_Face_Vertex_Count[C3D_MAX_ACTORS, C3D_MAX_FACES]
Dim C3D_Actor_Face_TCoord_Count[C3D_MAX_ACTORS, C3D_MAX_FACES]
Dim C3D_Actor_Face_Count[C3D_MAX_ACTORS]

Dim C3D_Visible_Init
Dim C3D_Visible_Min_X
Dim C3D_Visible_Min_Y
Dim C3D_Visible_Max_X
Dim C3D_Visible_Max_Y

Function PointCheck(actor, vert_num, face_num, ByRef point_z, ByRef face_closest_z)
	vx = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, vert_num], 0]
	vy = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, vert_num], 1]
	vz = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, vert_num], 2]
	
	Dim f_vx[4]
	Dim f_vy[4]
	Dim f_vz[4]
	
	f_v_count = C3D_Actor_Face_Vertex_Count[actor, face_num]
	
	min_x = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 0]
	min_y = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 1]
	max_x = min_x
	max_y = min_y
	face_closest_z = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 2]
	
	For i = 0 to C3D_Actor_Face_Vertex_Count[actor, face_num] - 1
		f_vx[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 0]
		f_vy[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 1]
		f_vz[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 2]
		min_x = Min(min_x, f_vx[i])
		min_y = Min(min_y, f_vy[i])
		max_x = Max(max_x, f_vx[i])
		max_y = Max(max_y, f_vy[i])
		face_closest_z = Min(face_closest_z, f_vz[i])
	Next
	
	If Not C3D_Visible_Init Then
		C3D_Visible_Min_X = min_x
		C3D_Visible_Min_Y = min_y
		C3D_Visible_Max_X = max_x
		C3D_Visible_Max_Y = max_y
		C3D_Visible_Init = True
	Else
		C3D_Visible_Min_X = Min(C3D_Visible_Min_X, min_x)
		C3D_Visible_Min_Y = Min(C3D_Visible_Min_Y, min_y)
		C3D_Visible_Max_X = Max(C3D_Visible_Max_X, max_x)
		C3D_Visible_Max_Y = Max(C3D_Visible_Max_Y, max_y)
	End If
	
	point_z = vz
	
	cmp_x = (vx >= min_x) And (vx <= max_x)
	cmp_y = (vy >= min_y) And (vy <= max_y)
	
	Return (cmp_x And cmp_y)
	
End Function

Dim C3D_Actor_Face_ZOrder[C3D_MAX_ACTORS, C3D_MAX_FACES]

Function SetFaceZ(actor, face_num)
	
	Dim vy[4]
	Dim vz[4]
	face_min_z = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 2]
	vcount = C3D_Actor_Face_Vertex_Count[actor, face_num]
	
	For i = 0 to vcount-1
		vy[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 1]
		vz[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 2]
		face_min_z = Min(face_min_z, vz[i])
	Next
	
	C3D_Actor_Face_ZOrder[actor, face_num] = 0
	
	For i = 0 to C3D_Visible_Faces_Count-1
		cmp_actor = C3D_Visible_Faces[i, 0]
		cmp_face = C3D_Visible_Faces[i, 1]
		cmp_min_z = C3D_Actor_Vertex[cmp_actor, C3D_Actor_Face_Vertex[cmp_actor, cmp_face, 0], 2]
		For cmp_vert_num = 0 to C3D_Actor_Face_Vertex_Count[cmp_actor, cmp_face]-1
			cmp_vertex = C3D_Actor_Face_Vertex[cmp_actor, cmp_face, cmp_vert_num]
			cmp_min_z = Min(cmp_min_z, C3D_Actor_Vertex[cmp_actor, cmp_vertex, 2])
		Next
		
		If face_min_z > cmp_min_z Then
			C3D_Actor_Face_ZOrder[actor, face_num] = C3D_Actor_Face_ZOrder[actor, face_num] + 1
		End If
	Next
	
	Return 0
	
End Function


Sub C3D_ComputeVisibleFaces(actor)
	C3D_Visible_Init = False
	Dim p_cmp[4]
	
	'C3D_Visible_Faces
	
	For a = 0 to C3D_Actor_Face_Count[actor]-1
		
	Next
End Sub