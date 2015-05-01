NB. J Utilities for Denhambowl
NB. 

NB. =========================================================
NB. jweb_denhambowl_team_v
NB. View scores for participant
NB. =========================================================
jweb_denhambowl_team_v=: 3 : 0
NB. y=.cgiparms ''
if. 0=#y do.
    denhambowl_team_all ''
elseif. 1=#y do. NB. Passed as parameter
    denhambowl_team_view >{. y
elseif. 1 do.
    pagenotfound ''
end.
)
NB. =========================================================
NB. Synonyms
NB. jweb_denhambowl_team
NB. =========================================================
jweb_denhambowl_team=: 3 : 0
denhambowl_team_all ''
)

NB. =========================================================
NB. denhambowl_team_all  
NB. View all courses and summary yards
NB. =========================================================
denhambowl_team_all=: 3 : 0
NB. Retrieve the details
xx=.glDbFile djwSqliteR 'select * from tbl_control;'
xx=.'tbl_control' djwSqliteSplit xx
xx=.glDbFile djwSqliteR 'select * from tbl_comp WHERE id=',(":,tbl_control_compid),';'
xx=.'tbl_comp' djwSqliteSplit xx
xx=.glDbFile djwSqliteR 'select * from tbl_team WHERE compid=',(":,tbl_control_compid),' ORDER BY sortname;' 
yy=.glDbFile djwSqliteR 'select * from tbl_partic WHERE compid=',(":,tbl_control_compid),' ORDER BY sortname;'
zz=.glDbFile djwSqliteR 'select * from tbl_partic_round JOIN tbl_partic ON tbl_partic_round.partid = tbl_partic.id WHERE compid=',(":,tbl_control_compid),';'

err=. ''
if. 0<#xx do.
    xx=.'tbl_team' djwSqliteSplit xx
else.
    tbl_team_id=: 0$0
    tbl_team_name=: 0$a:
    tbl_team_sortname=: 0$a:
    tbl_team_compid=: 0$0
    tbl_team_logopath=: 0$a:
end.

if. 0<#yy do.
    yy=.'tbl_partic' djwSqliteSplit yy
else.
    tbl_partic_id=: 0$0
    tbl_partic_name=: 0$a:
    tbl_partic_sortname=: 0$a:
    tbl_partic_compid=: 0$0
	tbl_partic_teamid=: 0$0;
end.

if. 0<#zz do.
    zz=.'tbl_partic_round' djwSqliteSplit zz
else.
    tbl_partic_round_id=: 0$0
    tbl_partic_round_partid=: 0$0
    tbl_partic_round_round=: 0$0
	tbl_partic_round_tee=: 0$a:
	tbl_partic_round_starttime=: 0$a:
end.

NB. Loop round the rounds for start time and tees
xx=. ((''$tbl_comp_rounds) # i. #tbl_partic_id)
xx=. xx,. (tbl_comp_rounds*(#tbl_partic_id)) $ i. tbl_comp_rounds
NB. this should look like 0 1 2 0 1 2 ,. 0 0 0 1 1 1 
xx=. (tbl_partic_round_partid,. tbl_partic_round_round) i. xx
tbl_partic_tee=: ((#tbl_partic_id),tbl_comp_rounds)$ (xx { (tbl_partic_round_tee, <'tee') )
tbl_partic_starttime=: ((#tbl_partic_id),tbl_comp_rounds)$ ( xx { (tbl_partic_round_starttime, <'time') )

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>'
djwBlueprintCSS ''
stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container">'
NB. Error page - No such team
if. 0<#err do.
stdout LF,TAB,'<div class="span-24">'
stdout, LF,TAB,TAB,'<h1>',err,'</h1>'
stdout, '<div class="error">No such team name : ',y
stdout  ,2$,: '</div>'
stdout LF,'<br><a href="/jw/denhambowl/team/v">Back to team list</a>'
stdout, '</div></body>'
exit ''
end.
NB. Print teams and participants
stdout LF, '<div class="span-24">'
user=.getenv 'REMOTE_USER'
if. 0 -: user do. user=. '' end.
stdout LF,TAB,'<h2>Team List : ',(":,>tbl_comp_name),'</h2>', user
stdout LF,TAB, '<div class="span-15">'

NB. Table to loop round the teams
stdout LF,'<table>'
stdout LF,'<thead><tr>'
stdout LF,'<th> </th><th>Team</th><th>Participants</th>'
for_rr. i. tbl_comp_rounds do.
	stdout '<th>Round ', (":rr+1),'</th>'
end.
stdout '</tr></thead><tbody>'
NB. Loop round the teams
for_cc. i. #tbl_team_name do.
	ct=. 1 >.  +/(tbl_partic_teamid=cc{tbl_team_id)
	stdout LF,'<tr><td rowspan=',(":ct),' align="center"><img src="',glDbRoot,'/',(>cc{tbl_team_logopath),'" height="',(":17*ct),'px" width="auto" align="center" VALIGN="Middle"></td>'
	stdout LF,'<td rowspan=',(":ct),' style="border-bottom: 2px solid lightgrey"><a href="http://',(,getenv 'SERVER_NAME'),'/jw/denhambowl/team/v/',(,>cc{tbl_team_name),'">',(>cc{tbl_team_name),'</td>'
	for_pp. I. (tbl_partic_teamid=cc{tbl_team_id) do.
		stdout LF,'<td>',(,>pp{tbl_partic_name),'</td>'
		for_rr. i. tbl_comp_rounds do.
			stdout LF,'<td>',(,>(<pp,rr){tbl_partic_tee)
			stdout ': ',(,>(<pp,rr){tbl_partic_starttime)
			stdout '</td>'
		end.
		stdout LF,'</tr>'
	end.
	if. -. (+./ (tbl_partic_teamid=cc{tbl_team_id)) do. stdout LF,'<td>&lt;No participants&gt;</td></tr>' end.
end.
stdout LF,'</table><hr></div>'
NB. Add the Edit Option
stdout LF,'<div class="span-4 prepend-1 last">'
stdout LF,'<a href="https://',(,getenv 'SERVER_NAME'),'/jw/denhambowl/team/a">Add new team</a></br>'
stdout LF,'<a href="https://',(,getenv 'SERVER_NAME'),'/jw/denhambowl/partic/a">Add new participant</a><div>'
NB. stdout LF,'<input type="button" value="eDit" onClick="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/e/',(,>tbl_team_name),''')">edit<div>'
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. denhambowl_team_view
NB. View scores for participant
NB. =========================================================
denhambowl_team_view=: 3 : 0
NB. Retrieve the details
xx=.glDbFile djwSqliteR 'select * from tbl_control;'
xx=.'tbl_control' djwSqliteSplit xx
xx=.glDbFile djwSqliteR 'select * from tbl_team WHERE name=''',y,''';'
err=. ''
if. 0<#xx do.
    xx=.'tbl_team' djwSqliteSplit xx
    xx=. djwBuildArray 'tbl_team_yards'
    xx=. djwBuildArray 'tbl_team_par'
    xx=. djwBuildArray 'tbl_team_index'
else.
    err=. 'Invalid Course name'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container">'
NB. Error page - No such course
if. 0<#err do.
    stdout LF,TAB,'<div class="span-24">'
    stdout LF,TAB,TAB,'<h1>',err,'</h1>'
    stdout LF,TAB,TAB,'<div class="error">No such course name : ',y
    stdout '</div>'
	stdout LF,TAB,'</div>'
    stdout LF,TAB,'<br><a href="/jw/denhambowl/course/v">Back to course list</a>'
    stdout LF, '</div>',LF,'</body>'
    exit ''
end.
NB. Print scorecard and yardage
stdout LF,TAB,'<h2>Course : ',(;tbl_team_name),' : ', (; tbl_team_desc),'</h2>'
stdout LF,TAB,'<div class="span-16 last">'
stdout LF,TAB,'Standard Scratch = ',(":,tbl_team_sss),'<hr>'
NB. Front 9
for_half. i. 2 do.
    if. 0=half do.
	stdout LF,'<div class="span-5">'
    else.
	stdout LF,'<div class="span-5 prepend-2">'
    end.
    stdout LF,'<table>'
    stdout LF,'<thead><tr>'
    stdout LF,'<th>Hole</th><th>Yards</th><th>Par</th><th>Index</th></tr></thead><tbody>'
    for_x. (9*half) + i. 9 do.
	stdout LF,'<tr><td>',(":1+x),'</td><td>',(": x{,tbl_team_yards)
	stdout LF,'</td><td>',(": x{,tbl_team_par),'</td>'
	stdout LF,'<td>',(": x{,tbl_team_index),'</td></tr>'
    end.

    if. half=0 do.
	stdout LF,'</tbody><tfoot><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_team_yards),'</td><td>',(": +/(i.9) {,tbl_team_par),'</td></tr>'
	stdout LF,'</tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { ,tbl_team_yards),'</td><td>',(": +/(9+i.9) {,tbl_team_par),'</td></tr>'
	stdout LF,'<tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_team_yards),'</td><td>',(": +/9{.,tbl_team_par),'</td></tr>'
	stdout LF,'<tr><td><b>TOTAL</b></td>'
	stdout LF,'<td><b>',(": +/18 {. ,tbl_team_yards),'</b></td><td><b>',(": +/18 {.,tbl_team_par),'</b></td></tr>'
	stdout LF,'</tfoot></table></div>'
    end.

end.
NB. Add the Edit Option
stdout LF,'<div class="span-3 prepend-1 last">'
stdout LF,'<a href="https://',(,getenv 'SERVER_NAME'),'/jw/denhambowl/course/e/',(,>tbl_team_name),'">Edit: ',(,>tbl_team_name),'</a></br></br>'
stdout LF,'<a href="http://',(,getenv 'SERVER_NAME'),'/jw/denhambowl/course/v">Back to list</a></div>'
stdout LF,'<hr></div>' NB. main span
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_denhambowl_team_e
NB. =========================================================
NB. View scores for participant
jweb_denhambowl_team_e=: 3 : 0
y=.cgiparms ''
if. 'denhambowl/course/e' -: >(< 0 1){y do.
    denhambowl_team_all ''
else.
    if. 1=#y do. NB. Passed as parameter
	y=. (#'denhambowl/course/e/')}. >(<0 1){y
    else.
	if. 'id' -: >(<1 0){ y do.
	    y=. >(<1 1) { y
	else.
	    pagenotfound ''
	end.
    end.
end.
denhambowl_team_edit y
)

NB. =========================================================
NB. denhambowl_team_edit
NB. =========================================================
NB. View scores for participant
denhambowl_team_edit=: 3 : 0
NB. Retrieve the details
xx=.glDbFile djwSqliteR 'select * from tbl_control;'
xx=.'tbl_control' djwSqliteSplit xx
xx=.glDbFile djwSqliteR 'select * from tbl_team WHERE name=''',y,''';'
err=. ''
if. 0<#xx do.
    xx=.'tbl_team' djwSqliteSplit xx
    xx=. djwBuildArray 'tbl_team_yards'
    xx=. djwBuildArray 'tbl_team_par'
    xx=. djwBuildArray 'tbl_team_index'
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
    stdout LF,'<br><a href="/jw/denhambowl/course/v">Back to course list</a>'
    stdout, '</div></body>'
    exit ''
end.
NB. Print scorecard and yardage
stdout LF,TAB,TAB,'<h2>Edit Course Details : ', (;tbl_team_name),' : ', ( ; tbl_team_desc),'</h2><i>',(": getenv 'REMOTE_USER'),'</i>'
stdout LF,TAB,'<div class="span-12">'
stdout LF, TAB,'<form action="/jw/denhambowl/course/editpost/',y,'" method="post">'
stdout LF, TAB,'<input type="hidden" name="tbl_team_name" value="',y,'">' NB. Have to pass through this value
stdout LF, TAB,'<input type="hidden" name="prevname" value="',(":;tbl_team_updatename),'">'
stdout LF, TAB,'<input type="hidden" name="prevtime" value="',(;tbl_team_updatetime),'">'
stdout LF,'<span class="span-3">Standard Scratch</span><input name="tbl_team_sss" value="',(":,tbl_team_sss),'" tabindex="1" ',(InputField 3),'>'
stdout LF,'<br><span class="span-3">Description</span><input name="tbl_team_desc" value="',(;tbl_team_desc),'" tabindex="2" ',(InputField 25),'><hr>'
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
	stdout LF,'<td><input  value="',(": x{,tbl_team_yards),'" tabindex="',(":  3+x),'" ',(InputFieldnum ('tbl_team_yards',hole) ; 4),'></td>'
	stdout LF,'<td><input  value="',(": x{,tbl_team_par),'" tabindex="',(":  21+x),'" ',(InputFieldnum ('tbl_team_par',hole) ; 2),'></td>'
	stdout LF,'<td><input  value="',(": x{,tbl_team_index),'" tabindex="',(":  39+x),'" ',(InputFieldnum ('tbl_team_index',hole) ; 2),'></td>'
    end.
    if. half=0 do.
	stdout LF,'</tbody><tfoot><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_team_yards),'</td><td>',(": +/(i.9) {,tbl_team_par),'</td></tr>'
	stdout LF,'</tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { ,tbl_team_yards),'</td><td>',(": +/(9+i.9) {,tbl_team_par),'</td></tr>'
	stdout LF,'<tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_team_yards),'</td><td>',(": +/9{.,tbl_team_par),'</td></tr>'
	stdout LF,'<span class="loud"><tr><td>TOTAL</td>'
	stdout LF,'<td>',(": +/18 {. ,tbl_team_yards),'</td><td>',(": +/18 {.,tbl_team_par),'</td></tr></span>'
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
NB. jweb_denhambowl_team_editpost
NB. =========================================================
NB. Process entries after edits to course
NB. based on the contents after the "post"
jweb_denhambowl_team_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by course/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. (-. +. / 'denhambowl/course/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
    pagenotvalid ''
end.

NB. Assign to variables
xx=. djwCGIPost y ; 'tbl_team_par' ; 'tbl_team_index' ; 'tbl_team_yards' ; 'tbl_team_sss'

NB. Check the time stamp
yy=.glDbFile djwSqliteR 'select updatename,updatetime from tbl_team WHERE name=''',(;tbl_team_name),''';'
yy=.'tbl_team' djwSqliteSplit yy
 
NB. Throw error page if updated
if. (tbl_team_updatetime) ~: (prevtime) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(;tbl_team_name),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;tbl_team_name)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; tbl_team_updatename),' at ',(;tbl_team_updatetime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/denhambowl/course/e/',(;tbl_team_name),'">Restart edit of: ',(;tbl_team_name),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.

tbl_team_updatename=: ,<getenv 'REMOTE_USER'
tbl_team_updatetime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'

string=. djwSqliteUpdate 'tbl_team' ; 'tbl_team_' ; 'tbl_team_name' ; 'tbl_team_'
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
NB. stdout 'Location: "http://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/v/',(,tbl_team_name),'"'
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''https://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/e/',(,>tbl_team_name),''')"'
	elseif. 0= 4!:0 <'control_delete' do.
		yy=. glDbFile djwSqliteR 'delete from tbl_team WHERE name=''', (,>tbl_team_name),''';'
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/v'')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/v'')"'
    end.
stdout LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_denhambowl_team_a
NB. ========================:=================================
NB. View scores for participant
jweb_denhambowl_team_a=: 3 : 0
y=.cgiparms ''
if. 'denhambowl/course/a' -: >(< 0 1){y do.
    denhambowl_team_add ''
else.
    if. 1=#y do. NB. Passed as parameter
	y=. (#'denhambowl/course/a/')}. >(<0 1){y
    else.
	if. 'error' -: >(<1 0){ y do.
	    y=.( (#'denhambowl/course/a/')}.>(<0 1) { y),'&error=', >(<1 1) { y
	else.
	    pagenotfound ''
	end.
    end.
end.
denhambowl_team_add y
)

NB. =========================================================
NB. denhambowl_team_add 
NB. =========================================================
NB. View scores for participant
denhambowl_team_add=: 3 : 0
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
stdout LF, TAB,'<form action="/jw/denhambowl/course/addpost" method="post">'
stdout LF,'<span class="span-3">Course code :</span><input name="tbl_team_name" value="',(":,y),'" tabindex="1" ',(InputField 8),'>'

NB. Submit buttons
stdout LF,'<input type="submit" name="control_add" value="Add" tabindex="58"></form></div>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_denhambowl_team_addpost
NB. =========================================================
NB. Process entries after edits to course
NB. based on the contents after the "post"
jweb_denhambowl_team_addpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by course/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. (-. +. / 'denhambowl/course/a' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
    pagenotvalid ''
end.

NB. Assign to variables
xx=. djwCGIPost y 
err=. ''
NB. Check whether the value already exists
yy=.glDbFile djwSqliteR 'select updatename,updatetime from tbl_team WHERE name=''',(;tbl_team_name),''';'
 
if. (0 <  # yy ) do.
	err=. 'Duplicate'
end.

yy=. *. / (;tbl_team_name) e. 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'
yy=. yy *. -. ({. ; tbl_team_name) e. '01234567890-_'
if. -.yy do.
	err=.'Not+Valid'
 end.

NB. Throw error page if updated
if. 0 < # err do.
	yy=. '/jw/denhambowl/course/a/',(;tbl_team_name),'&error'
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h2>Error adding : ',(;tbl_team_name),'</h2>'
 	stdout LF,'<div class="error">Database error trying to add : ',(;tbl_team_name)
 	stdout LF,'</br><br><b>**Addition has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
	NB. Strip out invalid characters in link string
 	stdout LF,'</br><a href="/jw/denhambowl/course/a/',((-.(;tbl_team_name) e. ' /\&?')#;tbl_team_name),'&error=',err,'">Restart to add: ',(;tbl_team_name),'</a>'
 	stdout, '</div></body>'
	exit ''
end.

tbl_team_updatename=: ,<": getenv 'REMOTE_USER'
tbl_team_updatetime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
tbl_team_desc=: ,<'Please add a description'

string=. djwSqliteInsert 'tbl_team' ; 'tbl_team_' ; 'tbl_team_name' ; 'tbl_team_'
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
NB. stdout 'Location: "http://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/v/',(,tbl_team_name),'"'
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
    if. 0= 4!:0 <'control_add' do.
	stdout '</head><body onLoad="redirect(''https://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/e/',(,>tbl_team_name),''')"'
    else.  
	stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/denhambowl/course/v/',(,>tbl_team_name),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)
