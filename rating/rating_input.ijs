NB. J Utilities for displaying sheet data
NB. 

NB. =========================================================
NB. rating_input
NB. =========================================================
NB. View scores for participant
jweb_rating_input=: 3 : 0
NB. y has two elements only
filename=. ;1{.y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	CheckXLFile glFilepath,'_xl'
	utKeyRead glFilepath,'_xl'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<!DOCTYPE html>',LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

stdout LF,'<h2>''Input macros for ', glCourseName,'</h2>'
tab=. ;4$<'&nbsp;'
NB. file exists if we have got this far
NB. Work out the unique values and loop round by hole, tee and gender
tees=. ~. ( (glXLHole e. i. 18 ) *. glXLOverwrite e. 1 2) # glXLTee
tees=. tees /: glTees i. tees
for_tee. tees do.
    genders=. ~. ((tee = glXLTee) *. glXLOverwrite e. 1 2)# glXLGender
    genders=. genders /: genders
    for_gender. genders do.
	holes=. ~. ((tee=glXLTee) *. (gender=glXLGender) *. glXLOverwrite e. 1 2) # glXLHole
	holes=. holes /: holes
	NB. Write the umbrella macro
	stdout LF,'Sub Input_',(>(glTees i. tee){glTeesName),'_',(>gender{' ' cut 'Men Women'),'()<br>'
	for_hole. holes do.
		stdout LT1,tab,'Call Input_',(>(glTees i. tee){glTeesName),'_',(>gender{' ' cut 'Men Women'),'_',(;'r<0>2.0' 8!:0 hole+1),'()<br>'
	end.
	stdout LF,'End Sub<br>'
	for_hole. holes do.
	    stdout LF,'Sub Input_',(>(glTees i. tee){glTeesName),'_',(>gender{' ' cut 'Men Women'),'_',(;'r<0>2.0' 8!:0 hole+1),'()<br>'
	    ix=. I. ((hole = glXLHole) *. (tee = glXLTee) *. (gender=glXLGender) *. glXLOverwrite e. 1 2)
	    for_i. ix do.
		ww=. LT1,tab,'If 2 = InputVal("',(>i{glXLSheet),'", '
		ww=. ww, (": >i{glXLRow),', '
		ww=. ww, (": >i{glXLColumn),', '
		ww=. ww, '"',(i{glXLType),'", '
		ww=. ww, (>(i{glXLNull){' ' cut 'False True'),', '
		ww=. ww, '"',(>i{glXLNote),'", '
		if. 'N' = i{glXLType do.
		    ww=. ww,('_' ; '-') stringreplace (": i{glXLNum)
		else.
		    ww=. ww, '"',(>i{glXLString),'"'
		end.
		ww=. ww, ') Then Exit Sub<br>'
		stdout ww
	    end.
	    stdout LF,'End Sub<br>'
	end.
    end.
end.
ww=. LF cut glMacroInput
for_i. ww do.
    stdout LF,(((' '); '&nbsp' ; TAB ; EM) stringreplace >i),'<br>'
end.

stdout LF,'<div class="span-20 last">'
stdout LF,''' <a href="/jw/rating/plannomap/v/',(glFilename),'">Return to plan</a>'
stdout LF,'</div>' 
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
res=. 1
exit ''
)


glMacroInput=: 0 : 0
Private Function InputVal(sheet As String, row As Integer, col As Integer, ty As String, nullallowed As Boolean, note As String, val As Variant) As Integer
    InputVal = 6 ' Default is Yes
    If 0 = StrComp(ty, "N") Then ' Must be number
        If val = Worksheets(sheet).Cells(row, col).Value Then
            Exit Function
        End If
    Else
    ' Must be string
        If 0 = StrComp(val, Worksheets(sheet).Cells(row, col).Value) Then
            Exit Function
        End If
        ' Null may be allowed
        If (nullallowed And (val = "") And ("" = Worksheets(sheet).Cells(row, col).Value)) Then
            Exit Function
        End If
    End If
    ' If we have got this far this is a difference
    ' If blank currently just overwrite
    If "" = Worksheets(sheet).Cells(row, col).Value Then
        Worksheets(sheet).Cells(row, col).Value = val
        Exit Function
    End If
    ' Otherwise check that we want to overwrite

    stg = "Sheet = " & sheet
    stg = stg & vbNewLine & "Row / Column = " & row & " / " & col
    stg = stg & vbNewLine & "Note = " & note
    stg = stg & vbNewLine & "Overwriting value = " & val
    stg = stg & vbNewLine & "Spreadsheet value = " & Worksheets(sheet).Cells(row, col).Value
    InputVal = MsgBox(stg, 3, "Overwrite check")        
    If 6 = InputVal Then
        Worksheets(sheet).Cells(row, col).Value = val
    End If
End Function
)

