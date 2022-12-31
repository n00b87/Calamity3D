Include Once
Include "C3D_Image.bas"

C3D_MAX_SPRITES = 500

C3D_MAX_SPRITE_ANIMATIONS = 200
C3D_MAX_SPRITE_FRAMES_PER_ANIMATION = 50

Dim C3D_Sprite_Image[C3D_MAX_SPRITES] 'Index in C3D_Image[]
Dim C3D_Sprite_Frame_Size[C3D_MAX_SPRITES, 2]
Dim C3D_Sprite_Animation[C3D_MAX_SPRITES, C3D_MAX_SPRITE_ANIMATIONS, C3D_MAX_SPRITE_FRAMES_PER_ANIMATION]
Dim C3D_Sprite_Animation_Frame_Time[C3D_MAX_SPRITES, C3D_MAX_SPRITE_ANIMATIONS]


'Image ID is the index in C3D_Image[]
Function C3D_CreateSprite(img_id, w, h)

End Function

'Sprite File will have saved sprite info
Function C3D_LoadSprite(sprite_file$)

End Function