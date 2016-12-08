NB. J Utilities for recording data at green
NB. 

NB. =========================================================
NB. rating_green_e
NB. =========================================================
jweb_rating_green_e=: 3 : 0
NB. Retrieve the details
NB. y has two elements only
'filename keyy'=. y
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
keyy=. <keyy

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_tee'
	utKeyRead glFilepath,'_green'
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
if. -. keyy e. keydir (glFilepath,'_green') do.
    djwErrorPage err ; ('No such green measurement point : ',}. ; (<'/'),each y) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

NB. Read the single green record, and relevant tee record
keyy utKeyRead glFilepath,'_green'
((glTeHole=''$glGrHole)#glTeID) utKeyRead glFilepath,'_tee'

stdout LF,'<h2>Course : ', glCourseName,EM,EM,'Green Measurements</h2>'

NB. Work out the back tee
ww=. I. glTeHole = ''$glGrHole
ww=. ww /: glTees i. ww{glTeTee
ww=.  +. /"1  ww { glTeMeasured NB. If either measured - don't need to split by gender
backtee=. ''${. ww # glTees

NB. Fix back tee
if. 0=glGrFrontYards do.
    glGrTee=: ,backtee
end.

stdout LF,'<div class="span-11 append-1">'
stdout LF,'<table><thead><tr><th>Parameter</th><th>Value</th></tr></thead><tbody>'

stdout LF,'<tr><td>Hole:</td><td>',(":1+ ; glGrHole),'</td></tr>'

for_t. (glTees) do.
	stdout LT3,'<tr>',LT4,'<td>Distance from : ',>t_index { glTeesName
	stdout '</td>'
	holelength=. (<t_index,glGrHole){glTeesYards
	stdout '<td>',(":,holelength),'</td></tr>'
	NB. Backtee different from tee in question
end.
stdout LT2,'</tbody></table>'

stdout LT1,'<form action="/jw/rating/green/editpost/',(;glFilename),'" method="post">'

NB. New tree variables
stdout LT1,'<h4>Tree Difficulty</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>From Tee</th><th>Men/Women</th><th>Scratch</th><th>Bogey</th></tr>',LT2,'</thead>',LT2,'<tbody>'
ind=. 0
for_t. glTeTee do.
    for_g. i. 2 do.
	stdout LT3,'<tr>'
	stdout LT4,'<td>',(>(glTees i. t){glTeesName),'</td><td>',>g{' ' cut 'Men Women'
	for_ab. i. 2 do.
		ind=. ind+1
		if. (<t_index,g){glTeMeasured do.
			stdout LT4,'<td>'
			msk=. glTreePar=4<.(<t_index,g){glTePar
			djwSelect ('tree',t,(":g),(":ab)) ; ind ; (msk#glTreeDesc) ; (msk#glTreeVal) ; <(<t_index,g,ab){glTeTree 
			stdout LT4,'</td>'
		else.
			stdout LT4,'<td><input type="hidden" name="',('tree',t,(":g),(":ab)),'" value="',(>(<t_index,g,ab){glTeTree),'"></td>'
		end.
	end.
	stdout LT3,'</tr>'
    end.
end.
stdout LT2,'</tbody></table>'
stdout LT1,'</div>'


NB. Hidden variables


stdout LT1,'<div class="span-12 last">'
stdout LT2,'<input type="hidden" name="prevname" value="',(":;glGrUpdateName),'">'
stdout LT2,'<input type="hidden" name="prevtime" value="',(;glGrUpdateTime),'">'
stdout LT2,'<input type="hidden" name="keyplan" value="',(;keyy),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Measurements
stdout LT1,'<h4>Distances and Green Target</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>From Tee</th><th>Green Front</th><th>Alt</th><th>Length</th><th>Width</th><th>Diam</th><th>Circle Concept</th><th>Tiered</th><th>Firmness</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td>'
djwSelect 'fromtee' ; 1 ; glTeesName ; (<"0 glTees) ; <<''$glGrTee
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrFrontYards),'" tabindex="2" ',(InputFieldnum 'frontyards'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrAlt),'" tabindex="3" ',(InputFieldnum 'alt'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrLength),'" tabindex="4',(InputFieldnum 'length'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrWidth),'" tabindex="5',(InputFieldnum 'width'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrDiam),'" tabindex="6',(InputFieldnum 'diam'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="circleconcept" name="circleconcept" value="1" '
stdout ((''$glGrCircleConcept)#'checked'),' tabindex="7">',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="tiered" name="tiered" value="1" '
stdout ((''$glGrTiered)#'checked'),' tabindex="8">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'firmness' ; 9 ; glGrFirmnessDesc ; glGrFirmnessVal ; <''$glGrFirmness
stdout LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

NB. Table of values - Common Values
stdout LT1,'<h4>Common Measurements</h4>'
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Surface contours</th><th>Dist Tree</th><th>Tree</th><th>Tree +1</th><th>Mounds</th><th>Bunk Frac</th><th>Bunk Dep</th><th>Dist OB</th><th>Dist Wat</th><th>Water Frac</th><th>Water SurrDist</th></tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td>'
djwSelect 'contour' ; 10 ; glGrContourDesc ; glGrContourVal ; <''$glGrContour
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrTreeDist),'" tabindex="11" ',(InputFieldnum 'treedist'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'tree' ; 12 ; glTreeDesc ; glTreeVal ; <''$glGrTree
stdout LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="treetween" name="treetween" value="1" '
stdout ((''$glGrTreeTween)#'checked'),' tabindex="13">',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="rrmounds" name="rrmounds" value="1" '
stdout ((''$glGrRRMounds)#'checked'),' tabindex="14">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'bunkfraction' ; 15 ; glBunkFractionDesc ; glBunkFractionVal ; <''$glGrBunkFraction
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'bunkdepth' ; 16 ; glBunkDepthDesc ; glBunkDepthVal ; <''$glGrBunkDepth
stdout LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrOOBDist),'" tabindex="17" ',(InputFieldnum 'oobdist'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input value="',(":;glGrWaterDist),'" tabindex="18" ',(InputFieldnum 'waterdist'; 3),'>',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'waterfraction' ; 19 ; glWaterFractionDesc ; glWaterFractionVal ; <''$glGrWaterFraction
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'watersurrdist' ; 20 ; glWaterSurrDistDesc ; glWaterSurrDistVal ; <''$glGrWaterSurrDist
stdout LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table>'

NB. Table of values - Green Surface, R&R, Bunkers, OOB
stdout LT1,'<h4>Green Surface, Recov and Rough, Bunkers, OOB/Extreme Rough, Water</h4>'
stdout LT1,'<table>',LT2,'<thead>'
stdout LT3,'<tr>'
stdout LT4,'<th colspan="3">Green Surface</th><th colspan="3">Recoverability and Rough</th><th>Bunkers</th><th colspan="3">OOB/ER</th><th colspan="3">Water</th>'
stdout LT3,'</tr>'
stdout LT3,'<tr>'
stdout LT4,'<th>Stimp</th><th>All</th><th>Unpleasant</th><th>Rough Inconsistent</th><th>Rise and Drop</th><th>Unpleasant</th><th>Extreme</th><th>Behind Green</th><th>Cart Path</th><th>%P</th><th>Behind Green</th><th>Cart Path</th><th>%P</th>'
stdout LT3,'</tr>',LT2,'</thead>',LT2,'<tbody>'
stdout LT3,'<tr>'
stdout LT4,'<td><input value="',(":;glGrStimp),'" tabindex="15" ',(InputFieldnum 'stimp'; 3),'>',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="all" name="all" value="1" '
stdout ' tabindex="16">',LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="surfaceunpleasant" name="surfaceunpleasant" value="1" '
stdout ((''$glGrSurfaceUnpleasant)#'checked'),' tabindex="13">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'rrinconsistent' ; 12 ; glRRInconsistentDesc ; glRRInconsistentVal ; <''$glGrRRInconsistent
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'rrrisedrop' ; 12 ; glRRRiseDropDesc ; glRRRiseDropVal ; <''$glGrRRRiseDrop
stdout LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="rrunpleasant" name="rrunpleasant" value="1" '
stdout ((''$glGrRRUnpleasant)#'checked'),' tabindex="13">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'bunkextreme' ; 14 ; glBunkExtremeDesc ; glBunkExtremeVal ; <''$glGrBunkExtreme
stdout LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="oobbehind" name="oobbehind" value="1" '
stdout ((''$glGrOOBBehind)#'checked'),' tabindex="15">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'oobcart' ; 16 ; glOOBCartDesc ; glOOBCartVal ; <''$glGrOOBCart
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'oobpercent' ; 17 ; glOOBPercentDesc ; glOOBPercentVal ; <''$glGrOOBPercent
stdout LT4,'</td>'
stdout LT4,'<td><input type="checkbox" id="waterbehind" name="waterbehind" value="1" '
stdout ((''$glGrWaterBehind)#'checked'),' tabindex="18">',LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'watercart' ; 19 ; glWaterCartDesc ; glWaterCartVal ; <''$glGrWaterCart
stdout LT4,'</td>'
stdout LT4,'<td>'
djwSelect 'waterpercent' ; 20 ; glWaterPercentDesc ; glWaterPercentVal ; <''$glGrWaterPercent
stdout LT4,'</td>'
stdout LT3,'</tr>'
stdout '</tbody></table></div>'


NB. Submit buttons
stdout LT1,'<div class="span-24 last">'

stdout LF,'<input type="submit" name="control_calc" value="Calc" tabindex="',(":2),'">'
stdout LF,'     <input type="submit" name="control_done" value="Done" tabindex="',(,":3),'">'
stdout LF,'</div>' NB. end submit
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
exit ''
)

NB. =========================================================
NB. jweb_rating_green_editpost
NB. =========================================================
NB. Process entries after edits to landing 
NB. based on the contents after the "post"
jweb_rating_green_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/green/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
circleconcept=: 0
tiered=: 0
all=: 0
treetween=: 0
surfaceunpleasant=: 0
rrmounds=: 0
rrunpleasant=: 0
oobbehind=: 0
waterbehind=: 0
xx=. djwCGIPost y ; ' ' cut 'all frontyards length width diam circleconcept tiered alt oobdist treedist treetween waterdist stimp all surfaceunpleasant rrmounds rrunpleasant oobbehind waterbehind'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and check the time stamp
ww=. utFileGet glFilepath
ww=. keyplan utKeyRead glFilepath,'_green'
utKeyRead glFilepath,'_tee'
((glTeHole=''$glGrHole)#glTeID) utKeyRead glFilepath,'_tee'

NB. Throw error page if updated
if. (-. glSimulate)  do.
if. (-. (;glGrUpdateTime) -: (;prevtime)) do.
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
 	stdout LF,'</br><br>It has since been updated by: ',(; glGrUpdateName),' at ',(;glGrUpdateTime)
 	stdout LF,'</br><br><b>**Update has been CANCELLED**</b>'
 	stdout  ,2$,: '</div>'
 	stdout LF,'</br><a href="/jw/rating/plan/v/',glFilename,'/',(;":1+glGrHole),'">Restart plan of hole: ',(;":1+glGrHole),'</a>'
 	stdout, '</div></body>'
 	exit ''
end.
end.

glGrUpdateName=: ,<": getenv 'REMOTE_USER'
glGrUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glTeUpdateName=: (#glTeID)$<": getenv 'REMOTE_USER'
glTeUpdateTime=: (#glTeID)$< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glGrTee=: ,>fromtee
glGrFrontYards=: ,frontyards 
glGrAlt=: ,alt
glGrLength=: ,length
glGrWidth=: ,width
glGrDiam=: ,diam
glGrDiam=: ,<. 0.5 + (0.5*length+width)
glGrCircleConcept=: ,circleconcept
glGrTiered=: ,tiered
glGrFirmness=: ,firmness
glGrContour=: ,contour
glGrTreeDist=: ,treedist
glGrTree=: ,tree
glGrTreeTween=: ,treetween
glGrFWWidth=: ,fwwidth
glGrOOBDist=: ,oobdist
glGrWaterDist=: , waterdist
glGrStimp=: ,stimp
glGrSurfaceUnpleasant=: ,surfaceunpleasant
glGrRRInconsistent=: ,rrinconsistent
glGrRRMounds=: ,rrmounds
glGrRRRiseDrop=: ,rrrisedrop
glGrRRUnpleasant=: ,rrunpleasant
glGrBunkFraction=: ,bunkfraction
glGrBunkDepth=: ,bunkdepth
glGrBunkExtreme=: ,bunkextreme
glGrOOBBehind=: ,oobbehind
glGrOOBCart=: ,oobcart
glGrOOBPercent=: ,oobpercent
glGrWaterFraction=: ,waterfraction
glGrWaterSurrDist=: ,watersurrdist
glGrWaterBehind=: ,waterbehind
glGrWaterCart=: ,watercart
glGrWaterPercent=: ,waterpercent
for_t. glTeTee do.
    for_g. i. 2 do.
	for_ab. i. 2 do.
	    glTeTree=: (". 'tree',t,(":g),(":ab)) (<t_index,g,ab)}glTeTree 
	end.
    end.
end.

NB. Write to files
keyplan utKeyPut glFilepath,'_green'
utKeyPut glFilepath,'_tee'
if. all do.
    utKeyRead glFilepath,'_green'
    glGrStimp=: 18$ stimp
    utKeyPut glFilepath,'_green'
end.

stdout 'Content-type: text/html',LF,LF
stdout LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+glGrHole),''')"'
    end.
stdout LF,'</body></html>'
exit ''
)

