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
utFilePut glFilepath
)

NB. =====================================================
NB. BuildPlan
NB. -----------------------------------------------------
NB. This is the monster function to loop round and build
NB. all the measurement distances
NB. Usage: BuildPlan holes ; genders ; abilities
BuildPlan=: 3 : 0
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
	remgroundyards=. glMY * +/ |(}.path) - }:path
	glTeesGroundYards=: <. 0.5+remgroundyards (< (glTees i. t), h)}glTeesGroundYards
	path=. LatLontoFullOS PathTeeToGreen h ; 0{tees
	rembackyards=. glMY * +/ |(}.path) - }:path
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
	if. radius >: (glMY * |(-/LatLontoFullOS start, _1{path)) do. continue. end.
	
	NB. If here, we can use the intercept logic
	ww=. InterceptPath path ; start ; radius
	glPlanTee=: glPlanTee, t
	glPlanHole=: glPlanHole , h
	glPlanGender=: glPlanGender, g
	glPlanAbility=: glPlanAbility, ab
	glPlanShot=: glPlanShot, shot
	glPlanHitYards=: glPlanHitYards, radius
	cumgroundyards=. cumgroundyards + 1{ww
	remgroundyards=. remgroundyards - 1{ww
	cumbackyards=. cumbackyards + 1{ww
	rembackyards=. rembackyards - 1{ww
	glPlanCumGroundYards=: glPlanCumGroundYards, cumgroundyards
	glPlanBackGroundYards=: glPlanBackGroundYards, cumbackyards
	glPlanLatLon=: glPlanLatLon, 0 {ww
	glPlanLayup=: glPlanLayup, layup
	glPlanRemGroundYards=: glPlanRemGroundYards, remgroundyards
	start=. 0{ww
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


NB. =====================================================
NB. slope_calc
NB. -----------------------------------------------------
NB. Calculate the number of tees required for a list of
NB. yardages
NB. Usage: gap slope_calc tees
NB. Return: list of best options
NB.
NB. If y is boxed, the first element is the list of given
NB. yardages, typically after the ladies tees have been
NB. determined
NB. -----------------------------------------------------
slope_calc=: 3 : 0
25 slope_calc y
:
NB. Unbox if necessary
if. 0 < (L. y) do.
    'given ww'=. y
    y=. ww -. given NB. Remove any already given
else.
    given=. 0$0
end.

y=. y /: y
NB. List all the options
list=. |. #: i. 2 ^ (#y)
found=. 0
gap=. _
for_ii. i. (1+#y) do. NB. Loop round with 1, 2, 3 elements etc.
	list2=. (ii= +/"1 list) # list NB. list with 1, 2, 3 elements etc.
	for_ll. list2 do.
		diff=. given, ll # y
		diff=. <./ (|(diff -/ y))
		diff=. >./diff
		if. diff <: x do. NB. found an answer
			found=. 1
			if. diff < gap do.
				gap=. diff
				ans=. given, ll # y
			end.
		end.
	end.
	if. found do. break. end.
end.
ans=. ans /: ans
)

