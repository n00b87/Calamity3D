System("clear")

Include "C3D_Mesh.bas"
Include "C3D_Image.bas"
Include "C3D_Sprite.bas"
Include "C3D_Camera.bas"



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
	
	For i = 0 to C3D_MAX_ACTORS-1
		If Not C3D_Actor_Active[i] Then
			Continue
		End If
		
		Select Case C3D_Actor_Type[i]
		Case C3D_ACTOR_TYPE_MESH	
			C3D_ComputeVisibleFaces(C3D_Actor_Source[i])
		End Select
	Next
	
End Sub

C3D_CreateActor(C3D_ACTOR_TYPE_MESH, C3D_LoadMesh("test_obj.obj"))

C3D_RenderScene()

