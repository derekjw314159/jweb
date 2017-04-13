NB. =========================================================
NB. jweb_u11_leader_v
NB. View scores for participant
NB. =========================================================
jweb_u11_leader_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    u11_leader_all y
elseif. 1 do.
    pagenotfound ''
end.
)
NB. =========================================================
NB. Synonyms
NB. jweb_u11_leader
NB. =========================================================
jweb_u11_leader=: 3 : 0
u11_leader_all y
)

NB. =========================================================
NB. jweb_u11_leaderscroll_v
NB. View scores for participant
NB. =========================================================
jweb_u11_leaderscroll_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    1 u11_leader_all y
elseif. 1 do.
    pagenotfound ''
end.
)

NB. =========================================================
NB. Synonyms
NB. jweb_u11_leader
NB. =========================================================
jweb_u11_leaderscroll=: 3 : 0
1 u11_leader_all y
)

NB. =========================================================
NB. u11_leader_all  
NB. View all leaders and summary yards
NB. =========================================================
u11_leader_all=: 3 : 0
0 u11_leader_all y
:
scroll=. x
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

err=. ReadAll glFilepath

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
if. scroll do.
	NB. three quarters of a second per player, minimum of 5 seconds
	tm=. ": <. 0.5+ 1000 * 1{glPageDelay
	stdout LF,'<script>setTimeout(function(){window.location.href=''/jw/u11/prizescroll/v/',glFilename,'''},',tm,');</script>'
end.
djwBlueprintCSS ''

if. scroll do.
	stdout LF,'</head>',LF,'<body onLoad="leaderScroll()">'
else.
	stdout LF,'</head>',LF,'<body>'
end.

NB. Hidden div to hold scroll parameters
stdout LF,'<span class="small" id="initial" style="visibility:hidden; border: 0; padding: 0; margin:0; width:5px">',(":0{glScrollParam),'</span>'
stdout LF,'<span class="small" id="scrollpixel" style="visibility:hidden; border: 0; padding: 0; margin:0; width:5px">',(":1{glScrollParam),'</span>'
stdout LF,'<span class="small" id="scrolltime" style="visibility:hidden; border: 0; padding: 0; margin:0; width:5px">',(":2{glScrollParam),'</span>'

stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/u11/leader/v' ; 'Back to course list'
end.

NB. Print tees and yardages
user=. getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O U12 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>Leaderboard</h3>'

NB. Order by leader time and get unique entries
NB. Need to drop the last nine if a nine-hole competition
drop=. _9 * gl9Hole
hcp=. (1 - 0.5*gl9Hole) * glPlHCP NB. do not round if halved

ww=:  /: >glPlFirstName
ww=: ww /: >ww{glPlLastName
ww=: ww /: (+/"1 (drop }."1 (glMax <. ww{glPlGross))) - ww{glPlHCP NB. Nett
ww=: ww /: (+/"1 (_1{."1 (drop }."1 (glMax <. ww{glPlGross))))  NB. back one
ww=: ww /: (+/"1 (_3{."1 (drop }."1 (glMax <. ww{glPlGross))))  NB. back three
ww=: ww /: (+/"1 (_6{."1 (drop }."1 (glMax <. ww{glPlGross))))  NB. back six
ww=: ww /: (+/"1 (_9{."1 (drop }."1 (glMax <. ww{glPlGross))))  NB. back nine
ww=: ww /: (+/"1 (drop }."1 (glMax <. ww{glPlGross)))  NB. Gross
NB. Finally put withdrawals at the bottom
ww=: ww /: (<'WD') =  ww{glPlStartTime
(ww{glPlID) utKeyRead glFilepath,'_player'
grosslist=.  (+/"1 (drop }."1 (glMax <. glPlGross)))  NB. Gross



NB. If scroll create two divs
stdout LF,'<div class="span-24 large" style="line-height: 1.4em;width: 100%; margin-bottom: 2px;">'
stdout LT1,'<table style="margin-bottom: 0px;">'
stdout LT1,'<thead>',LT2,'<tr>'
stdout LT3,'<th style="border-right: 2px solid lightgrey; width: 10%">Pos</th>'
stdout LT3,'<th style="width: 40%;">Player</th>'
stdout LT3,'<th style="width: 10%;">Gross</th>'
stdout LT3,'<th style="width: 10%;">Nett</th>'
for_p. glPuttDesc do.
	stdout LT3,'<th style="width: 10%;">',(>p),'</th>'
end.
stdout LT2,'</tr></thead><tbody>'
NB. Loop round the leader times
last=. _1
for_ll. i. #glPlID do. NB. Start of person loop
	NB. This is the major logic.  Create a second div after three elements and make the bottom part overflow
	NB. and trigger the javascript
	if. scroll *. (ll = 3) do.
	    stdout LT1,'</tbody>'
	    stdout LT1,'</table>'
	    stdout LF,'</div>'
	    stdout LF,'<div class="span-24 large" id="tablebody" style="line-height: 1.4em;width: 100%; height: 400px; overflow: auto;">'
	    stdout LT1,'<table>'
	    stdout LT1,'<tbody>'
	end.

	stdout LT2,'<tr>'
	gr=. +/ drop }. (glMax<. ll{glPlGross)
	if. (<'WD') = ll{glPlStartTime do.
		stdout LT3,'<td style="width: 10%;">WD</td>'
	NB. elseif. gr = last do.
	NB.	stdout LT3,'<td style="width: 10%;">=</td>'
	elseif. 1 do.
		stdout LT3,'<td style="width: 10%;">',(": 1+ll{grosslist i. grosslist)
		stdout ((1<+/grosslist=ll{grosslist)#'='),'</td>' NB. Logic for whether this is a tied rank
	end.
	last=. gr 
	stdout LT3,'<td style="width: 40%;">'
	NB. Only drill if not scrolling
	stdout (-. scroll) # LT3,'<a href="http://',(":getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,glFilename),'/',(>ll{glPlID),'">'
	stdout LT3,(>ll{glPlFirstName),' ',(>ll{glPlLastName)
	stdout (-. scroll) # '</a>'
	stdout ' [',(":>ll{glPlHCPFull),'/'
	stdout (":>ll{glPlHCP),'] '
	stdout '<i>',(":>ll{glPlClub),'</i></td>'
	gr=. ": gr
	if. (<'WD') = ll{glPlStartTime do.
	    stdout LT3,'<td style="width: 10%;">WD</td>'
	    stdout LT3,'<td style="width: 10%;"></td>'
	    stdout ; (#glPuttDesc)#,: '<td style="width: 10%;"></td>'
	    continue.
	elseif. *. / _ = drop }. ll{ glPlGross do.
	    gr=. '-'
	end.
	stdout LT3,'<td style="width: 10%;">',gr,'</td>'
	nt=. ": (+/ drop }. (glMax <. ll{glPlGross)) - (1 - 0.5 * gl9Hole) * ll{glPlHCP

	if. *. / _ = ll{ glPlGross do. nt=.'-' end.
	stdout LT3,'<td style="width: 10%;">',nt,'</td>'
	for_p. i. #glPuttDesc do.
		stdout LT3,'<td style="width: 10%;">',(": (<ll, p){glPlPutt),'</td>'
	end.
	stdout LT2,'</tr>'
end. NB. End of person loop
stdout LT1,'</tbody></table></div>'

NB. Add the Edit Option
stdout LF,'<div class="span-24 last">'
stdout (-. scroll) # LF,'<a href="/jw/u11/player/v/',glFilename,'">Player list</a>'
stdout (-. scroll) # LF,EM,'<a href="/jw/u11/start/v/',glFilename,'">Start Sheet</a>'
stdout (-. scroll) # LF,EM,'<a href="/jw/u11/prize/v/',glFilename,'">Prize Leaders</a>'
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
stdout LF,'<hr>'
stdout '</body></html>'
exit ''
)

