NB. J Utilities for Denhambowl
NB. Central functions
NB. 

NB. Standard input field behaviours
NB. ================================
NB. InputField
NB. ================================
InputField=: 3 : 0
r=. ' class="normal" style="font-size: 8pt; height: 16px; width: ',(":y),'em;" type="text"'
)

InputFieldnum=: 3 : 0
('nam';'wid')=. y
r=. ' class="normal" style="font-size: 8pt; height: 16px; margin: 0px; width: ',(":wid),'em;" type="tel" pattern="\d*\.*\d*" name="',nam,'" id="',nam,'" onkeyup="validatenum2(''',nam,''')"'
)

NB. ===================================
NB. CSS Standards
NB. djwBlueprintCSS
NB. ===================================
djwBlueprintCSS=: 3 : 0
NB. stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css">'
stdout LF,'<style>a:link:after, a:visited:after{'
stdout LF,TAB,'     content: normal;'
stdout LF,TAB,'}</style>'
NB. stdout LF,'<link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">'
stdout LF,'<!--[if lt IE 8]>'
stdout LF,TAB,'<link rel="stylesheet" href="/css/blueprint/ie.css" type="text/css" media="screen, projection">'
stdout LF,'<![endif]-->'
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

