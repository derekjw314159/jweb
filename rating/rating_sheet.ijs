NB. J Utilities for displaying sheet data
NB. 

NB. =========================================================
NB. rating_sheet
NB. =========================================================
NB. View scores for participant
jweb_rating_sheet=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename hole tee gender'=. y
hole=. ''$ ".hole
tee=. ''$ tee
gender=. ''$ ". gender
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	utKeyRead glFilepath,'_green'
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

NB. file exists if we have got this far
NB. Need to check this is a valid shot
ww=. glPlanRecType='P'
ww=. ww *. glPlanHole=hole
ww=. ww *. glPlanTee=tee
ww=. I. ww *. glPlanGender=gender

if.  (0=#ww) do.
    djwErrorPage err ; ('No such sheet : ',}. ; (<'/'),each y) ; ('/jw/rating/plannomap/v/',glFilename) ; 'Back to rating plan'
end.

stdout LF,'<h2>', glCourseName,EM,'Hole=',(":1+hole),' Tee=',(;(tee=glTees)#glTeesName),' ',(>gender{' ' cut' Men Women'),EM,'Yards=',(":(<(glTees i. tee),hole){glTeesYards),'</h2>'
NB. Order by ability, shot
ww=. ww /: ww{glPlanShot
ww=. ww /: ww{glPlanAbility

NB. Print the table of shot distances
stdout LF,'<div class="span-6 last">'
stdout LF,'<table><thead><tr><th>Shots Played</th>'
for_shot. i. 4 do.
    stdout LT4,'<th>',(": 1+shot),'</td>'
end.
stdout LT3,'</tr></thead><tbody>'
for_ability. i. 2 do.
    stdout LT3,'<tr><td>',(>ability{' ' cut 'Scratch Bogey'),'</td>'
    for_shot. i. 4 do.
	ww1=. ( (ability = ww{glPlanAbility) *. (shot = ww{glPlanShot)) # ww
	if. 0=#ww1 do.
	    stdout LT4, '<td></td>'
	else.
	    stdout LT4, '<td>',(": ww1{glPlanHitYards)
	    stdout ' ',(ww1{glPlanLayupType),'</td>'
	end.
    end.
    stdout LT3,'</tr>'
end.
stdout LT3,'</tbody></table>'
stdout LF,'</div>' 


stdout LF,'<div class="span-20 last">'
stdout LF,'<a href="/jw/rating/plannomap/v/',(glFilename),'/',(":1+hole),'">Return to plan</a>'
stdout LF,'</div>' 
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
res=. 1
exit ''
)

