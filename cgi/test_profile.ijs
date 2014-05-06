NB. cgi
NB.
NB. This is a standalone script, and can also be included with other
NB. scripts, as there is no conflict with the standard library.
NB.
NB. main definitions:
NB. cgiparms - return cgi parameters as table of names,.values
NB. cgitest - use to test cgi

NB. 18!:4 <'z'

NB. TAB=: 9 { a.
NB. LF=: 10 { a.
NB. stdin=: 1!:1@3:
NB. stdout=: 1!:2&4
NB. stderr=: 1!:2&5
NB. getenv=: 2!:5
NB. exit=: 2!:55

NB. =========================================================
NB. cgiparms v return cgi parameters
cgiparms=: 3 : 0
select. getenv 'REQUEST_METHOD'
case. 'GET' do.
  p=. getenv 'QUERY_STRING'
case. 'POST' do.
  p=. stdin''
case. do.
  p=. ''
end.
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
exit 0
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
exit 0 
)


NB. =========================================================
NB. Control which function to run
controlpage=: 3 : 0
NB. load    'files'
NB. xx=.cgiparms ''
NB. filepath=. (": getenv 'DOCUMENT_ROOT'),'/jw'
NB. basename=. >(<0 1){xx
NB. basename=. >{'/' cut basename
NB. if. fexist filepath,'/',basename do.
     cgitest ''
NB. else.
NB.     pagenotfound ''
NB. end.
)

NB. 18!:4 <'base'


NB. =========================================================
NB. decomment for testing:
NB. cgitest''
controlpage ''
