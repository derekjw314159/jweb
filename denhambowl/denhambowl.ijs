NB. J Utilities for Denhambowl
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
r=. ' class="normal" style="font-size: 8pt; height: 16px; margin: 0px; width: ',(":wid),'em;" type="text" name="',nam,'" id="',nam,'" onkeyup="validatenum2(''',nam,''')"'
)

NB. ===================================
NB. CSS Standards
NB. djwBlueprintCSS
NB. ===================================
djwBlueprintCSS=: 3 : 0
stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css">'
stdout LF, '<style>a:link:after, a:visited:after{'
stdout LF,TAB,'    content: normal;'
stdout LF, TAB,'}</style>'
stdout LF,'<!--[if lt IE 8]>'
stdout LF,TAB,'<link rel="stylesheet" href="/css/blueprint/ie.css" type="text/css" media="screen, projection">'
stdout LF,'<![endif]-->'
)

