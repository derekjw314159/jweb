NB. J Utilities for Rating Courses
NB. 

NB. =========================================================
NB. jweb_rating_plan_v
NB. View scores for participant
NB. =========================================================
jweb_rating_plan_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    rating_plan_all  y
elseif. 2=#y do. NB. Passed as parameter
    rating_plan_view y
elseif. 1 do.
    pagenotfound ''
end.
)

NB. =========================================================
NB. jweb_rating_plan_v
NB. View scores for participant
NB. =========================================================
jweb_rating_plannomap_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    0 rating_plan_all  y
elseif. 2=#y do. NB. Passed as parameter
    0 rating_plan_view y
elseif. 1 do.
    pagenotfound ''
end.
)


NB. =========================================================
NB. Synonyms
NB. jweb_rating_plan
NB. =========================================================
jweb_rating_plan=: 3 : 0
rating_plan_all y
)

NB. =========================================================
NB. rating_plan_all  
NB. View all courses and summary yards
NB. =========================================================
rating_plan_all=: 3 : 0
1 rating_plan_all y
:
showmap=. x
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_plan'
	xx=. utKeyRead glFilepath,'_tee'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. stdout LF,'<script>setTimeout(function(){window.location.href=''http://www.google.com''},5000);</script>'


djwBlueprintCSS ''

NB. Add the header stuff for the map
if. showmap do.
    BuildMap i. 18
end.

stdout LF,'</head>',LF,'<body>'
NB. Control map display
if. showmap do.
	stdout LT1,'  <div id="map-canvas"></div>'
end.
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print tees and yardages
stdout LF,'<h2>Course : ', glCourseName,'</h2><h3>All holes</h3>'
stdout LF,'<a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',(showmap#'nomap'),'/v/',glFilename,'">',(>showmap{'/' cut 'Show Map/Suppress map'),'</a>'
stdout LF,TAB,'<div class="span-10 last">'

stdout LT1,'<table><thead>'
stdout LT2,'<tr><th></th>'
for_t. glTees do.
    stdout LT3,'<th colspan="3">',(>t_index{glTeesName),'</th>'
end.
stdout LT2,'</tr>',LT2,'<tr><th>Hole</th>'
for_t. glTees do.
    stdout LT3,'<th>Yards</th><th>Mn</th><th>Wn</th>'
end.
stdout LT2,'</tr>'

stdout LT1,'</thead><tbody>'
for_hole. i. 18 do.
    stdout LT2,'<tr>',LT3,'<td><a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+hole),'">',(":1+hole),'</a></td>'
    for_t.  i. #glTees do.
	    stdout LT3,'<td>',(": <. 0.5 + (<t,hole){glTeesYards),'</td>'
	    utKeyRead glFilepath,'_tee'
	    ww=. (glTeHole=hole) *. glTeTee=t{glTees
	    (ww # glTeID) utKeyRead glFilepath,'_tee'
	    stdout LT3,'<td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">', ((0{,glTeMeasured){'-y' ),'</a></td>'
	    stdout LT3,'<td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">', ((1{,glTeMeasured){'-y' ),'</a></td>'
    end.
	    stdout LT2,'</tr>'
end.
stdout LT1,'</tbody></table>'


stdout LF,'</div>' NB. main span
stdout LF,'        '
for_h. i. 18 do.
		stdout '    <a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
end.
	
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''



)

NB. =========================================================
NB. rating_plan_view
NB. View scores for participant
NB. =========================================================
rating_plan_view=: 3 : 0
1 rating_plan_view y
:
showmap=. x
NB. Retrieve the details
NB. y has two elements, coursename & hole (+1)
hole=. ''$ 0". >1{y
hole=. <. 0.5 + hole
hole=. hole-1 
hole=. 0 >. 17 <. hole
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_plan'
	xx=. utKeyRead glFilepath,'_tee'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

NB. Add the header stuff for the map
if. showmap do.
    BuildMap ,hole
end.


stdout LF,'</head>',LF,'<body>'
NB. Control map display
if. showmap do.
	stdout LT1,'  <div id="map-canvas"></div>'
end.
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print course yardage and measurements
stdout LF,'<h2>Course : ', glCourseName,'</h2><h3>Hole : ',(":1+ ; hole),'</h3>'
stdout LF,'<a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',(showmap#'nomap'),'/v/',glFilename,'/',(": 1+hole),'">',(>showmap{'/' cut 'Show Map/Suppress map'),'</a>'
stdout LF,TAB,'<div class="span-8 last">'

stdout LF,'<table><thead>'
stdout '<tr><th>Tee</th><th>Card</th><th>Alt</th><th>Mn</th><th>Wn</th></tr>'
stdout '</thead><tbody>'
for_t.  i. #glTees do.
	stdout LF,'<tr><td>',(>t{glTeesName),'</td>'
	stdout '<td>',(": <. 0.5 + (<t,hole){glTeesYards),'</td>'
	utKeyRead glFilepath,'_tee'
	ww=. (glTeHole=hole) *. glTeTee=t{glTees
	(ww # glTeID) utKeyRead glFilepath,'_tee'
	stdout LT3,'<td>',(": glTeAlt),'</td>' NB. Altitude
	stdout LT3,'<td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">', ((0{,glTeMeasured){'-y' ),'</a></td>'
	stdout LT3,'<td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">', ((1{,glTeMeasured){'-y' ),'</a></td>'
	stdout '</tr>'
end.
stdout '</tbody></table></div>'
stdout LF,TAB,'<div class="span-24 last">'


stdout LF,'<table>'
stdout LF,'<thead><tr>'
NB. Work out the tees measured
utKeyRead glFilepath,'_tee'
ww=. I. glTeHole = hole
ww=. (+. /"1 ww{glTeMeasured ) # ww{glTeTee NB. Either gender
tees=. (glTees e. ww) # glTees

for_t. tees do.
	stdout '<th>',(>(glTees i. t){glTeesName),'</th>'
end.
stdout '<th>Shot</th><th>Hit</th><th>ToGreen</th><th>Edits</th><th>Alt</th><th>F/width</th><th>#Bunk</th><th>Dist OB</th><th>Dist Tr</th><th>F/w slope</th></tr></thead><tbody>'
NB. Sort the records and re-read
rr=. I. glPlanHole=hole
rr=. rr /: rr { glPlanShot
rr=. rr /: rr { glPlanAbility
rr=. rr /: rr { glPlanGender
rr=. rr /: glTees i. rr { glPlanTee
rr=. rr /: 'CPM' i. rr { glPlanRecType
rr=. (rr { glPlanID) \: rr { glPlanMeasDist
rr utKeyRead glFilepath,'_plan'

for_rr. i. #glPlanID do.
	if. 'P' = rr{glPlanRecType do.
		stdout '<tr>'
		if. 0 = rr{glPlanRemGroundYards do.
			for_t. tees do.
				stdout '<td>'
				if. (t=rr{glPlanTee) do.
					stdout '<b>Hole</b>'
				end.
				stdout '</td>'
			end.
		else.
			for_t. tees do.
				stdout '<td>'
				if. (t_index = 0) *. (t=rr{glPlanTee) do.
					stdout '<b>',(": <. 0.5+ (rr{glPlanBackGroundYards)+ (rr{glPlanRemGroundYards) - (rr{glPlanMeasDist) ),'</b>'
				elseif. t_index = 0. do.
					stdout '<i>',(": <. 0.5+ (rr{glPlanBackGroundYards) + (rr{glPlanRemGroundYards) - (rr{glPlanMeasDist) ),'</i>'
				elseif. t=rr{glPlanTee do.
					stdout '<b>',(": <. 0.5 + (rr{glPlanCumGroundYards) + (rr{glPlanRemGroundYards) - (rr{glPlanMeasDist) ),'</b>' 
				elseif. 1 do.
				end.
				stdout '</td>'
			end.
		end.
		stdout '<td>',((rr{glPlanGender){'MW'),((rr{glPlanAbility){'SB'),'-',(": 1+rr{glPlanShot),'</td>'
		stdout '<td><a href="/jw/rating/layup/e/',(glFilename),'/'
		stdout ;": 1+rr{glPlanHole
		stdout (;rr{glPlanTee),'/'
		stdout ((rr{glPlanGender){'MW'),((rr{glPlanAbility){'SB'),(": 1+rr{glPlanShot),'">'
		stdout (": rr{glPlanHitYards),' ',(rr{glPlanLayupType),'</a></td><td>', (": <. 0.5 + rr{glPlanRemGroundYards),'</td>' 
		if. 0<rr{glPlanRemGroundYards do.
		    stdout LT4,'<td><a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">Ed</a> <a href="/jw/rating/landingcopy/e/',(glFilename),'/',(;rr{glPlanID),'">Cop</a>'

		    stdout '<td>',(":rr{glPlanAlt),'</td>'
		    stdout LT3,'<td>',(":rr{glPlanFWWidth),'</td>'
		    stdout LT3,'<td>',(":rr{glPlanBunkNumber),'</td>'
		    stdout LT3,'<td>',(":rr{glPlanOOBDist),'</td>'
		    stdout LT3,'<td>',(":rr{glPlanTreeDist),'</td>'
		    stdout LT3, '<td></td>'
		else.
		    stdout LT4,'<td></td><td></td><td></td><td></td><td></td><td></td><td></td>' NB. At green
		end.
		    stdout LT3,'</tr>'

	elseif. 'M' = rr{glPlanRecType do.
		stdout '<tr>'
		if. 0 = rr{glPlanRemGroundYards do.
			for_t. tees do.
				stdout '<td>'
				stdout 'Hole'
				stdout '</td>'
			end.
		else.
			for_t. tees do.
				stdout '<td>'
				holelength=. (<(glTees i. t),hole){glTeesYards
				stdout ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
				stdout '</td>'
			end.
		end.
		stdout '<td colspan="2"><i>Measured Point</i></td>'
		stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		stdout LT4,'<td><a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">Ed</a> <a href="/jw/rating/landing/d/',glFilename,'/',(;rr{glPlanID),'">Del</a>'
		stdout LT3,'<td>',(":rr{glPlanAlt),'</td>'
		stdout LT3,'<td>',(":rr{glPlanFWWidth),'</td>'
		stdout LT3,'<td>',(":rr{glPlanBunkNumber),'</td>'
		stdout LT3,'<td>',(":rr{glPlanOOBDist),'</td>'
		stdout LT3,'<td>',(":rr{glPlanTreeDist),'</td>'
		stdout LT3, '<td></td></tr>'
	end.
end.

stdout '</tbody></table>'
NB. Add the Edit Option
stdout LF,'</div>' NB. main span
stdout LF,'        '
for_h. i. 18 do.
	if. h=hole do.
		stdout '   ',(": 1+h)
	else.
		stdout '    <a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
	end.
end.
stdout EM,'  <a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'">All</a>'
	
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_plan_e
NB. =========================================================
NB. View scores for participant
jweb_rating_plan_e=: 3 : 0
y=.cgiparms ''
if. 'rating/course/e' -: >(< 0 1){y do.
    rating_plan_all ''
else.
    if. 1=#y do. NB. Passed as parameter
	y=. (#'rating/course/e/')}. >(<0 1){y
    else.
	if. 'id' -: >(<1 0){ y do.
	    y=. >(<1 1) { y
	else.
	    pagenotfound ''
	end.
    end.
end.
rating_plan_edit y
)

NB. =========================================================
NB. rating_plan_edit
NB. =========================================================
NB. View scores for participant
rating_plan_edit=: 3 : 0
NB. Retrieve the details
xx=.glDbFile djwSqliteR 'select * from tbl_control;'
xx=.'tbl_control' djwSqliteSplit xx
xx=.glDbFile djwSqliteR 'select * from tbl_plan WHERE name=''',y,''';'
err=. ''
if. 0<#xx do.
    xx=.'tbl_plan' djwSqliteSplit xx
    xx=. djwBuildArray 'tbl_plan_yards'
    xx=. djwBuildArray 'tbl_plan_par'
    xx=. djwBuildArray 'tbl_plan_index'
else.
    err=. 'Invalid Course name'
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
    stdout, LF,TAB,TAB,'<h1>',err,'</h1>'
    stdout, '<div class="error">No such course name : ',y
    stdout  ,2$,: '</div>'
    stdout LF,'<br><a href="/jw/rating/course/v">Back to course list</a>'
    stdout, '</div></body>'
    exit ''
end.
NB. Print scorecard and yardage
stdout LF,TAB,TAB,'<h2>Edit Course Details : ', (;tbl_plan_name),' : ', ( ; tbl_plan_desc),'</h2><i>',(": getenv 'REMOTE_USER'),'</i>'
stdout LF,TAB,'<div class="span-12">'
stdout LF, TAB,'<form action="/jw/rating/course/editpost/',y,'" method="post">'
stdout LF, TAB,'<input type="hidden" name="tbl_plan_name" value="',y,'">' NB. Have to pass through this value
stdout LF, TAB,'<input type="hidden" name="prevname" value="',(":;tbl_plan_updatename),'">'
stdout LF, TAB,'<input type="hidden" name="prevtime" value="',(;tbl_plan_updatetime),'">'
stdout LF,'<span class="span-3">Standard Scratch</span><input name="tbl_plan_sss" value="',(":,tbl_plan_sss),'" tabindex="1" ',(InputField 3),'>'
stdout LF,'<br><span class="span-3">Description</span><input name="tbl_plan_desc" value="',(;tbl_plan_desc),'" tabindex="2" ',(InputField 25),'><hr>'
for_half. i. 2 do.
    if. 0=half do.
	stdout LF,'<div class="span-5">'
    else.
	stdout LF,'<div class="span-5 prepend-2 last">'
    end.
    stdout LF,'<table>'
    stdout LF,'<thead><tr>'
    stdout LF,'<th>Hole</th><th>Yards</th><th>Par</th><th>Index</th></tr></thead><tbody>'
    for_x. (9*half)+i. 9 do.
	hole=. ; 'r<0>2.0' 8!:0 x
	stdout LF,'<tr>'
	stdout LF,'<td>',(": 1+x),'</td>'
	stdout LF,'<td><input  value="',(": x{,tbl_plan_yards),'" tabindex="',(":  3+x),'" ',(InputFieldnum ('tbl_plan_yards',hole) ; 4),'></td>'
	stdout LF,'<td><input  value="',(": x{,tbl_plan_par),'" tabindex="',(":  21+x),'" ',(InputFieldnum ('tbl_plan_par',hole) ; 2),'></td>'
	stdout LF,'<td><input  value="',(": x{,tbl_plan_index),'" tabindex="',(":  39+x),'" ',(InputFieldnum ('tbl_plan_index',hole) ; 2),'></td>'
    end.
    if. half=0 do.
	stdout LF,'</tbody><tfoot><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_plan_yards),'</td><td>',(": +/(i.9) {,tbl_plan_par),'</td></tr>'
	stdout LF,'</tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { ,tbl_plan_yards),'</td><td>',(": +/(9+i.9) {,tbl_plan_par),'</td></tr>'
	stdout LF,'<tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_plan_yards),'</td><td>',(": +/9{.,tbl_plan_par),'</td></tr>'
	stdout LF,'<span class="loud"><tr><td>TOTAL</td>'
	stdout LF,'<td>',(": +/18 {. ,tbl_plan_yards),'</td><td>',(": +/18 {.,tbl_plan_par),'</td></tr></span>'
	stdout LF,'</tfoot></table></div><hr>'
    end.

end.
NB. Submit buttons
stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="57">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="58">'
stdout LF,'     <input type="submit" name="control_delete" value="Delete" tabindex="59"></form></div>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
NB. exit 0
)

NB. =========================================================
NB. cgitest v defines html with a timestamp and cgi parameters
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

NB. =======================================================================
NB. BuildMap
NB. -----------------------------------------------------------------------
NB. Builds the script logic for one or more holes
NB.
BuildMap=: 3 : 0
hole=. ,y

stdout LF,'<style>'
stdout LF,'  html, body, #map-canvas {'
stdout LF,'  height: 480px;'
stdout LF,'  width: 640px;'
stdout LF,'  }'
stdout LF,'</style>'
stdout LF,'<script src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>'
stdout LF,'<script>',LF,'var map;'
NB. Work out map centre from tees and greens
path=. glGPSName i. ('r<0>2.0' 8!:0 (1+hole)),each <'TW'
path=. path, glGPSName i. ('r<0>2.0' 8!:0 (1+hole)),each <'GC'
path=. (path < #glGPSName) # path NB. Remove not found
path=. LatLontoFullOS path { glGPSLatLon
path=. ( +/path ) % #path
path=.;  +. FullOStoLatLon path
ww=. 9!:11 (9) 
stdout LF,'var myCenter=new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),');'
NB. stdout LF,'var myCenter=new google.maps.LatLng(51.5,-0.57);'

stdout LF,'function dyncircle(inner, outer) {'
stdout LF,'   var circ={'
stdout LF,'      path: google.maps.SymbolPath.CIRCLE,'
stdout LF,'      fillColor: inner,'
stdout LF,'      fillOpacity: 1,'
stdout LF,'      scale: 3.5,'
stdout LF,'      strokeColor: outer,'
stdout LF,'      strokeWeight: 3'
stdout LF,'      };'
stdout LF,'   return circ;'
stdout LF,'}'

stdout LF,'function initialize() {'
stdout LF,'   var mapOptions = {'
if. 2 < $hole do.
    stdout LF,'     zoom: 15,'
else.
    stdout LF,'     zoom: 17,' 
end.
stdout LF,'     center: myCenter,'
stdout LF,'     mapTypeId: google.maps.MapTypeId.SATELLITE,'
stdout LF,'     mapTypeControl: false'
stdout LF,'     };'
stdout LF,'  map = new google.maps.Map(document.getElementById(''map-canvas''),mapOptions);'


for_hh. hole do.
    NB. Add the various points here, starting with tees
    NB. Only do the tees if a single hole
    if. 1=#hole do.
	for_t. i.#glTees  do.
		stdout LF,'   var marker',(":hh),'T',(t{glTees),'=new google.maps.Marker({'
		path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'T',t{glTees
		path=. +. path { glGPSLatLon
		stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
		rgb=. t{glTeesRGB
		rgb=. (0{"1 glRGB) i. rgb
		rgb=. >(<rgb,1) { glRGB
		rgb=. '#',rgb
		NB.	stdout LF,'      icon: dyncircle( ''white'', ''white''),'
		stdout LF,'      icon: dyncircle( ''',rgb,''', ''',rgb,'''),'
		stdout LF,'      title: ''Hole ',(":hh+1),' Tee ',(>t{glTeesName),''''
		stdout LF,'      });'
		stdout LF,'   marker',(":hh),'T',(t{glTees),'.setMap(map);'
	end. 
    end.

    NB. Green marker 
    stdout LF,'   var marker',(":hh),'GC=new google.maps.Marker({'
    path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'GC'
    path=. +. path { glGPSLatLon
    stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
    stdout LF,'      icon: "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|FF99CC|8|_|',(":1+hh),'"'
    stdout LF,'      });'
    stdout LF,'   marker',(":hh),'GC.setMap(map);'

    NB. Flightpath
    path=. PathTeeToGreen hh ; 'W'
    stdout LF,'var flightPathCoord',(":hh),' = ['
    for_p. path do.
	    pp=. +. p
	    stdout LF,'   new google.maps.LatLng(', (>'' 8!:0  (0{pp)),', ',(>'' 8!:0 (1{pp)),')'
	    if. p_index < _1 + #path do.
		    stdout ','
	    end.
    end.
    stdout LF,'   ];'
    stdout LF,'var flightPath',(":hh),' = new google.maps.Polyline({'
    stdout LF,'       path: flightPathCoord',(":hh),','
    stdout LF,'       geodesic: true,'
    stdout LF,'       strokeColor: ''#FFFFFF'','
    stdout LF,'       strokeOpacity: 1,'
    stdout LF,'       strokeWeight: 1,'
    stdout LF,'       });'
    stdout LF,'flightPath',(":hh),'.setMap(map);'
end.
    stdout LF,'}'
NB. End of hh loop
    stdout LF,'google.maps.event.addDomListener(window, ''load'', initialize);'
    stdout LF,'</script>'
)
