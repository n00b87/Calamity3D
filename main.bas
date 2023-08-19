Include "Calamity3D/Calamity3D.bas"


'Setting the Clear color for the renderer
C3D_CLEAR_COLOR = RGB(153,217,234)

'Initialize Engine and open a window
C3D_Init("test", 640, 480, 0, 1)

'C3D_SetFrameLimit(60)

'Opening Canvas 0 and setting it on top of the rendered display
'NOTE: Canvas 0 is where the weapon sprite will be drawn
CanvasOpen(0, 640, 480, 0, 0, 640, 480, 1)
SetCanvasZ(0, 0)

'Backbuffer to render frames for sprites
CanvasOpen(1, 640, 480, 0, 0, 640, 480, 1)
SetCanvasVisible(1, 0)


lf = C3D_LoadImage("Assets/bkg_lf.jpg")
rt = C3D_LoadImage("Assets/bkg_rt.jpg")
bk = C3D_LoadImage("Assets/bkg_bk.jpg")
ft = C3D_LoadImage("Assets/bkg_ft.jpg")
up = C3D_LoadImage("Assets/bkg_up.jpg")
dn = C3D_LoadImage("Assets/bkg_dn.jpg")

'C3D_GenerateBackground(lf, rt, bk, ft, up, dn)
bkg = C3D_LoadImage("Assets/skybox-assembled.jpg")
C3D_SetBackground(bkg)
C3D_ShowBackground(true)


C3D_DeleteImage(lf)
C3D_DeleteImage(rt)
C3D_DeleteImage(bk)
C3D_DeleteImage(ft)
C3D_DeleteImage(up)
C3D_DeleteImage(dn)


'C3D_SetRenderType(C3D_RENDER_TYPE_WIREFRAME)


'terrain_mesh = C3D_LoadMesh("Assets/terrain2.obj")
terrain_mesh = C3D_LoadMesh("Assets/large_level.obj")
'terrain_cd = C3D_LoadMesh("Assets/terrain_cd.obj")
terrain_cd = C3D_LoadMesh("Assets/large_level_cd.obj")
C3D_AddStageGeometryFromMesh(terrain_cd)

'terrain_texture = C3D_LoadImage("Assets/terrain1.png")
terrain_texture = C3D_LoadImage("Assets/plane1.bmp")

C3D_SetMeshTexture(terrain_mesh, terrain_texture)
'C3D_CreateActor(C3D_ACTOR_TYPE_MESH, terrain_mesh)

x1 = -15790 : y1 = 20 : z1 = -15694
x2 = 16383  : y2 = 20 : z2 = -15694
x3 = 16383  : y3 = 20 : z3 = 16478
x4 = -15790 : y4 = 20 : z4 = 16478

C3D_AddStageGeometry(C3D_STAGE_GEOMETRY_TYPE_FLOOR, x1, y1, z1, x2, y2, z2, x3, y3, z3, x4, y4, z4)


c = C3D_CutMesh(terrain_mesh, 4000)
Print "Cuts = "; c
'
For i = 0 to C3D_Mesh_Cut_Count-1
	C3D_SetMeshTexture(C3D_Mesh_Cuts[i], terrain_texture)
	C3D_CreateActor(C3D_ACTOR_TYPE_MESH, C3D_Mesh_Cuts[i])
Next


house_mesh = C3D_LoadMesh("Assets/house.obj")
house_cd = C3D_LoadMesh("Assets/house_cd.obj")
C3D_AddCollisionMesh(house_mesh, house_cd)

house_mesh_hd = C3D_LoadMesh("Assets/house_hd.obj")
house_texture = C3D_LoadImage("Assets/house.png")
C3D_SetMeshTexture(house_mesh, house_texture)
C3D_SetMeshTexture(house_mesh_hd, house_texture)

C3D_SetHDMesh(house_mesh, house_mesh_hd)
C3D_SetMeshHDDistance(house_mesh, 200)

C3D_ScaleMesh(house_mesh, 1)
C3D_ScaleMesh(house_mesh_hd, 1)
house1 = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, house_mesh)
C3D_AddStageGeometryFromActor(house1)


'Load Tree Mesh and Scale it by 3 because it starts out pretty small
tree_mesh = C3D_LoadMesh("Assets/tree.obj")
C3D_ScaleMesh(tree_mesh, 3)
tree_texture = C3D_LoadImage("Assets/tree.png")
C3D_SetMeshTexture(tree_mesh, tree_texture)

tree = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, tree_mesh)
C3D_SetActorPosition(tree, -500, 0, 700)

tree = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, tree_mesh)
C3D_SetActorPosition(tree, -700, 0, 1500)

tree = C3D_CreateActor(C3D_ACTOR_TYPE_MESH, tree_mesh)
C3D_SetActorPosition(tree, -700, 0, 2400)


'GRAVITY (effects how fast the camera falls after the peak of the jump)
gravity = 20
jump_speed = 36
max_jump_force = 10


weapon_sprite = C3D_GetFreeImageSlot()
LoadImage(weapon_sprite, "Assets/mg-sheet.png")
weapon_frame_w = 144
weapon_frame_h = 176

weapon_frame_current_time = timer()
weapon_frame_time_limit = 20

weapon_current_frame = 0
weapon_frame_count = 3

jump_force = 0


Sub FPSControl()
	'RSHIFT NEEDS TO BE ADDED
	
	If jump_force > 0 Then
		C3D_MoveFPSCamera(0, jump_speed, 0)
		jump_force = jump_force - 1
	Else
		C3D_MoveFPSCamera(0, -gravity, 0)
	End If
	
	if key(k_space) And C3D_CameraOnFloor() Then
		jump_force = max_jump_force
	end if
	
	If c3d_mb1 Then
		If weapon_frame_current_time > weapon_frame_time_limit Then
			weapon_current_frame = weapon_current_frame + 1
			If weapon_current_frame >= weapon_frame_count Then
				weapon_current_frame = 1
			End If
		End If
		weapon_frame_current_time = timer()
	Else
		weapon_current_frame = 0
	End If

End Sub


Sub DrawUI()
	Canvas(0)
	SetClearColor(0)
	ClearCanvas()
	
	x = 570-(weapon_frame_w/2)
	y = 480-weapon_frame_h
	sx = weapon_current_frame*weapon_frame_w
	sy = 0
	sw = weapon_frame_w
	sh = weapon_frame_h
	DrawImage_Blit(weapon_sprite, x, y, sx, sy, sw, sh)
	
	If C3D_PickActor(320,240) >= 0 Then
		SetColor(RGB(255,0,0))
	Else
		SetColor(RGB(255,255,255))
	End If
	Line(310, 240, 330, 240)
	Line(320, 230, 320, 250)
	
End Sub


'Load the demon sprites
NUM_DEMONS = 5

demon_img = C3D_LoadImage("Assets/demon.png")

demon_frame_w = 128
demon_frame_h = 110

Dim demon_anim_timer[5]

Dim demon[5], demon_frame[5], demon_frame_num[5], demon_health[5]


For i = 0 to NUM_DEMONS-1
	demon_frame[i] = C3D_GetFreeImage(300, 300)
	demon[i] = C3D_CreateActor(C3D_ACTOR_TYPE_SPRITE, demon_frame[i])
	mesh = C3D_GetActorMesh(demon[i])
	C3D_SetActorPickable(demon[i], True)
	demon_frame_num[i] = 0
	demon_health[i] = 10
	demon_anim_timer[i] = Timer()
Next

C3D_SetActorPosition(demon[0], -1300, 30, 500)
C3D_SetActorPosition(demon[1], -400, 30, 700)
C3D_SetActorPosition(demon[2], -800, 30, 100)
C3D_SetActorPosition(demon[3], -1100, 30, 200)
C3D_SetActorPosition(demon[4], -900, 30, 300)

'SetCanvasVisible(1, 1)

Sub GetDemonFrame()
	Canvas(1)
	SetClearColor(0)
	pick = C3D_PickActor(320, 240)
	
	For i = 0 to NUM_DEMONS-1
		
		If c3d_mb1 And pick = demon[i] Then
			demon_health[i] = demon_health[i] - 1
			'print "Health = ";demon_health[i]
		End If
			
		If demon_health[i] <= 0 Then
			C3D_SetActorPickable(demon[i], false)
			demon_frame_num[i] = 4
		ElseIf (Timer() - demon_anim_timer[i]) >= 60 Then
			demon_frame_num[i] = demon_frame_num[i] + 1
			If demon_frame_num[i] > 3 Then
				demon_frame_num[i] = 0
			End If
			demon_anim_timer[i] = Timer()
		End If
		
		ClearCanvas()
		DrawImage_Blit(C3D_ImageSlot(demon_img), 0, 0, demon_frame_num[i]*demon_frame_w, 0, demon_frame_w, demon_frame_h)
		
		mesh = C3D_GetActorMesh(demon[i])
		texture = C3D_GetMeshTexture(mesh)
		'print "mesh_tx = "; texture
		If ImageExists(texture) Then
			DeleteImage(texture)
		End If
		
		CanvasClip(texture, 0, 0, demon_frame_w, demon_frame_h, 1)
	Next
	
End Sub


m = false
Update()

C3D_EnableFPSCamera()
C3D_MoveFPSCamera(-1, 0, 0)
C3D_SetCameraRotation(24, 170, 0)

LoadFont(0, "FreeMono.ttf", 12)

While Not Key(K_ESCAPE)

	DrawUI()
	GetDemonFrame()
	
	Canvas(0)
	SetColor(RGBA(255,255,255,128))
	RectFill(5, 5, 150, 60)
	SetColor(RGB(0, 0, 0))
	DrawText("FPS: " + Str(FPS()), 10, 10)
	DrawText("PICK: " + Str(C3D_PickActor(320,240)), 10, 30)
	DrawText("Face Count: " + Str(dbg_face_count), 10, 50)
	
	If key(k_m) Then
		dim cx, cy, cz
		C3D_GetCameraPosition(cx, cy, cz)
		Print "Cam Info: "; cx; ", "; cy;", "; cz
		dim hx, hy, hz
		C3D_GetActorPosition(house1, hx, hy, hz)
		Print "House Info: "; hx; ", "; hy; ", "; hz
		Print "Angle: "; C3D_Camera_Rotation[1];" -> ";C3D_LineAngle(cx, cz, hx, hz)
		Print "View: "; C3D_ComputeActorInView(house1)
		Print ""
	End If
	
	If key(k_z) then
		Select Case C3D_GetRenderType()
		Case C3D_RENDER_TYPE_WIREFRAME : C3D_SetRenderType(C3D_RENDER_TYPE_TEXTURED)
		Default : C3D_SetRenderType(C3D_RENDER_TYPE_WIREFRAME)
		End Select
		Wait(90)
	End If
	
	C3D_RenderScene()
	C3D_Update()
	'waitkey
Wend
