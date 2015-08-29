NB. J Utilities for recording data at landing zones
NB. 

NB. =========================================================
NB. rating_landing_e
NB. =========================================================
NB. View scores for participant
jweb_rating_landing_e=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

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
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
if. -. keyy e. keydir (glFilepath,'_plan') do.
    djwErrorPage err ; ('No such measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename,'/',>keyy) ; 'Back to rating plan'
end.

NB. Read the single record
keyy utKeyRead glFilepath,'_plan'

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Landing Zone Measurements</h2>'

if. 'P'=glPlanRecType do.
	NB. Print the table of parameters
	stdout LF,'<div class="span-12 last">'
	stdout LF,'<table><thead><tr><th>Landing Zone</th><th>Value</th></tr></thead><tbody>'

	stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glPlanHole),'</td></tr>'

	backtee=. 0{ >glPlanHole{glTeesMeasured
	for_t. (glTees) do.
		if. (t=glPlanTee)  do.
			stdout LT3,'<tr>',LT4,'<td><b>Distance from : ',>t_index { glTeesName
			stdout '</b></td>'
			holelength=. (<t_index,glPlanHole){glTeesYards
			cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
			stdout '<td>',(":,cumyards),'</td></tr>'
		NB. Backtee different from tee in question
		elseif. (t=backtee) do.
			stdout LT3,'<tr>',LT4,'<td><i>Distance from : ',>t_index { glTeesName
			stdout '</i></td>'
			holelength=. (<t_index,glPlanHole){glTeesYards
			cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
			stdout '<td>',(":,cumyards),'</td></tr>'
		end.
	end.
	stdout LF,'<tr><td>Player:</td><td>',(>glPlanGender{' ' cut 'Man Lady ')
	stdout ' ',(>glPlanAbility{' ' cut 'Scratch Bogey')
	stdout LF,'</td></tr>'
	stdout LT4,'<tr><td>Shot:</td><td>',(":1+glPlanShot),'</td></tr>'
	stdout LT2,'</tbody></table></div>'
elseif. 'M'=glPlanRecType do.
	stdout LF,'<div class="span-12 last">'
	stdout LF,'<table><thead><tr><th>Measurement Point</th><th>Value</th></tr></thead><tbody>'

	stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glPlanHole),'</td></tr>'

	backtee=. 0{ >glPlanHole{glTeesMeasured
	for_t. (glTees) do.
			stdout LT3,'<tr>',LT4,'<td>Distance from : ',>t_index { glTeesName
			stdout '</td>'
			holelength=. (<t_index,glPlanHole){glTeesYards
			cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
			stdout '<td>',(":,cumyards),'</td></tr>'
		NB. Backtee different from tee in question
	end.
	stdout LT2,'</tbody></table></div>'
end.

stdout LT1,'<form action="/jw/rating/landing/editpost/',(;glFilename),'" method="post">'

NB. Hidden variables
stdout LT1,'<div class="span-15 last">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glPlanUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glPlanUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keyplan" value="',(;keyy),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Table of values - Fairway
stdout LT1,'<h4>Fairway & Topology</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Alt</th><th>FW Width</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input value="',(":;glPlanAlt),'" tabindex="1" ',(InputFieldnum 'alt'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glPlanFWWidth),'" tabindex="1" ',(InputFieldnum 'fwwidth'; 3),'>',LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table></div>'


NB. Submit buttons
stdout LT1,'<div class="span-15 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":2),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":3),'">'
if. 'M'=glPlanRecType do. NB. Only delete on measurement point
	stdout LF,'     <input type="submit" name="control_delete" value="Delete this M/Point" tabindex="',(,":4),'"></form>'
end.
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
res=. 1
exit ''
)

NB. =========================================================
NB. jweb_rating_landing_editpost
NB. =========================================================
NB. Process entries after edits to landing 
NB. based on the contents after the "post"
jweb_rating_landing_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/landing/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
xx=. djwCGIPost y ; ' ' cut 'alt fwwidth'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
ww=. keyplan utKeyRead glFilepath,'_plan'

NB. Throw error page if updated
if. (-. glSimulate)  do.
if. (-. (;glPlanUpdateTime) -: (;prevtime)) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
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
glPlanAlt=: ,alt
glPlanFWWidth=: ,fwwidth

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
