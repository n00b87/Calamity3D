Include Once
Include "Calamity3D/C3D_Image.bas"

C3D_MAX_SPRITES = 500

C3D_MAX_SPRITE_ANIMATIONS = 200
C3D_MAX_SPRITE_FRAMES_PER_ANIMATION = 50

Dim C3D_Sprite_Image[C3D_MAX_SPRITES] 'Index in C3D_Image[]
Dim C3D_Sprite_Frame_Size[C3D_MAX_SPRITES, 2]
Dim C3D_Sprite_Animation[C3D_MAX_SPRITES, C3D_MAX_SPRITE_ANIMATIONS, C3D_MAX_SPRITE_FRAMES_PER_ANIMATION]
Dim C3D_Sprite_Animation_Frame_Time[C3D_MAX_SPRITES, C3D_MAX_SPRITE_ANIMATIONS]
Dim C3D_Sprite_Animation_Count[C3D_MAX_SPRITES]
Dim C3D_Sprite_Animation_Frame_Count[C3D_MAX_SPRITES, C3D_MAX_SPRITE_ANIMATIONS]

Dim C3D_Sprite_Active[C3D_MAX_SPRITES]

'Image ID is the index in C3D_Image[]
Function C3D_CreateSprite(img_id, frame_w, frame_h)
	sprite = -1
	For i = 0 to C3D_MAX_SPRITES-1
		If Not C3D_Sprite_Active[i] Then
			sprite = i
			C3D_Sprite_Active[i] = True
			C3D_Sprite_Image[i] = img_id
			C3D_Sprite_Frame_Size[i, 0] = frame_w
			C3D_Sprite_Frame_Size[i, 1] = frame_h
			C3D_Sprite_Animation_Count[i] = 0
			Exit For
		End If
	Next
	Return sprite
End Function

'Sprite File will have saved sprite info
Function C3D_LoadSprite(sprite_file$)

End Function
