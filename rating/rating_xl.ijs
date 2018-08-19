NB. J Utilities for displaying sheet data
NB. 

NB. =========================================================
NB. rating_xl
NB. =========================================================
NB. View scores for participant
jweb_rating_xl=: 3 : 0
NB. Retrieve the details

NB. y has one element only

filename=. ;1{.y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
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

stdout LF,'<h2>''Macros for ', glCourseName,'</h2>'
tab=. ;4$<'&nbsp;'
NB. file exists if we have got this far
NB. Work out the unique values and loop round by hole, tee and gender
for_tee. glTees do.
    for_gender. 0 1 do.
		holes=. Holes ''
		NB. Write the umbrella macro
		stdout LF,'Sub Check_',(>(glTees i. tee){glTeesName),'_',(>gender{' ' cut 'Men Women'),'()<br>'
		for_hole. holes do.
			stdout LT1,tab,'Call Check_',(>(glTees i. tee){glTeesName),'_',(>gender{' ' cut 'Men Women'),'_',(;'r<0>2.0' 8!:0 hole+1),'()<br>'
		end.
		stdout LF,'End Sub<br>'
		NB. Write out the individual macros, assuming the file exists
		for_hole. holes do.
			shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole)),(gender{'MW'),tee
			xlfname=. glDocument_Root,'/tcpdf/',glBasename,'/',shortname,'.txt'
			stdout LF,'Sub Check_',(>(glTees i. tee){glTeesName),'_',(>gender{' ' cut 'Men Women'),'_',(;'r<0>2.0' 8!:0 hole+1),'()<br>'
			if. fexist xlfname do.
				NB. Read the file and write out the relevant rows
				ww=. 'b' fread xlfname
				ww=. (>+./ each(<'CheckVal') E. each ww)#ww
				ww=. (<LF,'&nbsp;&nbsp;'), each ww,each <'<br>',LF
				stdout ;ww
			end.
			stdout LF,'End Sub<br>'
		end.
    end. NB. End of Gender
end. NB. End of Tee


ww=. LF cut glMacroCheck
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


glMacroCheck=: 0 : 0
Private Function CheckVal(sheet As String, row As Integer, col As Integer, ty As String, nullallowed As Boolean, note As String, val As Variant) As Integer
    CheckVal = 1 ' Default is OK
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
    stg = "Sheet = " & sheet
    stg = stg & vbNewLine & "Row / Column = " & row & " / " & col
    stg = stg & vbNewLine & "Note = " & note
    stg = stg & vbNewLine & "Expected value = " & val
    stg = stg & vbNewLine & "Spreadsheet value = " & Worksheets(sheet).Cells(row, col).Value
    CheckVal = MsgBox(stg, 1, "Comparison Error")        
End Function
)

