Include Once

Dim C3D_Matrix_Active[1024]
ArrayFill(C3D_Matrix_Active, 0)

Function C3D_CreateMatrix(rows, cols)
	For i = 0 to 1023
		If Not C3D_Matrix_Active[i] Then
			C3D_Matrix_Active[i] = True
			DimMatrix(i, rows, cols, 0)
			Return i
		End If
	Next
	Return -1
End Function

Sub C3D_DeleteMatrix(m)
	If m < 0 OR m >= 1024 Then
		Return
	Else
		C3D_Matrix_Active[m] = 0
	End If
End Sub




C3D_AXIS_X = 0
C3D_AXIS_Y = 1
C3D_AXIS_Z = 2

Sub rotateX(mat, angle)
    sinTheta = Sin(Radians(angle))
    cosTheta = Cos(Radians(angle))
    IdentityMatrix(mat, 4)
    SetMatrixValue(mat, 0, 0, 1.0) : SetMatrixValue(mat, 0, 1, 0.0)      : SetMatrixValue(mat, 0, 2, 0.0)
    SetMatrixValue(mat, 1, 0, 0.0) : SetMatrixValue(mat, 1, 1, cosTheta) : SetMatrixValue(mat, 1, 2, -sinTheta)
    SetMatrixValue(mat, 2, 0, 0.0) : SetMatrixValue(mat, 2, 1, sinTheta) : SetMatrixValue(mat, 2, 2, cosTheta)
End Sub

Sub rotateY(mat, angle)
    sinTheta = Sin(Radians(angle))
    cosTheta = Cos(Radians(angle))
    IdentityMatrix(mat, 4)
    SetMatrixValue(mat, 0, 0, cosTheta)  : SetMatrixValue(mat, 0, 1, 0.0) : SetMatrixValue(mat, 0, 2, sinTheta)
    SetMatrixValue(mat, 1, 0, 0.0)       : SetMatrixValue(mat, 1, 1, 1.0) : SetMatrixValue(mat, 1, 2, 0.0)
    SetMatrixValue(mat, 2, 0, -sinTheta) : SetMatrixValue(mat, 2, 1, 0.0) : SetMatrixValue(mat, 2, 2, cosTheta)
End Sub

Sub rotateZ(mat, angle)
    sinTheta = Sin(Radians(angle))
    cosTheta = Cos(Radians(angle))
    IdentityMatrix(mat, 4)
    SetMatrixValue(mat, 0, 0, cosTheta) : SetMatrixValue(mat, 0, 1, -sinTheta) : SetMatrixValue(mat, 0, 2, 0.0)
    SetMatrixValue(mat, 1, 0, sinTheta) : SetMatrixValue(mat, 1, 1, cosTheta)  : SetMatrixValue(mat, 1, 2, 0.0)
    SetMatrixValue(mat, 2, 0, 0.0)      : SetMatrixValue(mat, 2, 1, 0.0)       : SetMatrixValue(mat, 2, 2, 1.0)
End Sub


Sub C3D_SetRotationMatrix(mat, axis, angle)
	Select Case axis
		Case C3D_AXIS_X
			rotateX(mat, angle)
		Case C3D_AXIS_Y
			rotateY(mat, angle)
		Case C3D_AXIS_Z
			rotateZ(mat, angle)
	End Select
End Sub