Include Once
Include "Calamity3D/C3D_Utility.bas"

C3D_MAX_IMAGES = 100

Dim C3D_Image[C3D_MAX_IMAGES]
Dim C3D_Image_Size[C3D_MAX_IMAGES, 2]
Dim C3D_Image_Loaded[C3D_MAX_IMAGES]
Dim C3D_Image_TM_Div[C3D_MAX_IMAGES, 3]

'---TEXTURE MAP---------------
C3D_Image[0] = 0
C3D_Image_Loaded[0] = True
'-----------------------------

Dim C3D_Image_Width[C3D_MAX_IMAGES]
Dim C3D_Image_Height[C3D_MAX_IMAGES]

ArrayFill(C3D_Image, -1)
ArrayFill(C3D_Image_Loaded, 0)
ArrayFill(C3D_Image_TM_Div, -1)

Function C3D_LoadImage(img_file$)
	If Not FileExists(img_file$) Then
		Return -1
	End If
	
	c_img = -1
	For i = 1 To C3D_MAX_IMAGES-1
		If Not C3D_Image_Loaded[i] Then
			c_img = i
			Exit For
		End If
	Next
	
	If c_img < 0 Then
		Return -1
	End If
	
	img_slot = -1
	For i = 1 to 4095 'RCBasic supports a max of 4096 images
		If Not ImageExists(i) Then
			img_slot = i
			Exit For
		End If
	Next
	
	If img_slot < 0 Then
		Return -1
	Else
		LoadImage(img_slot, img_file$)
		GetImageSize(img_slot, C3D_Image_Width[c_img], C3D_Image_Height[c_img])
		C3D_Image[c_img] = img_slot
		C3D_Image_Loaded[c_img] = True
		GetImageSize(img_slot, C3D_Image_Size[c_img, 0], C3D_Image_Size[c_img, 1])
		Return c_img
	End If
	
End Function


Sub C3D_DeleteImage(c_img)
	If ImageExists(C3D_Image[c_img]) Then
		DeleteImage(C3D_Image[c_img])
	End If
	C3D_Image_Loaded[c_img] = False
End Sub


Function C3D_ImageSlot(c_img)
	If c_img < 0 Or c_img >= C3D_MAX_IMAGES Or (Not C3D_Image_Loaded[c_img]) Then
		Return -1
	Else
		Return C3D_Image[c_img]
	End If
End Function


Function C3D_GetFreeImage(w, h)
	
	c_img = -1
	For i = 1 To C3D_MAX_IMAGES-1
		If Not C3D_Image_Loaded[i] Then
			c_img = i
			Exit For
		End If
	Next
	
	If c_img < 0 Then
		Return -1
	End If
	
	img_slot = -1
	For i = 1 to 4095 'RCBasic supports a max of 4096 images
		If Not ImageExists(i) Then
			img_slot = i
			Exit For
		End If
	Next
	
	If img_slot < 0 Then
		Return -1
	Else
		C3D_Image[c_img] = img_slot
		C3D_Image_Loaded[c_img] = True
		C3D_Image_Width[c_img] = w 
		C3D_Image_Height[c_img] = h
		C3D_Image_Size[c_img, 0] = w
		C3D_Image_Size[c_img, 1] = h
		Return c_img
	End If
	
End Function

Function C3D_GetFreeImageSlot()
	img_slot = -1
	For i = 1 to 4095 'RCBasic supports a max of 4096 images
		If Not ImageExists(i) Then
			img_slot = i
			Exit For
		End If
	Next
	
	Return img_slot
End Function

Function C3D_LinkImage(c_img, img_slot)
	If Not (C3D_Image_Loaded[c_img] Or ImageExists(img_slot) ) Then
		Return False
	Else
		GetImageSize(img_slot, C3D_Image_Width[c_img], C3D_Image_Height[c_img])
		C3D_Image[c_img] = img_slot
		C3D_Image_Loaded[c_img] = True
		GetImageSize(img_slot, C3D_Image_Size[c_img, 0], C3D_Image_Size[c_img, 1])
		Return True
	End If
End Function
