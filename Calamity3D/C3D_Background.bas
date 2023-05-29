Include Once
Include "Calamity3D/C3D_Image.bas"

C3D_Bkg_Left_Image = -1
C3D_Bkg_Right_Image = -1
C3D_Bkg_Back_Image = -1
C3D_Bkg_Front_Image = -1
C3D_Bkg_Up_Image = -1
C3D_Bkg_Down_Image = -1

C3D_Background_Image = -1

C3D_Background_Enabled = False

Function C3D_GenerateBackground(lf, rt, bk, ft, up, dn)
	C3D_Bkg_Left_Image = lf
	C3D_Bkg_Right_Image = rt
	C3D_Bkg_Back_Image = bk
	C3D_Bkg_Front_Image = ft
	C3D_Bkg_Up_Image = up
	C3D_Bkg_Down_Image = dn
	

	If C3D_Background_Image >= 0 Then
		If ImageExists(C3D_Image[C3D_Background_Image]) Then
			DeleteImage(C3D_Image[C3D_Background_Image])
		End If
	Else
		C3D_Background_Image = C3D_GetFreeImage(512, 512)
		If C3D_Background_Image < 0 Then
			Return False
		End If
	End If
	
	SetCanvasVisible(C3D_CANVAS_BACKBUFFER, true)
	SetCanvasVisible(C3D_CANVAS_RENDER, false)
	SetCanvasZ(C3D_CANVAS_BACKBUFFER, 0)
	
	Canvas(C3D_CANVAS_BACKBUFFER)
	ClearCanvas()
	
	w = 128
	h = 256
	
	Dim src_w
	Dim src_h
	
	x = 0
	y = 256
	
	If ImageExists(C3D_Image[C3D_Bkg_Up_Image]) Then
		GetImageSize(C3D_Image[C3D_Bkg_Up_Image], src_w, src_h)
		
		tmp_f = C3D_GetFreeImageSlot()
		ClearCanvas
		DrawImage_Rotate(C3D_Image[C3D_Bkg_Up_Image], 0, 0, 90)
		CanvasClip(tmp_f, 0, 0, src_w, src_h, 1)
		
		tmp_r = C3D_GetFreeImageSlot()
		ClearCanvas
		DrawImage_Rotate(C3D_Image[C3D_Bkg_Up_Image], 0, 0, 180)
		CanvasClip(tmp_r, 0, 0, src_w, src_h, 1)
		
		tmp_b = C3D_GetFreeImageSlot()
		ClearCanvas
		DrawImage_Rotate(C3D_Image[C3D_Bkg_Up_Image], 0, 0, 270)
		CanvasClip(tmp_b, 0, 0, src_w, src_h, 1)
		
		ClearCanvas()
		tmp_l = C3D_Image[C3D_Bkg_Up_Image]
		DrawImage_Blit_Ex(tmp_l, 0, 0, w, h, 0, 0, src_w, src_h)
		DrawImage_Blit_Ex(tmp_f, 128, 0, w, h, 0, 0, src_w, src_h)
		DrawImage_Blit_Ex(tmp_r, 256, 0, w, h, 0, 0, src_w, src_h)
		DrawImage_Blit_Ex(tmp_b, 384, 0, w, h, 0, 0, src_w, src_h)
		
		'Print "UP"
		'Update()
		'Wait(500)
		'WaitKey
		
		DeleteImage(tmp_f)
		DeleteImage(tmp_r)
		DeleteImage(tmp_b)
	End If
	
	
	
	If ImageExists(C3D_Image[C3D_Bkg_Left_Image]) Then
		GetImageSize(C3D_Image[C3D_Bkg_Left_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Left_Image], x, y, w, h, 0, 0, src_w, src_h)
		'DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Left_Image], x, y+256, w, h+128, 0, 400, src_w, 112)
		GetImageSize(C3D_Image[C3D_Bkg_Down_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Down_Image], x, y+256, w, h+256, 0, 0, src_w, src_h)
	End If
	
	x = x + w
	
	If ImageExists(C3D_Image[C3D_Bkg_Front_Image]) Then
		GetImageSize(C3D_Image[C3D_Bkg_Front_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Front_Image], x, y, w, h, 0, 0, src_w, src_h)
		'DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Front_Image], x, y+256, w, h+128, 0, 400, src_w, 112)
		GetImageSize(C3D_Image[C3D_Bkg_Down_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Down_Image], x, y+256, w, h+256, 0, 0, src_w, src_h)
	End If
	
	x = x + w
	
	If ImageExists(C3D_Image[C3D_Bkg_Right_Image]) Then
		GetImageSize(C3D_Image[C3D_Bkg_Right_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Right_Image], x, y, w, h, 0, 0, src_w, src_h)
		'DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Right_Image], x, y+256, w, h+128, 0, 400, src_w, 112)
		GetImageSize(C3D_Image[C3D_Bkg_Down_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Down_Image], x, y+256, w, h+256, 0, 0, src_w, src_h)
	End If
	
	x = x + w
	
	If ImageExists(C3D_Image[C3D_Bkg_Back_Image]) Then
		GetImageSize(C3D_Image[C3D_Bkg_Back_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Back_Image], x, y, w, h, 0, 0, src_w, src_h)
		'DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Back_Image], x, y+256, w, h+128, 0, 400, src_w, 112)
		GetImageSize(C3D_Image[C3D_Bkg_Down_Image], src_w, src_h)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Down_Image], x, y+256, w, h+256, 0, 0, src_w, src_h)
	End If
	
	'Update
	'print "test 3"
	'waitkey
	
	'SetColor(RGB(255,0,0))
	'BoxFill(x,y,w,h)
	
	'SetCanvasVisible(C3D_CANVAS_BACKBUFFER, true)
	'SetCanvasVisible(C3D_CANVAS_RENDER, false)
	'SetCanvasZ(C3D_CANVAS_BACKBUFFER, 0)
	'print "update 1"
	CanvasClip(C3D_Image[C3D_Background_Image], 0, 0, 512, 1024, 1)
	DrawImage(C3D_Image[C3D_Background_Image], 512, 0)
	
	DeleteImage(C3D_Image[C3D_Background_Image])
	CanvasClip(C3D_Image[C3D_Background_Image], 0, 0, 1024, 640, 1)
	
	ClearCanvas
	
	DrawImage(C3D_Image[C3D_Background_Image], 0, 0)
	'Print "Drawn"
	'Update
	
	'WaitKey
	
	SetCanvasVisible(C3D_CANVAS_BACKBUFFER, false)
	SetCanvasVisible(C3D_CANVAS_RENDER, true)
	
	'CanvasClip(C3D_Image[C3D_Background_Image], 0, 0, 512, 512, 1)
	
	Return True
	
End Function


Sub C3D_ShowBackground(flag)
	C3D_Background_Enabled = flag
End Sub


Sub C3D_RenderBackground()
	If C3D_Background_Enabled Then
		'If key(k_5) Then
		'	Print "Camera: ";C3D_Camera_Rotation[0];", ";C3D_Camera_Rotation[1];", ";C3D_Camera_Rotation[2]
		'	'Print ""
		'End If
		
		cx = 0
		cy = 0
		C3D_Ternary(C3D_Camera_Rotation[1] < 0, cx, 360 + (C3D_Camera_Rotation[1] MOD 360), C3D_Camera_Rotation[1] MOD 360)
		bkg_x = cx/360 * 512
		
		bkg_y = 0
		cy = C3D_Camera_Rotation[0]
		C3D_Ternary(cy >= 0, bkg_y, 90 - cy, 90 + abs(cy))
		bkg_y = 512 - (bkg_y/180 * 512)
		
		offset_y = 0
		C3D_Ternary( (bkg_y+256) >= 512, offset_y, 511 - (bkg_y + 256), 0)
		C3D_Ternary( offset_y <= -255, offset_y, -255, offset_y)
		
		'If key(k_5) Then
		'	print "bkg_y = ";bkg_y
		'	print ""
		'End If
		dw = 0
		dh = 0 
		
		sc_y_offset = (offset_y/512)*C3D_SCREEN_HEIGHT
		
		GetImageSize(C3D_Image[C3D_Bkg_Down_Image], dw, dh)
		DrawImage_Blit_Ex(C3D_Image[C3D_Bkg_Down_Image], 0, 0, C3D_SCREEN_WIDTH, C3D_SCREEN_HEIGHT, 0, 0, dw, dh)
		DrawImage_Blit_Ex(C3D_Image[C3D_Background_Image], 0, 0, C3D_SCREEN_WIDTH, C3D_SCREEN_HEIGHT, bkg_x, bkg_y, 256, 256)
	End If
End Sub