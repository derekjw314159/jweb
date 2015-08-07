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
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_layup'
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
	glLayupValue=: ,<'forced'
	glLayupReason=: ,<'Water'
	glLayupRollLevel=: ,<'level'
	glLayupRollFirmness=: ,<'average'
	ww=. utKeyPut glFilepath,'_layup'
end. 

NB. Calculate default yards (reducing if shot to the green)
defaulthit=. (< gender, ability, 1<. shot){glPlayerDistances
remain=. glPlanHitYards + glPlanRemGroundYards
defaulthit=. defaulthit <. remain
transition=. 0
NB. Transitional distance check if within 10 yards
if. (defaulthit < remain) *. (defaulthit + 10) >: remain do.
	defaulthit=. remain
	transition=. 1
end.

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Edit Layup or Roll</h2>'

NB. Sequence the entries
sequence=. (glLayupType='R') |. 'LR'
extraline=. 0

NB. Print the table of parameters
stdout LF,'<div class="span-12 last">'
stdout LF,'<table><thead><tr><th></th><th>Value</th></tr></thead><tbody>'

stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; hole),'</td></tr><tr><td>Tee:</td><td>',>(glTees i. tee){glTeesName
stdout '</td></tr><tr><td>Player:</td><td>',(>gender{' ' cut 'Man Lady ')
stdout ' ',(>ability{' ' cut 'Scratch Bogey')
stdout '</td></tr><tr><td>Shot:</td><td>',(":1+shot),'</td></tr><tr><td>Override Type:</td><td>',(;>('LR'i. glLayupType){' ' cut 'Layup Roll'),'</td></tr></tbody></table></div>'
stdout LT1,'<form action="/jw/rating/layup/editpost/',(;glFilename),'" method="post">'

NB. type layup or type roll
for_seq. sequence do.

if. seq = 'L' do. 

	stdout LT1,'<div class="span-15 last">'
NB.	stdout LF,'<h3>Layup</h3>'
	stdout LT2,'<input type="hidden" name="prevname" value="',(":;glLayupUpdateName),'">'
	stdout LT2,'<input type="hidden" name="prevtime" value="',(;glLayupUpdateTime),'">'
	stdout LT2,'<input type="hidden" name="keyplan" value="',(;ix),'">'
	stdout LT2,'<input type="hidden" name="keylayup" value="',(;key),'">'
	stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

	stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
	stdout LT4,'<th>Layup</th>',LT4,'<th>Previous</th>',LT4,'<th>Hit/Layup</th>',LT4,'<th>Cumulative</th>',LT4,'<th>Remain</th>',LT4,'<th>Total</th>',LT3,'</tr>',LT2,'</thead>',LT2,'<tbody>'
	backtee=. 0{ >hole{glTeesMeasured

	NB. Layup Table and Tyoe = Layup
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

	NB. Add the rows for the Layup Reason
	stdout LT3,'<tr>',LT4,'<td>Layup type</td><td colspan="4"><select name="layvalue" id="layvalue" tabindex="5" style="font-size: 8pt; height: 16px;">'
	for_ll. glLayValue do.
		stdout LT5,'<option value="',(>ll)
		if. ll = glLayupValue do.
			stdout '" selected>'
		else. stdout '">'
		end.
		stdout (>ll_index{glLayDesc),'</option>'
	end. 
	stdout LT4,'</select></td</tr>'
	stdout LT3,'<tr>',LT4,'<td>Layup Reason</td><td colspan="4">'
	stdout '<input name="layreason" value="',(;glLayupReason),'" tabindex="6" ',(InputField 15),'></td></tr>'

	stdout '</tbody></table></div>'

elseif. seq = 'R' do.
	stdout LT1,'<div class="span-15 last">'

NB. Second table is simple roll logic

	stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
	stdout LT4,'<th>Roll</th>',LT4,'<th>Previous</th>',LT4,'<th>Carry</th>',LT4,'<th>Roll</th>',LT4,'<th>Total Hit</th><th>Remain</th>',LT3,'</tr>',LT2,'</thead>',LT2,'<tbody>'
	stdout LT3,'<tr>',LT4,'<td>Default hit</td>',LT4,'<td></td><td></td><td></td>',LT4,'<td><font color="red">',(": defaulthit),(transition{' T'),'</font></td>',LT4,'<td></td>',LT4,'<td></td>',LT4,'<td></td>',LT3,'</tr>'
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
	stdout LT2,'</tbody></table></div>'
end.  NB. End of layout / roll conditional logic for roll
end. NB. End of sequence logic

NB. Submit buttons
stdout LT1,'<div class="span-15 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":4+extraline),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":5+extraline),'">'
stdout LF,'     <input type="submit" name="control_delete" value="Reset to Default Hit" tabindex="',(,":6+extraline),'"></form>'
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
xx=. djwCGIPost y ; ' ' cut 'defaulthit cumbackyards prevcumbackyards hityards prevhityards cumyards prevcumyards remyards prevremyards roll prevroll'
keyplan=: ; keyplan
keylayup=: ; keylayup
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. May not have fields for cumbackyards
if. _1 = 4!:0 <'cumbackyards' do.
	cumbackyards=: cumyards
	prevcumbackyards=: cumbackyards NB. No difference
end.

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
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
glLayupValue=: ,layvalue
glLayupReason=: ,layreason

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
	glPlanHitYards=: ,hityards 
	glLayupRemGroundYards=: glLayupRemGroundYards + prevhityards - hityards
	NB. All the others will be recalculated
elseif. remyards ~: prevremyards do.
	changed=. 1
	glLayupType=: ,'L'
	glPlanLayupType=: ,'L'
	glPlanHitYards=: glPlanHitYards + prevremyards - remyards
	glLayupRemGroundYards=: glLayupRemGroundYards - prevremyards - remyards
	NB. All the others will be recalculated
elseif. roll ~: prevroll do.
	changed=. 1
	glLayupType=: ,'R'
	glPlanLayupType=: ,'R'
	glPlanHitYards=: ,roll 
	glLayupRemGroundYards=: glLayupRemGroundYards + prevhityards - roll
	NB. All the others will be recalculated
end.

NB. Write to two files
if. 1 +. changed do.
	(,<keylayup) utKeyPut glFilepath,'_layup'
	(,<keyplan) utKeyPut glFilepath,'_plan'

	NB. Calculate Everything
	BuildPlan glPlanHole ; glPlanTee ; glPlanGender ; glPlanAbility
	(,<keylayup) utKeyRead glFilepath,'_layup'
	(,<keyplan) utKeyRead glFilepath,'_plan'
	
	NB. Write another measurepoint record based on original readings
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
		BuildPlan glPlanHole ; glPlanTee ; glPlanGender ; glPlanAbility
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
	elseif. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'

	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)

