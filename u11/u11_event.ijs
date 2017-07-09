NB. =========================================================
NB. jweb_u11_event_v
NB. View scores for participant
NB. =========================================================
jweb_u11_event_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    u11_event_all y
elseif. 1 do.
    pagenotfound ''
end.
)
NB. =========================================================
NB. Synonyms
NB. jweb_u11_event
NB. =========================================================
jweb_u11_event=: 3 : 0
u11_event_all y
)

NB. =========================================================
NB. u11_event_all  
NB. View list of all events
NB. =========================================================
u11_event_all=: 3 : 0
NB. Retrieve the details

'glFiles glDates glNames'=: read_events ''

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container">'

NB. Print tees and yardages
user=. getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O U12 Boys'' Development Tour: Competition List</h2><i>',user,'</i>'

NB. Loop round in two halves
    stdout LF,'<div class="span-11">'
    stdout LT1,'<table>'
    stdout LT1,'<thead>',LT2,'<tr>'
    stdout LT3,'<th>Date</th><th>Venue</th>'
    stdout LT3,'</tr></thead>'
    stdout LT3,'<tbody>'
    for_ff. glFiles do.
	stdout LT3,'<tr>',LT4,'<td>',(timestamp 1 tsrep ff_index{glDates),'</td>'
	stdout LT4,'<td><a href="/jw/u11/player/v/',(>ff),'">',(>ff_index{glNames),'</a></td>'
	stdout LT3,'</tr>'
    end.
    stdout LF,'</tbody></table></div>'
NB. Add the Edit Option
stdout LF,'<div class="span-14 last">'
stdout LF,'<a href="/jw/u11/event/a">Add new Competition</a>'
stdout LF,'</div>' NB. Edit buttons span
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_u11_event_a
NB. ========================:=================================
NB. View scores for participant
jweb_u11_event_a=: 3 : 0
if. 1 ~: #y do. NB. Passed as parameter
	pagenotfound ''
end.
u11_event_add y
)

NB. =========================================================
NB. u11_event_add 
NB. =========================================================
NB. View scores for participant
u11_event_add=: 3 : 0
NB. Retrieve the details
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

err=. ReadAll glFilepath

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
utKeyRead glFilepath,'_event'
ww=. ; ". each glPlID
ww=. (i. 3+ >. / ww,0) -. ww
ww=. ; 'r<0>4.0' 8!:0 {.ww
utKeyClear glFilepath,'_event'
glPlID=: ,< ww
glPlFirstName=: ,<'First Name'
glPlLastName=: ,<' Last Name'
glPlClub=: ,a:
glPlGross=: 1 18$_
glPlPutt=: 1 3$0 0 50
glPlUpdateName=: ,<": getenv 'REMOTE_USER'
glPlUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlDoB=: ,glCompDate
glPlHCPFull=: ,36
glPlHCP=: ,glHCPAllow * (36 <. glHCPMax) 
if. glHCPRound do. glPlHCP=: <. 0.5 + glPlHCP end.
utKeyPut glFilepath,'_event'

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

NB. ===========================================================================
read_events=: 3 : 0
NB. read_events
NB. ---------------------------------------------------------------------------
NB. Usage: read_events ''
NB. 
NB. Reads the directory of events and returns filename ; date ; name
NB. ===========================================================================
fname=. 0$<''
date=. 0$0
name=. 0$<''
xx=. 0{"1 fdir glDocument_Root,'/yii/',glBasename,'/protected/data/*_player.ijf'
fname=. (<'_player.ijf' ; '') stringreplace each xx
for_ff. fname do.
    utFileGet glDocument_Root,'/yii/',glBasename,'/protected/data/',>ff
    date=. date, glCompDate
    name=. name, <glCourseName
end.
ww=. \: date
xx=. (ww{fname) ; (ww{date) ; <ww{name
)


NB. ===========================================================================
build_new_event=: 3 : 0
NB. build_new_event
NB. ---------------------------------------------------------------------------
NB. Usage: build_new_event ''
NB.
NB. Build a new player list of variables

'glFiles glDates glNames'=: read_events ''
NB. Initialise variables
xxPlID=. 0$<''
xxPlFirstName=. 0$<''
xxPlLastName=. 0$<''
xxPlHCPFull=. 0$0
xxPlHCP=. 0$0
xxPlDoB=. 0$0
xxPlGross=. 0 18$0
xxPlPutt=. (0,_1{$glPuttDesc) $0
xxPlUpdateName=. 0$<''
xxPlUpdateTime=. 0$0
xxPlStartTime=. 0$<''
xxPlClub=. 0$<''

NB. Get list of variables
NB. Need to delete them before each file read in case they are still in memory from a previous file
key=. >keyread (glDocument_Root,'/yii/',glBasename,'/protected/data/',(>0{glFiles),'_player' ) ; '_dictionary' NB. Assume most recent one has set of variables
global=. >jread (glDocument_Root,'/yii/',glBasename,'/protected/data/',(>0{glFiles)) ; 0

NB. Loop round the files, oldest first
for_ff. |. glFiles do.
    4!:55 key,global NB. Delete before reading
    ReadAll (glDocument_Root,'/yii/',glBasename,'/protected/data/',>ff)
    ix=. (xxPlFirstName,each (<' '),each xxPlLastName) i. glPlFirstName,each (<' '),each glPlLastName
    new=. I. (ix >: #xxPlID)
    NB. Any new ones
    if. 0<#new do.
	xxPlID=. xxPlID, 'r<0>4.0' 8!:0 (#xxPlID) + 1 + i. #new
	xxPlFirstName=. xxPlFirstName, new{glPlFirstName
	xxPlLastName=. xxPlLastName, new{glPlLastName
	xxPlHCPFull=. xxPlHCPFull, new{glPlHCPFull
	xxPlHCP=. xxPlHCP, new{glPlHCP
	xxPlDoB=. xxPlDoB, new{glPlDoB
	xxPlGross=. xxPlGross, ((#new),18)$_ NB. Infinity
	xxPlPutt=. xxPlPutt, ((#new),_1{$glPuttDesc)$(-_1{$glPuttDesc){.50 NB. 0 0 50 
	xxPlUpdateName=. xxPlUpdateName, (#new)$<''
	xxPlUpdateTime=. xxPlUpdateTime, (#new)$<''
	xxPlStartTime=. xxPlStartTime, (#new)$<''
	xxPlClub=. xxPlClub, new{glPlClub
    end.
    NB. Read again and update variables
    ix=. (xxPlFirstName,each (<' '),each xxPlLastName) i. glPlFirstName,each (<' '), each glPlLastName
    xxPlHCPFull=.  (glPlHCPFull) ix } xxPlHCPFull
    xxPlHCP=.  (glPlHCP) ix } xxPlHCP
    xxPlDoB=.  (glPlDoB) ix } xxPlDoB
    xxPlClub=.  (glPlClub) ix } xxPlClub
end.

NB. Build new file name
xx=. (#glFiles), + i. 20 NB. Generate random names
xx=. 'r<0>6.0' 8!:0 xx
xx=. 0{(-. xx e. glFiles) # xx
utFileGet glDocument_Root,'/yii/',glBasename,'/protected/data/',>0{glFiles
xx=. glDocument_Root,'/yii/',glBasename,'/protected/data/',>xx
jcreate xx
(0$<'') jappend xx NB. Blank dictionary
for. i. $global do.
    ('') jappend xx
end.
global utFilePut xx
glPlID=: xxPlID
glPlFirstName=: xxPlFirstName
glPlLastName=: xxPlLastName
glPlHCPFull=: xxPlHCPFull
glPlHCP=: xxPlHCP
glPlDoB=: xxPlDoB
glPlGross=: xxPlGross
glPlPutt=: xxPlPutt
glPlUpdateName=: xxPlUpdateName
glPlUpdateTime=: xxPlUpdateTime
glPlStartTime=: xxPlStartTime
glPlClub=: xxPlClub
xx=. xx,'_player'
keycreate xx
(< key) keywrite xx ; <'_dictionary' NB. Make sure it is one row
glPlID utKeyPut xx
xx
2!:0 'chmod 775 ',(_7}.xx),'*'


)
