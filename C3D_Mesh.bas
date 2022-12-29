Include Once
Include "C3D_Camera.bas"
Include "strings.bas"
Include "Utility.bas"

C3D_MAX_MESH = 5
C3D_MAX_VERTICES = 99
C3D_MAX_FACES = 99

Dim C3D_Mesh_Active[C3D_MAX_MESH]

Dim C3D_Mesh_Vertex[C3D_MAX_MESH, C3D_MAX_VERTICES, 3] 'x, y, and z
Dim C3D_Mesh_Vertex_Count[C3D_MAX_MESH]

Dim C3D_Mesh_Origin[C3D_MAX_MESH, 3]

Dim C3D_Mesh_TCoord[C3D_MAX_MESH, C3D_MAX_VERTICES, 2] 'u and v
Dim C3D_Mesh_TCoord_Count[C3D_MAX_MESH]

Dim C3D_Mesh_Face_Vertex[C3D_MAX_MESH, C3D_MAX_FACES, 4] 'references a point in C3D_Mesh_Vertex
Dim C3D_Mesh_Face_TCoord[C3D_MAX_MESH, C3D_MAX_FACES, 4] 'references a point in C3D_Mesh_TCoord
Dim C3D_Mesh_Face_Vertex_Count[C3D_MAX_MESH, C3D_MAX_FACES]
Dim C3D_Mesh_Face_TCoord_Count[C3D_MAX_MESH, C3D_MAX_FACES]
Dim C3D_Mesh_Face_Count[C3D_MAX_MESH]

Dim C3D_Mesh_Texture[C3D_MAX_MESH] 'references an index in C3D_Images


Function C3D_GetVector(vector_size, vector_string$, delimeter$, ByRef vector_out)
	Dim v[vector_size]
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
			C3D_Mesh_Texture[i] = 0
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
	
	Dim min_x, min_y, min_z, max_x, max_y, max_z, min_max_init
	
	min_max_init = False
	
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
			Print "Vertex["; v_count ;"]  "; vec[0]; ", "; vec[1]; ", "; vec[2]
		Case "vt"
			Dim tc[2]
			t_count = C3D_GetVector(2, Replace(f_line$, "vt", ""), " ", tc)
			mesh_tc_num = C3D_Mesh_TCoord_Count[mesh_num]
			C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 0] = tc[0]
			C3D_Mesh_TCoord[mesh_num, mesh_tc_num, 1] = 1-tc[1]
			C3D_Mesh_TCoord_Count[mesh_num] = mesh_tc_num + 1
			Print "TexCoord: ";  tc[0]; ", "; tc[1]
		Case "f"
			Dim face$[32]
			f_count = Split(Replace(f_line$, "f", ""), " ", face)
			mesh_face_num = C3D_Mesh_Face_Count[mesh_num]
			Print "Face["; f_count; "]"
			
			C3D_Mesh_Face_Vertex_Count[mesh_num, mesh_face_num] = f_count
			C3D_Mesh_Face_TCoord_Count[mesh_num, mesh_face_num] = f_count
			
			Dim f_arg[3]
			
			For i = 0 to f_count-1
				Print "-- Point ["; i; "] --"
				Print "FDATA = "; face[i]
				f_arg_count = C3D_GetVector(3, face$[i], "/", f_arg)
				For j = 0 to f_arg_count-1
					Select Case j
					Case 0: C3D_Mesh_Face_Vertex[mesh_num, mesh_face_num, i] = f_arg[j]-1 : Print " Vertex = ";
					Case 1: C3D_Mesh_Face_TCoord[mesh_num, mesh_face_num, i] = f_arg[j]-1 : Print ", UV = ";
					Default : Exit For
					End Select
					
					Print f_arg[j];
				Next
				Print ""
			Next
			
			C3D_Mesh_Face_Count[mesh_num] = mesh_face_num + 1
			
			Print ""
			
		End Select
		
	Wend
	
	FileClose(f)
	
	C3D_Mesh_Origin[mesh_num, 0] = (min_x + max_x)/2
	C3D_Mesh_Origin[mesh_num, 1] = (min_y + max_y)/2
	C3D_Mesh_Origin[mesh_num, 2] = (min_z + max_z)/2
	
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





C3D_MAX_SCENE_FACES = 400
C3D_MAX_Z_DEPTH = 500
Dim C3D_Visible_Faces[C3D_MAX_SCENE_FACES, 2] '0 is actor, 1 is face
Dim C3D_ZSort_Faces[C3D_MAX_Z_DEPTH, C3D_MAX_SCENE_FACES] 'reference item in C3D_Visible_Faces, 500 is max Z depth (I will probably change it later)
Dim C3D_ZSort_Faces_Count[C3D_MAX_Z_DEPTH]


Dim C3D_Visible_Faces_Type[C3D_MAX_SCENE_FACES]
C3D_Visible_Faces_Count = 0


Dim C3D_Actor_Vertex[C3D_MAX_ACTORS, C3D_MAX_VERTICES, 3] 'x, y, and z
Dim C3D_Actor_Vertex_Count[C3D_MAX_ACTORS]

Dim C3D_Visible_Init
Dim C3D_Visible_Min_X
Dim C3D_Visible_Min_Y
Dim C3D_Visible_Max_X
Dim C3D_Visible_Max_Y


Function C3D_CreateActor(actor_type, actor_source)
	For i = 0 to C3D_MAX_ACTORS-1
		If Not C3D_Actor_Active[i] Then
			C3D_Actor_Active[i] = True
			C3D_Actor_Type[i] = actor_type
			C3D_Actor_Source[i] = actor_source
			
			'Print "face_count = ";C3D_Actor_Face_Count[i]
			
			'Defaults
			C3D_Actor_Position[i, 0] = 0
			C3D_Actor_Position[i, 1] = 0
			C3D_Actor_Position[i, 2] = 0
			
			C3D_Actor_Rotation[i, 0] = 0
			C3D_Actor_Rotation[i, 1] = 0
			C3D_Actor_Rotation[i, 2] = 0
			
			C3D_Actor_Scale[i, 0] = 1
			C3D_Actor_Scale[i, 1] = 1
			C3D_Actor_Scale[i, 2] = 1
			Return i
		End If
	Next
	Return -1
End Function

Sub C3D_ClearActor(actor)
	C3D_Actor_Active[actor] = False
End Sub

Sub C3D_SetActorPosition(actor, x, y, z)
	C3D_Actor_Position[actor, 0] = x
	C3D_Actor_Position[actor, 1] = y
	C3D_Actor_Position[actor, 2] = z
End Sub

Sub C3D_MoveActor(actor, x, y, z)
	C3D_Actor_Position[actor, 0] = C3D_Actor_Position[actor, 0] + x
	C3D_Actor_Position[actor, 1] = C3D_Actor_Position[actor, 1] + y
	C3D_Actor_Position[actor, 2] = C3D_Actor_Position[actor, 2] + z
End Sub

Sub C3D_SetActorRotation(actor, x, y, z)
	C3D_Actor_Rotation[actor, 0] = x
	C3D_Actor_Rotation[actor, 1] = y
	C3D_Actor_Rotation[actor, 2] = z
End Sub

Sub C3D_RotateActor(actor, x, y, z)
	C3D_Actor_Rotation[actor, 0] = (C3D_Actor_Rotation[actor, 0] + x) MOD 360
	C3D_Actor_Rotation[actor, 1] = (C3D_Actor_Rotation[actor, 1] + y) MOD 360
	C3D_Actor_Rotation[actor, 2] = (C3D_Actor_Rotation[actor, 2] + z) MOD 360
	
	Print "Rotation = ";C3D_Actor_Rotation[actor, 0];", ";C3D_Actor_Rotation[actor, 1];", ";C3D_Actor_Rotation[actor, 2]
End Sub

Sub C3D_SetActorScale(actor, x, y, z)
	C3D_Actor_Scale[actor, 0] = x
	C3D_Actor_Scale[actor, 1] = y
	C3D_Actor_Scale[actor, 2] = z
End Sub

Sub C3D_ScaleActor(actor, x, y, z)
	C3D_Actor_Scale[actor, 0] = C3D_Actor_Scale[actor, 0] * x
	C3D_Actor_Scale[actor, 1] = C3D_Actor_Scale[actor, 1] * y
	C3D_Actor_Scale[actor, 2] = C3D_Actor_Scale[actor, 2] * z
End Sub



'Function PointCheck(actor, vert_num, face_num, ByRef point_z, ByRef face_closest_z)
'	vx = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, vert_num], 0]
'	vy = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, vert_num], 1]
'	vz = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, vert_num], 2]
'	
'	Dim f_vx[4]
'	Dim f_vy[4]
'	Dim f_vz[4]
'	
'	f_v_count = C3D_Actor_Face_Vertex_Count[actor, face_num]
'	
'	min_x = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 0]
'	min_y = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 1]
'	max_x = min_x
'	max_y = min_y
'	face_closest_z = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, 0], 2]
'	
'	For i = 0 to C3D_Actor_Face_Vertex_Count[actor, face_num] - 1
'		f_vx[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 0]
'		f_vy[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 1]
'		f_vz[i] = C3D_Actor_Vertex[ actor, C3D_Actor_Face_Vertex[actor, face_num, i], 2]
'		min_x = Min(min_x, f_vx[i])
'		min_y = Min(min_y, f_vy[i])
'		max_x = Max(max_x, f_vx[i])
'		max_y = Max(max_y, f_vy[i])
'		face_closest_z = Min(face_closest_z, f_vz[i])
'	Next
'	
'	If Not C3D_Visible_Init Then
'		C3D_Visible_Min_X = min_x
'		C3D_Visible_Min_Y = min_y
'		C3D_Visible_Max_X = max_x
'		C3D_Visible_Max_Y = max_y
'		C3D_Visible_Init = True
'	Else
'		C3D_Visible_Min_X = Min(C3D_Visible_Min_X, min_x)
'		C3D_Visible_Min_Y = Min(C3D_Visible_Min_Y, min_y)
'		C3D_Visible_Max_X = Max(C3D_Visible_Max_X, max_x)
'		C3D_Visible_Max_Y = Max(C3D_Visible_Max_Y, max_y)
'	End If
'	
'	point_z = vz
'	
'	cmp_x = (vx >= min_x) And (vx <= max_x)
'	cmp_y = (vy >= min_y) And (vy <= max_y)
'	
'	Return (cmp_x And cmp_y)
'	
'End Function

Dim C3D_Actor_Face_ZOrder[C3D_MAX_ACTORS, C3D_MAX_FACES]

Function SetFaceZ(actor, face_num)
	
	Dim vy[4]
	Dim vz[4]
	mesh = C3D_Actor_Source[actor]
	
	'Set this as a default if its a sprite, Might need to change this when I actually implement sprites
	face_min_z = C3D_Actor_Vertex[actor, 0, 2]
	face_max_z = face_min_z
	
	If C3D_Actor_Type[actor] = C3D_ACTOR_TYPE_MESH Then
		face_min_z = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, 0], 2]
	End If
	vcount = C3D_Mesh_Face_Vertex_Count[mesh, face_num]
	
	For i = 0 to vcount-1
		'vy[i] = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, i], 1]
		vz[i] = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, i], 2]
		'If vz[i] >= 0 Then
		'	If face_min_z < 0 Then
		'		face_min_z = vz[i]
		'	Else
		face_min_z = Min(face_min_z, vz[i])
		'	End If
		'End If
		face_max_z = Max(face_max_z, vz[i])
	Next
	
	'Print "Min/Max = ";face_min_z;", ";face_max_z
	
	face_min_z = (face_min_z+face_max_z)/2 'This is some bullshit math to order the faces with out checking if they are obscured
	
	C3D_Actor_Face_ZOrder[actor, face_num] = face_min_z
	
	Return (C3D_CAMERA_LENS - face_min_z)
	
	'For i = 0 to C3D_Visible_Faces_Count-1
	'	cmp_actor = C3D_Visible_Faces[i, 0]
	'	cmp_face = C3D_Visible_Faces[i, 1]
	'	cmp_min_z = C3D_Actor_Vertex[cmp_actor, C3D_Actor_Face_Vertex[cmp_actor, cmp_face, 0], 2]
	'	For cmp_vert_num = 0 to C3D_Actor_Face_Vertex_Count[cmp_actor, cmp_face]-1
	'		cmp_vertex = C3D_Actor_Face_Vertex[cmp_actor, cmp_face, cmp_vert_num]
	'		cmp_min_z = Min(cmp_min_z, C3D_Actor_Vertex[cmp_actor, cmp_vertex, 2])
	'	Next
	'	
	'	If face_min_z > cmp_min_z Then
	'		C3D_Actor_Face_ZOrder[actor, face_num] = C3D_Actor_Face_ZOrder[actor, face_num] + 1
	'	End If
	'Next
	
	'Return 0
	
End Function


Sub C3D_ComputeVisibleFaces()
	C3D_Visible_Init = False
	
	'Print "Visible_Face_Count = "; C3D_Visible_Faces_Count
	C3D_Visible_Faces_Count = 0
	
	For i = 0 to C3D_MAX_Z_DEPTH-1
		C3D_ZSort_Faces_Count[i] = 0
	Next
	
	'Setting All faces visible for now
	
	For actor = 0 to C3D_MAX_ACTORS-1
		
		If Not C3D_Actor_Active[actor] Then
			Continue
		End If
		
		mesh = C3D_Actor_Source[actor]
	
		For face = 0 to C3D_Mesh_Face_Count[mesh]-1
			C3D_Visible_Faces[C3D_Visible_Faces_Count, 0] = actor
			C3D_Visible_Faces[C3D_Visible_Faces_Count, 1] = face
			C3D_Visible_Faces_Type[C3D_Visible_Faces_Count] = C3D_Actor_Type[actor]
			face_min_z = SetFaceZ(actor, face)
			'Print "face_min_z[ a=";actor;", f=";face;" ] = ";face_min_z
			If face_min_z >= 0 And face_min_z < C3D_MAX_Z_DEPTH Then
				'Print "VISIBLE FACE DBG: z = ";face_min_z;"  face = "; C3D_Visible_Faces_Count
				'Print "ZSort_Faces_Count[";face_min_z;"] = ";C3D_ZSort_Faces_Count[face_min_z]
				C3D_ZSort_Faces[face_min_z, C3D_ZSort_Faces_Count[face_min_z]] = C3D_Visible_Faces_Count
				C3D_ZSort_Faces_Count[face_min_z] = C3D_ZSort_Faces_Count[face_min_z] + 1
			End If
			C3D_Visible_Faces_Count = C3D_Visible_Faces_Count + 1
		Next
	Next
	
End Sub


Sub C3D_ComputeTransforms()
	For actor = 0 to C3D_MAX_ACTORS-1
		
		If Not C3D_Actor_Active[actor] Then
			Continue
		End If
		'Print "Found Actor"
		mesh = C3D_Actor_Source[actor]
		
		'Position
		pos_x = C3D_Actor_Position[actor, 0] - C3D_Camera_Position[0]
		pos_y = C3D_Actor_Position[actor, 1] - C3D_Camera_Position[1]
		pos_z = C3D_Actor_Position[actor, 2] - C3D_Camera_Position[2]
		
		'Rotation (Note: All rotations in the engine will be in degrees and I am converting it to radians here)
		rot_x = C3D_Actor_Rotation[actor, 0] + C3D_Camera_Rotation[0]
		rot_y = C3D_Actor_Rotation[actor, 1] + C3D_Camera_Rotation[1]
		rot_z = C3D_Actor_Rotation[actor, 2] + C3D_Camera_Rotation[2]
		
		center_x = C3D_Mesh_Origin[mesh, 0]
		center_y = C3D_Mesh_Origin[mesh, 1]
		center_z = C3D_Mesh_Origin[mesh, 2]
		
		'Scale (Note: Camera does not have a scale. The scene can be scales by changing the left, right, top, and bottom values)
		scale_x = C3D_Actor_Scale[actor, 0]
		scale_y = C3D_Actor_Scale[actor, 1]
		scale_z = C3D_Actor_Scale[actor, 2]
		
		'Don't need to worry about faces here since these transforms have to be applied to every vertex
		For vertex = 0 to C3D_Mesh_Vertex_Count[mesh]-1
				'vertex
				vx = C3D_Mesh_Vertex[mesh, vertex, 0]
				vy = C3D_Mesh_Vertex[mesh, vertex, 1]
				vz = C3D_Mesh_Vertex[mesh, vertex, 2]
				
				'Actor Transforms
				'Rotate On X
				C3D_RotatePoint(vy, vz, center_y, center_z, rot_x, vy, vz)
				
				'Rotate On Y
				C3D_RotatePoint(vx, vz, center_x, center_z, rot_y, vx, vz)
				
				'Rotate On Z
				C3D_RotatePoint(vx, vy, center_x, center_y, rot_z, vx, vy)
				
				
				'Orientation to Camera
				'Rotate On X
				C3D_RotatePoint(vy, vz, C3D_CAMERA_CENTER_Y, C3D_CAMERA_CENTER_Z, C3D_Camera_Rotation[0], vy, vz)
				
				'Rotate On Y
				C3D_RotatePoint(vx, vz, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Z, C3D_Camera_Rotation[1], vx, vz)
				
				'Rotate On Z
				C3D_RotatePoint(vx, vy, C3D_CAMERA_CENTER_X, C3D_CAMERA_CENTER_Y, C3D_Camera_Rotation[2], vx, vy)
				
				'Scaling is not implemented yet
				
				C3D_Actor_Vertex[actor, vertex, 0] = vx + pos_x
				C3D_Actor_Vertex[actor, vertex, 1] = vy + pos_y
				C3D_Actor_Vertex[actor, vertex, 2] = vz + pos_z
		Next
	Next
End Sub