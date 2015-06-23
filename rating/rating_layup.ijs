NB. J Utilities for Rating Courses
NB. 
EM=: ; 3$,: '&emsp;'

NB. =========================================================
NB. rating_layup_e
NB. =========================================================
NB. View scores for participant
jweb_rating_layup_e=: 3 : 0
NB. Retrieve the details

NB. y has six elements
'filename hole tee gender ability shot'=. y
hole=. ''$ 0". hole
hole=. <. 0.5 + hole
hole=. 0 >. 17 <. hole
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

tee=. ''$tee
gender=. ''$0". gender
ability=. ''$0". ability
shot=. ''$0". shot

NB. Read the keyed variables
ww=. utKeyRead glFilepath,'_plan'
ix=. glPlanHole=hole
ix=. ix *. glPlanTee=tee
ix=. ix *. glPlanGender=gender
ix=. ix *. glPlanAbility=ability
ix=. I. ix *. glPlanShot=shot
ix=. ix { glPlanID

NB. Need to check this is a valid shot
if. 0=#ix do.
	stdout LF,TAB,'<div class="span-24">'
	stdout LF,TAB,TAB,'<h1>',err,'</h1>'
	stdout LF,TAB,TAB,'<div class="error">No such hole combination : ',}. ; (<'/'),each y
	stdout '</div>'
	stdout LF,TAB,'</div>'
	stdout LF,TAB,'<br><a href="/jw/rating/plan/v">Back to rating plan</a>'
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
	glLayupUpdateName=: ,a:
	glLayupUpdateTime=: ,a:
	ww=. utKeyPut glFilepath,'_layup'
end. 

stdout LF,TAB,TAB,'<h2>Course : ', glCourseName,EM,EM,'Edit Layup or Roll</h2><h3>Layup for Hole=',(":1+ ; hole),EM,'Tee=',>(glTees i. tee){glTeesName
stdout EM, 'Player=',(>gender{' ' cut 'Man Lady ')
stdout ' ',(>ability{' ' cut 'Scratch Bogey')
stdout EM,'Shot=',(":1+shot),'</h3>'
stdout LF,TAB,'<div class="span-15 last">'

stdout LF, TAB,'<form action="/jw/rating/layup/editpost',(;(<'/'),each y),'" method="post">'
stdout LF, TAB,'<input type="hidden" name="prevname" value="',(":;glLayupUpdateName),'">'
stdout LF, TAB,'<input type="hidden" name="prevtime" value="',(;glLayupUpdateTime),'">'

NB. Table of potential values to change
stdout LF,'<table><thead><tr>'
stdout '<th> </th><th>Previous</th><th>Hit/Layup</th><th>Cumulative</th><th>Remain</th></tr></thead><tbody>'
backtee=. 0{ >hole{glTeesMeasured
for_t. glTees do.
	if. (t=tee) *. (t=backtee) do.
		stdout '<tr><td><b>From ',>t_index {glTeesName
		stdout ' tee</b></td><td>'
		stdout ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
		stdout '</td><td>', ": glPlanHitYards 
		stdout '</td><td>', ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards 
		stdout '</td><td>', ": glPlanRemGroundYards 
		stdout '</td></tr>'
	elseif. (t=backtee) do.
		stdout '<tr><td><i>From ',>t_index {glTeesName
		stdout ' tee</i></td><td>'
		stdout ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
		stdout '</td><td>', ": glPlanHitYards 
		stdout '</td><td>', ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards 
		stdout '</td><td>', ": glPlanRemGroundYards 
		stdout '</td></tr>'
	elseif. (t=tee) do.
		stdout '<tr><td><b>From ',>t_index {glTeesName
		stdout ' tee</b></td><td>'
		stdout ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards + glPlanHitYards
		stdout '</td><td>', ": glPlanHitYards 
		stdout '</td><td>', ": ((<t_index,hole){glTeesYards) - glPlanRemGroundYards 
		stdout '</td><td>', ": glPlanRemGroundYards 
		stdout '</td></tr>'
	end.
end.
stdout '</tbody></table>'


stdout LF,'<span class="span-3">Standard Scratch</span><input name="glLayupRemGroundYards" value="',(":,glLayupRemGroundYards),'" tabindex="1" ',(InputField 3),'>'
NB. Submit buttons
stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="57">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="58">'
stdout LF,'     <input type="submit" name="control_delete" value="Delete" tabindex="59"></form></div>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_plan_editpost
NB. =========================================================
NB. Process entries after edits to course
NB. based on the contents after the "post"
jweb_rating_plan_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by course/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. (-. +. / 'rating/course/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
    pagenotvalid ''
end.

NB. Assign to variables
xx=. djwCGIPost y ; 'tbl_plan_par' ; 'tbl_plan_index' ; 'tbl_plan_yards' ; 'tbl_plan_sss'

NB. Check the time stamp
yy=.glDbFile djwSqliteR 'select updatename,updatetime from tbl_plan WHERE name=''',(;tbl_plan_name),''';'
yy=.'tbl_plan' djwSqliteSplit yy
 
NB. Throw error page if updated
if. (tbl_plan_updatetime) ~: (prevtime) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(;tbl_plan_name),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;tbl_plan_name)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; tbl_plan_updatename),' at ',(;tbl_plan_updatetime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/course/e/',(;tbl_plan_name),'">Restart edit of: ',(;tbl_plan_name),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.

tbl_plan_updatename=: ,<getenv 'REMOTE_USER'
tbl_plan_updatetime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'

string=. djwSqliteUpdate 'tbl_plan' ; 'tbl_plan_' ; 'tbl_plan_name' ; 'tbl_plan_'
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
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''https://',(getenv 'SERVER_NAME'),'/jw/rating/course/e/',(,>tbl_plan_name),''')"'
	elseif. 0= 4!:0 <'control_delete' do.
		yy=. glDbFile djwSqliteR 'delete from tbl_plan WHERE name=''', (,>tbl_plan_name),''';'
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/rating/course/v'')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/rating/course/v'')"'
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
