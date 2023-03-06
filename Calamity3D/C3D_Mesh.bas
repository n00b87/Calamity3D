Include Once
Include "Calamity3D/C3D_Image.bas"
Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/strings.bas"
Include "Calamity3D/C3D_Utility.bas"
Include "Calamity3D/C3D_Matrix.bas"

C3D_MAX_MESH = 100
C3D_MAX_VERTICES = 5000
C3D_MAX_FACES = 5000

Dim C3D_Mesh_Active[C3D_MAX_MESH]

Dim C3D_Mesh_TMP_Vertex[C3D_MAX_VERTICES, 4] 'x, y, z, w = 1.0
Dim C3D_Mesh_Vertex_Matrix[C3D_MAX_MESH] 'x, y, and z
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
	
	tmp_matrix = C3D_CreateMatrix(2,2)
	MatrixFromBuffer(tmp_matrix, C3D_Mesh_Vertex_Count[mesh_num], 4, C3D_Mesh_TMP_Vertex)
	TransposeMatrix(tmp_matrix, C3D_Mesh_Vertex_Matrix[mesh_num])
	C3D_DeleteMatrix(tmp_matrix)
	
	Return mesh_num
End Function

Sub C3D_SetMeshTexture(mesh, img)
	C3D_Mesh_Texture[mesh] = C3D_Image[img]
End Sub




C3D_MAX_ACTORS = 100

Dim C3D_Actor_Active[C3D_MAX_ACTORS]

Dim C3D_Actor_Position[C3D_MAX_ACTORS, 3]
Dim C3D_Actor_Rotation[C3D_MAX_ACTORS, 3]
Dim C3D_Actor_Scale[C3D_MAX_ACTORS]

C3D_ACTOR_TYPE_SPRITE_2D = 1
C3D_ACTOR_TYPE_SPRITE_3D = 2
C3D_ACTOR_TYPE_MESH = 3

Dim C3D_Actor_Type[C3D_MAX_ACTORS]

Dim C3D_Actor_Source[C3D_MAX_ACTORS] 'Image or Mesh 

C3D_ACTOR_MATRIX_T = 1
C3D_ACTOR_MATRIX_RX = 2
C3D_ACTOR_MATRIX_RY = 3
C3D_ACTOR_MATRIX_RZ = 4

C3D_MAX_SCENE_FACES = 3000
Dim C3D_Visible_Faces[C3D_MAX_SCENE_FACES, 2] '0 is actor, 1 is face
Dim C3D_ZSort_Faces[C3D_MAX_Z_DEPTH, C3D_MAX_SCENE_FACES] 'reference item in C3D_Visible_Faces, 500 is max Z depth (I will probably change it later)
Dim C3D_ZSort_Faces_Distance[C3D_MAX_Z_DEPTH, C3D_MAX_SCENE_FACES]
Dim C3D_ZSort_Faces_Count[C3D_MAX_Z_DEPTH]
Dim C3D_Actor_Face_ZOrder[C3D_MAX_ACTORS, C3D_MAX_FACES]

Dim C3D_Visible_Faces_Type[C3D_MAX_SCENE_FACES]
C3D_Visible_Faces_Count = 0


Dim C3D_Actor_Matrix[C3D_MAX_ACTORS, 5] 'Output, Translation, and Rotation

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
			
			C3D_Actor_Scale[i] = 1
			
			C3D_Actor_Matrix[i, 0] = C3D_CreateMatrix(2,2) 'OUTPUT MATRIX
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T] = C3D_CreateMatrix(2,2) 'TRANSLATE MATRIX
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RX] = C3D_CreateMatrix(2,2) 'ROTATE X
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RY] = C3D_CreateMatrix(2,2) 'ROTATE Y
			C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RZ] = C3D_CreateMatrix(2,2) 'ROTATE Z
			
			C3D_SetRotationMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RX], C3D_AXIS_X, 0)
			C3D_SetRotationMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RY], C3D_AXIS_Y, 0)
			C3D_SetRotationMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_RZ], C3D_AXIS_Z, 0)
			
			Select Case actor_type
				Case C3D_ACTOR_TYPE_MESH
					DimMatrix(C3D_Actor_Matrix[i, 0], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM OUTPUT MATRIX
					DimMatrix(C3D_Actor_Matrix[i, C3D_ACTOR_MATRIX_T], 4, C3D_Mesh_Vertex_Count[actor_source], 0) 'DIM TRANSLATION MATRIX
				Case C3D_ACTOR_TYPE_SPRITE_2D
				Case C3D_ACTOR_TYPE_SPRITE_3D
			End Select
			Return i
		End If
	Next
	Return -1
End Function

Function C3D_GetActorMesh(actor)
	Return C3D_Actor_Source[actor]
End Function

Sub C3D_ClearActor(actor)
	C3D_Actor_Active[actor] = False
End Sub

Sub C3D_SetActorPosition(actor, x, y, z)
	'C3D_Actor_Position[actor, 0] = x
	'C3D_Actor_Position[actor, 1] = y
	'C3D_Actor_Position[actor, 2] = z
	'actor_source = C3D_Actor_Source[actor]
	
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, x)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, y)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, z)
End Sub

Sub C3D_MoveActor(actor, x, y, z)
	'C3D_Actor_Position[actor, 0] = C3D_Actor_Position[actor, 0] + x
	'C3D_Actor_Position[actor, 1] = C3D_Actor_Position[actor, 1] + y
	'C3D_Actor_Position[actor, 2] = C3D_Actor_Position[actor, 2] + z
	
	
	tx = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 0) + x
	ty = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 0) + y
	tz = MatrixValue(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 0) + z
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 0, 1, tx)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 1, 1, ty)
	FillMatrixRows(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], 2, 1, tz)
End Sub

Sub C3D_SetActorRotation(actor, x, y, z)
	C3D_Actor_Rotation[actor, 0] = x
	C3D_Actor_Rotation[actor, 1] = y
	C3D_Actor_Rotation[actor, 2] = z
	
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], C3D_AXIS_X, x)
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], C3D_AXIS_Y, y)
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], C3D_AXIS_Z, z)
End Sub

Sub C3D_RotateActor(actor, x, y, z)
	C3D_Actor_Rotation[actor, 0] = ((C3D_Actor_Rotation[actor, 0] + x) MOD 360)
	C3D_Actor_Rotation[actor, 1] = ((C3D_Actor_Rotation[actor, 1] + y) MOD 360)
	C3D_Actor_Rotation[actor, 2] = ((C3D_Actor_Rotation[actor, 2] + z) MOD 360)
	
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], C3D_AXIS_X, C3D_Actor_Rotation[actor, 0])
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], C3D_AXIS_Y, C3D_Actor_Rotation[actor, 1])
	C3D_SetRotationMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], C3D_AXIS_Z, C3D_Actor_Rotation[actor, 2])
	
	'Print "Rotation = ";C3D_Actor_Rotation[actor, 0];", ";C3D_Actor_Rotation[actor, 1];", ";C3D_Actor_Rotation[actor, 2]
End Sub

Sub C3D_SetActorScale(actor, s_value)
	C3D_Actor_Scale[actor] = s_value
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
	Dim outlier_index[4]
	oi_count = 0
	
	
	Dim vertex_x, vertex_y, vertex_z
	'Set this as a default if its a sprite, Might need to change this when I actually implement sprites
	'face_min_z = C3D_Actor_Vertex[actor, 0, 2]
	face_min_z = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, 0)
	
	'min_zx = C3D_Actor_Vertex[actor, 0, 0]
	'min_zx = MatrixValue(C3D_Actor_Matrix[actor, 0], 0, 0)
	
	face_max_z = face_min_z
	
	If C3D_Actor_Type[actor] = C3D_ACTOR_TYPE_MESH Then
		'face_min_z = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, 0], 2]
		'min_zx = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, 0], 0]
		face_min_z = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, C3D_Mesh_Face_Vertex[mesh, face_num, 0])
		'min_zx = MatrixValue(C3D_Actor_Matrix[actor, 0], 0, C3D_Mesh_Face_Vertex[mesh, face_num, 0])
	End If
	
	face_max_z = face_min_z
	
	vcount = C3D_Mesh_Face_Vertex_Count[mesh, face_num]
	
	in_zx_range = false
	in_zy_range = false
	
	For i = 0 to vcount-1
		'vy[i] = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, i], 1]
		'vz[i] = C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, i], 2]
		vz[i] = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, C3D_Mesh_Face_Vertex[mesh, face_num, i])
		
		vx = MatrixValue(C3D_Actor_Matrix[actor, 0], 0, C3D_Mesh_Face_Vertex[mesh, face_num, i])
		vy = MatrixValue(C3D_Actor_Matrix[actor, 0], 1, C3D_Mesh_Face_Vertex[mesh, face_num, i])
		
		distance = -1*vz[i]
		
		If distance >= 0 And distance < C3D_MAX_Z_DEPTH Then
			in_zx_range = in_zx_range Or (vx >= C3D_ZX_Range[distance, 0] And vx < C3D_ZX_Range[distance, 1]) 'Or (vy >= C3D_ZY_Range[distance, 0] And vy < C3D_ZY_Range[distance, 1])
			in_zy_range = in_zy_range Or (vy >= C3D_ZY_Range[distance, 0] And vy < C3D_ZY_Range[distance, 1])
			
			If key(k_p) Then
				Print "Z = ";distance; "  -- ";vy; " --> (";C3D_ZY_Range[distance, 0];", ";C3D_ZY_Range[distance, 1];")    ===>>> ";in_zy_range
			End If
		
		ElseIf vz[i] >= 0 And vz[i] < C3D_MAX_Z_DEPTH Then
			in_zx_range = in_zx_range Or (vx >= C3D_ZX_Range[vz[i], 0] And vx < C3D_ZX_Range[vz[i], 1])
			in_zy_range = in_zy_range Or (vy >= C3D_ZY_Range[vz[i], 0] And vy < C3D_ZY_Range[vz[i], 1])
		End If
		
		If key(k_n) And distance < 100 And (Not in_zy_range) Then
			Print "Z = ";distance;"  ==  ";vy
		End If
		
		face_min_z = Min(face_min_z, vz[i])
		'C3D_Ternary(face_min_z=vz[i], min_zx, C3D_Actor_Vertex[ actor, C3D_Mesh_Face_Vertex[mesh, face_num, i], 0], min_zx)
		'C3D_Ternary(face_min_z=vz[i], min_zx, MatrixValue(C3D_Actor_Matrix[actor, 0], 0, C3D_Mesh_Face_Vertex[mesh, face_num, i]), min_zx)
		
		'	End If
		'End If
		face_max_z = Max(face_max_z, vz[i])
		If face_max_z >= C3D_CAMERA_LENS Then
			outlier_index[oi_count] = i
			oi_count = oi_count + 1
		End If
	Next
	
	If (Not in_zx_range) Or (Not in_zy_range) Then
		return -1
	End If
	
	'Print "Min/Max = ";face_min_z;", ";face_max_z
	
	z_avg = (face_min_z+face_max_z) /2 'This is some bullshit math to order the faces with out checking if they are obscured
	
	C3D_Actor_Face_ZOrder[actor, face_num] = face_min_z
	
	If face_max_z >= C3D_CAMERA_LENS Then
		Return -1
	Else
		Return (C3D_CAMERA_LENS - face_min_z)
	End If
	
End Function


Sub C3D_ComputeVisibleFaces()
	C3D_Visible_Init = False
	z_avg = 0
	
	'Print "Visible_Face_Count = "; C3D_Visible_Faces_Count
	C3D_Visible_Faces_Count = 0
	
	'For i = 0 to C3D_MAX_Z_DEPTH-1
	'	C3D_ZSort_Faces_Count[i] = 0
	'Next
	
	ArrayFill(C3D_ZSort_Faces_Count, 0)
	
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
			face_min_z = SetFaceZ(actor, face, z_avg)
			'Print "face_min_z[ a=";actor;", f=";face;" ] = ";face_min_z
			If face_min_z >= 0 And face_min_z < C3D_MAX_Z_DEPTH Then
				C3D_ZSort_Faces[face_min_z, C3D_ZSort_Faces_Count[face_min_z]] = C3D_Visible_Faces_Count
				C3D_ZSort_Faces_Distance[face_min_z, C3D_ZSort_Faces_Count[face_min_z]] = z_avg
				C3D_ZSort_Faces_Count[face_min_z] = C3D_ZSort_Faces_Count[face_min_z] + 1
			End If
			C3D_Visible_Faces_Count = C3D_Visible_Faces_Count + 1
		Next
	Next
	
End Sub


Sub C3D_ComputeTransforms()
	Dim tmp_matrix1, tmp_matrix2, camera_matrix_t
	
	tmp_matrix1 = C3D_CreateMatrix(2,2)
	tmp_matrix2 = C3D_CreateMatrix(2,2)
	camera_matrix_t = C3D_CreateMatrix(2,2)
	
	vx = C3D_CreateMatrix(4,4)
	vy = C3D_CreateMatrix(4,4)
	vz = C3D_CreateMatrix(4,4)
	
	calculateViewMatrix(vx, vy, vz)
	
	For actor = 0 to C3D_MAX_ACTORS-1
		
		'If the actor isn't part of the scene then check the next one
		If Not C3D_Actor_Active[actor] Then
			Continue
		End If
		
		'Get the mesh for the actor
		mesh = C3D_Actor_Source[actor]
		
		'Scale (Note: Camera does not have a scale. The scene can be scales by changing the left, right, top, and bottom values)
		scale = C3D_Actor_Scale[actor]
		
		'Moves the vertices based on the actors local rotation
		MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RY], C3D_Mesh_Vertex_Matrix[mesh], tmp_matrix1)
		MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RX], tmp_matrix1, tmp_matrix2)
		MultiplyMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_RZ], tmp_matrix2, tmp_matrix1)
		
		ScalarMatrix(tmp_matrix1, tmp_matrix1, scale)
		
		
		DimMatrix(camera_matrix_t, 4, C3D_Mesh_Vertex_Count[mesh], 0)
		
		'Create a Translation Matrix For the Camera
		FillMatrixRows(camera_matrix_t, 0, 1, C3D_Camera_Position[0])
		FillMatrixRows(camera_matrix_t, 1, 1, C3D_Camera_Position[1])
		FillMatrixRows(camera_matrix_t, 2, 1, C3D_Camera_Position[2])
		FillMatrixRows(camera_matrix_t, 3, 1, 0)
		
		'Add the Actors Translation Matrix to its rotated vertices (ie. Move the actor to its position that is set with C3D_SetActorPosition or C3D_MoveActor)
		AddMatrix(C3D_Actor_Matrix[actor, C3D_ACTOR_MATRIX_T], tmp_matrix1, tmp_matrix2)
		
		'Move the actor based on its Position to the Camera (ie. If an actor is in the center of the view and the camera moves left then the actor should move right)
		SubtractMatrix(tmp_matrix2, camera_matrix_t, tmp_matrix1)
		
		'Apply orientation in view space
		MultiplyMatrix(vy, tmp_matrix1, tmp_matrix2)
		MultiplyMatrix(vx, tmp_matrix2, tmp_matrix1)
		MultiplyMatrix(vz, tmp_matrix1, C3D_Actor_Matrix[actor, 0])
		
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