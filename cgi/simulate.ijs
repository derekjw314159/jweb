NB. cgi
NB.
NB. This is a standalone script, and can also be included with other
NB. scripts, as there is no conflict with the standard library.
NB.
NB. main definitions:
NB. cgiparms - return cgi parameters as table of names,.values
NB. cgitest - use to test cgi

18!:4 <'z'

TAB=: 9 { a.
LF=: 10 { a.

LT1=: LF, TAB
LT2=: LF, 2$TAB
LT3=: LF, 3$TAB
LT4=: LF, 4$TAB
LT5=: LF, 5$TAB
LT6=: LF, 6$TAB
LT7=: LF, 7$TAB

EM=: ; 3$,: '&emsp;'

stdin=: 1!:1@3:
stdout=: 1!:2&4
stderr=: 1!:2&5
getenv=: 2!:5

NB. Change the exit function
exit=: 3 : 0
	stdout LF,'*** exit ***',LF
)
exitexit=: 2!:55 

18!:4 <'base'

glSimulate=: 1

each=: &.>
dltb_z_=: #~ [: (+./\ *. +./\.) ' '&~:
18!:4 <'base'


NB. =========================================================
NB. cgiparms v return cgi parameters
cgiparms=: 3 : 0
p=. >2{ARGV
cgiparms1 p
)

NB. =========================================================
NB. cgiparms1 v parse parameter string
cgiparms1=: 3 : 0
y=. ' ' (I. y = '+') } y
y=. <;._1 '&', y
ndx=. y i.&> '='
nms=. ndx {. &.> y
val=. (ndx+1) }. &.> y
cgiparms2 &.> nms,.val
)

NB. =========================================================
NB. cgiparms2 v url decode
cgiparms2=: 3 : 0
if. -. '%' e. y do. y return. end.
y=. <;._1 '%00', y
a=. '0123456789abcdef0123456789ABCDEF'
p=. a. {~ 16 #. 16 | a i. 2 {.&> y
}. ; p ,&.> 2 }.&.> y
)

NB. Postvars are the second parameter onwards
glPostVars=:  1}. cgiparms''


NB. ==========================================================
NB. Global variables
NB. ==========================================================
setglobals=: 3 : 0
if. 0 < # 1!:0 <'/Users' do. glHome=: '/Users' else. glHome=: '/home' end.
if. 0 < # 1!:0 <glHome,'/djw' do. glHome=: glHome, '/djw' else. glHome=: glHome,'/ubuntu' end.
if. 0 < # 1!:0 <'/Users' do. glDocument_Root=: '/Library/WebServer/Documents' else. glDocument_Root=: '/var/www' end.
glBasename=: > {. (<;._1) '/',>(<0 1){cgiparms ''
glDbFile=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glBasename,'.db'
glDbRoot=: '/yii/',glBasename,'/protected/data'
glJPath=: _4 }. BINPATH_z_
NB. glJPath=: glHome,'/j602'
)

x=.setglobals ''

NB. =========================================================
NB. cgitest v defines html with a timestamp and cgi parameters
cgitest=: 3 : 0
stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/myscript.js"></script>',LF
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">'
stdout LF,'<script>'
stdout LF,'alert("My first JS");'
stdout LF,'</script>'
stdout LF,'</head><body><pre>'
stdout LF,~":6!:0''
stdout LF,.~":cgiparms''
stdout LF,'</pre><div class="container">'
stdout LF,TAB,'<div class="span-24">'
stdout LF,TAB,TAB,'<h3>The header</h3>'
stdout LF,'<table><tr><th>Table Header</th></tr>'
for_x. i. 8 do.
    stdout LF,'<br><tr><td>Line ',(":x),'</td></tr>'
end.


stdout LF,'<br><em>QUERY STRING</em>',": getenv 'QUERY_STRING'
stdout LF,'<br>DOCUMENT ROOT',": getenv 'DOCUMENT_ROOT'
stdout LF,'<br>',TAB,'</div><hr></div><pre>'
stdout LF,LF
stdout '<span class="highlight">',LF,.~":cgiparms''
stdout '</span></pre>'
stdout LF,'<body onLoad="pageScroll()">'
stdout '</body></html>'
NB. exit 0
)

pagenotfound=: 3 : 0
stdout 'Status: 404 Not Found'
stdout LF,'Content-Type: text/html'
stdout LF,LF,'<head>'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">'
stdout LF,'</head>','<title>404 Not Found</title>'
stdout LF,'<h1>404 Not Found</h1>'
string=. (": getenv'HTTP_HOST'),'/jw/',(2}. ": getenv 'QUERY_STRING')
stdout LF,'<br><body class="error loud">',string,'</body>'
exit ''
NB. exit 0 
)

NB. ================================================================
NB. pagenotvalid
NB. ================================================================
pagenotvalid=: 3 : 0
stdout 'Status: 404 Not Found'
stdout LF,'Content-Type: text/html'
stdout LF,LF,'<head>'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">'
stdout LF,'</head>','<title>404 Not Found</title><body class="error loud">'
stdout LF,'<h1>404 This is not a valid page for direct loading</h1>'
stdout LF,'<br>QUERY_STRING=',getenv 'QUERY_STRING'
stdout LF,'<br>HTTP_REFERER=',getenv 'HTTP_REFERER'
stdout LF,'<br>HTTP HOST=', getenv 'HTTP_HOST'
stdout LF,'<br>SERVER ADMIN=', getenv 'SERVER_ADMIN'
stdout LF,'<br>SERVER NAME=', getenv 'SERVER_NAME'
stdout LF,'<br>REQUEST URI=', getenv 'REQUEST_URI'
stdout LF,'<br>HTTPS=', ": getenv 'HTTPS'
stdout LF,'<br>REMOTE USER=', ": getenv 'REMOTE_USER'
stdout LF,'</body>'
exit ''
)

NB. =========================================================
NB. Control which function to run
controlpage=: 3 : 0
NB. load    'files'
xx=.cgiparms ''
filepath=. glDocument_Root,'/jweb'
params=.   > (<0 1){xx
params=. <;._1 '/',params
basename=. > {. params

NB. Load sqlite utilities
xx=. 0!:0 <glDocument_Root,'/jweb/cgi/util_sqlite.ijs'

if. 0 < # 1!:0 <filepath,'/',basename do.
    NB. cgitest ''
    NB. Load the script from the basename
    NB. looping round directories to load each ijs file in turn
    name=. filepath
    for_chunk. params do.
	name=. name,'/',>chunk
	if. 0< # 1!:0 name do.
	    ff=. 1!:0 name,'/*.ijs'
	    for_f. ff do.
		xx=.0!:0 <name, '/',>{.f
	    end.
	end.
    end.
    NB. Then loop round the function names in reverse order
    for_chunk. |. i. #params do.
	ff=. (1+chunk) {. params
	ff=. 'jweb', ; (<'_') , each ff
	if. 3= 4!:0 < ff do. 
	    NB. Killer line which executes the right function
	    NB. Pass the remaining parameters
		". 'xx=.',ff,' (1+chunk) }. params'
		return.    
	    NB. jweb_denhambowl_course_e ''
	end.
    end.
    NB. Didn't find the function
    pagenotfound ''
else.
    pagenotfound ''
end.
)

NB. ===================================
NB. Error Page
NB. djwErrorPage
NB. ===================================
djwErrorPage=: 3 : 0
'errhead errmessage returnloc returnmessage'=. y
stdout LF,TAB,'<div class="span-24">'
stdout LF,TAB,TAB,'<h1>',errhead,'</h1>'
stdout LF,TAB,TAB,'<div class="error">',errmessage
stdout '</div>'
stdout LF,TAB,'</div>'
stdout LF,TAB,'<br><a href="',returnloc,'">',returnmessage
stdout LF, '</div>',LF,'</body></html>'
exit ''
)

NB. ===================================
NB. Sync Error Page
NB. djwErrorPage
NB. ===================================
djwSyncError=: 3 : 0
'errhead errmessage returnloc returnmessage'=. y
stdout LF,TAB,'<div class="span-24">'
stdout LF,TAB,TAB,'<h1>',errhead,'</h1>'
stdout LF,TAB,TAB,'<div class="error">',errmessage
stdout '</div>'
stdout LF,TAB,'</div>'
stdout LF,TAB,'<br><a href="',returnloc,'">',returnmessage
stdout LF, '</div>',LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. decomment for testing:
NB. cgitest''
controlpage ''
