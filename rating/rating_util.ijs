NB. Utilities for rating programme
NB. Including GPS calculations
NB. and offline updates

glMY=: 1.0936133

NB. ==============================================
NB. setglobalsfromcurrent
NB. ----------------------------------------------
NB. Sets the global variables for paths etc.
NB. Only use this in offline mode, from the 
NB. database directory, e.g. /var/www/jweb/<zzz>    
NB. ==============================================
setglobalsfromcurrent=: 3 : 0
if. 0 < # 1!:0 <'/Users' do. glHome=: '/Users' else. glHome=: '/home' end.
if. 0 < # 1!:0 <glHome,'/djw' do. glHome=: glHome, '/djw' else. glHome=: glHome,'/ubuntu' end.
if. 0 < # 1!:0 <'/Users' do. glDocument_Root=: '/Library/WebServer/Documents' else. glDocument_Root=: '/var/www' end.
basename=. 'rating'
NB. Check if basename already created
if. 0~: 4!:0 <'glBasename' do. glBasename=: basename end.
)

basename=.setglobalsfromcurrent ''
ww=. 4!:55 <'setglobalsfromcurrent'

require glDocument_Root,'/jweb/cgi/djwUtilFile.ijs'
require glDocument_Root,'/jweb/cgi/djwGpsRead.ijs'
require glDocument_Root,'/jweb/cgi/djwOrdSurvey.ijs'

NB. ============================================
NB. ReadGPS 
NB. --------------------------------------------
NB. Read GPS file
NB. ============================================
ReadGPS=: 3 : 0
require 'tables/csv'
ww=. readcsv glDocument_Root,'/yii/',glBasename,'/protected/data/',y,'.txt'
res=. (0{ww) i. 'Latitude' ; 'Longitude' ; 'Altitude' ; 'Time' ; 'Name' ; 'Icon' ; 'Description'
res=. res {"1 (ww,"1 a:)
res=. }. res
NB. Convert the first three columns to numbers
res=. (". each 3{."1 res),"1 (3 }."1 res)
res=. res /: 'TPG' i. 2{"1 >4{"1 res NB. sort by type
res=. res /: 0 1{"1 >4{"1 res  NB. then by tee
glGPSLatLon=: (j. /"1 >0 1{"1 res)
glGPSAlt=: >2{"1 res
glGPSName=: 4{"1 res
glGPSName=: toupper each glGPSName
glGPSMeasured=: (#glGPSLatLon)$1
(' ' cut 'glGPSLatLon glGPSAlt glGPSName glGPSMeasured') utFilePut glDocument_Root,'/yii/',glBasename,'/protected/data/',y
)

NB. =============================================
NB. ResetFileName
NB. =============================================
ResetFileName=: 3 : 0
glFilename=: y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',y
utFileGet glFilepath
)

NB. =============================================
NB. PathTeeToGreen
NB. =============================================
NB. List of points from tee to green for a given
NB. hole
NB. Usage: PathTeeToGreen 1 ; 'W'
NB. =============================================
PathTeeToGreen=: 3 : 0
('h' ; 'tee' ) =. y
string=. >'r<0>2.0' 8!:0 (1+h)
res=. I. ((<string,'P') = (3{. each glGPSName) ) NB. Pivot ppints
res=. (glGPSName i.  (<string,'T',tee)),res NB. Tee
res=. res, (glGPSName i. (<string,'GC')) NB. Green
latlon=. res { glGPSLatLon
NB. Order by distance from start
latlon=. LatLontoFullOS latlon
latlon=. |latlon - 0{latlon
res=. res /: latlon
res=. res { glGPSLatLon
)

NB. ============================================
NB. InterceptPath
NB. --------------------------------------------
NB. A fairly complicated bit of trig and vector
NB. stuff to calculate where a shot of a given
NB. length cuts the path to the green, e.g. for
NB. a dogleg
NB. Usage:  InterceptPath  path ; startpoint ; radius in yards
NB. Returns the latlon of the intercept, and the distance along
NB. the path
NB. ----------------------------------------------
InterceptPathold=: 3 : 0
(' ' cut 'path start radius')=. y
radius=. radius % glMY NB. Need to do the geometry in meters

NB. Assume the green is the last point in path, and
NB. delete any points further away than the start
path=. LatLontoFullOS path
start=. LatLontoFullOS start
path=.((| path - _1{path) < (|start - _1{path)) # path

NB. If first point of path is further than radius, simple calc
if. radius < (|start - 0{path) do.
	prop=. radius % (|start -0{path)
	res=. start + prop * (0{path) - start
	res=. FullOStoLatLon res
	res=. res, radius * glMY
	return.
end.

NB. If last point of path is less than radius, zoom there
if. radius >: (|start - _1{path) do.
	res=. FullOStoLatLon _1{path
	NB. Truncate path to startpoint
	path=. start, path
	res=. res, glMY * +/|(}.path) - (}:path)
	return.
end.
NB. Need to find out which chunk of the path is crossed by radius
dist=.( (| path - start) > radius) i. 1
NB. Need to image a triangle with point <B> at the start
NB. The first side, or vector <a> is from the start to the point less than the
NB. radius
a=. ((dist-1) { path ) - start
NB. the top side is <b> which is cut by the radius.  We need to find the 
NB. length of b
NB. The final side is the shot <c> and we can work out the angle <C> 
NB. using the dot product
blarge=. -/ (dist,dist-1) { path
C=. pi - arccos (+/(+. a) * (+. blarge)) % (|a) * |blarge NB. dot product
NB. We can now work out the angle A using the sin rule
A=. arcsin (|a) * (sin C) % radius NB. radius = |c
NB. ..and angle B because they add up to pi radians
B=. pi - A + C
b=. radius * (sin B) % sin C

NB. So the shot cuts at length b along blarge
res=. ((dist-1){path) + (b % |blarge) * blarge
res=. FullOStoLatLon res  
path=. start, dist{. path
length=. +/ (|(}. path) - }:path)
length=. length + b
res=. res, glMY*length 

)

NB. ============================================
NB. InterceptPath
NB. --------------------------------------------
NB. A fairly complicated bit of trig and vector
NB. stuff to calculate where a shot of a given
NB. length cuts the path to the green, e.g. for
NB. a dogleg
NB. Usage:  InterceptPath  path ; startpoint ; radius in yards
NB. Returns the latlon of the intercept, and the distance along
NB. the path
NB. Changed 12/5/15 to make it easier
NB. Now assumes it follows the route of the fairway
NB. and returns the LatLon of the new position
NB. and the crow's flight distance of the ball
NB. ----------------------------------------------
InterceptPath=: 3 : 0
(' ' cut 'path start radius')=. y
radius=. radius % glMY NB. Need to do the geometry in meters

NB. Assume the green is the last point in path, and
NB. delete any points further away than the start
path=. LatLontoFullOS path
start=. LatLontoFullOS start
path=.((| path - _1{path) < (|start - _1{path)) # path

NB. If first point of path is further than radius, simple calc
if. radius < (|start - 0{path) do.
	prop=. radius % (|start -0{path)
	res=. start + prop * (0{path) - start
	res=. FullOStoLatLon res
	res=. res, <. 0.5 + radius * glMY
	return.
end.

NB. Else add the start point to the path
path=. start,path
length=. 0, +/ \ (|(}. path) - }:path)

NB. If last point of path is less than radius, zoom there
if. radius >: ({:length) do.
	res=. FullOStoLatLon _1{path
	NB. Truncate path to startpoint
	res=. res, <. 0.5 + glMY *  _1{length
	return.
end.

NB. Need to find out which chunk of the path is crossed by radius
dist=.( length > radius) i. 1
NB. Need to image a triangle with point <B> at the start
NB. length of b
b=. radius - (dist-1){length
blarge=. -/ (dist,dist-1) { path
res=. ((dist-1){path) + (b % |blarge) * blarge
res=. FullOStoLatLon res
res=. res, <. 0.5 + glMY * radius

)



NB. =============================================
NB. AugmentGPS
NB. =============================================
NB. Augment the GPS file with missing tee and
NB. green information
NB. =============================================
NB. Usage: AugmentGPS holes
AugmentGPS=: 3 : 0
y=. ,y
y=. (y e. i.18 ) # y NB. Limit to valid holes
for_h. y do. NB. Start of hole loop <h>
	NB. Green centres
	xx=. ('r<0>2.0' 8!:0 (1+h)),each(' ' cut 'GC GF GB')
	xx=. glGPSName i. xx
	if. (0{xx) < #glGPSName do. continue. end. NB. already exists
	latlon=. LatLontoFullOS (1 2{xx)  { glGPSLatLon
	latlon=. 0.5 * +/ latlon NB. average of two positions
	latlon=. FullOStoLatLon latlon
	glGPSLatLon=: glGPSLatLon, latlon
	glGPSAlt=: glGPSAlt, 0.5 * +/ 1 2 {glGPSAlt
	glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
	glGPSMeasured=: glGPSMeasured, 0
end.  NB. end of first hole loop

for_h. y do. NB. Start of hole loop <h>

	NB. Other tees
	for_t. }. glTees do. NB. start of tee loop
		xx=. (>'r<0>2.0' 8!:0 (1+h)),'T',t
		xx=. glGPSName i. xx
		if. xx < #glGPSName do. continue. end. NB. already exists
		path=. PathTeeToGreen h ; 0{glTees
		NB. Difference between card values
		radius=. -/(<(0,glTees i. t) ; h) { glTeesYards
		latlon=. 0{ InterceptPath path ; (0{path) ; radius		
		glGPSLatLon=: glGPSLatLon, latlon
		glGPSAlt=: glGPSAlt, (glGPSLatLon i. 0{path){glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'T',t
		glGPSMeasured=: glGPSMeasured, 0
	end. NB. End of tee loop	

end. NB. End of hole loop <h>	

NB. Finally, adjust tee position to be the same as the card
for_h. y do. NB. Start of hole loop <h>

	NB. Other tees
	for_t. glTees do. NB. start of tee loop
		path=. PathTeeToGreen h ; t
		NB. Difference between card values
		card=. -/(<(t_index) ; h) { glTeesYards
		path=. LatLontoFullOS path
		length=. glMY * +/ | (}. path) - (}:path) 
		NB. Move first point
		latlon=. (0{path) + ((length-card) % glMY * |-/2{.path) * (-/1 0 { path)
		latlon=. FullOStoLatLon latlon
		xx=. <(>'r<0>2.0' 8!:0 (1+h)),'T',t
		xx=. glGPSName i. xx
		glGPSLatLon=: latlon (xx)} glGPSLatLon
	
	end. NB. End of tee loop	

end. NB. End of hole loop <h>	

utFilePut glFilepath
)

NB. =====================================================
NB. BuildPlan
NB. -----------------------------------------------------
NB. This is the monster function to loop round and build
NB. all the measurement distances
NB. Usage: BuildPlan holes ; tees ; genders ; abilities
BuildPlan=: 3 : 0
if. 0=L. y do. y=. 4{. <y end.
y=. 4{. y
(' ' cut 'holes tees genders abilities')=. y
holes=. , holes
if. 0=#holes do. holes=. i. 18 end.
genders=. ,genders
if. 0=#genders do. genders=. 0 1 end.
abilities=. , abilities
if. 0=#abilities do. abilities=. 0 1 end.
tees=. , tees
if. 0=#tees do. tees=. glTees end.

utKeyRead glFilepath,'_tee'

for_h. holes do.
NB. New logic for tees meaured
NB. for_t. (tees e. >h{glTeesMeasured) # tees do. NB. Only relevant tees for the hole

NB. Work out the back tee
ww=. I. glTeHole = h
ww=. ww /: glTees i. ww{glTeTee
ww=.  +. /"1  ww { glTeMeasured NB. If either measured - don't need to split by gender
backtee=. ''${. ww # glTees

for_t. tees do. NB. Only relevant tees for the hole
    

for_g. genders do.
    if. -. t e. >g{glTeesPlayer do. continue. end. 
    NB. Fish out records for any plan records no longer measured
    ww=. glTeHole=h
    ww=. I. ww *. glTeTee=t
    if. -.  (<ww,g) {glTeMeasured do. NB. Dead tee
    	NB. Find any plan points pointing at dead tee
	utKeyRead glFilepath,'_plan'
	ww=. glPlanRecType='P'
	ww=. ww *. glPlanHole = h
	ww=. ww *. glPlanTee = t
	ww=. I. ww *. glPlanGender = g
	if. 0<#ww do.
	    key=. ww{glPlanID
	    key utKeyRead glFilepath,'_plan'
	    newkey=. 'r<0>2.0' 8!:0 glPlanHole
	    newkey=. newkey ,each <'-'
	    newkey=. newkey ,each 'r<0>3.0' 8!:0 glPlanRemGroundYards
	    glPlanHitYards=: (#key) $0
	    glPlanUpdateName=: (#key)$<": getenv 'REMOTE_USER'
	    glPlanUpdateTime=: (#key)$< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
	    glPlanLayupType=: (#key)$,' '
	    glPlanRecType=: (#key)$,'M'
	    glPlanCarryType=: (#key)$,' '
	    glPlanID=: newkey
	    utKeyPut glFilepath,'_plan'
	    key utKeyDrop glFilepath,'_plan' 
	end.
	continue. NB. Loop to next gender
    end.


for_ab. abilities do.
	shot=. _1
	cumgroundyards=. 0 
	path=. LatLontoFullOS PathTeeToGreen h ; t
	remgroundyards=. <. 0.5 + glMY * +/ |(}.path) - }:path
	glTeesGroundYards=: <. 0.5+remgroundyards (< (glTees i. t), h)}glTeesGroundYards
	path=. LatLontoFullOS PathTeeToGreen h ; backtee
	rembackyards=. <. 0.5 + glMY * +/ |(}.path) - }:path
	cumbackyards=. rembackyards - remgroundyards
	path=. PathTeeToGreen h ; t
	start=. 0{path

label_shot.
	NB. Remove this record by pushing out a measurement-only
	NB. record.
	shot=. shot + 1

	NB. Find the matching records and shift to measurement records
	NB. Logic is to find the keys
	utKeyRead glFilepath,'_plan'
	ww=. glPlanHole =  h
	ww=. ww *. glPlanTee =  t
	ww=. ww *. glPlanGender =  g
	ww=. ww *. glPlanAbility =  ab
	ww=. ww *. glPlanShot = shot
	ww=. ww *. glPlanRecType = 'P'
	ww=. ww # glPlanID
	if. 1 < $ww do.
		NB. No should not happen
		stderr 'Too many records in plan file'
		return.
	elseif. 0=$ww do.
		NB. Nothing to do
		NB. but do need to restore glPlanID
		glPlanID=: ,EnKey h ; '' ; t ; g ; ab ; shot
	elseif. 1=$ww do.
		ww utKeyRead glFilepath,'_plan'

		NB. player on this tee
		NB. Should only be one record
		newkey=. EnKey h ; glPlanMeasDist ; t ; g ;ab ; shot
		newkey=. <6 {. >newkey NB. Just need first six characters
		glPlanHitYards=: ,0
		glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
		glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
		glPlanLayupType=: ,' '
		glPlanRecType=: ,'M'
		glPlanCarryType=: ,' '
		glPlanID=: ,newkey
		utKeyPut glFilepath,'_plan'
		
		NB. Read it back again
		ww utKeyRead glFilepath,'_plan'
	end.

	NB. Pull normal shot distance
	NB. Check if there is a layup record
	defaulthit=.  (<g,ab, 1<.shot){glPlayerDistances
	glPlanID utKeyRead glFilepath,'_layup'
	if. ( -. _4 -: >glLayupID) do. NB. Found
		radius2=. ''$ remgroundyards - glLayupRemGroundYards 
		glPlanLayupType=: glLayupType
	else.
		radius2=. ''$ defaulthit
 		glPlanLayupType=: ,' '
	end.
	ww=. InterceptPath path ; start ; radius2
	NB. New logic for transition within 10 yards of 
	NB. of the green
	rem=. remgroundyards - <. 0.5 + 1{ww
	if. ( 0 < rem) *. (10 >: rem) *. (glPlanLayupType=' ') do.
		radius2=. radius2 + rem
		ww=. InterceptPath path ; start ; radius2
		glPlanLayupType=: ,'T'
	end.

	NB. glPlanID already exists
	glPlanTee=: ,t
	glPlanHole=: ,h
	glPlanGender=: ,g
	glPlanAbility=: ,ab
	glPlanShot=: ,shot
	glPlanHitYards=: , <. 0.5+ 1{ww
	cumgroundyards=. <. 0.5 + cumgroundyards + 1{ww
	remgroundyards=. <. 0.5  + remgroundyards - 1{ww
	cumbackyards=. <. 0.5 + cumbackyards + 1{ww
	glPlanCumGroundYards=: ,cumgroundyards
	glPlanBackGroundYards=: ,cumbackyards
	glPlanLatLon=: , 0{ww
	glPlanRemGroundYards=: ,remgroundyards
	glPlanRecType=: ,'P'
	glPlanCarryType=: ,' '
	glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
	glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
	start=. 0{ww
	NB. Measurepoint is in middle of roll
	if. glPlanRecType ~: 'P' do.
		glPlanMeasDist=: glPlanRemGroundYards
	elseif. glPlanLayupType =  'R' do. NB. Roll
		midpoint=. 10 + <. 0.5 * glPlanHitYards - defaulthit
		glPlanMeasDist=: glPlanRemGroundYards + midpoint
	elseif. glPlanRemGroundYards = 0 do. NB. Fly all the way there
		glPlanMeasDist=: ,0
	elseif. 1 do. NB. Normal stroke
		glPlanMeasDist=: glPlanRemGroundYards + 10
	end.
	glPlanCarryDist=: ,<' '
	glPlanFWWidth=: ,0
	glPlanOOBDist=: ,0
	glPlanTreeDist=: ,0
	glPlanAlt=: ,0
	glPlanBunkNumber=: ,0
	glPlanLatWaterDist=: ,0
	glPlanDefaultHit=: glPlanHitYards
	glPlanRRMounds=: ,0
	glPlanRRRiseDrop=: ,0
	glPlanRRUnpleasant=: ,0

	utKeyPut glFilepath,'_plan'
	
	if. 0=remgroundyards do. 
	    NB. Need to delete any records hanging around when there were more shots
	    utKeyRead glFilepath,'_plan'
	    ww=. glPlanHole =  h
	    ww=. ww *. glPlanTee =  t
	    ww=. ww *. glPlanGender =  g
	    ww=. ww *. glPlanAbility =  ab
	    ww=. ww *. glPlanShot > shot
	    ww=. ww *. glPlanRecType = 'P'
	    ww=. ww # glPlanID
	    ww utKeyDrop glFilepath,'_plan' 
	    continue.
	end.

	goto_shot.	

end. NB. end of abilities loop
end. NB. end of genders loop
end. NB. end of tees loop
end. NB. end of holes loop
CleanupPlan holes ; tees ; genders ; abilities
)


NB. =====================================================
NB. BuildPlanOld
NB. -----------------------------------------------------
NB. This is the monster function to loop round and build
NB. all the measurement distances
NB. Usage: BuildPlan holes ; genders ; abilities
BuildPlanOld=: 3 : 0
if. 0=L. y do. y=. 3{. <y end.
y=. 3{. y
(' ' cut 'holes genders abilities')=. y
holes=. , holes
if. 0=#holes do. holes=. i. 18 end.
genders=. ,genders
if. 0=#genders do. genders=. 0 1 end.
abilities=. , abilities
if. 0=#abilities do. abilities=. 0 1 end.

for_h. holes do.
tees=. >h{glTeesMeasured
for_t. tees do.
for_g. genders do.
if. -. t e. >g{glTeesPlayer do. continue. end. 
for_ab. abilities do.
	shot=. _1
	cumgroundyards=. 0 
	path=. LatLontoFullOS PathTeeToGreen h ; t
	remgroundyards=. <. 0.5 + glMY * +/ |(}.path) - }:path
	glTeesGroundYards=: <. 0.5+remgroundyards (< (glTees i. t), h)}glTeesGroundYards
	path=. LatLontoFullOS PathTeeToGreen h ; 0{tees
	rembackyards=. <. 0.5 + glMY * +/ |(}.path) - }:path
	cumbackyards=. rembackyards - remgroundyards
	path=. PathTeeToGreen h ; t
	start=. 0{path

	ww=. glPlanHole ~: h
	ww=. ww +. glPlanTee ~: t
	ww=. ww +. glPlanGender ~: g
	ww=. ww +. glPlanAbility ~: ab
	glPlanTee=: ww # glPlanTee
	NB. don't match shots - need to delete all for this
	NB. player on this tee
	glPlanHole=: ww # glPlanHole
	glPlanGender=: ww# glPlanGender
	glPlanAbility=: ww # glPlanAbility
	glPlanShot=: ww # glPlanShot
	glPlanHitYards=: ww # glPlanHitYards
	glPlanCumGroundYards=: ww # glPlanCumGroundYards
	glPlanBackGroundYards=: ww # glPlanBackGroundYards
	glPlanLatLon=: ww # glPlanLatLon
	glPlanLayup=: ww # glPlanLayup
	glPlanRemGroundYards=: ww # glPlanRemGroundYards


label_shot.
	NB. Remove this record
	shot=. shot + 1
	NB. Pull normal shot distance
	radius=. (<g,ab,h,shot){glPlayerLayup
	if. 0=radius do.
		radius=. (<g,ab, 1<.shot){glPlayerDistances
 		layup=. 0
	else.
		layup=. 1
	end.
	NB. If hitting beyond green, no entry	
NB.	if. radius >: (glMY * |(-/LatLontoFullOS start, _1{path)) do.  continue. end.
	
	NB. If here, we can use the intercept logic
	ww=. InterceptPath path ; start ; radius
	glPlanTee=: glPlanTee, t
	glPlanHole=: glPlanHole , h
	glPlanGender=: glPlanGender, g
	glPlanAbility=: glPlanAbility, ab
	glPlanShot=: glPlanShot, shot
	glPlanHitYards=: glPlanHitYards, 1{ww
	cumgroundyards=. <. 0.5 + cumgroundyards + 1{ww
	remgroundyards=. <. 0.5  + remgroundyards - 1{ww
	cumbackyards=. <. 0.5 + cumbackyards + 1{ww
	rembackyards=. <. 0.5 + rembackyards - 1{ww
	glPlanCumGroundYards=: glPlanCumGroundYards, cumgroundyards
	glPlanBackGroundYards=: glPlanBackGroundYards, cumbackyards
	glPlanLatLon=: glPlanLatLon, 0 {ww
	glPlanLayup=: glPlanLayup, layup
	glPlanRemGroundYards=: glPlanRemGroundYards, remgroundyards
	start=. 0{ww
	
	if. 0=remgroundyards do. continue. end.

	goto_shot.	

end. NB. end of abilities loop
end. NB. end of genders loop
end. NB. end of tees loop
end. NB. end of holes loop

NB. Sort the records
ww=. <"0 glPlanHole
ww=. ww,. <"0 glPlanBackGroundYards
ww=. ww,. <"0 glPlanGender
glPlanTee=: glPlanTee /:ww
glPlanHole=: glPlanHole /:ww
glPlanGender=: glPlanGender /:ww 
glPlanAbility=: glPlanAbility /: ww
glPlanShot=: glPlanShot /:ww 
glPlanHitYards=: glPlanHitYards /:ww 
glPlanCumGroundYards=: glPlanCumGroundYards /:ww
glPlanBackGroundYards=: glPlanBackGroundYards /: ww
glPlanLatLon=: glPlanLatLon /: ww
glPlanLayup=: glPlanLayup /: ww
glPlanRemGroundYards=: glPlanRemGroundYards /:ww

utFilePut glFilepath
)

NB. =============================================================
NB. EnKey
NB. -------------------------------------------------------------
EnKey=: 3 : 0
y=. 6{. y
('hole distance tee gender ability shot')=. y
res=. ('r<0>2.0' 8!:0 ,hole)
if. 0<#distance do.
	res=. res, each <'-'
	res=. res, each 'r<0>3.0' 8!:0 ,distance
end.
res=. res,each <'-T'
res=. res, each <"0 ,tee
res=. res, each <'-'
res=. res, each <"0 ,gender{'MW'
res=. res, each <"0 ,ability{'SB'
res=. res, each <"0 ,shot{'012345'
if. 0=$$hole do. res=. ''$res end.
)

NB. =============================================================
NB. CopyMeasure
NB. =============================================================
NB. Copy measurement point information from y to x keys
NB. -------------------------------------------------------------
CopyMeasure=: 4 : 0
to=. x
from=. y
(to, from) utKeyRead glFilepath,'_plan'
glPlanAlt=: 1 1 { glPlanAlt
glPlanFWWidth=: 1 1 { glPlanFWWidth
glPlanOOBDist=: 1 1 { glPlanOOBDist
glPlanTreeDist=: 1 1 { glPlanTreeDist
glPlanBunkNumber=: 1 1 { glPlanBunkNumber
glPlanLatWaterDist=: 1 1{glPlanLatWaterDist
glPlanRRMounds=: 1 1 { glPlanRRMounds
glPlanRRRiseDrop=: 1 1 { glPlanRRRiseDrop
glPlanRRUnpleasant=: 1 1 { glPlanRRUnpleasant
glPlanFWStance=: 1 1 { glPlanFWStance
glPlanFWWidthAdj=: 1 1 { glPlanFWWidthAdj
glPlanFWUnpleasant=: 1 1 { glPlanFWUnpleasant
glPlanFWObstructed=: 1 1 { glPlanFWObstructed
glPlanRRHeight=: 1 1 { glPlanRRHeight
glPlanRRInconsistent=: 1 1 { glPlanRRInconsistent
glPlanRRMounds=: 1 1 { glPlanRRMounds
glPlanRRRiseDrop=: 1 1 { glPlanRRRiseDrop
glPlanRRUnpleasant=: 1 1 {glPlanRRUnpleasant


utKeyPut glFilepath,'_plan'
)


NB. =============================================================
NB. CleanupPlan
NB. -------------------------------------------------------------
NB. Remove dead measurement records
NB. Usage CleanupPlan holes
NB. -------------------------------------------------------------
CleanupPlan=: 3 : 0
'holes tees genders abilities'=. y
holes=. ,<. 0.5 + holes
holes=. (holes e. i. 18) # holes

NB. Delete if a measurement record and no recordings
utKeyRead glFilepath,'_plan'
ww=. glPlanFWWidth = 0
ww=. ww *. glPlanBunkNumber = 0
ww=. ww *. glPlanAlt = 0
ww=. ww *. glPlanOOBDist = 0
ww=. ww *. glPlanTreeDist = 0
ww=. ww *. glPlanHole e. holes
ww=. ww *. glPlanRecType = 'M'
( ww # glPlanID) utKeyDrop glFilepath,'_plan'

NB. Delete if a measurement record and at the hole
utKeyRead glFilepath,'_plan'
ww=. glPlanRemGroundYards = 0
ww=. ww *. glPlanHole e. holes
ww=. ww *. glPlanRecType = 'M'
( ww # glPlanID) utKeyDrop glFilepath,'_plan'

NB. Loop round looking for duplicate 'P' and 'M' records
utKeyRead glFilepath,'_plan'
ww=. glPlanHole e. holes
ww=. ww *. glPlanTee e. tees
ww=. ww *. glPlanGender e. genders
ww=. ww *. glPlanAbility e. abilities
ww=. ww *. glPlanRecType = 'P'
uniq=. ww # glPlanID
for_u. uniq do.
	utKeyRead glFilepath,'_plan'
	ix=. glPlanID i. u
	if. 0< ix { glPlanAlt + glPlanFWWidth + glPlanBunkNumber + glPlanOOBDist + glPlanTreeDist do. continue. end.
	NB. Look for measurement point at the same distance
	ww=. glPlanHole = ix{glPlanHole
	ww=. ww *. glPlanRecType='M'
	ww=. ww *. glPlanRemGroundYards = ix{glPlanRemGroundYards
	NB. Must be non-zero because already compressed out for measurement points
	cp=. ww # glPlanID
	if. 0<$cp do.
		u CopyMeasure 0{cp NB. Only the first one
		NB. Delete measurement point because no longer needed
		cp utKeyDrop glFilepath,'_plan'
		NB. Next element in loop
		continue.
	end.
	NB. Look for ordinary point at the same distance
	ww=. glPlanHole = ix{glPlanHole
	ww=. ww *. glPlanRecType='P'
	ww=. ww *. glPlanRemGroundYards = ix{glPlanRemGroundYards
	cp=. ww # glPlanID
	if. 0<$cp do.
		u CopyMeasure 0{cp NB. Only the first one
	end.
end.
)
