NB. J Utilities for Rating Courses
NB. 

NB. =========================================================
NB. jweb_rating_plan_v
NB. View scores for participant
NB. =========================================================
jweb_rating_plan_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    rating_plan_all  y
elseif. 2=#y do. NB. Passed as parameter
    rating_plan_view y
elseif. 1 do.
    pagenotfound ''
end.
)

NB. =========================================================
NB. jweb_rating_plan_v
NB. View scores for participant
NB. =========================================================
jweb_rating_plannomap_v=: 3 : 0
NB. y=.cgiparms ''
if. 1=#y do.
    0 rating_plan_all  y
elseif. 2=#y do. NB. Passed as parameter
    0 rating_plan_view y
elseif. 1 do.
    pagenotfound ''
end.
)


NB. =========================================================
NB. Synonyms
NB. jweb_rating_plan
NB. =========================================================
jweb_rating_plan=: 3 : 0
rating_plan_all y
)

NB. =========================================================
NB. rating_plan_all  
NB. View all courses and summary yards
NB. =========================================================
rating_plan_all=: 3 : 0
1 rating_plan_all y
:
showmap=. x
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_plan'
	xx=. utKeyRead glFilepath,'_tee'
	xx=. utKeyRead glFilepath,'_green'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. stdout LF,'<script>setTimeout(function(){window.location.href=''http://www.google.com''},5000);</script>'


djwBlueprintCSS ''

NB. Add the header stuff for the map
if. showmap do.
    BuildMap i. 18
end.

stdout LF,'</head>',LF,'<body>'
NB. Control map display
if. showmap do.
	stdout LT1,'  <div id="map-canvas"></div>'
end.
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print tees and yardages
stdout LF,'<h2>Course : ', glCourseName,'</h2><h3>All holes</h3>'
stdout LF,'<a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',(showmap#'nomap'),'/v/',glFilename,'">',(>showmap{'/' cut 'Show Map/Suppress map'),'</a>'
stdout LF,TAB,'<div class="span-14 last">'

stdout LT1,'<table><thead>'
stdout LT2,'<tr><th></th>'
for_t. glTees do.
    stdout LT3,'<th colspan="3">',(>t_index{glTeesName),'</th>'
end.
stdout LT3,'<th></th>'
stdout LT2,'</tr>',LT2,'<tr><th>Hole</th>'
for_t. glTees do.
    stdout LT3,'<th>Yards</th><th>Mn</th><th>Wn</th>'
end.
stdout LT3,'<th>RoughLength</th>'
stdout LT2,'</tr>'

stdout LT1,'</thead><tbody>'
for_hole. i. 18 do.
    stdout LT2,'<tr>',LT3,'<td><a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+hole),'">',(":1+hole),'</a></td>'
    for_t.  i. #glTees do.
	    stdout LT3,'<td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">',(": <. 0.5 + (<t,hole){glTeesYards),'</td>'
	    utKeyRead glFilepath,'_tee'
	    ww=. (glTeHole=hole) *. glTeTee=t{glTees
	    (ww # glTeID) utKeyRead glFilepath,'_tee'
	    for_gender. 0 1 do.
		if. (gender{,glTeMeasured) do.
		    stdout LT3,'<td><a href="/jw/rating/sheet/',glFilename,'/',(":hole),'/',(t{glTees),'/',(":gender),'">y</a></td>'
		else.
		    stdout LT3,'<td>-</td>'
		end.
	    end.
    end.
	    stdout LT3,'<td>',(": ; (hole=glGrHole)#glGrRRRoughLength),'</td>'
	    stdout LT2,'</tr>'
end.
stdout LT1,'</tbody></table>'


stdout LF,'</div>' NB. main span
stdout LF,'        '
for_h. i. 18 do.
		stdout '    <a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
end.
	
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. rating_plan_view
NB. View scores for participant
NB. =========================================================
rating_plan_view=: 3 : 0
1 rating_plan_view y
:
showmap=. x
NB. Retrieve the details
NB. y has two elements, coursename & hole (+1)
hole=. ''$ 0". >1{y
hole=. <. 0.5 + hole
hole=. hole-1 
hole=. 0 >. 17 <. hole
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_plan'
	xx=. utKeyRead glFilepath,'_tee'
	xx=. utKeyRead glFilepath,'_green'
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

NB. Add the header stuff for the map
if. showmap do.
    BuildMap ,hole
end.

stdout LF,'</head>',LF,'<body>'
NB. Control map display
if. showmap do.
	stdout LT1,'  <div id="map-canvas"></div>'
end.
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print course yardage and measurements
stdout LF,'<h2>Course : ', glCourseName,'</h2><h3>Hole : ',(":1+ ; hole),'</h3>'
stdout LF,'<a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',(showmap#'nomap'),'/v/',glFilename,'/',(": 1+hole),'">',(>showmap{'/' cut 'Show Map/Suppress map'),'</a>'
stdout LF,TAB,'<div class="span-8 last">'

stdout LF,'<table><thead>'
stdout '<tr><th>Tee</th><th>Card</th><th>Par M/W</th><th>Alt</th><th>Mn</th><th>Wn</th><th>Rough Length</th></tr>'
stdout '</thead><tbody>'
utKeyRead glFilepath,'_green'
for_t.  i. #glTees do.
	stdout LF,'<tr><td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">',(>t{glTeesName),'</td>'
	stdout '<td>',(": <. 0.5 + (<t,hole){glTeesYards),'</td>'
	utKeyRead glFilepath,'_tee'
	ww=. (glTeHole=hole) *. glTeTee=t{glTees
	(ww # glTeID) utKeyRead glFilepath,'_tee'
	stdout LT3,'<td>',(2 1 0 1 4{'/',;'2.0' 8!:0 glTePar),'</td>'
	stdout LT3,'<td>',(": glTeAlt),'</td>' NB. Altitude
	for_gender. 0 1 do.
	    if. (gender{,glTeMeasured) do.
		stdout LT3,'<td><a href="/jw/rating/report/',glFilename,'/',(":hole),'/',(": gender),'/',(t{glTees),'" target="_blank" >y</a></td>'
	    else.
		stdout LT3,'<td>-</td>'
	    end.
	end.
	
	stdout LT3,'<td>',(": ;(glGrHole=hole)#glGrRRRoughLength),'</td>'
	stdout '</tr>'
end.
stdout '</tbody></table></div>'
stdout LF,TAB,'<div class="span-24 last">'

stdout LF,'<table>'
stdout LF,'<thead><tr>'
utKeyRead glFilepath,'_tee'
ww=. I. glTeHole = hole
ww=. (+. /"1 ww{glTeMeasured ) # ww{glTeTee NB. Either gender
tees=. (glTees e. ww) # glTees

for_t. tees do.
	stdout '<th>',(>(glTees i. t){glTeesName),'</th>'
end.
stdout '<th colspan=1>Player Shot</th><th>Hit / Layup</th><th>ToGreen</th><th>Edits</th><th>Alt</th><th>F/width</th><th>Bunk in LZ</th><th>Bunk in Line</th><th>Dist OB</th><th>Dist Tr</th><th>Dist Wat</th><th>F/w U/L/D</th><th>F/w So/Av/Fi</th><th>Toplgy</th><th>F/w width</th><th colspan=1>Other</th></tr></thead><tbody>'
NB. Sort the records and re-read
rr=. I. glPlanHole=hole
rr=. rr /: rr { glPlanShot
rr=. rr /: rr { glPlanAbility
rr=. rr /: rr { glPlanGender
rr=. rr /: glTees i. rr { glPlanTee
rr=. rr /: 'CPM' i. rr { glPlanRecType
rr=. (rr { glPlanID) \: rr { glPlanMeasDist
rr utKeyRead glFilepath,'_plan'

NB. Add buttons first
stdout LT3,'<tr>',LT4,'<td colspan="8">'
stdout '<a href="/jw/rating/carry/a/',(glFilename),'/'
stdout ;": 0{glPlanHole
stdout '">Add carry point</a>',EM
stdout '<a href="/jw/rating/squeeze/a/',(glFilename),'/'
stdout ;": 0{glPlanHole
stdout '">Add squeeze/chute</a></td></tr>'

for_rr. i. #glPlanID do.
	if. 'P' = rr{glPlanRecType do.
		stdout '<tr>'
		if. 0 = rr{glPlanRemGroundYards do.
			for_t. tees do.
				stdout '<td>'
				if. (t=rr{glPlanTee) do.
					stdout '<b>Hole</b>'
				end.
				stdout '</td>'
			end.
		else.
			for_t. tees do.
				stdout '<td>'
				holelength=. (<(glTees i. t),hole){glTeesYards
				holelength=. ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
				if. (t=rr{glPlanTee) do.
					stdout '<b>',holelength,'</b>'
				elseif. t_index = 0. do.
					stdout '<i>',holelength,'</i>'
				elseif. 1 do.
				end.
				stdout '</td>'
			end.
		end.
		stdout '<td colspan=1>',((rr{glPlanGender){'MW'),((rr{glPlanAbility){'SB'),'-',(": 1+rr{glPlanShot),({.>(glTees i. rr{glPlanTee){glTeesName),'</td>'
		stdout '<td><a href="/jw/rating/layup/e/',(glFilename),'/'
		stdout ;": 1+rr{glPlanHole
		stdout (;rr{glPlanTee),'/'
		stdout ((rr{glPlanGender){'MW'),((rr{glPlanAbility){'SB'),(": 1+rr{glPlanShot),'">'
		stdout (": rr{glPlanHitYards),' ',(rr{glPlanLayupType),' '
		stdout (('L'=rr{glPlanLayupType)#(3{.": >rr{glPlanLayupCategory)),'</a></td><td>', (": <. 0.5 + rr{glPlanRemGroundYards),'</td>' 
		if. 0<rr{glPlanRemGroundYards do.
		    stdout LT4,'<td><a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">E</a> <a href="/jw/rating/landingcopy/e/',(glFilename),'/',(;rr{glPlanID),'">C</a>'

		    stdout '<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanAlt),'</td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanFWWidth),'</td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLZ){'-y'),'</td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLine){'-y'),'</td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanOOBDist),'</td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanTreeDist),'</td>'
		    NB.	stdout LT3,'<td>',(;(glTreeRecovVal i. rr{glPlanTreeRecov){glTreeRecovDesc),'</td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanLatWaterDist),'</td>'
		    stdout LT3, '<td>', (2{. ":  ,>rr{glPlanRollLevel),'</td>'
		    stdout LT3, '<td>', (2{. ":  ,>rr{glPlanRollFirmness),'</td>'
		    stdout LT3, '<td> </td>'
		    stdout LT3, '<td> </td>'
		    stdout LT3,'<td colspan=1>','','</td>'
		    
		else.
		    stdout LT4,'<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td colspan=3></td>' NB. At green
		end.
		    stdout LT3,'</tr>'

	elseif. 'M' = rr{glPlanRecType do.
		stdout '<tr>'
		if. 0 = rr{glPlanRemGroundYards do.
			for_t. tees do.
				stdout '<td>'
				stdout 'Hole'
				stdout '</td>'
			end.
		else.
			for_t. tees do.
				stdout '<td>'
				holelength=. (<(glTees i. t),hole){glTeesYards
				stdout ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
				stdout '</td>'
			end.
		end.
		stdout '<td colspan="3"><i>Measured Point</i></td>'
		NB. stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		stdout LT4,'<td><a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">E</a> <a href="/jw/rating/landing/d/',glFilename,'/',(;rr{glPlanID),'">D</a>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanAlt),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanFWWidth),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLZ){'-y'),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLine){'-y'),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanOOBDist),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanTreeDist),'</td>'
		NB. stdout LT3,'<td>',(;(glTreeRecovVal i. rr{glPlanTreeRecov){glTreeRecovDesc),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanLatWaterDist),'</td>'
		stdout LT3, '<td>', (2{. ":  ,>rr{glPlanRollLevel),'</td>'
		stdout LT3, '<td>', (2{. ":  ,>rr{glPlanRollFirmness),'</td>'
	        stdout LT3, '<td> </td>'
		stdout LT3, '<td> </td>'
		
		stdout LT3,'<td colspan=1>','','</td>'
	elseif. 'C' = rr{glPlanRecType do.
		stdout '<tr>'
		for_t. tees do.
			stdout '<td>'
			holelength=. (<(glTees i. t),hole){glTeesYards
			stdout ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
			stdout '</td>'
		end.
		stdout '<td colspan="3"><i>Carry : ',(;('FWBR' i. rr{glPlanCarryType){'/' cut 'Fairway/Water/Bunkers/Extreme Rough'),'</i></td>'
		NB. stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		stdout LT4,'<td><a href="/jw/rating/carry/e/',(glFilename),'/',(;rr{glPlanID),'">E</a> <a href="/jw/rating/carry/d/',glFilename,'/',(;rr{glPlanID),'">D</a>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3, '<td colspan=1></td></tr>'
	elseif. 'Q' = rr{glPlanRecType do.
		stdout '<tr>'
		for_t. tees do.
			stdout '<td>'
			holelength=. (<(glTees i. t),hole){glTeesYards
			stdout ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
			stdout '</td>'
		end.
		stdout '<td colspan="3"><i>Squeeze/Chute : ',(;('TWBR' i. rr{glPlanSqueezeType){'/' cut 'Trees/Water/Bunkers/Extreme Rough'),' width=',(": rr{glPlanSqueezeWidth),'</i></td>'
		NB. stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		stdout LT4,'<td><a href="/jw/rating/squeeze/e/',(glFilename),'/',(;rr{glPlanID),'">Ed</a> <a href="/jw/rating/squeeze/d/',glFilename,'/',(;rr{glPlanID),'">Del</a>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3, '<td colspan=1></td></tr>'
	end.
end.

stdout '</tbody></table></div>'
NB. Green Data

stdout LF,'<div class="span-17 last">'
stdout LT1,'<table><thead>'
stdout LT3,'<tr><th>Green</th><th>From tee</th><th>To Front</th><th>GrLength</th><th>GrWidth</th><th>Diam</th><th>Alt</th><th>Stimp</th><th>Visibility</th><th>Obstructed</th><th>Tiered</th><th>Firmness</th><th>Contour</th><th>%Bunk</th><th>%Water</th><th>Dist Water</th><th>Unpleasant</th></tr>'
stdout LT2,'</thead><tbody><tr>'
ww=. ''$glGrHole i. hole
stdout LT4,'<td><a href="/jw/rating/green/e/',glFilename,'/',(>ww{glGrID),'">Edit</a></td>'
stdout LT4,'<td>',(> (glTees i. ww{glGrTee){glTeesName),'</td>'
stdout LT4,'<td>',(": ww{glGrFrontYards),'</td>'
stdout LT4,'<td>',(": ww{glGrLength),'</td>'
stdout LT4,'<td>',(": ww{glGrWidth),'</td>'
stdout LT4,'<td>',(": ww{glGrDiam),'</td>'
stdout LT4,'<td>',(": ww{glGrAlt),'</td>'
stdout LT4,'<td>',(": ww{glGrStimp),'</td>'
stdout LT4,'<td>',(>(glGrVisibilityVal i. ww{glGrVisibility){glGrVisibilityDesc),'</td>'
stdout LT4,'<td>',(>(ww{glGrObstructed){' ' cut '- y'),'</td>'
stdout LT4,'<td>',(>(ww{glGrTiered){' ' cut '- y'),'</td>'
stdout LT4,'<td>',(>(glGrFirmnessVal i. ww{glGrFirmness){glGrFirmnessDesc),'</td>'
stdout LT4,'<td>',(>(glGrContourVal i. ww{glGrContour){glGrContourDesc),'</td>'
stdout LT2,'</tr></tbody></table>'
stdout LF,'</div>' NB. main span
stdout LF,'        '
for_h. i. 18 do.
	if. h=hole do.
		stdout '   ',(": 1+h)
	else.
		stdout '    <a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
	end.
end.
stdout EM,'  <a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'">All</a>'
	
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =======================================================================
NB. BuildMap
NB. -----------------------------------------------------------------------
NB. Builds the script logic for one or more holes
NB.
BuildMap=: 3 : 0
hole=. ,y

stdout LF,'<style>'
stdout LF,'  html, body, #map-canvas {'
stdout LF,'  height: 480px;'
stdout LF,'  width: 640px;'
stdout LF,'  }'
stdout LF,'</style>'
stdout LF,'<script src="https://maps.googleapis.com/maps/api/js?v=3.exp"></script>'
stdout LF,'<script>',LF,'var map;'
NB. Work out map centre from tees and greens
path=. glGPSName i. ('r<0>2.0' 8!:0 (1+hole)),each <'TW'
path=. path, glGPSName i. ('r<0>2.0' 8!:0 (1+hole)),each <'GC'
path=. (path < #glGPSName) # path NB. Remove not found
path=. LatLontoFullOS path { glGPSLatLon
path=. ( +/path ) % #path
path=.;  +. FullOStoLatLon path
ww=. 9!:11 (9) 
stdout LF,'var myCenter=new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),');'
NB. stdout LF,'var myCenter=new google.maps.LatLng(51.5,-0.57);'

stdout LF,'function dyncircle(inner, outer) {'
stdout LF,'   var circ={'
stdout LF,'      path: google.maps.SymbolPath.CIRCLE,'
stdout LF,'      fillColor: inner,'
stdout LF,'      fillOpacity: 1,'
stdout LF,'      scale: 3.5,'
stdout LF,'      strokeColor: outer,'
stdout LF,'      strokeWeight: 3'
stdout LF,'      };'
stdout LF,'   return circ;'
stdout LF,'}'

stdout LF,'function initialize() {'
stdout LF,'   var mapOptions = {'
if. 2 < $hole do.
    stdout LF,'     zoom: 15,'
else.
    stdout LF,'     zoom: 17,' 
end.
stdout LF,'     center: myCenter,'
stdout LF,'     mapTypeId: google.maps.MapTypeId.SATELLITE,'
stdout LF,'     mapTypeControl: false'
stdout LF,'     };'
stdout LF,'  map = new google.maps.Map(document.getElementById(''map-canvas''),mapOptions);'


for_hh. hole do.
    NB. Add the various points here, starting with tees
    NB. Only do the tees if a single hole
    if. 1=#hole do.
	for_t. i.#glTees  do.
		stdout LF,'   var marker',(":hh),'T',(t{glTees),'=new google.maps.Marker({'
		path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'T',t{glTees
		path=. +. path { glGPSLatLon
		stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
		rgb=. t{glTeesRGB
		rgb=. (0{"1 glRGB) i. rgb
		rgb=. >(<rgb,1) { glRGB
		rgb=. '#',rgb
		NB.	stdout LF,'      icon: dyncircle( ''white'', ''white''),'
		stdout LF,'      icon: dyncircle( ''',rgb,''', ''',rgb,'''),'
		stdout LF,'      title: ''Hole ',(":hh+1),' Tee ',(>t{glTeesName),''''
		stdout LF,'      });'
		stdout LF,'   marker',(":hh),'T',(t{glTees),'.setMap(map);'
	end. 
    end.

    NB. Green marker 
    stdout LF,'   var marker',(":hh),'GC=new google.maps.Marker({'
    path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'GC'
    path=. +. path { glGPSLatLon
    stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
    stdout LF,'      icon: "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|FF99CC|8|_|',(":1+hh),'"'
    stdout LF,'      });'
    stdout LF,'   marker',(":hh),'GC.setMap(map);'

    NB. Flightpath
    path=. PathTeeToGreen hh ; 'W'
    stdout LF,'var flightPathCoord',(":hh),' = ['
    for_p. path do.
	    pp=. +. p
	    stdout LF,'   new google.maps.LatLng(', (>'' 8!:0  (0{pp)),', ',(>'' 8!:0 (1{pp)),')'
	    if. p_index < _1 + #path do.
		    stdout ','
	    end.
    end.
    stdout LF,'   ];'
    stdout LF,'var flightPath',(":hh),' = new google.maps.Polyline({'
    stdout LF,'       path: flightPathCoord',(":hh),','
    stdout LF,'       geodesic: true,'
    stdout LF,'       strokeColor: ''#FFFFFF'','
    stdout LF,'       strokeOpacity: 1,'
    stdout LF,'       strokeWeight: 1,'
    stdout LF,'       });'
    stdout LF,'flightPath',(":hh),'.setMap(map);'
end.
    stdout LF,'}'
NB. End of hh loop
    stdout LF,'google.maps.event.addDomListener(window, ''load'', initialize);'
    stdout LF,'</script>'
)
