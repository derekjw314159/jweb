
NB. =========================================================
NB. jweb_u11_player_v
NB. View scores for participant
NB. =========================================================
jweb_u11_player_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    u11_player_all y
elseif. 1<#y do. NB. Passed as parameter
    u11_player_view y
elseif. 1 do.
    pagenotfound ''
end.
)
NB. =========================================================
NB. Synonyms
NB. jweb_u11_player
NB. =========================================================
jweb_u11_player=: 3 : 0
u11_player_all y
)

NB. =========================================================
NB. u11_player_all  
NB. View all players and summary yards
NB. =========================================================
u11_player_all=: 3 : 0
NB. Retrieve the details

glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_player'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/u11/player/v' ; 'Back to course list'
end.

NB. Print tees and yardages
user=. ": getenv 'REMOTE_USER'
NB. if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>All players</h3>'

NB. Order by player
ww=:  /: >glPlFirstName
ww=: ww /: >ww{glPlLastName
(ww{glPlID) utKeyRead glFilepath,'_player'


NB. Loop round in two halves
for_hh. 0 1 do.
    stdout LF,TAB, '<div class="span-11">'

    stdout LT1,'<table>'
    stdout LT1,'<thead>',LT2,'<tr>'
    stdout LT3,'<th>Name</th><th>Age</th><th>HCP</th><th>Start</th><th>Gross</th></tr></thead><tbody>'
    NB. Loop round the players
    chunk=. >. 0.5 * #glPlID
    for_cc. (hh *chunk ) + i. chunk do.
	if. cc >: #glPlID do. continue. end. NB. May be odd one at end.
	stdout LF,'<tr><td><a href="http://',(":getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,glFilename),'/',(>cc{glPlID),'">',(>cc{glPlFirstName),' ',(>cc{glPlLastName),'</td>'
	NB. stdout LT3,'<td>',(":>cc{glPlClub),'</td>'
	stdout LT3,'<td>',(": glCompDate CalcAge cc{glPlDoB),'</td>'
	stdout LF,'<td>',(":>cc{glPlHCP),'</td>'
	stdout LF,'<td>',(":>cc{glPlStartTime),'</td>'
	gr=. ": +/7<. cc{glPlGross
	if. *. / _ = cc{ glPlGross do. gr=.'-' end.
	stdout LF,'<td>',gr,'</td>'
	stdout LT2,'</tr>'
    end.
    stdout LF,'</tbody></table></div>'
end. NB. End of half
NB. Add the Edit Option
stdout LF,'<div class="span-2 last">'
stdout LF,'<a href="https://',(":,getenv 'SERVER_NAME'),'/jw/u11/player/a/',glFilename,'">Add new player</a><div>'
NB. stdout LF,'<input type="button" value="eDit" onClick="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/player/e/',(,>tbl_player_name),''')">edit<div>'
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
stdout LF,'<hr>'
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. u11_player_view
NB. View scores for participant
NB. =========================================================
u11_player_view=: 3 : 0
NB. Retrieve the details

glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_player'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/u11/player/v' ; 'Back to player list'
end.

key=. 1{y
ww=. keydir glFilepath,'_player'
if. -. key e. ww do.
    djwErrorPage err ; ('No such player : ',glFilename,' - ',>key) ; '/jw/u11/player/v' ; 'Back to player list'
end.

(,key) utKeyRead glFilepath,'_player'


NB. Print tees and yardages
user=. ": getenv 'REMOTE_USER'
NB. if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>View details for :',(>glPlFirstName),' ',(>glPlLastName),'</h3>'

NB. Print scorecard and yardage
stdout LF,'<div class="span-16 last">'
stdout LT1,'Club = ',(>glPlClub),'<br>'
stdout LT1,'Handicap = ',(": glPlHCP),'<br>'
stdout LT1,'Date of Birth = ',(11{. , timestamp 1 tsrep glPlDoB),'<br>'
NB. Front 9
for_half. i. 2 do.
    if. 0=half do.
	stdout LF,'<div class="span-5">'
    else.
	stdout LF,'<div class="span-5 prepend-2">'
    end.
stdout LF,'<table>'
    stdout LF,'<thead><tr>'
    stdout LF,'<th>Hole</th><th>Yards</th><th>Par</th><th>Gross</th></tr></thead><tbody>'
    for_x. (9*half) + i. 9 do.
	stdout LF,'<tr><td>',(":1+x),'</td>'
	stdout LF,'<td>',(": x{glYards),'</td>'
	stdout LF,'<td>',(": x{glPar),'</td>'
	stdout LF,'<td>',(": x{,glPlGross),'</td></tr>'
    end.

    if. half=0 do.
	stdout LF,'</tbody><tfoot><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. glYards),'</td>'
	stdout LF,'<td>',(": +/9 {. glPar ),'</td>'
	stdout LF,'<td>',(": +/9 {. ,glPlGross ),'</td>'
	stdout LF,'</tr></tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { glYards),'</td>'
	stdout LF,'<td>',(": +/(9+i.9) {glPar),'</td>'
	stdout LF,'<td>',(": +/(9+i.9) {,glPlGross),'</td>'
	stdout LF,'</tr><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. glYards),'</td>'
	stdout LF,'<td>',(": +/9{. glPar),'</td>'
	stdout LF,'<td>',(": +/9{. ,glPlGross),'</td>'
	stdout LF,'</tr><tr><td><b>TOTAL</b></td>'
	stdout LF,'<td><b>',(": +/glYards),'</b></td>'
	stdout LF,'<td><b>',(": +/glPar),'</b></td>'
	stdout LF,'<td><b>',(": +/,glPlGross),'</b></td>'
	stdout LF,'</tr></tfoot></table></div>'
    end.

end.
NB. Add the Edit Option
stdout LF,'<div class="span-3 prepend-1 last">'
stdout LF,'<a href="https://',(":,getenv 'SERVER_NAME'),'/jw/u11/player/e/',(glFilename),'/',(>key),'">Edit: ',(;glPlFirstName),' ',(;glPlLastName),'</a></br></br>'
stdout LF,'<a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/u11/player/v/',glFilename,'">Back to player list</a></div>'
stdout LF,'<hr></div>' NB. main span
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_u11_player_e
NB. =========================================================
NB. View scores for participant
jweb_u11_player_e=: 3 : 0
if. 2 ~: #y do. NB. Passed as parameter
	pagenotfound ''
end.
u11_player_edit y
)

NB. =========================================================
NB. u11_player_edit
NB. =========================================================
NB. View scores for participant
u11_player_edit=: 3 : 0
NB. Retrieve the details
xx=.glDbFile djwSqliteR 'select * from tbl_control;'
xx=.'tbl_control' djwSqliteSplit xx
xx=.glDbFile djwSqliteR 'select * from tbl_player WHERE name=''',y,''';'
err=. ''
if. 0<#xx do.
    xx=.'tbl_player' djwSqliteSplit xx
    xx=. djwBuildArray 'tbl_player_yards'
    xx=. djwBuildArray 'tbl_player_par'
    xx=. djwBuildArray 'tbl_player_index'
else.
    err=. 'Invalid Course name'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'
NB. Error page - No such player
if. 0<#err do.
    stdout LF,TAB,'<div class="span-24">'
    stdout, LF,TAB,TAB,'<h1>',err,'</h1>'
    stdout, '<div class="error">No such player name : ',y
    stdout  ,2$,: '</div>'
    stdout LF,'<br><a href="/jw/u11/player/v">Back to player list</a>'
    stdout, '</div></body>'
    exit ''
end.
NB. Print scorecard and yardage
stdout LF,TAB,TAB,'<h2>Edit Course Details : ', (;tbl_player_name),' : ', ( ; tbl_player_desc),'</h2><i>',(": getenv 'REMOTE_USER'),'</i>'
stdout LF,TAB,'<div class="span-12">'
stdout LF, TAB,'<form action="/jw/u11/player/editpost/',y,'" method="post">'
stdout LF, TAB,'<input type="hidden" name="tbl_player_name" value="',y,'">' NB. Have to pass through this value
stdout LF, TAB,'<input type="hidden" name="prevname" value="',(":;tbl_player_updatename),'">'
stdout LF, TAB,'<input type="hidden" name="prevtime" value="',(;tbl_player_updatetime),'">'
stdout LF,'<span class="span-3">Standard Scratch</span><input name="tbl_player_sss" value="',(":,tbl_player_sss),'" tabindex="1" ',(InputField 3),'>'
stdout LF,'<br><span class="span-3">Description</span><input name="tbl_player_desc" value="',(;tbl_player_desc),'" tabindex="2" ',(InputField 25),'><hr>'
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
	stdout LF,'<td><input  value="',(": x{,tbl_player_yards),'" tabindex="',(":  3+x),'" ',(InputFieldnum ('tbl_player_yards',hole) ; 4),'></td>'
	stdout LF,'<td><input  value="',(": x{,tbl_player_par),'" tabindex="',(":  21+x),'" ',(InputFieldnum ('tbl_player_par',hole) ; 2),'></td>'
	stdout LF,'<td><input  value="',(": x{,tbl_player_index),'" tabindex="',(":  39+x),'" ',(InputFieldnum ('tbl_player_index',hole) ; 2),'></td>'
    end.
    if. half=0 do.
	stdout LF,'</tbody><tfoot><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_player_yards),'</td><td>',(": +/(i.9) {,tbl_player_par),'</td></tr>'
	stdout LF,'</tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { ,tbl_player_yards),'</td><td>',(": +/(9+i.9) {,tbl_player_par),'</td></tr>'
	stdout LF,'<tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. ,tbl_player_yards),'</td><td>',(": +/9{.,tbl_player_par),'</td></tr>'
	stdout LF,'<span class="loud"><tr><td>TOTAL</td>'
	stdout LF,'<td>',(": +/18 {. ,tbl_player_yards),'</td><td>',(": +/18 {.,tbl_player_par),'</td></tr></span>'
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
NB. jweb_u11_player_editpost
NB. =========================================================
NB. Process entries after edits to player
NB. based on the contents after the "post"
jweb_u11_player_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by player/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. (-. +. / 'u11/player/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
    pagenotvalid ''
end.

NB. Assign to variables
xx=. djwCGIPost y ; 'tbl_player_par' ; 'tbl_player_index' ; 'tbl_player_yards' ; 'tbl_player_sss'

NB. Check the time stamp
yy=.glDbFile djwSqliteR 'select updatename,updatetime from tbl_player WHERE name=''',(;tbl_player_name),''';'
yy=.'tbl_player' djwSqliteSplit yy
 
NB. Throw error page if updated
if. (tbl_player_updatetime) ~: (prevtime) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(;tbl_player_name),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;tbl_player_name)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; tbl_player_updatename),' at ',(;tbl_player_updatetime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/u11/player/e/',(;tbl_player_name),'">Restart edit of: ',(;tbl_player_name),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.

tbl_player_updatename=: ,<getenv 'REMOTE_USER'
tbl_player_updatetime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'

string=. djwSqliteUpdate 'tbl_player' ; 'tbl_player_' ; 'tbl_player_name' ; 'tbl_player_'
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
NB. stdout 'Location: "http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,tbl_player_name),'"'
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''https://',(getenv 'SERVER_NAME'),'/jw/u11/player/e/',(,>tbl_player_name),''')"'
	elseif. 0= 4!:0 <'control_delete' do.
		yy=. glDbFile djwSqliteR 'delete from tbl_player WHERE name=''', (,>tbl_player_name),''';'
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v'')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v'')"'
    end.
stdout LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_u11_player_a
NB. ========================:=================================
NB. View scores for participant
jweb_u11_player_a=: 3 : 0
if. 1 ~: #y do. NB. Passed as parameter
	pagenotfound ''
end.
u11_player_add y
)

NB. =========================================================
NB. u11_player_add 
NB. =========================================================
NB. View scores for participant
u11_player_add=: 3 : 0
NB. Retrieve the details
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_player'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print tees and yardages
user=. getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>All players</h3>'

httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
    if. (-. +. / 'u11/player/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
	pagenotvalid ''
    end.
end.

NB. Don't take any input, just add a new variable and go back to listing page
utKeyRead glFilepath,'_player'
ww=. ; ". each glPlID
ww=. (i. 3+ >. / ww) -. ww
ww=. ; 'r<0>2.0' 8!:0 {.ww
utKeyClear glFilepath,'_player'
glPlID=: ,< ww
glPlFirstName=: ,<' edit name'
glPlLastName=: ,<''
glPlClub=: ,a:
glPlGross=: 1 18$_
glPlPutt=: 1 3$0 0 _
glPlUpdateName=: ,<": getenv 'REMOTE_USER'
glPlUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlDoB=: ,glCompDate
utKeyPut glFilepath,'_player'

stdout 'Content-type: text/html',LF,LF
NB. stdout 'Location: "http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,tbl_player_name),'"'
stdout LF,'<html><head>' 
stdout '</head><body onLoad="redirect(''https://',(": getenv 'SERVER_NAME'),'/jw/u11/player/v/',glFilename,''')"'
stdout LF,'</body></html>'
exit ''
)
