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
if. scroll do.
	stdout LF,'<script>setTimeout(function(){window.location.href=''/jw/u11/prizescroll/v/',glFilename,'''},10000);</script>'
end.
djwBlueprintCSS ''

if. scroll do.
	stdout LF,'</head>',LF,'<body onLoad="pageScroll()">'
else.
	stdout LF,'</head>',LF,'<body>'
end.
	
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/u11/leader/v' ; 'Back to course list'
end.

NB. Print tees and yardages
user=. getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>Leaderboard</h3>'

NB. Order by leader time and get unique entries
ww=:  /: >glPlFirstName
ww=: ww /: >ww{glPlLastName
ww=: ww /: (+/"1 (7 <. ww{glPlGross)) - ww{glPlHCP NB. Nett
ww=: ww /: (+/"1 (_1{."1 (7 <. ww{glPlGross)))  NB. back one
ww=: ww /: (+/"1 (_3{."1 (7 <. ww{glPlGross)))  NB. back one
ww=: ww /: (+/"1 (_6{."1 (7 <. ww{glPlGross)))  NB. back one
ww=: ww /: (+/"1 (_9{."1  (7 <. ww{glPlGross)))  NB. back one
ww=: ww /: (+/"1 (7 <. ww{glPlGross))  NB. Gross
(ww{glPlID) utKeyRead glFilepath,'_player'

    
stdout LF,'<div class="span-24 large">'
stdout LT1,'<table>'
stdout LT1,'<thead>',LT2,'<tr>'
stdout LT3,'<th style="border-right: 2px solid lightgrey">Pos</th><th>Player</th><th>Gross</th><th>Nett</th>'
for_p. glPuttDesc do.
	stdout LT3,'<th>',(>p),'</th>'
end.
stdout LT2,'</tr></thead><tbody>'
NB. Loop round the leader times
last=. _1
for_ll. i. #glPlID do. NB. Start of person loop
	stdout LT2,'<tr>'
	gr=. +/(7<. ll{glPlGross)
	if. gr = last do.
		stdout LT3,'<td>=</td>'
	else.
		stdout LT3,'<td>',(": 1+ll_index),'</td>'
	end.
	last=. gr 
	stdout LT3,'<td><a href="http://',(":getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,glFilename),'/',(>ll{glPlID),'">',(>ll{glPlFirstName),' ',(>ll{glPlLastName),'</a>  ['
	stdout (":>ll{glPlHCP),'] '
	stdout '<i>',(":>ll{glPlClub),'</i></td>'
	gr=. ": gr
	if. *. / _ = ll{ glPlGross do. gr=.'-' end.
	stdout LT3,'<td>',gr,'</td>'
	nt=. ": (+/(7 <. ll{glPlGross)) - ll{glPlHCP

	if. *. / _ = ll{ glPlGross do. nt=.'-' end.
	stdout LT3,'<td>',nt,'</td>'
	for_p. i. #glPuttDesc do.
		stdout LT3,'<td>',(": (<ll, p){glPlPutt),'</td>'
	end.
	stdout LT2,'</tr>'
end. NB. End of person loop
stdout LT1,'</tbody></table></div>'

NB. Add the Edit Option
stdout LF,'<div class="span-4 last">'
stdout (-. scroll) # LF,'<a href="/jw/u11/player/v/',glFilename,'">Player list</a>'
stdout (-. scroll) # LF,'<a href="/jw/u11/start/v/',glFilename,'">Start Sheet</a>'
stdout (-. scroll) # LF,'<a href="/jw/u11/prize/v/',glFilename,'">Prize Sheet</a>'
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
stdout LF,'<hr>'
stdout '</body></html>'
exit ''
)

