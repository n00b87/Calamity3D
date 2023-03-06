Include Once
Include "Calamity3D/C3D_Utility.bas"

C3D_MAX_IMAGES = 5

Dim C3D_Image[C3D_MAX_IMAGES]
Dim C3D_Image_Size[C3D_MAX_IMAGES, 2]
Dim C3D_Image_Loaded[C3D_MAX_IMAGES]

Function C3D_LoadImage(img_file$)
	If Not FileExists(img_file$) Then
		Return -1
	End If
	
	c_img = -1
	For i = 0 To C3D_MAX_IMAGES-1
		If Not C3D_Image_Loaded[i] Then
			c_img = i
			Exit For
		End If
	Next
	
	If c_img < 0 Then
		Return -1
	End If
	
	img_slot = -1
	For i = 0 to 4095 'RCBasic supports a max of 4096 images
		If Not ImageExists(i) Then
			img_slot = i
			Exit For
		End If
	Next
	
	If img_slot < 0 Then
		Return -1
	Else
		LoadImage(img_slot, img_file$)
		C3D_Image[c_img] = img_slot
		C3D_Image_Loaded[c_img] = True
		GetImageSize(img_slot, C3D_Image_Size[c_img, 0], C3D_Image_Size[c_img, 1])
		Return c_img
	End If
	
End Function