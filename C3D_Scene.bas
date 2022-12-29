Include Once
Include "C3D_Mesh.bas"
Include "C3D_Image.bas"
Include "C3D_Sprite.bas"
Include "C3D_Camera.bas"
Include "Utility.bas"

C3D_GRAPH_LEFT = -20
C3D_GRAPH_RIGHT = 20
C3D_GRAPH_BOTTOM = 0
C3D_GRAPH_TOP = 40
C3D_GRAPH_NEARZ = 0.1
C3D_GRAPH_FARZ = 100

C3D_GRAPH_RANGE_LR = C3D_GRAPH_RIGHT - C3D_GRAPH_LEFT
C3D_GRAPH_RANGE_TB = C3D_GRAPH_TOP - C3D_GRAPH_BOTTOM

C3D_GRAPH_FOV = 45
C3D_GRAPH_ASPECT_RATIO = 640/480 'Default that will be changed when window is opened

C3D_SCREEN_WIDTH = 640
C3D_SCREEN_HEIGHT = 480

C3D_SCREEN_GRAPH_OFFSET_X = C3D_SCREEN_WIDTH / 2
C3D_SCREEN_GRAPH_OFFSET_Y = C3D_SCREEN_HEIGHT

Sub C3D_DrawMeshFace(actor, face)
	Dim vertex[ C3D_MAX_VERTICES, 8]
	Dim index[ (C3D_MAX_VERTICES-3) * 3 + 3 + 12 ] 'After 3 vertices, every new vertex adds 3 indices
	index_count = 0
	mesh = C3D_Actor_Source[actor]
	vertex_count = C3D_Mesh_Face_Vertex_Count[mesh, face]
	
	'Print "Vertex Count = "; vertex_count
	
	'Convert 3D coordinates into 2D screen location
	For i = 0 to vertex_count-1
		vert_num = C3D_Mesh_Face_Vertex[mesh, face, i] 'vertex number will be the same between Mesh and Actor Arrays
		z = C3D_Actor_Vertex[actor, vert_num, 2 ]
		distance = C3D_CAMERA_LENS - z
		C3D_Ternary(distance=0, distance, 1, distance)
		vertex[ i, 0 ] = (C3D_CAMERA_LENS * C3D_Actor_Vertex[actor, vert_num, 0 ] / distance) + C3D_SCREEN_GRAPH_OFFSET_X
		vertex[ i, 1 ] = C3D_SCREEN_GRAPH_OFFSET_Y - (C3D_CAMERA_LENS * C3D_Actor_Vertex[actor, vert_num, 1 ] / distance)
		vertex[ i, 2 ] = 255
		vertex[ i, 3 ] = 255
		vertex[ i, 4 ] = 255
		vertex[ i, 5 ] = 255
		vertex[ i, 6 ] = C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 0] 'u
		vertex[ i, 7 ] = C3D_Mesh_TCoord[mesh, C3D_Mesh_Face_TCoord[mesh, face, i], 1] 'v
		
		'SetColor(RGB(255,255,255))
		'RectFill(vertex[i, 0], vertex[i, 1], 2, 2)
		
		'DEBUG
		'Print "Original: "; C3D_Actor_Vertex[actor, vert_num, 0 ];", ";C3D_Actor_Vertex[actor, vert_num, 1 ];", ";z;", v=";vert_num;", t=";C3D_Mesh_Face_TCoord[mesh, face, i]
		'for a = 0 to 7
		'	Print vertex[i, a]; ", ";
		'Next
		'Print ""
		'Print ""
		'END DEBUG
		
		If i >= 2 Then
			index[index_count] = 0
			index[index_count+1] = i-1
			index[index_count+2] = i
			index_count = index_count + 3
		End If
		
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
	
	DrawGeometry(C3D_Mesh_Texture[mesh], vertex_count, vertex, index_count, index)
	'Update()
	'Wait(50)
	'Waitkey
	'Print "NEXT"
	
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

Sub C3D_RenderScene()
	
	C3D_ComputeTransforms()
	C3D_ComputeVisibleFaces()
	
	'Print "Come one"
	
	For z = (C3D_MAX_Z_DEPTH-1) to 1 step -1
		'Print "z = "; z
		If C3D_ZSort_Faces_Count[z] > 0 Then
			'Print "ZSRT FC = "; C3D_ZSort_Faces_Count[z]
			For i = 0 to C3D_ZSort_Faces_Count[z]-1
				visible_face_index = C3D_ZSort_Faces[z, i]
				actor = C3D_Visible_Faces[visible_face_index, 0]
				face = C3D_Visible_Faces[visible_face_index, 1]
				face_type = C3D_Visible_Faces_Type[visible_face_index]
				
				'Print face_type; " == "; C3D_ACTOR_TYPE_MESH
				
				Select Case face_type
				Case C3D_ACTOR_TYPE_MESH
					'Print "Draw Face"
					C3D_DrawMeshFace(actor, face)
				Case C3D_ACTOR_TYPE_SPRITE_2D
					'Do nothing for now
				End Select
			Next
		End If
	Next
	
	Update()
	
End Sub
