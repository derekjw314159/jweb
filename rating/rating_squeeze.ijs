NB. J Utilities for recording data at landing zones
NB. 

NB. =========================================================
NB. jweb_rating_squeeze_e
NB. View scores for participant
NB. =========================================================
jweb_rating_squeeze_e=: 3 : 0
NB. y=.cgiparms ''
if. 2=#y do.
    'e' rating_squeeze_e  y
elseif. 1 do.
    pagenotfound ''
end.
)

NB. =========================================================
NB. jweb_rating_squeeze_a
NB. View scores for participant
NB. =========================================================
jweb_rating_squeeze_a=: 3 : 0
NB. y=.cgiparms ''
if. 2=#y do.
    'a' rating_squeeze_e  y
elseif. 1 do.
    pagenotfound ''
end.
)



NB. =========================================================
NB. rating_squeeze_e
NB. =========================================================
NB. View scores for participant
rating_squeeze_e=: 4 : 0
NB. Retrieve the details

NB. y has two elements only
if. 'a' = x do.
   'filename hole'=. y
   hole=. ". hole
else.
    'filename keyy'=. y
    keyy=. <keyy
end.
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
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

NB. Add a new carry point
if. 'a' = x do.
    utKeyRead glFilepath,'_plan'
    ww=. glPlanHole = hole
    ww=. ww *. glPlanRecType='Q'
    ww=. I. ww
    if. 0=#ww do.
	ind=. 0
    else.
	ind=. (<4) }. each ww{glPlanID
	ind=. >. / (> ". each ind)
	ind=. 1 + ind
    end.
    keyy=. ,< (;'r<0>2.0' 8!:0 hole),'-Q',": ind
    (,<'_default') utKeyRead glFilepath,'_plan'
    glPlanID=: keyy
    glPlanHole=: hole
    t_index=. _1 + #glTees
    dist=. (<t_index,hole){glTeesYards
    glPlanTee=: ,t_index{glTees
    glPlanGender=: ,_1
    glPlanAbility=: ,_1
    glPlanShot=: ,_1
    glPlanRemGroundYards=: ,dist
    glPlanMeasDist=: ,dist
    glPlanRecType=: ,'Q'
    glPlanSqueezeType=: ,'T'
    utKeyPut glFilepath,'_plan'
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
if. -. keyy e. keydir (glFilepath,'_plan') do.
    djwErrorPage err ; ('No such squeeze point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Read the single record
keyy utKeyRead glFilepath,'_plan'

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Squeeze / Chute Point</h2>'

NB. Work out the back tee
ww=. I. glTeHole = ''$glPlanHole
ww=. ww /: glTees i. ww{glTeTee
ww=.  +. /"1  ww { glTeMeasured NB. If either measured - don't need to split by gender
backtee=. ''${. ww # glTees

stdout LF,'<div class="span-12 last">'
stdout LF,'<table><thead><tr><th>Carry Point</th><th>Value</th></tr></thead><tbody>'

stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glPlanHole),'</td></tr>'

for_t. (glTees) do.
		stdout LT3,'<tr>',LT4,'<td>Distance from : ',>t_index { glTeesName
		stdout '</td>'
		holelength=. (<t_index,glPlanHole){glTeesYards
		cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
		stdout '<td>',(":,cumyards),'</td></tr>'
	NB. Backtee different from tee in question
end.
stdout LT2,'</tbody></table></div>'

stdout LT1,'<form action="/jw/rating/squeeze/editpost/',(;glFilename),'" method="post">'

NB. Hidden variables
stdout LT1,'<div class="span-15 last">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glPlanUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glPlanUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keyplan" value="',(;keyy),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Table of values - Fairway
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>From tee</th><th>Distance</th><th>Squeeze type</th><th>Width</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td>'
djwSelect 'fromtee' ; 1 ; glTeesName ; (<"0 glTees) ; <<''$glPlanTee
t_index=. glTees i. glPlanTee
dist=. (<t_index, glPlanHole){glTeesYards
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;dist - glPlanMeasDist),'" tabindex="2" ',(InputFieldnum 'yards'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'type' ; 3 ; ('/' cut 'Trees/Water/Bunkers/Extreme Rough'); (<"0 'TWBR') ; <<''$glPlanCarryType
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":; glPlanSqueezeWidth),'" tabindex="4" ',(InputFieldnum 'width'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
stdout LT3,'</tr>'
stdout '</tbody></table></div>'

NB. Submit buttons
stdout LT1,'<div class="span-15 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":2),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":3),'">'
stdout LF,'     <input type="submit" name="control_delete" value="Delete this Squeeze" tabindex="',(,":4),'"></form>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_squeeze_editpost
NB. =========================================================
NB. Process entries after edits to landing 
NB. based on the contents after the "post"
jweb_rating_squeeze_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/squeeze/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
xx=. djwCGIPost y ; ' ' cut 'yards width'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
ww=. keyplan utKeyRead glFilepath,'_plan'

NB. Throw error page if updated
if. (-. glSimulate)  do.
if. (-. (;glPlanUpdateTime) -: (;prevtime)) do.
	stdout 'Content-type: text/html',LF,LF,'<!DOCTYPE html>',LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(,;glPlanID),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;glPlanID)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; glPlanUpdateName),' at ',(;glPlanUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/plan/v/',glFilename,'/',(;":1+glPlanHole),'">Restart plan of hole: ',(;":1+glPlanHole),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.
end.

glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlanTee=: ,>fromtee
t_index=. glTees i. glPlanTee
dist=. (<t_index, glPlanHole){glTeesYards
glPlanRemGroundYards=: , dist - yards
glPlanMeasDist=: glPlanRemGroundYards
glPlanSqueezeType=: ,>type
glPlanSqueezeWidth=: ,width
NB. Write to files
keyplan utKeyPut glFilepath,'_plan'

stdout 'Content-type: text/html',LF,LF
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. (0= 4!:0 <'control_delete')  do.
		NB. Delete the landing record
		keyplan utKeyDrop glFilepath,'_plan'
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
	elseif. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)


NB. =========================================================
NB. rating_squeeze_d
NB. =========================================================
NB. Copy data from nearest point
jweb_rating_squeeze_d=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
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
if. -. keyy e. keydir (glFilepath,'_plan') do.
    djwErrorPage err ; ('No such measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Delete the record
keyy utKeyRead glFilepath,'_plan'
(,keyy)utKeyDrop glFilepath,'_plan'

stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
stdout LF,'</body></html>'
exit ''
)

