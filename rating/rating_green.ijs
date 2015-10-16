NB. J Utilities for recording data at green
NB. 

NB. =========================================================
NB. rating_green_e
NB. =========================================================
jweb_rating_green_e=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_tee'
	utKeyRead glFilepath,'_green'
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
if. -. keyy e. keydir (glFilepath,'_green') do.
    djwErrorPage err ; ('No such green measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Read the single record
keyy utKeyRead glFilepath,'_green'

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Green Measurements</h2>'

NB. Work out the back tee
ww=. I. glTeHole = ''$glGrHole
ww=. ww /: glTees i. ww{glTeTee
ww=.  +. /"1  ww { glTeMeasured NB. If either measured - don't need to split by gender
backtee=. ''${. ww # glTees

NB. Fix back tee
if. 0=glGrFrontYards do.
    glGrTee=: ,backtee
end.

stdout LF,'<div class="span-12 last">'
stdout LF,'<table><thead><tr><th>Parameter</th><th>Value</th></tr></thead><tbody>'

stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glGrHole),'</td></tr>'

for_t. (glTees) do.
	stdout LT3,'<tr>',LT4,'<td>Distance from : ',>t_index { glTeesName
	stdout '</td>'
	holelength=. (<t_index,glGrHole){glTeesYards
	stdout '<td>',(":,holelength),'</td></tr>'
	NB. Backtee different from tee in question
end.
stdout LT2,'</tbody></table></div>'

stdout LT1,'<form action="/jw/rating/green/editpost/',(;glFilename),'" method="post">'

NB. Hidden variables
stdout LT1,'<div class="span-15 last">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glGrUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glGrUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keyplan" value="',(;keyy),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Measurements
stdout LT1,'<h4>Distances</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>From Tee</th><th>Green Front</th><th>Length</th><th>Width</th><th>Diam</th><th>Circle Concept</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td>'
djwSelect 'fromtee' ; 1 ; glTeesName ; (<"0 glTees) ; <<''$glGrTee
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrFrontYards),'" tabindex="2" ',(InputFieldnum 'frontyards'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrLength),'" tabindex="3',(InputFieldnum 'length'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrWidth),'" tabindex="4',(InputFieldnum 'width'; 3),'>',LT4,'</td>'
stdout LT4,'<td>',(":;glGrDiam),LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="circleconcept" name="circleconcept" value="1" '
stdout ((''$glGrCircleConcept)#'checked'),' tabindex="5">',LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

NB. Table of values - Common Values
stdout LT1,'<h4>Common Measurements</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Alt</th><th>Dist OB</th><th>Dist Tr</th><th>Tree Recov</th><th>Dist Wat</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input value="',(":;glGrAlt),'" tabindex="1" ',(InputFieldnum 'alt'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrOOBDist),'" tabindex="4" ',(InputFieldnum 'oobdist'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrTreeDist),'" tabindex="5" ',(InputFieldnum 'treedist'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'treerecov' ; 6 ; glTreeRecovDesc ; glTreeRecovVal ; <''$glGrTreeRecov
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrWaterDist),'" tabindex="7" ',(InputFieldnum 'waterdist'; 3),'>',LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table></div>'

NB. Submit buttons
stdout LT1,'<div class="span-15 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":2),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":3),'">'
stdout LF,'</div>' NB. end submit
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_green_editpost
NB. =========================================================
NB. Process entries after edits to landing 
NB. based on the contents after the "post"
jweb_rating_green_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/green/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
circleconcept=: 0
xx=. djwCGIPost y ; ' ' cut 'frontyards length width circleconcept alt oobdist treedist waterdist'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
ww=. keyplan utKeyRead glFilepath,'_green'

NB. Throw error page if updated
if. (-. glSimulate)  do.
if. (-. (;glGrUpdateTime) -: (;prevtime)) do.
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
 	stdout LF,'</br><br>It has since been updated by: ',(; glGrUpdateName),' at ',(;glGrUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/plan/v/',glFilename,'/',(;":1+glGrHole),'">Restart plan of hole: ',(;":1+glGrHole),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.
end.

glGrUpdateName=: ,<": getenv 'REMOTE_USER'
glGrUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glGrTee=: ,>fromtee
glGrFrontYards=: ,frontyards 
glGrLength=: ,length
glGrWidth=: ,width
glGrDiam=: ,<. 0.5 + (0.5*length+width)
glGrCircleConcept=: ,circleconcept
glGrAlt=: ,alt
glGrFWWidth=: ,fwwidth
glGrOOBDist=: ,oobdist
glGrTreeDist=: ,treedist
glGrTreeRecov=: ,treerecov
glGrWaterDist=: , waterdist

NB. Write to files
keyplan utKeyPut glFilepath,'_green'

stdout 'Content-type: text/html',LF,LF
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glGrHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)
