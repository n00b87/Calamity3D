Include Once

Include "Calamity3D/C3D_Mesh.bas"
Include "Calamity3D/C3D_Image.bas"
Include "Calamity3D/C3D_Sprite.bas"
Include "Calamity3D/C3D_Camera.bas"
Include "Calamity3D/C3D_Utility.bas"
Include "Calamity3D/C3D_Window.bas"

Dim vertex[ C3D_MAX_VERTICES, 8]
Dim index[ (C3D_MAX_VERTICES-3) * 3 + 3 + 12 ] 'After 3 vertices, every new vertex adds 3 indices

vi = 0
index_count = 0
vertex_count = 0

Sub C3D_DrawMeshFace(actor, face)
	'Dim vertex[ C3D_MAX_VERTICES, 8]
	'Dim index[ (C3D_MAX_VERTICES-3) * 3 + 3 + 12 ] 'After 3 vertices, every new vertex adds 3 indices
	'index_count = 0
	mesh = C3D_Actor_Source[actor]
	f_vertex_count = C3D_Mesh_Face_Vertex_Count[mesh, face]
	
	if f_vertex_count > 4 Then
		Return
	end if
	
	vertex_count = vertex_count + f_vertex_count
	
	vi_zero = vi
	'Convert 3D coordinates into 2D screen location
	For i = 0 to f_vertex_count-1
		vert_num = C3D_Mesh_Face_Vertex[mesh, face, i] 'vertex number will be the same between Mesh and Actor Arrays
		'z = C3D_Actor_Vertex[actor, vert_num, 2 ]
		z = MatrixValue(C3D_Actor_Matrix[actor, 0], 2, vert_num)
		distance = C3D_CAMERA_LENS - z
		C3D_Ternary(distance=0, distance, 1, distance)
		'vertex[ vi, 0 ] = (C3D_CAMERA_LENS * C3D_Actor_Vertex[actor, vert_num, 0 ] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
		'vertex[ vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * C3D_Actor_Vertex[actor, vert_num, 1 ] / distance)
		vertex[ vi, 0 ] = (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 0, vert_num) / distance) + C3D_SCREEN_GRAPH_OFFSET_X
		vertex[ vi, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * MatrixValue(C3D_Actor_Matrix[actor, 0], 1, vert_num) / distance)
		vertex[ vi, 2 ] = 255
		vertex[ vi, 3 ] = 255
		vertex[ vi, 4 ] = 255
		vertex[ vi, 5 ] = 255
		vertex[ vi, 6 ] = C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0] 'u
		vertex[ vi, 7 ] = C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1] 'v
		
		If i >= 2 Then
			index[index_count] = vi_zero
			index[index_count+1] = vi-1
			index[index_count+2] = vi
			index_count = index_count + 3
		End If
		vi = vi + 1
	Next
	
	'DEBUG
	'Print "-START-"
	'if index_count > 0 then
		'SetColor(RGB(255,255,255))
		'for a = 0 to index_count-1 step 3
			'Print index[a]
		'	Line(vertex[index[a], 0], vertex[index[a], 1], vertex[index[a+1], 0], vertex[index[a+1], 1])
		'	Line(vertex[index[a+1], 0], vertex[index[a+1], 1], vertex[index[a+2], 0], vertex[index[a+2], 1])
		'	Line(vertex[index[a+2], 0], vertex[index[a+2], 1], vertex[index[a], 0], vertex[index[a], 1])
		'Next
	'Else
		'print "No index"
	'end if
	'Print "-END-"
	'END DEBUG
	
	'DrawGeometry(C3D_Mesh_Texture[mesh], vertex_count, vertex, index_count, index)
	
End Sub


C3D_RENDER_TYPE_NONE = 0
C3D_RENDER_TYPE_WIREFRAME = 1
C3D_RENDER_TYPE_SOLID = 2
C3D_RENDER_TYPE_TEXTURED = 3

C3D_Render_Type = C3D_RENDER_TYPE_TEXTURED



Sub C3D_SetRenderType(render_type)

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
	For i = (c*d2) to MAX_I
		'print "n = ";arr[i]
		For j = i to MAX_I
			If arr1[j] < arr1[i] Then
				Push_N(arr1[i])
				arr1[i] = arr1[j]
				arr1[j] = Pop_N()
				
				Push_N(arr2[i])
				arr2[i] = arr2[j]
				arr2[j] = Pop_N()
				
			End If
		Next
	Next			
end sub

C3D_Rendered_Faces_Count = 0

Sub C3D_RenderScene()
	
	C3D_ComputeTransforms()
	C3D_ComputeVisibleFaces()
	
	C3D_Rendered_Faces_Count = 0
	
	vi = 0
	index_count = 0
	vertex_count = 0
	
	For z = (C3D_MAX_Z_DEPTH-1) to 1 step -1
		If C3D_ZSort_Faces_Count[z] > 0 Then
			sortJoinColumn(C3D_ZSort_Faces_Distance, C3D_ZSort_Faces, z, C3D_ZSort_Faces_Count[z], C3D_MAX_SCENE_FACES)
			For i = 0 to C3D_ZSort_Faces_Count[z]-1
				visible_face_index = C3D_ZSort_Faces[z, i]
				actor = C3D_Visible_Faces[visible_face_index, 0]
				face = C3D_Visible_Faces[visible_face_index, 1]
				face_type = C3D_Visible_Faces_Type[visible_face_index]
				
				Select Case face_type
				Case C3D_ACTOR_TYPE_MESH
					'Draw Face
					C3D_DrawMeshFace(actor, face)
					C3D_Rendered_Faces_Count = C3D_Rendered_Faces_Count + 1
				Case C3D_ACTOR_TYPE_SPRITE_2D
					'Do nothing for now
				End Select
			Next
		End If
	Next
	
	Canvas(C3D_CANVAS_RENDER)
	ClearCanvas()
	
	DrawGeometry(C3D_TEXTURE_MAP, vertex_count, vertex, index_count, index)
	
End Sub
