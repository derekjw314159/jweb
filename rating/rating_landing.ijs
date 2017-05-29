NB. J Utilities for recording data at landing zones
NB. 

NB. =========================================================
NB. rating_landing_e
NB. =========================================================
NB. View scores for participant
jweb_rating_landing_e=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
if. -. keyy e. keydir (glFilepath,'_plan') do.
    djwErrorPage err ; ('No such measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Read the single record
keyy utKeyRead glFilepath,'_plan'

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Landing Zone Measurements</h2>'

NB. Work out the back tee
ww=. I. glTeHole = ''$glPlanHole
ww=. ww /: glTees i. ww{glTeTee
ww=.  +. /"1  ww { glTeMeasured NB. If either measured - don't need to split by gender
backtee=. ''${. ww # glTees

if. 'P'=glPlanRecType do.
	NB. Print the table of parameters
	stdout LF,'<div class="span-8 append-1">'
	stdout LF,'<table><thead><tr><th>Landing Zone</th><th>Value</th></tr></thead><tbody>'

	stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glPlanHole),'</td></tr>'
	stdout LF,'<tr><td>Hit distance:</td><td>',(": ; glPlanHitYards),'</td></tr>'

	for_t. (glTees) do.
		if. (t=glPlanTee)  do.
			stdout LT3,'<tr>',LT4,'<td><b>Distance from : ',>t_index { glTeesName
			stdout '</b></td>'
			holelength=. (<t_index,glPlanHole){glTeesYards
			cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
			stdout '<td>',(":,cumyards),'</td></tr>'
		NB. Backtee different from tee in question
		elseif. (t=backtee) do.
			stdout LT3,'<tr>',LT4,'<td><i>Distance from : ',>t_index { glTeesName
			stdout '</i></td>'
			holelength=. (<t_index,glPlanHole){glTeesYards
			cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
			stdout '<td>',(":,cumyards),'</td></tr>'
		end.
	end.
	stdout LF,'<tr><td>Player:</td><td>',(>glPlanGender{' ' cut 'Man Lady ')
	stdout ' ',(>glPlanAbility{' ' cut 'Scratch Bogey')
	stdout LF,'</td></tr>'
	stdout LT4,'<tr><td>Shot:</td><td>',(":1+glPlanShot),'</td></tr>'
	stdout LT2,'</tbody></table></div>'
elseif. 'M'=glPlanRecType do.
	stdout LF,'<div class="span-8 last">'
	stdout LF,'<table><thead><tr><th>Measurement Point</th><th>Value</th></tr></thead><tbody>'

	stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glPlanHole),'</td></tr>'

	for_t. (glTees) do.
			stdout LT3,'<tr>',LT4,'<td>Distance from : ',>t_index { glTeesName
			stdout '</td>'
			holelength=. (<t_index,glPlanHole){glTeesYards
			cumyards=.  <. 0.5+ holelength - (glPlanMeasDist) 
			stdout '<td>',(":,cumyards),'</td></tr>'
		NB. Backtee different from tee in question
	end.
	stdout LT2,'</tbody></table></div>'
end.

stdout LT1,'<form action="/jw/rating/landing/editpost/',(;glFilename),'" method="post">'

NB. Hidden variables
stdout LT1,'<div class="span-19 last">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glPlanUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glPlanUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keyplan" value="',(;keyy),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Table of values - Common Values
stdout LT1,'<h4>Common Measurements</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Alt</th><th>FW Width</th><th>Bunk LZ</th><th>Bunk LoP</th><th>Dist OB</th><th>OOB %age</th><th>OOB LoP</th><th>Dist Tr</th><th>Dist Wat</th><th>Water %age</th><th>Wat LoP</th><th>Mounds</th><th>Dogleg Neg</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input value="',(":;glPlanAlt),'" tabindex="1" ',(InputFieldnum 'alt'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glPlanFWWidth),'" tabindex="2" ',(InputFieldnum 'fwwidth'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="bunklz" name="bunklz" value="1" '
stdout ((''$glPlanBunkLZ)#'checked'),' tabindex="3">',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="bunkline" name="bunkline" value="1" '
stdout ((''$glPlanBunkLine)#'checked'),' tabindex="4">',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glPlanOOBDist),'" tabindex="5" ',(InputFieldnum 'oobdist'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'oobpercent' ; 6 ; glOOBPercentDesc ; glOOBPercentVal ; <''$glPlanOOBPercent
stdout LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="oobline" name="oobline" value="1" '
stdout ((''$glPlanOOBLine)#'checked'),' tabindex="7">',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glPlanTreeDist),'" tabindex="8" ',(InputFieldnum 'treedist'; 3),'>',LT4,'</td>'
NB. stdout LT4,'<td>'
NB. djwSelect 'treerecov' ; 7 ; glTreeRecovDesc ; glTreeRecovVal ; <''$glPlanTreeRecov
NB. stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;glPlanLatWaterDist),'" tabindex="9" ',(InputFieldnum 'latwaterdist'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'waterpercent' ; 9 ; glWaterPercentDesc ; glWaterPercentVal ; <''$glPlanWaterPercent
stdout LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="waterline" name="waterline" value="1" '
stdout ((''$glPlanWaterLine)#'checked'),' tabindex="10">',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="rrmounds" name="rrmounds" value="1" '
stdout ((''$glPlanRRMounds)#'checked'),' tabindex="11">',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glPlanDoglegNeg),'" tabindex="12" ',(InputFieldnum 'doglegneg'; 3),'>',LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

NB. Table of values - Roll
stdout LT1,'<h4>Roll</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Level</th><th>Slope</th><th>Stance or Lie</th><th>FW +/-W</th><th>Extreme</th><th>Twice</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td>'
djwSelect 'rolllevel' ; 13 ; glRollLevelDesc ; glRollLevelVal ; <''$glPlanRollLevel
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'rollslope' ; 14 ; glRollSlopeDesc ; glRollSlopeVal ; <''$glPlanRollSlope
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'topogstance' ; 15 ; glTopogStanceDesc ; glTopogStanceVal ; <''$glPlanTopogStance
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'widthadj' ; 16 ; glFWWidthAdjDesc ; glFWWidthAdjVal ; <''$glPlanFWWidthAdj
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'rollextreme' ; 17 ; glRollExtremeDesc ; glRollExtremeVal ; <''$glPlanRollExtreme
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'rolltwice' ; 18 ; glRollTwiceDesc ; glRollTwiceVal ; <''$glPlanRollTwice
stdout LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

NB. Table of values - Shot TO Landing Zone
stdout LT1,'<h4>Shot TO Landing Zone</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Landing Zone not Visible</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input type="checkbox" id="fwvisible" name="fwvisible" value="1" '
stdout ((''$glPlanFWVisible)#'checked'),' tabindex="19">',LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

NB. Table of values - Topography
stdout LT1,'<h4>Topography and Shot FROM Landing Zone</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Unpleasant Lie</th><th>Obstructed Shot</th><th>Targ not Visible</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input type="checkbox" id="fwunpleasant" name="fwunpleasant" value="1" '
stdout ((''$glPlanFWUnpleasant)#'checked'),' tabindex="20">',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="fwobstructed" name="fwobstructed" value="1" '
stdout ((''$glPlanFWObstructed)#'checked'),' tabindex="21">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'fwtargvisible' ; 22 ; glTargVisibleDesc ; glTargVisibleVal ; <''$glPlanFWTargVisible
stdout LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

stdout LT1,'</div>'

NB. Submit buttons
stdout LT1,'<div class="span-15 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":100),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":101),'">'
if. 'M'=glPlanRecType do. NB. Only delete on measurement point
	stdout LF,'     <input type="submit" name="control_delete" value="Delete this M/Point" tabindex="',(,":4),'"></form>'
end.
stdout LF,'</div>' NB. end of submit loop
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
res=. 1
exit ''
)

NB. =========================================================
NB. jweb_rating_landing_editpost
NB. =========================================================
NB. Process entries after edits to landing 
NB. based on the contents after the "post"
jweb_rating_landing_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/landing/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
bunklz=: 0
bunkline=: 0
fwvisible=: 0
fwunpleasant=: 0
fwobstructed=: 0
rrmounds=: 0
waterline=: 0
oobline=: 0
xx=. djwCGIPost y ; ' ' cut 'alt fwwidth bunklz bunkline oobdist treedist latwaterdist doglegneg fwvisible fwunpleasant fwobstructed waterline rrmounds oobline'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
ww=. keyplan utKeyRead glFilepath,'_plan'

NB. Throw error page if updated
if. (-. glSimulate)  do.
if. (-. (;glPlanUpdateTime) -: (;prevtime)) do.
	stdout 'Content-type: text/html',LF,LF,'<html>',LF
 	stdout LF,'<head>'
 	stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
 	djwBlueprintCSS ''
 	stdout LF,'</head><body>'
 	stdout LF,'<div class="container">'
 	stdout LF,TAB,'<div class="span-24">'
 	stdout LF,TAB,TAB,'<h1>Error updating ',(,;glPlanID),'</h1>'
 	stdout LF,'<div class="error">Synch error updating ',(;glPlanID)
 	stdout LF,'</br></br>',(":getenv 'REMOTE_USER'),' started to update record previously saved by ',(;prevname),' at ',;prevtime
 	stdout LF,'</br><br>It has since been updated by: ',(; glPlanUpdateName),' at ',(;glPlanUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/plan/v/',glFilename,'/',(;":1+glPlanHole),'">Restart plan of hole: ',(;":1+glPlanHole),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.
end.

glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlanAlt=: ,alt
glPlanFWWidth=: ,fwwidth
glPlanFWWidthAdj=: ,widthadj
glPlanBunkLZ=: ,bunklz
glPlanBunkLine=: ,bunkline
glPlanOOBDist=: ,oobdist
glPlanOOBPercent=: ,oobpercent
glPlanOOBLine=: ,oobline
glPlanTreeDist=: ,treedist
NB. glPlanTreeRecov=: ,treerecov
glPlanLatWaterDist=: , latwaterdist
glPlanWaterPercent=: ,waterpercent
glPlanWaterLine=: ,waterline
glPlanDoglegNeg=: ,doglegneg
glPlanRollLevel=: ,rolllevel
glPlanRollSlope=: ,rollslope
glPlanRollExtreme=: ,rollextreme
glPlanRollTwice=: ,rolltwice
glPlanFWVisible=: ,fwvisible
glPlanFWTargVisible=: ,fwtargvisible
glPlanTopogStance=: ,topogstance
glPlanFWUnpleasant=: ,fwunpleasant
glPlanFWObstructed=: ,fwobstructed
glPlanRRMounds=: ,rrmounds

NB. Write to files
keyplan utKeyPut glFilepath,'_plan'

stdout 'Content-type: text/html',LF,LF
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. (0= 4!:0 <'control_delete')  do.
		NB. Delete the landing record
		keyplan utKeyDrop glFilepath,'_plan'
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
	elseif. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. rating_landingcopy_e
NB. =========================================================
NB. Copy data from nearest point
jweb_rating_landingcopy_e=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
if. -. keyy e. keydir (glFilepath,'_plan') do.
    djwErrorPage err ; ('No such measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Read all the records
utKeyRead glFilepath,'_plan'
ix=. ''$glPlanID i. keyy

NB. Look for measurement point at the nearest distance
hole=. ix{glPlanHole
ww=. I. glPlanHole = hole
ww=. ww -. ix NB. can't be self
ww=.  ( 0< ww { glPlanAlt + glPlanFWWidth + glPlanBunkLZ - glPlanBunkLine + glPlanOOBDist + glPlanTreeDist ) # ww

if. 0<#ww do.

    diff=. |(ww { glPlanRemGroundYards) - ix{glPlanRemGroundYards
    ww=. (diff i. <. / diff) { ww
    diff=. <. / diff

    if. diff < 30 do. NB. Must be less than 30 yards
	(ix{glPlanID) CopyPlanRecord ww{glPlanID
    end.
end.

stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+hole),''')"'
stdout LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. rating_landing_d
NB. =========================================================
NB. Copy data from nearest point
jweb_rating_landing_d=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
if. -. keyy e. keydir (glFilepath,'_plan') do.
    djwErrorPage err ; ('No such measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Delete the record
keyy utKeyRead glFilepath,'_plan'
(,keyy)utKeyDrop glFilepath,'_plan'

stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glPlanHole),''')"'
stdout LF,'</body></html>'
exit ''
)
