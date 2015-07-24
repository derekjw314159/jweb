NB. J Utilities for Rating Courses
NB. 
EM=: ; 3$,: '&emsp;'

NB. =========================================================
NB. rating_layup_e
NB. =========================================================
NB. View scores for participant
jweb_rating_layup_e=: 3 : 0
NB. Retrieve the details

NB. y has three elements, which need to be decomposed

'filename hole_tee gender_ability_shot'=. y
hole=. ''$ 0". }:hole_tee
hole=. <. 0.5 + hole
hole=. 0 >. 17 <. hole-1
tee=. ''$_1{hole_tee NB. case sensitive
gender=. ''$ 'MW' i. 0{gender_ability_shot NB. zero indexed
ability=. ''$ 'SB' i. 1{gender_ability_shot
shot=. ''$ '123456789' i. 2{gender_ability_shot NB. shot is zero indexed
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
	stdout LF,TAB,'<div class="span-24">'
	stdout LF,TAB,TAB,'<h1>',err,'</h1>'
	stdout LF,TAB,TAB,'<div class="error">No such course name : ',glFilename
	stdout '</div>'
	stdout LF,TAB,'</div>'
	stdout LF,TAB,'<br><a href="/jw/rating/plan/v">Back to rating plan</a>'
	stdout LF, '</div>',LF,'</body></html>'
	exit ''
end.

NB. file exists if we have got this far


NB. Read the keyed variables
ww=. utKeyRead glFilepath,'_plan'
ix=. glPlanHole=hole
ix=. ix *. glPlanTee=tee
ix=. ix *. glPlanGender=gender
ix=. ix *. glPlanAbility=ability
ix=. ix *. glPlanShot=shot
ix=. I. ix *. glPlanRecType='P'
ix=. ix { glPlanID

NB. Need to check this is a valid shot
if. 0=#ix do.
	stdout LF,TAB,'<div class="span-24">'
	stdout LF,TAB,TAB,'<h1>',err,'</h1>'
	stdout LF,TAB,TAB,'<div class="error">No such hole combination : ',}. ; (<'/'),each y
	stdout '</div>'
	stdout LF,TAB,'</div>'
	stdout LF,TAB,'<br><a href="/jw/rating/plan/v/',filename,'/',(":hole+1),'">Back to rating plan</a>'
	stdout LF, '</div>',LF,'</body></html>'
	exit ''
end.

ww=. ix utKeyRead glFilepath,'_plan' NB. Read one record only

key=. EnKey hole ; '' ; tee ; gender ; ability ; shot
NB. New item check
ww=. key utKeyRead glFilepath,'_layup'
if. ( _4 -: >glLayupID ) do.  NB. Not found
	glLayupID=: ,key
	glLayupHole=: ,hole
	glLayupTee=: ,tee
	glLayupGender=: ,gender
	glLayupAbility=: ,ability
	glLayupShot=: ,shot
	glLayupRemGroundYards=: glPlanRemGroundYards
	glLayupType=: ,'L'
	glLayupUpdateName=: ,<": getenv 'REMOTE_USER'
	glLayupUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
	ww=. utKeyPut glFilepath,'_layup'
end. 

NB. Calculate default yards (reducing if shot to the green)
defaulthit=. (< gender, ability, 1<. shot){glPlayerDistances
remain=. glPlanHitYards + glPlanRemGroundYards
defaulthit=. defaulthit <. remain
transition=. 0
NB. Transitional distance check if within 10 yards
if. (defaulthit < remain) *. (defaulthit + 10) >: remain do.
	defaulthit=. glPlanHitYards + glPlanRemGroundYards
	transition=. 1
end.

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Edit Layup or Roll</h2>'
stdout LF,'<h3>Layup for Hole=',(":1+ ; hole),EM,'Tee=',>(glTees i. tee){glTeesName
stdout EM, 'Player=',(>gender{' ' cut 'Man Lady ')
stdout ' ',(>ability{' ' cut 'Scratch Bogey')
stdout EM,'Shot=',(":1+shot),'</h3>'
stdout LT1,'<div class="span-15 last">'

stdout LT1,'<form action="/jw/rating/layup/editpost/',(;glFilename),'" method="post">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glLayupUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glLayupUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keyplan" value="',(;ix),'">'
stdout LT2,'<input type="hidden" name="keylayup" value="',(;key),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. First table is layup values

NB. Logic is different depending on whether it is 
NB. type layup or type roll
if. glLayupType='L' do.

	NB. Table of potential values to change
	stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
	stdout LT4,'<th></th>',LT4,'<th>Previous</th>',LT4,'<th>Hit/Layup</th>',LT4,'<th>Cumulative</th>',LT4,'<th>Remain</th>',LT4,'<th>Total</th>',LT3,'</tr>',LT2,'</thead>',LT2,'<tbody>'
	backtee=. 0{ >hole{glTeesMeasured

	NB. Add the default hit
	stdout LT3,'<tr>',LT4,'<td>Default hit</td>',LT4,'<td></td>',LT4,'<td><font color="red">',(": defaulthit),(transition{' T'),'</font></td>',LT4,'<td></td>',LT4,'<td></td>',LT4,'<td></td>'
	stdout LT4,'<input type="hidden" name="defaulthit" value="',(":;defaulthit),'">',LT3,'</tr>'

	extraline=. 0

	for_t. (glTees) do.
		if. (t=tee)  do.
			stdout LT3,'<tr>',LT4,'<td><b>From ',>t_index { glTeesName
			stdout ' tee</b></td>'
			stdout LT3,'<td>',": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
			prevhityards=. glPlanHitYards
			stdout '</td><td><input  value="',(":,prevhityards),'" tabindex="1" ',(InputFieldnum 'hityards'; 4),'>'
			stdout '<input type="hidden" name="prevhityards" value="',(":,prevhityards),'">'

			prevcumyards=.  ((<t_index,hole){glTeesYards) - glPlanRemGroundYards 
			stdout '</td><td><input value="',(":,prevcumyards),'" tabindex="2" ',(InputFieldnum 'cumyards' ; 4),'>'
			stdout '<input type="hidden" name="prevcumyards" value="',(":,prevcumyards),'">'
			
			prevremyards=. glPlanRemGroundYards 
			stdout '</td><td><input  value="',(":,prevremyards),'" tabindex="3" ',(InputFieldnum 'remyards' ; 4),'>'
			stdout '<input type="hidden" name="prevremyards" value="',(":,prevremyards),'">'
			stdout '</td><td>',": ,prevcumyards + prevremyards
			stdout '</td>',LT3,'</tr>'
		NB. Backtee different from tee in question
		elseif. (t=backtee) do.
			extraline=. 1
			stdout LT3,'<tr>',LT4,'<td><i>Calc distances from ',>t_index { glTeesName
			stdout ' tee</i></td>',LT4,'<td>'
			stdout ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
			stdout '</td><td>', ": glPlanHitYards
			prevcumbackyards=.  ((<t_index,hole){glTeesYards) - glPlanRemGroundYards 
			stdout '</td>',LT4,'<td><input  value="',(":,prevcumbackyards),'" tabindex="4" ',(InputFieldnum 'cumbackyards' ; 4 ),'>'
			stdout '<input type="hidden" name="prevcumbackyards" value="',(":,prevcumbackyards),'">'
			stdout '</td><td>', ": glPlanRemGroundYards 
			stdout '</td><td>', ": prevcumbackyards + glPlanRemGroundYards
			stdout '</td></tr>'
		end.
	end.
	stdout '</tbody></table>'

else.

	NB. Table of potential values to change
	stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
	stdout LT4,'<th></th>',LT4,'<th>Previous</th>',LT4,'<th>Hit/Layup</th>',LT4,'<th>Cumulative</th>',LT4,'<th>Remain</th>',LT4,'<th>Total</th>',LT3,'</tr>',LT2,'</thead>',LT2,'<tbody>'
	backtee=. 0{ >hole{glTeesMeasured

	NB. Add the default hit
	stdout LT3,'<tr>',LT4,'<td>Default hit</td>',LT4,'<td></td>',LT4,'<td><font color="red">',(": defaulthit),(transition{' T'),'</font></td>',LT4,'<td></td>',LT4,'<td></td>',LT4,'<td></td>'
	stdout LT4,'<input type="hidden" name="defaulthit" value="',(":;defaulthit),'">',LT3,'</tr>'

	extraline=. 0

	for_t. (glTees) do.
		if. (t=tee)  do.
			stdout LT3,'<tr>',LT4,'<td><b>From ',>t_index { glTeesName
			stdout ' tee</b></td>'
			stdout LT3,'<td>',": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
			NB. Need to adjust back to defaults
			prevhityards=. defaulthit
			stdout '</td><td><input  value="',(":,prevhityards),'" tabindex="1" ',(InputFieldnum 'hityards'; 4),'>'
			stdout '<input type="hidden" name="prevhityards" value="',(":,prevhityards),'">'

			prevcumyards=.  ((<t_index,hole){glTeesYards) + defaulthit - glPlanRemGroundYards + glPlanHitYards
			stdout '</td><td><input value="',(":,prevcumyards),'" tabindex="2" ',(InputFieldnum 'cumyards' ; 4),'>'
			stdout '<input type="hidden" name="prevcumyards" value="',(":,prevcumyards),'">'
			
			prevremyards=. glPlanRemGroundYards + glPlanHitYards - defaulthit
			stdout '</td><td><input  value="',(":,prevremyards),'" tabindex="3" ',(InputFieldnum 'remyards' ; 4),'>'
			stdout '<input type="hidden" name="prevremyards" value="',(":,prevremyards),'">'
			stdout '</td><td>',": ,prevcumyards + prevremyards
			stdout '</td>',LT3,'</tr>'
		NB. Backtee different from tee in question
		elseif. (t=backtee) do.
			extraline=. 1
			stdout LT3,'<tr>',LT4,'<td><i>Calc distances from ',>t_index { glTeesName
			stdout ' tee</i></td>',LT4,'<td>'
			stdout ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
			stdout '</td><td>', ": defaulthit
			prevcumbackyards=.  ((<t_index,hole){glTeesYards) + defaulthit - glPlanRemGroundYards + glPlanHitYards 
			stdout '</td>',LT4,'<td><input  value="',(":,prevcumbackyards),'" tabindex="4" ',(InputFieldnum 'cumbackyards' ; 4 ),'>'
			stdout '<input type="hidden" name="prevcumbackyards" value="',(":,prevcumbackyards),'">'
			stdout '</td><td>', ": glPlanRemGroundYards  + glPlanHitYards - defaulthit
			stdout '</td><td>', ": prevcumbackyards + glPlanRemGroundYards + glPlanHitYards - defaulthit
			stdout '</td></tr>'
		end.
	end.
	stdout '</tbody></table>'
end.  NB. End of layout / roll conditional logic for layup

NB. Second table is simple roll logic
stdout LF,'<h3><br><br>Roll for Hole=',(":1+ ; hole),EM,'Tee=',>(glTees i. tee){glTeesName
stdout EM, 'Player=',(>gender{' ' cut 'Man Lady ')
stdout ' ',(>ability{' ' cut 'Scratch Bogey')
stdout EM,'Shot=',(":1+shot),'</h3>'
NB. Logic is different depending on whether it is 
NB. type layup or type roll
if. glLayupType='L' do.

	NB. Table of potential values to change
	stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
	stdout LT4,'<th></th>',LT4,'<th>Previous</th>',LT4,'<th>Carry</th>',LT4,'<th>Roll</th>',LT4,'<th>Total Hit</th>',LT3,'<th>Remain</th></tr>',LT2,'</thead>',LT2,'<tbody>'
	t_index=. glTees i. tee
	stdout LT4,'<tr>',LT4,'<td><b>From ',>t_index { glTeesName
	stdout ' tee</b></td>'
	stdout LT4,'<td>',": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
	prevroll=. defaulthit
	stdout '</td><td>',(,": prevroll-20),'</td><td>+20</td>'
	stdout LT4,'<td><input  value="',(":,prevroll),'" tabindex="',(":3+extraline),'" ',(InputFieldnum 'roll'; 4),'>'
	stdout '<input type="hidden" name="prevroll" value="',(":,prevroll),'">'
	stdout '</td>',LT4,'<td>',(,":glPlanRemGroundYards + glPlanHitYards - defaulthit),'</td></tr>'
	NB. Backtee different from tee in question
	stdout LT2,'</tbody></table>'
else.
	NB. Table of potential values to change
	stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
	stdout LT4,'<th></th>',LT4,'<th>Previous</th>',LT4,'<th>Carry</th>',LT4,'<th>Roll</th>',LT4,'<th>Total Hit</th><th>Remain</th>',LT3,'</tr>',LT2,'</thead>',LT2,'<tbody>'
	t_index=. glTees i. tee
	stdout LT4,'<tr>',LT4,'<td><b>From ',>t_index { glTeesName
	stdout ' tee</b></td>'
	stdout LT4,'<td>',": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
	prevroll=. glPlanHitYards 
	stdout '</td><td>',(,": defaulthit-20),'</td>',LT4,'<td>', (;'p<+>m<->' 8!:0 prevroll-defaulthit-20),'</td>'
	stdout LT4,'<td><input  value="',(":,prevroll),'" tabindex="',(":3+extraline),'" ',(InputFieldnum 'roll'; 4),'>'
	stdout '<input type="hidden" name="prevroll" value="',(":,prevroll),'">'
	stdout '</td><td>',(,":glPlanRemGroundYards),'</td>',LT3,'</tr>'
	NB. Backtee different from tee in question
	stdout LT2,'</tbody></table>'
end.  NB. End of layout / roll conditional logic for roll

NB. Submit buttons
stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":4+extraline),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":5+extraline),'">'
stdout LF,'     <input type="submit" name="control_delete" value="Reset to Default Hit" tabindex="',(,":6+extraline),'"></form></div>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
res=. 1
exit ''

)

NB. =========================================================
NB. jweb_rating_layup_editpost
NB. =========================================================
NB. Process entries after edits to layup 
NB. based on the contents after the "post"
jweb_rating_layup_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by layup/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/layup/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
xx=. djwCGIPost y ; ' ' cut 'defaulthit cumbackyards prevcumbackyards hityards prevhithards cumyards prevcumyards remyards prevremyards roll prevroll'
keyplan=: ; keyplan
keylayup=: ; keylayup
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. (<keyplan) utKeyRead glFilepath,'_plan'
ww=. (<keylayup) utKeyRead glFilepath,'_layup'

NB. Throw error page if updated
if. (-. glSimulate) *. (-. (;glLayupUpdateTime) -: (;prevtime)) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(,;glLayupID),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;glLayupID)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; glLayupUpdateName),' at ',(;glLayupUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/plan/v/',glFilename,'/',(;":1+glLayupHole),'">Restart plan of hole: ',(;":1+glLayupHole),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.

glLayupUpdateName=: ,<": getenv 'REMOTE_USER'
glLayupUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlanUpdateName=: glLayupUpdateName
glPlanUpdateTime=: glPlanUpdateTime

NB. Check for changes
deletelayup=. 0
changed=. 0
if. cumyards ~: prevcumyards do.
	changed=. 1
	glLayupType=: ,'L'
	glPlanLayupType=: ,'L'
	glPlanHitYards=: glPlanHitYards + cumyards - prevcumyards
	glLayupRemGroundYards=: glLayupRemGroundYards + prevcumyards - cumyards
	NB. All the others will be recalculated
elseif. cumbackyards ~: prevcumbackyards do.
	changed=. 1
	glLayupType=: ,'L'
	glPlanLayupType=: ,'L'
	glPlanHitYards=: glPlanHitYards + cumbackyards - prevcumbackyards
	glLayupRemGroundYards=: glLayupRemGroundYards + prevcumbackyards - cumbackyards
	NB. All the others will be recalculated
elseif. hityards ~: prevhityards do.
	changed=. 1
	glLayupType=: ,'L'
	glPlanLayupType=: ,'L'
	glPlanHitYards=: glPlanHitYards + hityards - prevhityards
	glLayupRemGroundYards=: glLayupRemGroundYards + prevhityards - hityards
	NB. All the others will be recalculated
elseif. remyards ~: prevremyards do.
	changed=. 1
	glLayupType=: ,'L'
	glPlanLayupType=: ,'L'
	glPlanHitYards=: glPlanHitYards + prevremyards - remyards
	glLayupRemGroundYards=: glLayupRemGroundYards + prevremyards - remyards
	NB. All the others will be recalculated
elseif. roll ~: prevroll do.
	changed=. 1
	glLayupType=: ,'R'
	glPlanLayupType=: ,'R'
	glPlanHitYards=: glPlanHitYards + roll - prevroll
	glLayupRemGroundYards=: glLayupRemGroundYards + prevroll - roll
	NB. All the others will be recalculated
end.

NB. Write to two files
if. changed do.
	(,<keylayup) utKeyPut glFilepath,'_layup'
	(,<keyplan) utKeyPut glFilepath,'_plan'
	NB. Write another measurepoint record based on original readings
	glPlanRemGroundYards=: ,prevremyards
	glPlanRecType=: ,'M'
	glPlanLayupType=: ,' '
	glPlanID=: ,<6{. keyplan
	(,<6{. keyplan) utKeyPut glFilepath,'_plan'
end.

if. defaulthit = glPlanHitYards do.
	deletelayup=. 1
end.

stdout 'Content-type: text/html',LF,LF
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. (0= 4!:0 <'control_delete') +. deletelayup do.
		NB. Delete the layup record
		(<keylayup) utKeyDrop glFilepath,'_layup'
		glPlanHitYards=: defaulthit
		glPlanRecType=: ,'P'
		glPlanLayupType=: ,' '
		(<keyplan) utKeyPut glFilepath,'_plan'
		stdout '</head><body onLoad="redirect(''/jw/rating/plan/v/',glFilename,'/',(;":1+glPlanHole),''')"'
	elseif. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'

	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plan/v/',glFilename,'/',(;":1+glPlanHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_plan_a
NB. ========================:=================================
NB. View scores for participant
jweb_rating_plan_a=: 3 : 0
y=.cgiparms ''
if. 'rating/course/a' -: >(< 0 1){y do.
    rating_plan_add ''
else.
    if. 1=#y do. NB. Passed as parameter
	y=. (#'rating/course/a/')}. >(<0 1){y
    else.
	if. 'error' -: >(<1 0){ y do.
	    y=.( (#'rating/course/a/')}.>(<0 1) { y),'&error=', >(<1 1) { y
	else.
	    pagenotfound ''
	end.
    end.
end.
rating_plan_add y
)

NB. =========================================================
NB. rating_plan_add 
NB. =========================================================
NB. View scores for participant
rating_plan_add=: 3 : 0
NB. Retrieve the details
xx=.glDbFile djwSqliteR 'select * from tbl_control;'
xx=.'tbl_control' djwSqliteSplit xx

NB. Check input parameters
NB. If two parameters it is in error no edit
x=.'&error' E. y
if. +. / x do.
	x=. I. x
	if. +. / 'Duplicate' E. y do.
		err=. 'Duplicate entry : '
	else. 
		err=. 'Name not valid: use only letters and numbers : '
	end.
	y=. x {. y
else. err=. ''
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'
stdout LF,TAB,TAB,'<h2>New Course</h2><i>',(": getenv 'REMOTE_USER'),'</i>'
NB. Error page - No such course
if. 0<# err do.
    stdout LF,TAB,'<div class="span-24">'
    stdout, '<div class="error">',err,y
    stdout  ,2$,: '</div>'
end.
NB. Print scorecard and yardage
stdout LF,TAB,'<div class="span-12">'
stdout LF, TAB,'<form action="/jw/rating/course/addpost" method="post">'
stdout LF,'<span class="span-3">Course code :</span><input name="tbl_plan_name" value="',(":,y),'" tabindex="1" ',(InputField 8),'>'

NB. Submit buttons
stdout LF,'<input type="submit" name="control_add" value="Add" tabindex="58"></form></div>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_plan_addpost
NB. =========================================================
NB. Process entries after edits to course
NB. based on the contents after the "post"
jweb_rating_plan_addpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by course/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. (-. +. / 'rating/course/a' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
    pagenotvalid ''
end.

NB. Assign to variables
xx=. djwCGIPost y 
err=. ''
NB. Check whether the value already exists
yy=.glDbFile djwSqliteR 'select updatename,updatetime from tbl_plan WHERE name=''',(;tbl_plan_name),''';'
 
if. (0 <  # yy ) do.
	err=. 'Duplicate'
end.

yy=. *. / (;tbl_plan_name) e. 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
yy=. yy *. -. ({. ; tbl_plan_name) e. '01234567890-_'
if. -.yy do.
	err=.'Not+Valid'
 end.

NB. Throw error page if updated
if. 0 < # err do.
	yy=. '/jw/rating/course/a/',(;tbl_plan_name),'&error'
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h2>Error adding : ',(;tbl_plan_name),'</h2>'
 	stdout LF,'<div class="error">Database error trying to add : ',(;tbl_plan_name)
 	stdout LF,'</br><br><b>**Addition has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
	NB. Strip out invalid characters in link string
 	stdout LF,'</br><a href="/jw/rating/course/a/',((-.(;tbl_plan_name) e. ' /\&?')#;tbl_plan_name),'&error=',err,'">Restart to add: ',(;tbl_plan_name),'</a>'
 	stdout, '</div></body>'
	exit ''
end.

tbl_plan_updatename=: ,<": getenv 'REMOTE_USER'
tbl_plan_updatetime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
tbl_plan_desc=: ,<'Please add a description'

string=. djwSqliteInsert 'tbl_plan' ; 'tbl_plan_' ; 'tbl_plan_name' ; 'tbl_plan_'
NB. Can't handle too big a file on "echo"
NB. so write out to random seed
label_seed.
seed=. <. 1000 * 5 { 6!:0 ''
xx=. 9!:1 seed
rand=. ? 9999999
rand=. glDbFile,'.',":rand
if. 8 < # 1!:0 <rand do. goto_seed. end.
xx=.string 1!:2 <rand
xx=.glDbFile djwSqliteR '.read ',rand
xx=. 1!:55 <rand

NB. xx=.glDbFile djwSqliteR string

stdout 'Content-type: text/html',LF,LF
NB. stdout 'Location: "http://',(getenv 'SERVER_NAME'),'/jw/rating/course/v/',(,tbl_plan_name),'"'
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
    if. 0= 4!:0 <'control_add' do.
	stdout '</head><body onLoad="redirect(''https://',(getenv 'SERVER_NAME'),'/jw/rating/course/e/',(,>tbl_plan_name),''')"'
    else.  
	stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/rating/course/v/',(,>tbl_plan_name),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)
