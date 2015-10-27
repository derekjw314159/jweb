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
user=. getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>All players</h3>'

NB. Order by player
ww=:  /: >glPlFirstName
ww=: ww /: >ww{glPlLastName
(ww{glPlID) utKeyRead glFilepath,'_player'

NB. Loop round in two halves
for_hh. 0 1 do.
    
    if. hh=0 do.
	stdout LF,'<div class="span-9">'
    else.
	stdout LF,'<div class="span-9 prepend-1">'
    end.

    stdout LT1,'<table>'
    stdout LT1,'<thead>',LT2,'<tr>'
    stdout LT3,'<th>Name</th><th>Age</th><th>HCP</th><th>Start</th><th>Gross</th></tr></thead><tbody>'
    NB. Loop round the players
    chunk=. >. 0.5 * #glPlID
    for_cc. (hh *chunk ) + i. chunk do.
	if. cc >: #glPlID do. continue. end. NB. May be odd one at end.
	stdout LF,'<tr><td><a href="http://',(":getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,glFilename),'/',(>cc{glPlID),'">',(>cc{glPlFirstName),' ',(>cc{glPlLastName),'</td>'
	NB. stdout LT3,'<td>',(":>cc{glPlClub),'</td>'
	stdout LT3,'<td>',(;'6.3' 8!:0 glCompDate CalcAge cc{glPlDoB),'</td>'
	stdout LF,'<td>',(":>cc{glPlHCP),'</td>'
	stdout LF,'<td>',(":>cc{glPlStartTime),'</td>'
	gr=. ": +/glMax <. cc{glPlGross
	if. *. / _ = cc{ glPlGross do. gr=.'-' end.
	stdout LF,'<td>',gr,'</td>'
	stdout LT2,'</tr>'
    end.
    stdout LF,'</tbody></table></div>'
end. NB. End of half
NB. Add the Edit Option
stdout LF,'<div class="span-4 last">'
stdout LF,'<a href="https://',(":,getenv 'SERVER_NAME'),'/jw/u11/player/a/',glFilename,'">Add new player</a>'
stdout LF,'<br><br><a href="http://',(":,getenv 'SERVER_NAME'),'/jw/u11/start/v/',glFilename,'">Start sheet</a>'
stdout LF,'<br><br><a href="http://',(":,getenv 'SERVER_NAME'),'/jw/u11/leader/v/',glFilename,'">Leaderboard</a>'
stdout LF,'<br><br><a href="http://',(":,getenv 'SERVER_NAME'),'/jw/u11/prize/v/',glFilename,'">Prize Leaders</a><div>'
stdout LF,'</div>' NB. main span
stdout LF,'<div class="span-24">'
stdout LF,'<hr>'
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
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
user=.  getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>View details for :',(>glPlFirstName),' ',(>glPlLastName),'</h3>'

NB. Print scorecard and yardage
stdout LF,'<div class="span-24 last">'
stdout LT1,'Club = ',(>glPlClub),'<br>'
stdout LT1,'Full Handicap = ',(": glPlHCPFull),'<br>'
stdout LT1,'Handicap = ',(": glPlHCP),'<br>'
stdout LT1,'Start time = ',(>glPlStartTime),'<br>'
stdout LT1,'Date of Birth = ',(11{. , timestamp 1 tsrep glPlDoB),'<br>'

NB. Flag for not started
notstarted=. _ * *. / _ = ,glPlGross

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
	stdout LF,'<td>',(": notstarted + +/ glMax <. 9 {. ,glPlGross ),'</td>'
	stdout LF,'</tr></tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { glYards),'</td>'
	stdout LF,'<td>',(": +/(9+i.9) {glPar),'</td>'
	stdout LF,'<td>',(": notstarted + +/ glMax <. (9+i.9) {,glPlGross),'</td>'
	stdout LF,'</tr><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. glYards),'</td>'
	stdout LF,'<td>',(": +/9{. glPar),'</td>'
	stdout LF,'<td>',(": notstarted + +/ glMax <. 9{. ,glPlGross),'</td>'
	stdout LF,'</tr><tr><td><b>TOTAL</b></td>'
	stdout LF,'<td><b>',(": +/glYards),'</b></td>'
	stdout LF,'<td><b>',(": +/glPar),'</b></td>'
	stdout LF,'<td><b>',(": notstarted + +/ glMax <. ,glPlGross),'</b></td>'
	stdout LF,'</tr></tfoot></table></div>'
    end.

end.
NB. Add the Edit Option
stdout LF,'<div class="span-7 prepend-1 last">'
stdout LF,'<a href="https://',(":,getenv 'SERVER_NAME'),'/jw/u11/player/e/',(glFilename),'/',(>key),'">Edit: ',(;glPlFirstName),' ',(;glPlLastName),'</a>'
stdout LF,'<br><br><a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/u11/player/v/',glFilename,'">Back to Player List</a>'
stdout LF,'<br><br><a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/u11/start/v/',glFilename,'">Back to Start Sheet</a>'
stdout LF,'<br><br><a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/u11/leader/v/',glFilename,'">Back to Leaderboard</a></div>'
stdout LF,'<hr></div>' NB. main span

NB. Print the putting scores
for_rr. glPuttDesc do.
    stdout '<br>',(>rr),' = ',":rr_index{,glPlPutt
end.

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
user=.  getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2><h3>Edit details for :',(>glPlFirstName),' ',(>glPlLastName),'</h3>','<i>',user,'</i>'

NB. Print scorecard and yardage
stdout LF,'<div class="span-24 last">'
stdout LF, TAB,'<form action="/jw/u11/player/editpost/',glFilename,'/',(;key),'" method="post">'
stdout LF, TAB,'<input type="hidden" name="filename" value="',glFilename,'">' NB. Have to pass through this value
stdout LF, TAB,'<input type="hidden" name="key" value="',(;key),'">'
stdout LF, TAB,'<input type="hidden" name="prevtime" value="',(,>glPlUpdateTime),'">'
stdout LF, TAB,'<input type="hidden" name="prevname" value="',(,>glPlUpdateName),'">'
stdout LF,'<span class="span-3">Name</span><input name="firstname" value="',(,>glPlFirstName),'" tabindex="1" ',(InputField 20),'>'
stdout LF,EM,'<input name="lastname" value="',(,>glPlLastName),'" tabindex="2" ',(InputField 20),'>'
stdout LF,'<br><span class="span-3">Club</span><input name="club" value="',(,>glPlClub),'" tabindex="3" ',(InputField 25),'>'
stdout LF,'<br><span class="span-3">Full Handicap</span><input value="',(": ,glPlHCPFull),'" tabindex="4" ',(InputFieldnum 'hcpfull'; 3),'>'
stdout LF,'<br><span class="span-3">Handicap</span>',(": ,glPlHCP)
stdout LF,'<br><span class="span-3">Start time</span><input name="starttime" value="',(,>glPlStartTime),'" tabindex="5" ',(InputField 6),'>'
stdout LF,'<br><span class="span-3">Date of birth</span><input name="dob" value="',(11{. , timestamp 1 tsrep glPlDoB),'" tabindex="6" ',(InputField 12),'>'
stdout '</div>'

NB. Flag for not started
notstarted=. _ * *. / _ = ,glPlGross

NB. Front 9
for_half. i. 2 do.
    if. 0=half do.
	stdout LF,'<div class="span-5">'
    else.
	stdout LF,'<div class="span-5 prepend-2" last>'
    end.
stdout LF,'<table>'
    stdout LF,'<thead><tr>'
    stdout LF,'<th>Hole</th><th>Yards</th><th>Par</th><th>Gross</th></tr></thead><tbody>'
    for_x. (9*half) + i. 9 do.
	hole=. ;'r<0>2.0' 8!:0 x
	stdout LF,'<tr><td>',(":1+x),'</td>'
	stdout LF,'<td>',(": x{glYards),'</td>'
	stdout LF,'<td>',(": x{glPar),'</td>'
	val=.; 'd<>0.0' 8!:0 x{,glPlGross NB. Can't display infinity
	stdout LF,'<td><input value="',val,'" tabindex="',(":7+x),'" ',(InputFieldnum ('gross',hole);3),'"></td></tr>'
    end.

    if. half=0 do.
	stdout LF,'</tbody><tfoot><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. glYards),'</td>'
	stdout LF,'<td>',(": +/9 {. glPar ),'</td>'
	stdout LF,'<td>',(": notstarted + +/ glMax <. 9 {. ,glPlGross ),'</td>'
	stdout LF,'</tr></tfoot></table></div>'
    else.
	stdout LF,'</tbody><tfoot><tr><td>IN</td>'
	stdout LF,'<td>',(": +/(9+i.9)  { glYards),'</td>'
	stdout LF,'<td>',(": +/(9+i.9) {glPar),'</td>'
	stdout LF,'<td>',(": notstarted + +/ glMax <. (9+i.9) {,glPlGross),'</td>'
	stdout LF,'</tr><tr><td>OUT</td>'
	stdout LF,'<td>',(": +/9 {. glYards),'</td>'
	stdout LF,'<td>',(": +/9{. glPar),'</td>'
	stdout LF,'<td>',(": notstarted + +/ glMax <. 9{. ,glPlGross),'</td>'
	stdout LF,'</tr><tr><td><b>TOTAL</b></td>'
	stdout LF,'<td><b>',(": +/glYards),'</b></td>'
	stdout LF,'<td><b>',(": +/glPar),'</b></td>'
	stdout LF,'<td><b>',(": notstarted + +/ glMax <. ,glPlGross),'</b></td>'
	stdout LF,'</tr></tfoot></table></div>'
    end.

end.
NB. Add the Edit Option
stdout '<div class="span-5 prepend-2">'
stdout '<table><thead><tr><th>Putting</th><th></th></tr></thead><tbody>'
NB. Print the putting scores
for_rr. glPuttDesc do.
    hole=. ; 'r<0>2.0' 8!:0 rr_index 
    if. rr_index < (#glPuttDesc) -1 do.
	val=. ; 'd<>b<>0.0' 8!:0 rr_index{,glPlPutt NB. suppress zero and infinity
    else.
	val=. ; '0.1' 8!:0 rr_index{,glPlPutt NB. suppress zero and infinity
    end.
    stdout '<tr><td>',(>rr),'</td><td><input value="',val,'" tabindex="',(":25+rr_index),'" ',(InputFieldnum ('putt',hole) ; 3),'"></td></tr>'
end.
stdout LT2,'</tbody></table></div>'


NB. Print scorecard and yardage
stdout '<div class="span-24">'

NB. Submit buttons
stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="28">'
stdout LF,'     <input type="submit" name="control_player" value="Player list" tabindex="29">'
stdout LF,'     <input type="submit" name="control_start" value="Start sheet" tabindex="30">'
stdout LF,'     <input type="submit" name="control_leader" value="Leaderboard" tabindex="30">'
stdout LF,'     <input type="submit" name="control_delete" value="Delete" tabindex="31"></form></div>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
NB. exit 0
)

NB. =========================================================
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
if. -. glSimulate do.
    if. (-. +. / 'u11/player/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
    end.
end.
NB. Assign to variables
xx=. djwCGIPost y ; 'hcpfull' ; 'hcp' ; 'gross' ; 'putt'
djwBuildArray 'gross'
djwBuildArray 'putt'
glFilename=: dltb >filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

utFileGet glFilepath
(key) utKeyRead glFilepath,'_player'

NB. Check the time stamp
 
NB. Throw error page if updated
if.  -. (,>glPlUpdateTime) -: (,>prevtime) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(;glPlFirstName),' ',(;glPlLastName),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;glPlFirstName),' ',(;glPlLastName)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; glPlUpdateName),' at ',(;glPlUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/u11/player/e/',glFilename,'/',(;key),'">Restart edit of: ',(;glPlFirstName),' ',(;glPlLastName),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.

glPlUpdateName=: ,<getenv 'REMOTE_USER'
glPlUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlFirstName=: ,firstname
glPlLastName=: ,lastname
glPlHCPFull=: ,hcpfull
hcp=: glHCPMax <. hcpfull
hcp=: glHCPAllow * hcp
if. glHCPRound do. hcp=: <. 0.5 + hcp end.
glPlHCP=: ,hcp 
glPlClub=: club
glPlDoB=: ,tsrep 6 {. getdate >dob
glPlStartTime=: ,starttime
glPlGross=: 1 18$,gross
glPlGross=: <. 0.5 + glPlGross + _ * 0=glPlGross
glPlPutt=:  (1,#glPuttDesc) $,putt
NB. glPlPutt=: glPlPutt + _ * 25<glPlPutt

(key) utKeyPut glFilepath,'_player'

stdout 'Content-type: text/html',LF,LF
NB. stdout 'Location: "http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,tbl_player_name),'"'
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''https://',(getenv 'SERVER_NAME'),'/jw/u11/player/e/',glFilename,'/',(;key),''')">'
	elseif. 0= 4!:0 <'control_delete' do.
		(,key) utKeyDrop glFilepath,'_player'
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v/',glFilename,''')">'
	elseif. 0= 4!:0 <'control_player' do.
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/player/v/',glFilename,''')">'
	elseif. 0= 4!:0 <'control_start' do.
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/start/v/',glFilename,''')">'
	elseif. 0= 4!:0 <'control_leader' do.
		stdout '</head><body onLoad="redirect(''http://',(getenv 'SERVER_NAME'),'/jw/u11/leader/v/',glFilename,''')">'
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


NB. Error page - No such course
if. 0<#err do.
    stdout 'Content-type: text/html',LF,LF,'<html>',LF
    stdout LF,'<head>'
    stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
    djwBlueprintCSS ''

    stdout LF,'</head>',LF,'<body>'
    stdout LF,'<div class="container">'
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print tees and yardages

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
ww=. (i. 3+ >. / ww,0) -. ww
ww=. ; 'r<0>4.0' 8!:0 {.ww
utKeyClear glFilepath,'_player'
glPlID=: ,< ww
glPlFirstName=: ,<''
glPlLastName=: ,<' New Player'
glPlClub=: ,a:
glPlGross=: 1 18$_
glPlPutt=: 1 3$0 0 50
glPlUpdateName=: ,<": getenv 'REMOTE_USER'
glPlUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlDoB=: ,glCompDate
glPlHCPFull=: ,36
glPlHCP=: ,glHCPAllow * (36 <. glHCPMax) 
if. glHCPRound do. glPlHCP=: <. 0.5 + glPlHCP end.
utKeyPut glFilepath,'_player'

NB.stdout 'Content-type: text/html',LF,LF
NB. stdout '<html><head>' 
stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF

stdout LF,'</head>',LF,'<body>'
stdout '</head><body onLoad="redirect(''https://',(": getenv 'SERVER_NAME'),'/jw/u11/player/e/',glFilename,'/',(;glPlID),''')">'
stdout LF,'</body></html>'
exit ''
)
