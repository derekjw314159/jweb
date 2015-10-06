NB. J Utilities for recording data at tees
NB. 

NB. =========================================================
NB. rating_tee_e
NB. =========================================================
NB. View scores for participant
jweb_rating_tee_e=: 3 : 0
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
if. -. keyy e. keydir (glFilepath,'_tee') do.
    djwErrorPage err ; ('No such tee : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Read the single record
keyy utKeyRead glFilepath,'_tee'
hole=. ''$glTeHole

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Tee Measurements</h2>'
stdout LF,'<div class="span-12 last">'
stdout LF,'<table><thead><tr><th></th><th>Value</th></tr></thead><tbody>'
stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glTeHole),'</td></tr>'
stdout LF,'<tr><td>Tee:</td><td>',(": ; (glTees i. glTeTee){glTeesName),'</td></tr>'
stdout LF,'<tr><td>Yards:</td><td>',(": ; (<(glTees i. glTeTee),glTeHole){glTeesYards),'</td></tr>'
stdout LT2,'</tbody></table></div>'

stdout LT1,'<form action="/jw/rating/tee/editpost/',(;glFilename),'" method="post">'

NB. Hidden variables
stdout LT1,'<div class="span-15 last">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glTeUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glTeUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keytee" value="',(;keyy),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Table of values - Tee Measurements
stdout LT1,'<h4>Tee Measurements</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Alt</th><th>Men Measured</th><th>Women Measured</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input value="',(":;glTeAlt),'" tabindex="1" ',(InputFieldnum 'alt'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" name="m0" value="1" '
stdout (0{,glTeMeasured)#'checked '
stdout ' tabindex="2"></td>'
stdout LT4,'<td><input type="checkbox" name="m1" value="1" '
stdout (1{,glTeMeasured)#'checked '
stdout ' tabindex="3"></td>'
stdout LT3,'</tr>'
stdout '</tbody></table></div>'

NB. Table of values - Rough Length
stdout LT1,'<div class="span-15 last">'
stdout LT1,'<h4>General</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>RoughLength</th><th>Apply to all Holes?</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input value="',(":;(hole=glGrHole)#glGrRRRoughLength),'" tabindex="4" ',(InputFieldnum 'rrlength'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" name="all" value="1" '
stdout ' tabindex="5"></td>'
stdout LT3,'</tr>'
stdout '</tbody></table></div>'

NB. Submit buttons
stdout LT1,'<div class="span-15 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":2),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":3),'">'
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
jweb_rating_tee_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/tee/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
NB. Assign default values first
m0=: 0
m1=: 0
all=: 0
xx=. djwCGIPost y ; ' ' cut 'alt m0 m1 rrlength all'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
ww=. keytee utKeyRead glFilepath,'_tee'
hole=. ''$glTeHole
utKeyRead glFilepath,'_green'
((glGrHole=hole)#glGrID) utKeyRead glFilepath,'_green'

NB. Throw error page if updated
if. (-. glSimulate)  do.
if. (-. (;glTeUpdateTime) -: (;prevtime)) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(,;glTeID),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;glTeID)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; glTeUpdateName),' at ',(;glTeUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/plan/v/',glFilename,'/',(;":1+glTeHole),'">Restart plan of hole: ',(;":1+glTeHole),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.
end.

glTeUpdateName=: ,<": getenv 'REMOTE_USER'
glTeUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glTeAlt=: ,alt
glTeMeasured=: 1 2 $,m0,m1
glGrRRRoughLength=: ,rrlength
if. all do.
    utKeyRead glFilepath,'_green'
    glGrRRRoughLength=: 18$rrlength
end.

NB. Write to files
keytee utKeyPut glFilepath,'_tee'
utKeyPut glFilepath,'_green'
BuildPlan glTeHole ; glTeTee ; '' ; '' ; ''
keytee utKeyRead glFilepath,'_tee'
utKeyRead glFilepath,'_green'
((glGrHole=hole)#glGrID) utKeyRead glFilepath,'_green'

stdout 'Content-type: text/html',LF,LF
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(":1+glTeHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)

