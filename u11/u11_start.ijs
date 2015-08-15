NB. =========================================================
NB. jweb_u11_start_v
NB. View scores for participant
NB. =========================================================
jweb_u11_start_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    u11_start_all y
elseif. 1 do.
    pagenotfound ''
end.
)
NB. =========================================================
NB. Synonyms
NB. jweb_u11_start
NB. =========================================================
jweb_u11_start=: 3 : 0
u11_start_all y
)

NB. =========================================================
NB. jweb_u11_startscroll_v
NB. View scores for participant
NB. =========================================================
jweb_u11_startscroll_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    1 u11_start_all y
elseif. 1 do.
    pagenotfound ''
end.
)

NB. =========================================================
NB. Synonyms
NB. jweb_u11_start
NB. =========================================================
jweb_u11_startscroll=: 3 : 0
1 u11_start_all y
)

NB. =========================================================
NB. u11_start_all  
NB. View all starts and summary yards
NB. =========================================================
u11_start_all=: 3 : 0
0 u11_start_all y
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
	NB. one quarter of a second per player, minimum of 10 seconds
	tm=. ": <. 0.5+ (250* (10 >. # glPlID))
	stdout LF,'<script>setTimeout(function(){window.location.href=''/jw/u11/leaderscroll/v/',glFilename,'''},',tm,');</script>'
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
    djwErrorPage err ; ('No such course : ',glFilename) ; '/jw/u11/start/v' ; 'Back to course list'
end.

NB. Print tees and yardages
user=. getenv 'REMOTE_USER'
if. 0 -: user do. user=.'' end.
stdout LF,'<h2>BB&O Nike U11 Boys'' Competition : ', glCourseName,' : ',(11{.,timestamp 1 tsrep glCompDate),'</h2>','<i>',user,'</i><h3>Start Sheet</h3>'

NB. Order by start time and get unique entries
ww=:  /: >glPlFirstName
ww=: ww /: >ww{glPlLastName
ww=: ww /: >ww{glPlStartTime
(ww{glPlID) utKeyRead glFilepath,'_player'

    
stdout LF,'<div class="span-24 large">'
stdout LT1,'<table>'
stdout LT1,'<thead>',LT2,'<tr>'
stdout LT3,'<th style="border-right: 2px solid lightgrey">Start</th><th colspan="2" style="text-align:center;border-right: 2px solid lightgrey">Player 1</th><th colspan="2" style="text-align:center;border-right: 2px solid lightgrey">Player 2</th><th colspan="2" style="text-align:center;border-right: 2px solid lightgrey">Player 3</th></tr></thead><tbody>'
NB. Loop round the start times
uniq=. ~. glPlStartTime
for_u. uniq do.
	stdout LT2,'<tr>'
	list=. I. glPlStartTime=u 
	for_ll. list do. NB. Start of person loop
		if. ll_index=0 do. 
			stdout '<td style="border-right: 2px solid lightgrey">',(>u),'</td>'
		elseif. 0=3 | ll_index do.
			stdout LT2,'</tr>',LT2,'<tr><td style="border-right: 2px solid lightgrey">(cont''d)</td>' NB. new continuation row
		end.

		stdout LT3,'<td><a href="http://',(":getenv 'SERVER_NAME'),'/jw/u11/player/v/',(,glFilename),'/',(>ll{glPlID),'">',(>ll{glPlFirstName),' ',(>ll{glPlLastName),'</a>  ['
		stdout (":>ll{glPlHCP),'] '
		stdout '<i>',(":>ll{glPlClub),'</i></td>'
		gr=. ": +/7<. ll{glPlGross
		if. *. / _ = ll{ glPlGross do. gr=.'-' end.
		stdout LT3,'<td style="border-right: 2px solid lightgrey">',gr,'</td>'
	end. NB. End of person loop
	NB. Need to pad it out with blank elements or stripes look odd
	if. 1=3|#list do.
		stdout LT3,'<td></td><td style="border-right: 2px solid lightgrey"></td><td></td><td style="border-right: 2px solid lightgrey"></td>'
	elseif. 2=3|#list do.
		stdout LT3,'<td></td><td style="border-right: 2px solid lightgrey"></td>'
	end.
	stdout LT2,'</tr>'
end. NB. End of start time loop
stdout LT1,'</tbody></table></div>'

NB. Add the Edit Option
stdout LF,'<div class="span-24 last">'
stdout (-. scroll) # LF,'<a href="/jw/u11/player/v/',glFilename,'">Player list</a>'
stdout (-. scroll) # LF,EM,'<a href="/jw/u11/leader/v/',glFilename,'">Leaderboard</a>'
stdout (-. scroll) # LF,EM,'<a href="/jw/u11/prize/v/',glFilename,'">Prize Leaders</a>'
stdout LF,'</div>' NB. main span
stdout LF,'</div>' NB. container
stdout LF,'<hr>'
stdout '</body></html>'
exit ''
)

