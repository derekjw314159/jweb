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

stdout 'Content-type: text/html',LF,LF,'<!DOCTYPE html>',LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. stdout LF,'<script>setTimeout(function(){window.location.href=''http://www.google.com''},5000);</script>'

djwBlueprintCSS ''

NB. Add the header stuff for the map
if. showmap do.
    BuildMap (Holes '')
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
stdout LF,TAB,'<div class="span-15">'

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
for_hole. (Holes '') do.
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
for_h. (Holes '') do.
		stdout '    <a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
end.
stdout LF,'<br><a href="/jw/rating/xl/',glFilename,'">XL Macro</a>'
stdout LF,'<br><a href="/pw/rating/report/summary/',glFilename,'/0/',(0{glTees),'">Report Summary</a>'
	
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit 2
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
	CheckMainFile glFilepath
	CheckPlanFile glFilepath,'_plan'  NB. Check for added variables
	err=. ''
else.
	err=. 'No such course'
end.

stdout 'Content-type: text/html',LF,LF,'<!DOCTYPE html>',LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'<link rel="stylesheet" href="/css/rating_plan.css" type="text/css">'

NB. Add the header stuff for the map
if. showmap do.
    BuildMap ,hole
end.

stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container" width="100%">'
NB. Control map display
if. showmap do.
	stdout LT1,'  <div id="map-canvas"></div>'
end.
NB. stdout LF,'<div class="container" width="100%">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print course yardage and measurements
stdout LF,'<h2>Course : ', glCourseName,'</h2><h3>Hole : ',(":1+ ; hole),'</h3>'
stdout LF,'<a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',(showmap#'nomap'),'/v/',glFilename,'/',(": 1+hole),'">',(>showmap{'/' cut 'Show Map/Suppress map'),'</a>'
stdout LF,TAB,'<div class="span-10 last">'

stdout LF,'<table><thead>'
stdout '<tr><th>Tee</th><th>Card</th><th>Par M/W</th><th>Alt</th><th>Mn</th><th>Wn</th><th>Rough Length</th></tr>'
stdout '</thead><tbody>'
utKeyRead glFilepath,'_green'
for_t.  i. #glTees do.
	stdout LF,'<tr><td><a href="/jw/rating/tee/e/',glFilename,'/',(1 1 0 0 1#5{.>EnKey hole ; '' ; (t{glTees) ; 0 ; 0 ; 0),'">',(>t{glTeesName),'</td>'
	backpath=. PathTeeToGreen hole ; t{glTees
	crow=. <. 0.5 + glMY * |-/LatLontoFullOS 0 _1{backpath NB. Crows flight distance
	stdout '<td>',(": <. 0.5 + (<t,hole){glTeesYards),' <span style="color: gray;">[',(":crow),']</span></td>'
	utKeyRead glFilepath,'_tee'
	ww=. (glTeHole=hole) *. glTeTee=t{glTees
	(ww # glTeID) utKeyRead glFilepath,'_tee'
	stdout LT3,'<td>',(2 1 0 1 4{'/',;'2.0' 8!:0 glTePar),'</td>'
	stdout LT3,'<td>',(;'b<.>' 8!:0  glTeAlt),'</td>' NB. Altitude
	for_gender. 0 1 do.
	    if. (gender{,glTeMeasured) do.
		stdout LT3,'<td><a href="/jw/rating/report/',glFilename,'/',(":hole),'/',(": gender),'/',(t{glTees),'" target="_blank" >y</a></td>'
	    else.
		stdout LT3,'<td>-</td>'
	    end.
	end.
e	
	stdout LT3,'<td>',(": ;(glGrHole=hole)#glGrRRRoughLength),'</td>'
	stdout '</tr>'
end.
stdout '</tbody></table></div>'
stdout LF,TAB,'<div class="span-24 last">'

stdout LF,'<table class="tableplan">'
stdout LF,'<thead><tr>'
utKeyRead glFilepath,'_tee' NB. Just read for this hole
ww=. I. glTeHole = hole
ww=. (+. /"1 ww{glTeMeasured ) # ww{glTeTee NB. Either gender
tees=. (glTees e. ww) # glTees

NB. Store path for back tee in order to show crow's flight
backpath=. PathTeeToGreen hole ; 0{tees
backstart=. 0{backpath

for_t. tees do.
	stdout '<th>',(>(glTees i. t){glTeesName),'</th>'
end.
NB. Pad to five columns for a maximum of five tees
for. (i. 0 >. 5-#tees) do.
	stdout '<th class="zz"></th>'
end.
stdout '<th>Player Shot</th><th>Hit / Layup</th><th>To Green</th><th>Edit Copy</th><th>Alt</th><th>F/width</th><th>Bunk LZ</th><th>Bunk LoP</th><th>Dist OB</th><th>OOB %age</th><th>OOB LoP</th><th>Dist Tr</th><th>Dist Wat</th><th>Wat LoP</th><th>Roll U/L/D</th><th>Mi/Mo /Sig</th><th>MP/MA SA/EA</th><th>F/w +/-W</th><th colspan="3">Other Variables</th></tr></thead><tbody>'
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
stdout LT3,'<tr>',LT4,'<td data-tee="Carry Points" colspan="8">'
stdout '<a href="/jw/rating/carry/a/',(glFilename),'/'
stdout ;": 0{glPlanHole
stdout '">Add carry point</a>',EM
stdout '<a href="/jw/rating/squeeze/a/',(glFilename),'/'
stdout ;": 0{glPlanHole
stdout '">Add chute</a></td></tr>'

for_rr. i. #glPlanID do.
	if. 'P' = rr{glPlanRecType do.
		rgb=. (glTees i. rr{glPlanTee){glTeesRGB
		rgb=. (0{"1 glRGB) i. rgb
		rgb=. >(<rgb,1) { glRGB
		rgb=. '#',rgb
		stdout '<tr>'
		if. 0 = rr{glPlanRemGroundYards do.
			for_t. tees do.
				tdtext=.'<td style="background-color:',rgb,';" data-tee','="',(>(glTees i. t){glTeesName),'">'
				if. (t=rr{glPlanTee) do.
					stdout tdtext,'<b>Hole</b>'
				else.
					stdout '<td style="padding: 0px; border: 0px; border-collapse: collapse;">'
				end.
				stdout '</td>'
			end.
			for. (i. 0 >. 5-#tees) do.
				stdout '<td class="zz"></td>'
			end.
		else.
			for_t. tees do. NB. Write out the distances and crow's flight distance
				tdtext=.'<td style="background-color:',rgb,';" data-tee','="',(>(glTees i. t){glTeesName),'">'
				holelength=. (<(glTees i. t),hole){glTeesYards
				holelength=. <. 0.5+ holelength - (rr{glPlanMeasDist) 
				ww=. InterceptPath backpath ; backstart ; holelength
				ww=. <. 0.5 + glMY * |-/LatLontoFullOS backstart, 0{ww
				if. holelength ~: ww do.
					ww=. ' <span style="color: gray">[',(":ww),']</span>'
				else.
					ww=. ''
				end.
				holelength=. ":holelength
				
				if. (t=rr{glPlanTee) *. (0=t_index) do.
					stdout tdtext,'<b>',holelength,ww,'</b>'
				elseif. (t=rr{glPlanTee) do.
					stdout tdtext,'<b>',holelength,'</b>'
				elseif. t_index = 0. do.
					stdout tdtext,'<i>',holelength,ww,'</i>'
				elseif. 1 do.
					stdout '<td style="padding: 0px; border: 0px; border-collapse: collapse;">'
				end.
				stdout '</td>'
			end.
			for. (i. 0 >. 5-#tees) do.
				stdout '<td class="zz"></td>'
			end.
		end.
		stdout 'Player Shot' djwTDClass ((rr{glPlanGender){'MW'),({.>(glTees i. rr{glPlanTee){glTeesName),'-',((rr{glPlanAbility){'SB'),(": 1+rr{glPlanShot)
NB.stdout '<td>',((rr{glPlanGender){'MW'),((rr{glPlanAbility){'SB'),'-',(": 1+rr{glPlanShot),({.>(glTees i. rr{glPlanTee){glTeesName),'</td>'
		str=. '<a href="/jw/rating/layup/e/',(glFilename),'/'
		str=. str, ;": 1+rr{glPlanHole
		str=. str, (;rr{glPlanTee),'/'
		str=. str, ((rr{glPlanGender){'MW'),((rr{glPlanAbility){'SB'),(": 1+rr{glPlanShot),'">'
		str=. str, (": rr{glPlanHitYards),( rr{glPlanHitYards ~: glPlanCrowDist)#' <span style="color: gray">[',(": rr{glPlanCrowDist),']</span>'
		str=. str, (rr{glPlanLayupType)
		str=. str, (('L'=rr{glPlanLayupType)#(3{.": >rr{glPlanLayupCategory)),'</a>'
		stdout LT4, 'Hit' djwTDClass str
		stdout LT4, 'To Green' djwTDClass  (": <. 0.5 + rr{glPlanRemGroundYards)
		if. 0<rr{glPlanRemGroundYards do.
		    other=. ''
		    other=. other, (0<#>rr{glPlanBunkExtreme)#' BuEx:',>rr{glPlanBunkExtreme
		    other=. other, (0 ~: rr{glPlanDoglegNeg)#' D/LNeg:',": |rr{glPlanDoglegNeg
		    other=. other, (0<#>rr{glPlanRollExtreme)#' RoEx:',;>rr{glPlanRollExtreme
		    other=. other, (0<#>rr{glPlanRollTwice)#' Ro2:',;>rr{glPlanRollTwice
		    other=. other, (rr{glPlanFWVisible)#' LZ:V'
		    other=. other, (rr{glPlanFWUnpleasant)#' FW:U'
		    other=. other, (rr{glPlanFWObstructed)#' FW:O'
		    other=. other, (rr{glPlanTreeTargObstructed)#' Targ:TreeObs'
		    other=. other, (rr{glPlanTreeLZObstructed)#' LZ:TreeObs'
		    other=. other, (rr{glPlanBunkLZCarry)#' LZ:BunkCarry'
		    other=. other, (rr{glPlanBunkTargCarry)#' Targ:BunkCarry'
		    other=. other, (0<#>rr{glPlanFWTargVisible)#' Targ:',;>rr{glPlanFWTargVisible
		    other=. other, (rr{glPlanRRMounds)#' RR:M'
		    other=. other, (0<#>rr{glPlanWaterPercent)#' Wat%:',;>rr{glPlanWaterPercent
		    other=. other, (0<#>rr{glPlanBunkSqueeze)#' BuSq:',;>rr{glPlanBunkSqueeze
		    other=. other, (0<#>rr{glPlanTransitionOverride)#' Tran O/R:',;>rr{glPlanTransitionOverride
		    other=. other, (0<#>rr{glPlanTransitionAdj)#' Tran Adj:',;>rr{glPlanTransitionAdj
		    NB. Edit / Copy links
		    str=. '<a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">E</a>'
		    str=. str,' <a href="/jw/rating/landingcopy/e/',(glFilename),'/',(;rr{glPlanID),'">C</a>'
		    str=. str,' <a href="/jw/rating/landingcopyshot/e/',(glFilename),'/',(;rr{glPlanID),'">X</a>'
		    stdout LT4,'Edit / Copy / Xcopy' djwTDClass str 
		    stdout LT4, 'Altitude' djwTDClass ;'b<.>' 8!:0 rr{glPlanAlt
		    stdout LT4, 'FW Width' djwTDClass ;'b<.>' 8!:0 rr{glPlanFWWidth
		    stdout LT4, 'Bunker in LZ' djwTDClass (rr{glPlanBunkLZ){'-y'
		    stdout LT4, 'Bunker in LoP' djwTDClass (rr{glPlanBunkLine){'-y'
		    stdout LT4, 'OOB Distance' djwTDClass ;'b<.>' 8!:0 rr{glPlanOOBDist
		    stdout LT4, 'OOB %age red' djwTDClass >rr{glPlanOOBPercent
		    stdout LT4, 'OOB on LoP' djwTDClass (rr{glPlanOOBLine){'-y'
		    stdout LT4, 'Tree Distance' djwTDClass ;'b<.>' 8!:0 rr{glPlanTreeDist
		    stdout LT4, '<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanLatWaterDist),'</td>'
		    stdout LT4, '<td style="border-right: 1px solid lightgray">',((rr{glPlanWaterLine){'-y'),'</td>'
		    stdout LT4, '<td style="border-right: 1px solid lightgray">', (2{. ":  ,>rr{glPlanRollLevel),'</td>'
		    stdout LT4, '<td style="border-right: 1px solid lightgray">', (3{. ":  ,>rr{glPlanRollSlope),'</td>'
		    stdout LT4, '<td style="border-right: 1px solid lightgray">', (,>rr{glPlanTopogStance),'</td>'
		    stdout LT4, '<td style="border-right: 1px solid lightgray">', (6{. ":  ,>rr{glPlanFWWidthAdj),'</td>'
		    stdout LT4,'<td colspan="3">',(}.other),'</td>'
		    
		else. NB. Truncated row when at hole
		    other=. ''
		    other=. other, (0<#>rr{glPlanBunkExtreme)#' BuEx:',>rr{glPlanBunkExtreme
		    other=. other, (0 ~: rr{glPlanDoglegNeg)#' D/LNeg:',": |rr{glPlanDoglegNeg
		    other=. other, (rr{glPlanFWVisible)#' LZ:V'
		    other=. other, (rr{glPlanFWObstructed)#' FW:O'
		    other=. other, (rr{glPlanTreeTargObstructed)#' Targ:TreeObs'
		    other=. other, (rr{glPlanTreeLZObstructed)#' LZ:TreeObs'
		    other=. other, (rr{glPlanBunkLZCarry)#' LZ:BunkCarry'
		    other=. other, (rr{glPlanBunkTargCarry)#' Targ:BunkCarry'
		    other=. other, (0<#>rr{glPlanRollTwice)#' Ro2:',;>rr{glPlanRollTwice
		    other=. other, (0<#>rr{glPlanTransitionOverride)#' Tran O/R:',;>rr{glPlanTransitionOverride
		    other=. other, (0<#>rr{glPlanTransitionAdj)#' Tran Adj:',;>rr{glPlanTransitionAdj
		    stdout LT4,'<td><a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">E</a>'
		    stdout LT4,'<td></td><td></td><td></td>'
		    stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLine){'-y'),'</td>' NB. Show bunker in LoP
			stdout '<td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td><td></td>' NB. At green
		    stdout LT4,'<td colspan="3">',(}.other),'</td>'
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
			for. (i. 0 >. 5-#tees) do.
				stdout '<td class="zz"></td>'
			end.
		else.
			for_t. tees do.
				stdout '<td>'
				holelength=. (<(glTees i. t),hole){glTeesYards
				stdout ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
				stdout '</td>'
			end.
			for. (i. 0 >. 5-#tees) do.
				stdout '<td class="zz"></td>'
			end.
		end.
		stdout '<td colspan="3"><i>Measured Point</i></td>'
		NB. stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		other=. ''
		other=. other, (0 ~: rr{glPlanDoglegNeg)#' D/LNeg:',": |rr{glPlanDoglegNeg
		other=. other, (0<#>rr{glPlanRollExtreme)#' RoEx:',;>rr{glPlanRollExtreme
		other=. other, (0<#>rr{glPlanRollTwice)#' Ro2:',;>rr{glPlanRollTwice
		other=. other, (rr{glPlanFWVisible)#' LZ:V'
		other=. other, (rr{glPlanFWUnpleasant)#' FW:U'
		other=. other, (rr{glPlanFWObstructed)#' FW:O'
		other=. other, (rr{glPlanBunkLZCarry)#' LZ:BunkCarry'
		other=. other, (rr{glPlanBunkTargCarry)#' Targ:BunkCarry'
		other=. other, (rr{glPlanTreeTargObstructed)#' Targ:TreeObs'
		other=. other, (rr{glPlanTreeLZObstructed)#' LZ:TreeObs'
		other=. other, (0<#>rr{glPlanFWTargVisible)#' Targ:',;>rr{glPlanFWTargVisible
		other=. other, (rr{glPlanRRMounds)#' RR:M'
		other=. other, (0<#>rr{glPlanWaterPercent)#' Wat%:',;>rr{glPlanWaterPercent
		other=. other, (0<#>rr{glPlanBunkSqueeze)#' BuSq:',;>rr{glPlanBunkSqueeze
		other=. other, (0<#>rr{glPlanTransitionOverride)#' Tran O/R:',;>rr{glPlanTransitionOverride
		other=. other, (0<#>rr{glPlanTransitionAdj)#' Tran Adj:',;>rr{glPlanTransitionAdj
		stdout LT4,'<td><a href="/jw/rating/landing/e/',(glFilename),'/',(;rr{glPlanID),'">E</a> <a href="/jw/rating/landing/d/',glFilename,'/',(;rr{glPlanID),'">D</a>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanAlt),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanFWWidth),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLZ){'-y'),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanBunkLine){'-y'),'</td>'
	    stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanOOBDist),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(>rr{glPlanOOBPercent),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',((rr{glPlanOOBLine){'-y'),'</td>'
		stdout LT3,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanTreeDist),'</td>'
		NB. stdout LT3,'<td>',(;(glTreeRecovVal i. rr{glPlanTreeRecov){glTreeRecovDesc),'</td>'
		stdout LT3, '<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 rr{glPlanLatWaterDist),'</td>'
	    stdout LT3, '<td style="border-right: 1px solid lightgray">',((rr{glPlanWaterLine){'-y'),'</td>'
		stdout LT3, '<td style="border-right: 1px solid lightgray">', (2{. ":  ,>rr{glPlanRollLevel),'</td>'
		stdout LT3, '<td style="border-right: 1px solid lightgray">', (3{. ":  ,>rr{glPlanRollSlope),'</td>'
		stdout LT3, '<td style="border-right: 1px solid lightgray">', (,>rr{glPlanTopogStance),'</td>'
		stdout LT3, '<td style="border-right: 1px solid lightgray">', (6{. ":  ,>rr{glPlanFWWidthAdj),'</td>'
		stdout LT3,'<td colspan=3>',(}.other),'</td>'

	elseif. 'C' = rr{glPlanRecType do.
		stdout '<tr>'
		for_t. tees do.
			tdtext=.'<td data-tee','="',(>(glTees i. t){glTeesName),'">'
			holelength=. (<(glTees i. t),hole){glTeesYards
			stdout tdtext,": <. 0.5+ holelength - (rr{glPlanMeasDist) 
			stdout '</td>'
		end.
		for. (i. 0 >. 5-#tees) do.
			stdout '<td class="zz"></td>'
		end.
		str=. '<i>Carry : ',(;('FWBR' i. rr{glPlanCarryType){'/' cut 'Fairway/Water/Bunkers/Extreme Rough')
		affects=. ''$rr{glPlanCarryAffectsTee
		if. (' ' ~: affects) do.
			str=. str, ' [',(>(glTees i. affects){glTeesName),']'
		end.
		str=. str, '</i>'
		stdout LT3, ('Carry point'; 'colspan="3"') djwTDClass str
		NB. stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		stdout LT4,'Edit / Delete' djwTDClass '<a href="/jw/rating/carry/e/',(glFilename),'/',(;rr{glPlanID),'">E</a> <a href="/jw/rating/carry/d/',glFilename,'/',(;rr{glPlanID),'">D</a>'
		for. i. 12 do.
			stdout LT3,djwTDClass ''
		end.
		stdout LT3, '<td class="zzempty" colspan=3></td></tr>'
	elseif. 'Q' = rr{glPlanRecType do.
		stdout '<tr>'
		for_t. tees do.
			stdout '<td>'
			holelength=. (<(glTees i. t),hole){glTeesYards
			stdout ": <. 0.5+ holelength - (rr{glPlanMeasDist) 
			stdout '</td>'
		end.
		for. (i. 0 >. 5-#tees) do.
			stdout '<td class="zz"></td>'
		end.
		stdout '<td colspan="3"><i>Squeeze/Chute : ',(;('TWBR' i. rr{glPlanSqueezeType){'/' cut 'Trees/Water/Bunkers/Extreme Rough'),' width=',(": rr{glPlanSqueezeWidth),'</i></td>'
		NB. stdout LT3,'<td>',(": rr{glPlanRemGroundYards),'</td>'
		stdout LT4,'<td><a href="/jw/rating/squeeze/e/',(glFilename),'/',(;rr{glPlanID),'">E</a> <a href="/jw/rating/squeeze/d/',glFilename,'/',(;rr{glPlanID),'">D</a>'
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
		stdout LT3,'<td></td>'
		stdout LT3,'<td></td>'
		stdout LT3, '<td colspan=3></td></tr>'
	end.
end.

stdout '</tbody></table></div>'
NB. Green Data

stdout LF,'<div class="span-24 last">'
stdout LT1,'<table><thead>'
stdout LT3,'<tr><th>Green</th><th>From tee</th><th>To Front</th><th>Alt</th><th>Wid</th><th>Len</th><th>Diam</th><th>Tier</th><th>Firm</th><th>Contour</th><th>Stimp</th><th>Mounds</th><th>Bunk Frac</th><th>Bunk Dep</th><th>OOB Dist</th><th>Water Dist</th><th>Water Frac</th><th>Water SurrDist</th><th colspan="5">Other Variables</th></tr>'
stdout LT2,'</thead><tbody><tr>'
ww=. ''$glGrHole i. hole
other=. ''
other=. other, (ww{glGrSurfaceUnpleasant)#' Surf:U'
other=. other, (0<#>ww{glGrRRInconsistent)#' Inc:',>ww{glGrRRInconsistent
other=. other, (0<#>ww{glGrRRRiseDrop)#' R/D:',>ww{glGrRRRiseDrop
other=. other, (ww{glGrRRUnpleasant)#' RR:U'
other=. other, (0<#>ww{glGrBunkExtreme)#' BuEx:',>ww{glGrBunkExtreme
other=. other, (0<#>ww{glGrOOBBehind)#' OOB:Behind',>ww{glGrOOBBehind
other=. other, (0<#>ww{glGrOOBCart)#' OOBCart:',>ww{glGrOOBCart
other=. other, (0<#>ww{glGrOOBPercent)#' OOB%:',>ww{glGrOOBPercent
other=. other, (0<#>ww{glGrWaterBehind)#' Wat:Behind',>ww{glGrWaterBehind
other=. other, (0<#>ww{glGrWaterCart)#' WatCart:',>ww{glGrWaterCart
other=. other, (0<#>ww{glGrWaterPercent)#' Wat%:',>ww{glGrWaterPercent
stdout LT4,'<td><a href="/jw/rating/green/e/',glFilename,'/',(>ww{glGrID),'">Edit</a></td>'
stdout LT4,'<td>',(> (glTees i. ww{glGrTee){glTeesName),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrFrontYards),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrAlt),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrWidth),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrLength),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrDiam),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>(ww{glGrTiered){' ' cut '. y'),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>ww{glGrFirmness),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>ww{glGrContour),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrStimp),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>(ww{glGrRRMounds){' ' cut '. y'),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>ww{glGrBunkFraction),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>ww{glGrBunkDepth),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrOOBDist),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(;'b<.>' 8!:0 ww{glGrWaterDist),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>ww{glGrWaterFraction),'</td>'
stdout LT4,'<td style="border-right: 1px solid lightgray">',(>ww{glGrWaterSurrDist),'</td>'
stdout LT4,'<td colspan="5">',(}.other),'</td>'
stdout LT2,'</tr></tbody></table>'
stdout LF,'</div>' NB. main span

NB. Tree variables
utKeyRead glFilepath,'_tee' NB. Just read for this hole
((hole=glTeHole)#glTeID) utKeyRead glFilepath,'_tee' NB. Just read for this hole
head=. ''
row=. ''
for_t. glTeTee do.
    for_g. i. 2 do.
		if. (<t_index,g){glTeMeasured do.
			for_ab. i. 2 do.
				head=. head,'<th style="border-right: 1px solid lightgray">',(>(glTees i. t){glTeesName),' ',(>g{' ' cut 'Men Women'),' ',(>ab{' 'cut 'Scr Bgy'),'</th>'
				row=. row,'<td style="border-right: 1px solid lightgray">',(>(<t_index,g,ab){glTeTree),'</td>'
			end.

		end.
    end.
end.
stdout LF,'<div class="span-24">'
stdout LT1,'<h4>Tree Difficulty</h4>'
stdout LT2,'<table><thead>'
stdout LT3,'<tr>'
stdout LT4,head
stdout LT3,'</tr></thead><tbody>'
stdout LT3,'<tr>'
stdout LT4,row
stdout LT3,'</tr></tbody></table>'
NB. Notes field
stdout LT2,'Notes:',EM,;ww{glGrNotes
stdout LF,'</div>' NB. main span

if. hole>0{Holes '' do.
	stdout ' <a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": hole),'">&lt;&lt;</a>'
end.
for_h. (Holes '') do.
	if. h=hole do.
		stdout ' ',(": 1+h)
	else.
		stdout ' <a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
	end.
end.
if. hole<_1{Holes '' do.
	stdout ' <a href="http://',(": ,getenv 'SERVER_NAME'),'/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'/',(": 2+hole),'">&gt;&gt;</a>'
end.
stdout ' <a href="/jw/rating/plan',((-. showmap)#'nomap'),'/v/',glFilename,'">All</a>'
	
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
NB. stdout LF,'  html, body, #map-canvas {'
stdout LF,'  #map-canvas {'
stdout LF,'  height: 480px;'
stdout LF,'  width: 640px;'
stdout LF,'  float: left;'
stdout LF,'  margin-right: 5px;'
stdout LF,'  margin-bottom: 5px;'
stdout LF,'  }'
stdout LF,'</style>'
stdout LF,'<script src="https://maps.googleapis.com/maps/api/js?key=AIzaSyAenjNEmfxxMDt3XnAXyY6jXwVgYmC5wjc&v=3.exp"></script>'
stdout LF,'<script src="/javascript/myLatLon.js"></script>'
stdout LF,'<script>',LF,'var map;'
NB. Work out map centre from tees and greens
path=. glGPSName i. ('r<0>2.0' 8!:0 (1+hole)),each <'TW'
path=. path, glGPSName i. ('r<0>2.0' 8!:0 (1+hole)),each <'GC'
path=. (path < #glGPSName) # path NB. Remove not found
path=. LatLontoFullOS path { glGPSLatLon
path=. ( +/path ) % #path
path=.;  +. FullOStoLatLon path
ww=. 9!:11 (9)  NB. Print precision
stdout LF,'var myCenter=new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),');'
stdout LF,'oldclick=[91,181];  // Global variable with impossible Lat, Lon'
stdout LF,'newclick=[91,181];'
NB. stdout LF,'var myCenter=new google.maps.LatLng(51.5,-0.57);'

stdout LF,'function dyncircle(inner, outer) {'
stdout LF,'   var circ={'
stdout LF,'      path: google.maps.SymbolPath.CIRCLE,'
stdout LF,'      fillColor: inner,'
stdout LF,'      fillOpacity: 1,'
stdout LF,'      scale: 4.5,'
stdout LF,'      strokeColor: outer,'
stdout LF,'      strokeWeight: 2.5'
stdout LF,'      };'
stdout LF,'   return circ;'
stdout LF,'   }'

stdout LF,'function initialize() {'
stdout LF,'   var mapOptions = {'
if. 2 < $hole do.
    stdout LF,'     zoom: 15,'
else.
    stdout LF,'     zoom: 17,' 
end.
stdout LF,'     center: myCenter,'
stdout LF,'     mapTypeId: google.maps.MapTypeId.SATELLITE,'
NB. stdout LF,'     mapTypeControl: false'
stdout LF,'     };'
stdout LF,'  map = new google.maps.Map(document.getElementById(''map-canvas''),mapOptions);'
NB. Add listener for elevation within the initialise function
stdout LF,'  var elevator = new google.maps.ElevationService;'
stdout LF,'  // Click and infowindow setup'
stdout LF,'  var infowindow = new google.maps.InfoWindow ( {map: map} );'
stdout LF,'  map.addListener(''click'', function(event) {'
stdout LF,'      oldclick = newclick.slice();'
stdout LF,'      newclick[0] = event.latLng.lat();'
stdout LF,'      newclick[1] = event.latLng.lng();'
stdout LF,'      displayLocationElevation(event.latLng, elevator, infowindow);'
stdout LF,'      });'
NB. Loop round the points for this hold
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

    NB. Landing points
    utKeyRead glFilepath,'_plan'
    ww=. glPlanHole =hh
    ww=. ww *. glPlanRecType = 'P'
    ww=. ww *. glPlanRemGroundYards > 0
    ww=. ww * 1=#hole NB. Do show for multiple holes
    for_rr. I. ww do.
		stdout LF,'   var marker',((>rr{glPlanID)-.'-'),'=new google.maps.Marker({'
		path=. +. rr { glPlanLatLon
		stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
		outer=. rr { (2 * glPlanGender) + glPlanAbility
		outer=. >outer { ' ' cut 'black blue brown grey'
		rgb=. (glTees i. rr { glPlanTee){glTeesRGB
		rgb=. (0{"1 glRGB) i. rgb
		rgb=. >(<rgb,1) { glRGB
		rgb=. '#',rgb
		NB.	stdout LF,'      icon: dyncircle( ''white'', ''white''),'
		stdout LF,'      icon: dyncircle( ''',rgb,''', ''',outer,'''),'
		stdout LF,'      title: ''',(>(rr{glPlanGender){' ' cut 'Men Wmn'),' ',(>(glTees i. rr{glPlanTee){glTeesName),' ',(>(rr{glPlanAbility){' ' cut 'Scr Bgy'),' shot ',(": 1+rr{glPlanShot),''''
		stdout LF,'      });'
		stdout LF,'   marker',((>rr{glPlanID)-.'-'),'.setMap(map);'
    end.
	
    NB. Green marker 
    stdout LF,'   var marker',(":hh),'GC=new google.maps.Marker({'
    rr=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'GC'
    rr=. +. rr { glGPSLatLon
    stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{rr)),',',(>'' 8!:0 (1{rr)),'),'
    stdout LF,'      icon: "http://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|FF99CC|8|_|',(":1+hh),'"'
    stdout LF,'      });'
    stdout LF,'   marker',(":hh),'GC.setMap(map);'

	NB. Flightpath
	NB. Loop round each tee to draw the "crow's feet"
	path=. 0$0
	for_t. }. glTees do. NB. All bar first tee
		path=. path, 1 0 1{ PathTeeToGreen hh ; t
	end.
	path=. path, PathTeeToGreen hh ; 0{glTees
    stdout LF,'   var flightPathCoord',(":hh),' = ['
    for_p. path do.
	    pp=. +. p
	    stdout LF,'      new google.maps.LatLng(', (>'' 8!:0  (0{pp)),', ',(>'' 8!:0 (1{pp)),')'
	    if. p_index < _1 + #path do.
		    stdout ','
	    end.
    end.
	NB. Reset path
	path=. PathTeeToGreen hh ; 0{glTees

    stdout LF,'      ];'
    stdout LF,'   var flightPath',(":hh),' = new google.maps.Polyline({'
    stdout LF,'       path: flightPathCoord',(":hh),','
    stdout LF,'       geodesic: true,'
    stdout LF,'       strokeColor: ''#FFFFFF'','
    stdout LF,'       strokeOpacity: 1,'
    stdout LF,'       strokeWeight: 1,'
    stdout LF,'       });'
    stdout LF,'   flightPath',(":hh),'.setMap(map);'

	NB. Actual trail points
    stdout LF,'   var flightPathTrail',(":hh),' = ',(ReadGPSActual ''),';'
    stdout LF,'   var flightPathActual',(":hh),' = new google.maps.Polyline({'
    stdout LF,'       path: flightPathTrail',(":hh),','
    stdout LF,'       geodesic: true,'
    stdout LF,'       strokeColor: ''pink'','
    stdout LF,'       strokeOpacity: 1,'
    stdout LF,'       strokeWeight: 1,'
    stdout LF,'       });'
    stdout LF,'   flightPathActual',(":hh),'.setMap(map);'

    NB. Carry Point .. draw perpendicular line
    ww=. glPlanHole = hh
    ww=. ww *. glPlanRecType e. 'QC' NB. Carry or chute
    ww=. ww *. glPlanRemGroundYards > 0
    ww=. ww * 1=#hole NB. Do show for multiple holes
    for_rr. I. ww do.
	radius=. (<0,hh){glTeesYards
	radius=. radius - rr{glPlanRemGroundYards
	ww=. InterceptPath path ; (0{path) ; radius
	latlon=. LatLontoFullOS 0{ww
	width=. 0.5 * ('Q'=rr{glPlanRecType){ 40, rr{glPlanSqueezeWidth
	latlon=. latlon + _1 1 * ( width % glMY) * 0j1 * 2{ww NB. Multiply by 0j1 rotates vector by 90 degrees.  25 yards either side
	latlon=. FullOStoLatLon latlon
	stdout LF,'   var flightPathCoordCarry',(":rr_index),' = ['
	pp=. +. 0{latlon
	stdout LF,'      new google.maps.LatLng(', (>'' 8!:0  (0{pp)),', ',(>'' 8!:0 (1{pp)),'),'
	pp=. +. 1{latlon
	stdout LF,'      new google.maps.LatLng(', (>'' 8!:0  (0{pp)),', ',(>'' 8!:0 (1{pp)),'),'
	stdout LF,'      ];'
	stdout LF,'   var flightPathCarry',(":rr_index),' = new google.maps.Polyline({'
	stdout LF,'          path: flightPathCoordCarry',(":rr_index),','
	stdout LF,'          geodesic: true,'
	rgb=. 'FWBR' i. rr{glPlanCarryType
	rgb=. >rgb { ' ' cut '#007F00 #3333FF gold white pink'
	stdout LF,'          strokeColor: ''',(rgb),''',' NB. Colour based on carry
	stdout LF,'          strokeOpacity: 1,'
	weight=. ('Q'=rr{glPlanRecType) { 1.5 2.5
	stdout LF,'          strokeWeight: ',(":weight),','
	stdout LF,'          });'
	stdout LF,'   flightPathCarry',(":rr_index),'.setMap(map);'
    end.
end.
stdout LF,'   }'
NB. Add display for elevator outside the initalize loop
stdout LF,'// Listener to show elevation'
stdout LF,'function displayLocationElevation(location, elevator, infowindow) {'
stdout LF,'    elevator.getElevationForLocations({'
stdout LF,'	''locations'': [location]'
stdout LF,'	}, function(results, status ) {'
stdout LF,'	    infowindow.setPosition(location);'
stdout LF,'	    var content = ''Elevation = '' + Math.round(3.28084 * results[0].elevation) + ''ft'';'
stdout LF,'         content = content + ''<br>Lat-Lon = ('' + newclick[0].toFixed(4);'
stdout LF,'         content = content +  '', '' + newclick[1].toFixed(4) + '')'';'
stdout LF,'         if (oldclick[0] <= 90) { // Only call this if second click or later'
stdout LF,'            var dist = getDistance(newclick, oldclick);'
stdout LF,'            content = content + ''<br>Distance from last click = '' + dist.toFixed(0) + ''yds'';'
stdout LF,'            }'
stdout LF,'         infowindow.setContent(content);'
stdout LF,'	    })'
stdout LF,'	};'

NB.    stdout LF,'}'
NB. End of hh loop
    stdout LF,'google.maps.event.addDomListener(window, ''load'', initialize);'
    stdout LF,'</script>'
)

NB. ==========================================================================
NB. djwTDclass
NB. --------------------------------------------------------------------------
djwTDClass=: 3 : 0
NB. Output class information with row "::before" format
'' djwTDClass y
:
if. 32 ~: 3!:0 x do. x=. <x end.
x=. 2{. ,x
if. 2 ~: 3!:0 y do. y=. ": y end. NB. Numeric
if. 32 = 3!:0 y do. y=. ; ": each y end. NB. boxed
y=. ,y
null=. 0
select. y
	case. ,'' do. null=. 1 
	case. ,'.' do. null=. 1
	case. ,'.' do. null=. 1
	case. ,'-' do. null=. 1
end.
res=. '<td'
res=. res,null#' class="zzempty"'
res=. res,(0<#>0{x)#' data-tee="',(>0{x),'"'
res=. res,(0<#>1{x)#' ',>1{x
res=. res,'>',y,'</td>'
)
