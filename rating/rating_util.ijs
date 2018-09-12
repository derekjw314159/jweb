NB. =====================================================
NB. Check_dogleg
NB. No longer used.  Was originally for crow-flight distance calculations.
NB. =====================================================
Check_dogleg=: 3 : 0
'hole tee gender ability'=. y
i=. <(>'r<0>2.0' 8!:0 (1+hole)),'P1'
i=. glGPSName i. i
if. i >: #glGPSName do. NB. No Pivot point
	res=. ''
	return.
end.
gps_t=. LatLontoFullOS (glGPSName i. <(>'r<0>2.0' 8!:0 (1+hole)),'T',tee) { glGPSLatLon
gps_p=. LatLontoFullOS (glGPSName i. <(>'r<0>2.0' 8!:0 (1+hole)),'P1') { glGPSLatLon
gps_g=. LatLontoFullOS (glGPSName i. <(>'r<0>2.0' 8!:0 (1+hole)),'GC') { glGPSLatLon
dist=. (<gender,ability){glPlayerDistances
NB. Convert to metres
dist=. dist % glMY
if. (0{dist) >: |gps_p - gps_t do.
	NB. Hit beyond pivot point
	res=. 'Tee shot restricted to ',": <. 0.5 + glMY * |gps_p - gps_t
	return.
else.
	NB. Have to calculate complex second shot
	res=. 'Tee shot normal ',": <. 0.5 + glMY*0{dist
	NB. Calculate pivot point 
	gps_lay=. gps_t + ((0{dist) % (|gps_p-gps_t)) * (gps_p - gps_t)
	NB. Angle between lines on fairway using scalar product
	theta=. (gps_p - gps_t), (gps_g - gps_p)
	theta=. ( */(0.5 * theta + +theta) ) - (*/ 0.5 * theta - +theta)
	theta=. theta % (|gps_p - gps_t) * (|gps_g - gps_p) 
	theta=. _2 o. theta NB. arccos
	theta=. (o. 1) - theta
	NB. Sin rule for next angle
	bit1=. (|gps_p - gps_t) - 0{dist
	alpha=. _1 o.  (1 o. theta) * bit1 % 1{dist
	beta=. (o. 1) - (theta+alpha)
	NB. Sin rule again
	bit2=. (1 o. beta) * (1{dist) % 1 o. theta
	res=. res, LF, 'second shot ', ": <. 0.5 + glMY * bit1 + bit2
	res=. res, LF, 'extra ',": <. 0.5 + glMY * bit1 + bit2 - 1{dist
end.
)
NB. Utilities for rating programme
NB. Including GPS calculations
NB. and offline updates

glMY=: 1.0936133

NB. ==============================================
NB. Global values and descriptions
NB. ==============================================
glTreeVal=: (<''),':' cut '+2 P3 Mod:+3 P3 Sig:+4 P3 Ext:+1 P4 MP(-1):.:+3 P4 Mod(-1):+4 P4 Mod:+5 P4 Sig(-1):+6 P4 Sig:+7 P4 Ext(-1):+8 P4 Ext:0 P3:0 P4' NB. Need two defaults
glTreeDesc=: ':' cut '+1 Par3 Min Prob:+2 Par3 Mod Prob:+3 Par3 Sig Prob:+4 Par3 Ext Prob:+1 Min Prob(-1):+2 Min Prob:+3 Mod Prob (-1):+4 Mod Prob:+5 Sig Prob (-1):+6 Sig Prob:+7 Ext Prob (-1):+8 Ext Prob:0 Par3:0 Trees'
glTreePar=: 3 3 3 3 4 4 4 4 4 4 4 4 3 4
glTreeNum=: 1 2 3 4 2 2 4 4 6 6 8 8 0 0
glTreeSev=: ' ' cut 'Min Mod Sig Ext Min Min Mod Mod Sig Sig Ext Ext Zer Zer'
glTreeTweener=: 0 0 0 0 _1 0 _1 0 _1 0 _1 0 0 0
glRollLevelVal=: 1 0 2{ (<''),':' cut 'Down:Up'
glRollLevelDesc=: 1 0 2 { (<''),':' cut 'Downhill:Uphill'
glRollLevelNum=: ':' cut 'Down:Level:Up'
glRollLevelText=: ':' cut 'Downhill:Level:Uphill'
glRollSlopeVal=:  (<''),':' cut 'Mod:Sig'
glRollSlopeDesc=: ':' cut 'Minor:Moderate:Significant'
glRollSlopeNum=: ':' cut 'Minor:Mod:Sig'
glRollExtremeVal=:  (<''),':' cut '+1:+2:-1:-2'
glRollExtremeDesc=:  ':' cut 'Normal Firmness:+1 Extreme Soft:+2 Extreme Soft:-1 Extreme Firm:-2 Extreme Firm'
glRollExtremeNum=: 0 1 2 _1 _2
glRollTwiceVal=:  (<''),':' cut '+1:-1'
glRollTwiceDesc=:  ':' cut 'Normal:+1 Less Cumulative Roll:-1 More Cumulative Roll'
glRollTwiceNum=: 0 1 _1
glRRRiseDropVal=: (<''),':' cut '>5'':>10'''
glRRRiseDropDesc=: ':' cut 'None:+1 >5'':+2 >10'''
glRRRiseDropNum=: 0 1 2
glRRRiseDropText=: (<''),':' cut '5-10'':gt 10'''
glTopogStanceVal=: (<''),':' cut 'MP-MA:MA:SA:EA'
glTopogStanceDesc=: ':' cut 'Minor Problem:MP-MA:Moderately Awkward:Signif Awkward:Extremely Awkward'
glTopogStanceText=: ':' cut 'MP:MP/A:MA:SA:EA'
glTopogStanceXL=: ':' cut 'MP:MP-MA:MA:SA:EA'
NB. glTopogStanceNum=: 1 2 3 4 5
glBunkFractionVal=: (<''),':' cut '<1/4:<1/2:<3/4:>3/4'
glBunkFractionDesc=: ':' cut '0:>0 to 1/4:>1/4 to 1/2:>1/2 to 3/4:>3/4'
glBunkFractionNum=: 0 1 2 3 4
glBunkFractionText=: ':' cut 'Zero:0-&frac14;:&frac14;-&frac12;:&frac12;-&frac34;:&gt;&frac34;'
glBunkDepthVal=: (<''),':' cut '2-3:3-5:5-6:6-8:8-10:10-12:12-15:>15'
glBunkDepthDesc=: ':' cut '<2'':2'' - 3'':3'' - 5'':5'' - 6'':6'' - 8'':8'' - 10'':10'' - 12'':12'' - 15'':>15'''
glBunkDepthMen=: ':' cut '<=3:<=3:>3:>3:>6:>6:>10:>10:>15'
glBunkDepthWomen=: ':' cut '<=2:>2:>2:>5:>5:>8:>8:>12:>12'
glBunkDepthText=:':' cut '&lt;2&#39;:2&#39;-3&#39;:3&#39;-5&#39;:5&#39;-6&#39;:6&#39;-8&#39;:8&#39;-10&#39;:10&#39;-12&#39;:12&#39;-15&#39;:&gt;15&#39;'
glBunkDepthNum=: 0 2.5 4 5.5 7 9 11 13.5 16
glBunkExtremeVal=: (<''),':' cut '+1:+2'
glBunkExtremeDesc=: ':' cut 'Zero:+1:+2'
glBunkExtremeNum=: 0 1 2
glBunkSqueezeVal=: (<''),':' cut '+1:+2'
glBunkSqueezeDesc=: ':' cut 'None:+1 30y wide:+2 20y wide'
glBunkSqueezeNum=: 0 1 2
glOOBCartVal=: (<''),':' cut '+1:-1'
glOOBCartDesc=: ':' cut 'None:+1 Bounce away:-1 Bounce towards'
glOOBPercentVal=: (<''),':' cut '25%:50%:75%:100%'
glOOBPercentDesc=: ':' cut '-:-25%:-50%:-75%:-100%'
glOOBPercentNum=: 0 0.25 0.5 0.75 1
glOOBBehindVal=: (<''),':' cut '-1:-2'
glOOBBehindDesc=: ':' cut '-:-1 Behind:-2 Behind'
glOOBBehindNum=: 0 _1 _2
glTransitionAdjVal=: (<''),':' cut '+1:-1'
glTransitionAdjDesc=: ':' cut 'None:+1 GC front of TZ:-1 GC back of TZ'
glTransitionAdjNum=: 0 1 _1
glTransitionOverrideVal=: (<''),':' cut 'Y:N'
glTransitionOverrideDesc=: ':' cut 'None:Yes:No'
glTransitionOverrideNum=: 0 1 _1
glRRInconsistentVal=: (<''),':' cut '+1:-1'
glRRInconsistentDesc=: ':' cut 'None:+1 Harder:-1 Easier'
glWaterFractionVal=: (<''),':' cut '1/4-<1/2:>1/2'
glWaterFractionDesc=: ':' cut '0 - 1/4:1/4 - 1/2:>1/2'
glWaterFractionNum=: 0 1 2
glWaterFractionText=: (<''),':' cut '&lt;&frac12;:&gt;&frac12;'
glWaterSurrDistVal=: (<''),':' cut '1-4:5-10:11-20:>20'
glWaterSurrDistDesc=: ':' cut 'None:1 - 4:5 - 10:11 - 20:>20'
glWaterSurrDistNum=: 0 3 2 1 0
glWaterSurrDistText=: (<''),':' cut '1&#215;-4&#215;:5&#215;-10&#215;:11&#215;-20&#215;:&gt;20&#215;'
glWaterCartVal=: (<''),':' cut '+1:-1'
glWaterCartDesc=: ':' cut 'None:+1 Bounce away:-1 Bounce towards'
glWaterPercentVal=: (<''),':' cut '25%:50%:75%:100%'
glWaterPercentDesc=: ':' cut '-:-25%:-50%:-75%:-100%'
glWaterPercentNum=: 0 0.25 0.5 0.75 1
glWaterBehindVal=: (<''),':' cut '-1:-2'
glWaterBehindDesc=: ':' cut '-:-1 Behind:-2 Behind'
glWaterBehindNum=: 0 _1 _2
glTargVisibleVal=: (<''),':' cut '+1:+2'
glTargVisibleDesc=: (<''),':' cut '+1 gt Half Green:+2 Flag'
glGrFirmnessVal=: (<''),':' cut 'firm:soft'
glGrFirmnessDesc=: ':' cut 'Av:+1 Firm:-1 Soft'
glGrFirmnessNum=: 0 1 _1
glFWWidthAdjVal=: (<''),':' cut '+1 red:+2 very:-1 bounce:-1 gentle:-2 very'
glFWWidthAdjDesc=: ':' cut 'No Adj:+1 Reduced:+2 Very Reduced:-1 Bounce Back:-1 Gentle Rough:-2 Very Gentle Rough'
glFWWidthAdjNum=: 0 1 2 _1 _1 _2
glLayupCategoryVal=: (<''), ':' cut 'dogleg:forced:choice:dcc'
glLayupCategoryDesc=: ':' cut 'None:Dogleg:Forced Layup:Layup by Choice:Dogleg Neg'
glLayupCategoryText=: (<''), ':' cut 'DLU:FLU:CLU:DCC'
glGrContourVal=: (<''),':' cut 'MC:HC'
glGrContourDesc=: ':' cut 'RF/GS:MC/MS:HC/SS'
glGrVisibilityVal=: (<''),':' cut '+1:+2'
glGrVisibilityDesc=: ':' cut 'OK:+1 less than 1/2 visible:blind'
glTargVisibleNum=: 0 1 2


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
NB. Usage:
NB.		ReadGPS ''
NB.	File context is automatic.  Converts .txt file to global variables.
NB. ============================================
ReadGPS=: 3 : 0
require 'tables/csv'
ww=. readcsv glDocument_Root,'/yii/',glBasename,'/protected/data/',y,'.txt'
res=. (0{ww) i. 'Latitude' ; 'Longitude' ; 'Altitude' ; 'Time' ; 'Name' ; 'Icon' ; 'Description'
res=. res {"1 (ww,"1 a:) NB. Order the columns
res=. }. res NB. Drop the row titles
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

NB. ============================================
NB. ReadGPSActual
NB. --------------------------------------------
NB. Read GPS actual file
NB. Usage:
NB.		ReadGPSActual ''
NB.	Returns a javascript format set of coordinates
NB. ============================================
ReadGPSActual=: 3 : 0
require 'tables/csv'
if. -. fexist (glFilepath,'actual.txt') do.
	res=. '[]'
	return.
end.
ww=. readcsv glFilepath,'actual.txt'
res=. (0{ww) i. 'Latitude' ; 'Longitude' ; 'Altitude' ; 'Time' ; 'Name' ; 'Icon' ; 'Description'
res=. res {"1 (ww,"1 a:) NB. Order the columns
res=. }. res NB. Drop the row titles
latlon=. 2 0 3 1 4{"1 (0 1{"1 res),"1 (LF,'   new google.maps.LatLng(') ; ', ' ; '),'
latlon=. '   [',(}: ;latlon),LF,'   ]'
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
res=. I. ((<string,'P') = (3{. each glGPSName) ) NB. Pivot points
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
NB. InterceptPathold
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
NB. and the fairway distance (not the crow's flight)
NB. and the vector of the direction (in OSGB units)
NB. ----------------------------------------------
InterceptPath=: 3 : 0
(' ' cut 'path start radius')=. y
radius=. radius % glMY NB. Need to do the geometry in meters

NB. Assume the green is the last point in path, and
NB. delete any points further away than the start
path=. LatLontoFullOS path
start=. LatLontoFullOS start
path=.((| path - _1{path) < (|start - _1{path)) # path

NB. If first point of path is further than radius, simple calc because point is on first leg
if. radius < (|start - 0{path) do.
    prop=. radius % (|start -0{path)
    res=. start + prop * (0{path) - start
    res=. FullOStoLatLon res
    res=. res, <. 0.5 + radius * glMY
    blarge=. (0{path) - start
    res=. res, blarge % |blarge NB. One metre long
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
    blarge=. - / _1 _2{path
    res=. res, blarge % |blarge NB. One metre long
    return.
end.

NB. Need to find out which chunk of the path is crossed by radius
dist=.( length > radius) i. 1
NB. Need to imagine a triangle with point <B> at the start
NB. length of b
b=. radius - (dist-1){length
blarge=. -/ (dist,dist-1) { path
res=. ((dist-1){path) + (b % |blarge) * blarge NB. Proportion along this length
res=. FullOStoLatLon res
res=. res, <. 0.5 + glMY * radius
res=. res, blarge % |blarge NB. One metre long

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
y=. (y e. Holes '' ) # y NB. Limit to valid holes

NB. Delete any infeasible
msk=. +. glGPSLatLon
msk=. (90 >: 0{"1 msk) *. (180 >: 1{"1 msk) *. (0 <: 0{"1 msk) *. (_180 <: 1{"1 msk)
NB. msk=. msk *. glGPSMeasured
glGPSName=: msk # glGPSName
glGPSLatLon=: msk # glGPSLatLon
glGPSAlt=: msk#glGPSAlt
glGPSMeasured=: msk # glGPSMeasured

for_h. y do. NB. Start of hole loop <h>
	NB. Delete any unmeasured for this hole, i.e. keep if measured, or if different hole
	msk=.  (2{.each glGPSName) ~: (<;'r<0>2.0' 8!:0 (1+h))
	msk=. msk +. glGPSMeasured
	glGPSName=: msk # glGPSName
	glGPSLatLon=: msk # glGPSLatLon
	glGPSAlt=: msk#glGPSAlt
	glGPSMeasured=: msk # glGPSMeasured

    NB. Green centres
    xx=. ('r<0>2.0' 8!:0 (1+h)),each(' ' cut 'GC GF GB')
    xx=. glGPSName i. xx
    if. (0{xx) < #glGPSName do. continue. end. NB. already exist
	NB. Check if GF and GB exists
	if. *. / (1 2{xx) < #glGPSName do.
		latlon=. LatLontoFullOS (1 2{xx)  { glGPSLatLon
		latlon=. 0.5 * +/ latlon NB. average of two positions
		latlon=. FullOStoLatLon latlon
		glGPSLatLon=: glGPSLatLon, latlon
		glGPSAlt=: glGPSAlt, 0.5 * +/ 1 2 {glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. Check if any other points exist for this hole
	elseif.  (+. / (ww=. (2{. each glGPSName) i. ('r<0>2.0' 8!:0 (1+h))) < #glGPSName) do.
		ww=. 0{ (ww < #glGPSName)#ww NB. First one which meets criterion
		glGPSLatLon=: glGPSLatLon, ww{glGPSLatLon + 0j0.0005 NB. Need to add a few yards to avoid clash
		glGPSAlt=: glGPSAlt, ww{glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. Check if green reading exists for previous hole
	elseif. ( +. / (ww=. (3{. each glGPSName) i. ('r<0>2.0' 8!:0 (0+h)),each <'G') < #glGPSName) do.
		ww=. 0{ (ww < #glGPSName)#ww NB. First one which meets criterion
		glGPSLatLon=: glGPSLatLon, ww{glGPSLatLon
		glGPSAlt=: glGPSAlt, ww{glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. Check if any reading exists on previous hole
	elseif.  (+. / (ww=. (2{. each glGPSName) i. ('r<0>2.0' 8!:0 (0+h))) < #glGPSName) do.
		ww=. 0{ (ww < #glGPSName)#ww NB. First one which meets criterion
		glGPSLatLon=: glGPSLatLon, ww{glGPSLatLon
		glGPSAlt=: glGPSAlt, ww{glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. Check if tee reading exists for next hole
	elseif. ( +. / (ww=. (3{. each glGPSName) i. ('r<0>2.0' 8!:0 (2+h)),each <'T') < #glGPSName) do.
		ww=. 0{ (ww < #glGPSName)#ww NB. First one which meets criterion
		glGPSLatLon=: glGPSLatLon, ww{glGPSLatLon
		glGPSAlt=: glGPSAlt, ww{glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. Check if any reading exists on next hole
	elseif.  (+. / (ww=. (2{. each glGPSName) i. ('r<0>2.0' 8!:0 (2+h))) < #glGPSName) do.
		ww=. 0{ (ww < #glGPSName)#ww NB. First one which meets criterion
		glGPSLatLon=: glGPSLatLon, ww{glGPSLatLon
		glGPSAlt=: glGPSAlt, ww{glGPSAlt
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. Check if any reading exists anywhere
	elseif.  (0<#glGPSName)  do.
		latlon=. LatLontoFullOS glGPSLatLon
		latlon=. FullOStoLatLon (+/latlon) % #latlon NB. Take average
		glGPSLatLon=: glGPSLatLon, latlon
		glGPSAlt=: glGPSAlt, (+/glGPSAlt)% (#glGPSAlt)
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	NB. If all else fails, do a radius around the BBO office
	elseif. 1 do.
		glGPSLatLon=: glGPSLatLon, 51.72926843499641j_1.0429796775924842
		glGPSAlt=: glGPSAlt, 0
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		glGPSMeasured=: glGPSMeasured, 0
	end.
end.  NB. end of first hole loop


for_h. y do. NB. Start of hole loop <h>

	NB. See if back tee exists first
	t=. 0{glTees
    xx=. <(>'r<0>2.0' 8!:0 (1+h)),'T',t
    xx=. glGPSName i. xx
    if. (xx = #glGPSName) do.
	    xx=. <(>'r<0>2.0' 8!:0 (1+h)),'GC'
		xx=. glGPSName i. xx
		latlon=. FullOStoLatLon (LatLontoFullOS xx{glGPSLatLon) - 150j0 NB. Adjust by 150m
	    glGPSLatLon=: glGPSLatLon, latlon
	    glGPSAlt=: glGPSAlt, xx{glGPSAlt
	    glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+h)),'T',t
	    glGPSMeasured=: glGPSMeasured, 0
	end.

    NB. Other tees
    for_t. }. glTees do. NB. start of tee loop
	    xx=. <(>'r<0>2.0' 8!:0 (1+h)),'T',t
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

NB. Finally, adjust tee position to be the same as the card yardage
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
NB. '1' + 0
if. 0=L. y do. y=. 4{. <y end.
y=. 4{. y
(' ' cut 'holes tees genders abilities')=. y
holes=. , holes
if. 0=#holes do. holes=. (Holes '') end.
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

for_t. tees do. NB. Only relevant tees for the hole was the old logic, now need to do all in case ..
NB. .. tee has been added or deleted

for_g. genders do.
NB. Remove condition for women not playing white tees - control is all with <<glTeMeasured>>
NB. if. -. t e. >g{glTeesPlayer do. continue. end. 

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
	    NB. Write out measurement points with existing values
	    key=. ww{glPlanID
	    key utKeyRead glFilepath,'_plan'
	    newkey=. 'r<0>2.0' 8!:0 glPlanHole
	    newkey=. newkey ,each <'-'
	    newkey=. newkey ,each 'r<0>3.0' 8!:0 glPlanRemGroundYards
	    glPlanHitYards=: (#key) $0
	    glPlanCrowDist=: (#key) $0
	    glPlanUpdateName=: (#key)$<": getenv 'REMOTE_USER'
	    glPlanUpdateTime=: (#key)$< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
	    glPlanLayupType=: (#key)$,' '
	    glPlanRecType=: (#key)$,'M'
	    glPlanCarryType=: (#key)$,' '
	    glPlanCarryAffectsTee=: (#key)$,' '
	    glPlanSqueezeType=: (#key)$,' '
	    glPlanSqueezeWidth=: (#key)$0
	    glPlanID=: newkey
	    utKeyPut glFilepath,'_plan'
	    key utKeyDrop glFilepath,'_plan' 
    end.
    continue. NB. Loop to next gender
end.

for_ab. abilities do.
    shot=. _1
    previouslayup=. ,' '
    cumgroundyards=. 0 
    path=. LatLontoFullOS PathTeeToGreen h ; t
    remgroundyards=. <. 0.5 + glMY * +/ |(}.path) - }:path
    NB. glTeesGroundYards=: <. 0.5+remgroundyards (< (glTees i. t), h)}glTeesGroundYards
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
	    glPlanLayupType=: ,' '
	    glPlanLayupCategory=: ,<''
	    glPlanLayupReason=: ,<''
    elseif. 1=$ww do.
	    ww utKeyRead glFilepath,'_plan'
	    NB. player on this tee
	    NB. Should only be one record
	    NB. Write out a Measurement Point
	    newkey=. EnKey h ; glPlanMeasDist ; t ; g ;ab ; shot
	    newkey=. <6 {. >newkey NB. Just need first six characters
	    glPlanHitYards=: ,0
	    glPlanCrowDist=: ,0
	    glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
	    glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
	    glPlanLayupType=: ,' '
	    glPlanRecType=: ,'M'
	    glPlanCarryType=: ,' '
	    glPlanCarryAffectsTee=: ,' '
	    glPlanSqueezeType=: ,' '
	    glPlanID=: ,newkey
	    utKeyPut glFilepath,'_plan'
	    
	    NB. Read it back again
	    ww utKeyRead glFilepath,'_plan'
    end.

    NB. Pull normal shot distance
    NB. Check if there is a layup record
    defaulthit=.  (<g,ab, 1<.shot){glPlayerDistances
    if. ( glPlanLayupType e. 'LR') do. NB. Found
	    radius2=. ''$ glPlanHitYards
	    previouslayup=. ((glPlanLayupType='L'){' L'),previouslayup NB. need to know if previous shot was layup for transition
    else.
	    radius2=. ''$ defaulthit
	    glPlanLayupType=: ,' '
	    previouslayup=. ' ',previouslayup
    end.
    ww=. InterceptPath path ; start ; radius2
    NB. New logic for transition within 10 yards of 
	NB. of the green for a Par 3 or 20 for Par 4/5
	trans_dist=. shot { 10 20 20 20 20 20 
	rem=. remgroundyards - <. 0.5 + 1{ww NB. THIS LINE
	NB. Logic is now changed to only add 'T' if within 20 yards
	NB. i.e. don'e extend previous shot
	NB. if. ( 0 < rem) *. (trans_dist >: rem) *. (glPlanLayupType=' ') do.
	if. ( remgroundyards > 0) *. ( remgroundyards <: trans_dist ) *. (glPlanLayupType=' ') *. ' '=1{previouslayup do. NB. second element of previous layup
		NB. radius2=. radius2 + rem
		NB. ww=. InterceptPath path ; start ; radius2
		glPlanLayupType=: ,'T'
	end.

	NB. glPlanID already exists
	glPlanTee=: ,t
	glPlanHole=: ,h
	glPlanGender=: ,g
	glPlanAbility=: ,ab
	glPlanShot=: ,shot
	ClearPlanRecord '' NB. Zero numerics
	glPlanHitYards=: , <. 0.5+ 1{ww
	cumgroundyards=. <. 0.5 + cumgroundyards + 1{ww
	remgroundyards=. <. 0.5  + remgroundyards - 1{ww NB. THIS LINE
	cumbackyards=. <. 0.5 + cumbackyards + 1{ww
	glPlanCumGroundYards=: ,cumgroundyards
	glPlanLatLon=: , 0{ww
	glPlanRemGroundYards=: ,remgroundyards
	glPlanRecType=: ,'P'
	glPlanCarryType=: ,' '
	glPlanCarryAffectsTee=: ,' '
	glPlanSqueezeType=: ,' '
	glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
	glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
	glPlanCrowDist=: ,<.0.5 + glMY * | -/LatLontoFullOS start, 0{ww
	start=. 0{ww
	NB. Measurepoint is in middle of roll
	if. glPlanRecType ~: 'P' do.
		glPlanMeasDist=: glPlanRemGroundYards NB. Should not get here
	elseif. glPlanLayupType =  'R' do. NB. Roll
		NB. midpoint=. 10 + <. 0.5 * glPlanHitYards - defaulthit
		NB. glPlanMeasDist=: glPlanRemGroundYards + midpoint
		NB. New logic to use roll variable
		glPlanMeasDist=: <. 0.5 + glPlanRemGroundYards + 0.5 * glPlanRollDist
	elseif. glPlanRemGroundYards = 0 do. NB. Fly all the way there
		glPlanMeasDist=: ,0
		glPlanRollDist=: ,0
	elseif. 1 do. NB. Normal stroke
		NB. glPlanMeasDist=: glPlanRemGroundYards + 10
		glPlanRollDist=: ,20
		glPlanMeasDist=: <. 0.5 + glPlanRemGroundYards + 0.5 * glPlanRollDist
	end.
	glPlanCarryDist=: ,<' '
	glPlanFWWidth=: ,0
	glPlanOOBDist=: ,0
	glPlanOOBLine=: ,0
	glPlanTreeDist=: ,0
	glPlanAlt=: ,0
	glPlanTopogStance=: ,<''
	glPlanBunkLZ=: ,0
	glPlanBunkLine=: ,0
	glPlanBunkExtreme=: ,<''
	glPlanBunkLZCarry=: ,0
	glPlanBunkTargCarry=: ,0
	glPlanBunkSqueeze=: ,<''
	glPlanTransitionAdj=: ,<''
	glPlanTransitionOverride=: ,<''
	glPlanLatWaterDist=: ,0
	glPlanWaterLine=: ,0
	if. (glPlanLayupType='L') *. (glPlanLayupCategory ~: <'choice') do.
	    glPlanDefaultHit=: ,defaulthit
	else.
	    glPlanDefaultHit=: glPlanHitYards
	end.
	glPlanFWVisible=: ,0
	glPlanFWTargVisible=: ,<''
	glPlanFWUnpleasant=: ,0
	glPlanRRMounds=: ,0
	glPlanRRRiseDrop=: ,0
	glPlanRRUnpleasant=: ,0
	glPlanRRInconsistent=: ,0
	glPlanRollExtreme=: ,<''
	glPlanRollTwice=: ,<''
	glPlanSqueezeWidth=: ,0
	glPlanCarryType=: ,' '
	glPlanCarryAffectsTee=: ,' '
	glPlanSqueezeType=: ,' '
	glPlanBunkCarry=: ,<''
	NB. Don't reset the layup or roll stuff as it has just been entered
	NB.	glPlanLayupCategory=: ,<''
	NB.	glPlanLayupReason=: ,<''

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
NB. CopyPlanRecord
NB. =============================================================
NB. Copy measurement point information from y to x keys
NB. -------------------------------------------------------------
CopyPlanRecord=: 4 : 0
to=. x
from=. y
(to, from) utKeyRead glFilepath,'_plan'
glPlanAlt=: 1 1 { glPlanAlt
glPlanFWWidth=: 1 1 { glPlanFWWidth
glPlanOOBDist=: 1 1 { glPlanOOBDist
glPlanOOBPercent=: 1 1 { glPlanOOBPercent
glPlanOOBLine=: 1 1 { glPlanOOBLine
glPlanTreeDist=: 1 1 { glPlanTreeDist
glPlanTreeRecov=: 1 1 { glPlanTreeRecov
glPlanBunkLZ=: 1 1 { glPlanBunkLZ
glPlanBunkLine=: 1 1 { glPlanBunkLine
glPlanBunkExtreme=: 1 1 { glPlanBunkExtreme
glPlanBunkLZCarry=: 1 1 { glPlanBunkLZCarry
glPlanBunkTargCarry=: 1 1 { glPlanBunkTargCarry
glPlanBunkSqueeze=: 1 1 { glPlanBunkSqueeze
glPlanTransitionAdj=: 1 1 { glPlanTransitionAdj
glPlanTransitionOverride=: 1 1 { glPlanTransitionOverride
glPlanLatWaterDist=: 1 1{glPlanLatWaterDist
glPlanWaterPercent=: 1 1{glPlanWaterPercent
glPlanWaterLine=: 1 1 { glPlanWaterLine
glPlanRRMounds=: 1 1 { glPlanRRMounds
glPlanRRRiseDrop=: 1 1 { glPlanRRRiseDrop
glPlanRRUnpleasant=: 1 1 { glPlanRRUnpleasant
glPlanTopogStance=: 1 1 { glPlanTopogStance
glPlanFWWidthAdj=: 1 1 { glPlanFWWidthAdj
glPlanFWVisible=: 1 1 { glPlanFWVisible
glPlanFWTargVisible=: 1 1 { glPlanFWTargVisible
glPlanFWUnpleasant=: 1 1 { glPlanFWUnpleasant
glPlanFWObstructed=: 1 1 { glPlanFWObstructed
glPlanTreeTargObstructed=: 1 1 { glPlanTreeTargObstructed
glPlanTreeLZObstructed=: 1 1 { glPlanTreeLZObstructed
glPlanRRHeight=: 1 1 { glPlanRRHeight
glPlanRRInconsistent=: 1 1 { glPlanRRInconsistent
glPlanRRMounds=: 1 1 { glPlanRRMounds
glPlanRRRiseDrop=: 1 1 { glPlanRRRiseDrop
glPlanRRUnpleasant=: 1 1 {glPlanRRUnpleasant
glPlanRollLevel=: 1 1{glPlanRollLevel
glPlanRollSlope=: 1 1 {glPlanRollSlope
glPlanRollExtreme=: 1 1 {glPlanRollExtreme
glPlanRollTwice=: 1 1 {glPlanRollTwice
glPlanDoglegNeg=: 1 1 {glPlanDoglegNeg
glPlanBunkCarry=: 1 1 {glPlanBunkCarry

utKeyPut glFilepath,'_plan'
)


NB. =============================================================
NB. CleanupPlan
NB. -------------------------------------------------------------
NB. Remove dead measurement records
NB. Usage CleanupPlan holes
NB. -------------------------------------------------------------
CleanupPlan=: 3 : 0
NB.  '1' + 0
'holes tees genders abilities'=. y
holes=. ,<. 0.5 + holes
holes=. (holes e. Holes '') # holes	NB. Augmented to cover >18 holes

NB. Delete if a measurement record and no recordings
utKeyRead glFilepath,'_plan'
ww=. glPlanFWWidth = 0
ww=. ww *. glPlanBunkLZ = 0
ww=. ww *. glPlanBunkLine = 0
ww=. ww *. glPlanAlt = 0
ww=. ww *. glPlanOOBDist = 0
ww=. ww *. glPlanTreeDist = 0
ww=. ww *. glPlanHole e. holes
ww=. ww *. glPlanRecType = 'M'
NB. Need to retain if there is a roll measurement
ww=. ww *. 0 = >#each glPlanRollLevel
ww=. ww *. 0 = >#each glPlanRollSlope
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
	if. 0< ix { glPlanAlt + glPlanFWWidth + glPlanBunkLZ + glPlanBunkLine + glPlanOOBDist + glPlanTreeDist do. continue. end.
	NB. Look for measurement point at the same distance
	ww=. glPlanHole = ix{glPlanHole
	ww=. ww *. glPlanRecType='M'
	ww=. ww *. glPlanMeasDist = ix{glPlanMeasDist
	NB. Must be non-zero because already compressed out for measurement points
	cp=. ww # glPlanID
	if. 0<$cp do.
		u CopyPlanRecord 0{cp NB. Only the first one
		NB. Delete measurement point because no longer needed
		cp utKeyDrop glFilepath,'_plan'
		NB. Next element in loop
		continue.
	end.
	NB. Look for ordinary point at the same distance
	ww=. glPlanHole = ix{glPlanHole
	ww=. ww *. glPlanRecType='P'
	ww=. ww *. glPlanMeasDist = ix{glPlanMeasDist
	cp=. ww # glPlanID
	if. 0<$cp do.
		u CopyPlanRecord 0{cp NB. Only the first one
	end.
end.

NB. Add carry to fairway if not already there
for_h. holes do.
    utKeyRead glFilepath,'_plan'
    ww=. glPlanHole = h
    ww=. ww *. glPlanRecType='C'
    ww=. I. ww
    if. 0=#ww do.
		ind=. 0
    else.
		continue.
    end.
    keyy=. ,< (;'r<0>2.0' 8!:0 h),'-C',": ind
    (,<'_default') utKeyRead glFilepath,'_plan'
    glPlanID=: keyy
    glPlanHole=: h
    t_index=. _1 + #glTees
    dist=. (<t_index,h){glTeesYards NB. i.e. assume at shortest "Red" tee
    glPlanTee=: 0{glTees NB. assume measured from longest "White" tee
    glPlanGender=: ,_1
    glPlanAbility=: ,_1
    glPlanShot=: ,_1
    glPlanRemGroundYards=: ,dist
    glPlanMeasDist=: ,dist
    glPlanRecType=: ,'C'
    glPlanCarryType=: ,'F'
    glPlanCarryAffectsTee=: ,' '
    utKeyPut glFilepath,'_plan'
end.
)

NB. ===========================================================
NB. ClearPlanRecord
NB. ===========================================================
ClearPlanRecord=: 3 : 0
NB. Don't overwrite the key, tee, hole etc
NB. glPlanID
NB. glPlanTee=: ,t
NB. glPlanHole=: ,h
NB. glPlanGender=: ,g
NB. glPlanAbility=: ,ab
NB. glPlanShot=: ,shot
NB. glPlanRecType
glPlanHitYards=: , 0
glPlanCrowDist=: ,0
glPlanCumGroundYards=: ,0
glPlanLatLon=: , 0
glPlanRemGroundYards=: ,0
glPlanCarryType=: ,' '
glPlanCarryAffectsTee=: ,' '
glPlanSqueezeType=: ,' '
glPlanSqueezeWidth=: ,0
glPlanUpdateName=: ,<": getenv 'REMOTE_USER'
glPlanUpdateTime=: ,< 6!:0 'YYYY-MM-DD hh:mm:ss.sss'
glPlanMeasDist=: ,0
NB. glPlanRollDist=: ,0
glPlanCarryDist=: ,<' '
glPlanOOBDist=: ,0
glPlanOOBPercent=: ,<''
glPlanOOBLine=: ,0
glPlanTreeDist=: ,0
glPlanAlt=: ,0
glPlanBunkLZ=: ,0
glPlanBunkLine=: ,0
glPlanBunkExtreme=: ,<''
glPlanBunkLZCarry=: ,0
glPlanBunkTargCarry=: ,0
glPlanBunkSqueeze=: ,<''
glPlanTransitionAdj=: ,<''
glPlanTransitionOverride=: ,<''
glPlanLatWaterDist=: ,0
glPlanWaterPercent=: ,<''
glPlanWaterLine=: ,0
glPlanDefaultHit=: ,0
glPlanRRHeight=: ,0
glPlanRRInconsistent=:,0
glPlanRRMounds=: ,0
glPlanRRRiseDrop=: ,0
glPlanRRUnpleasant=: ,0
glPlanRollExtreme=: ,(#glPlanID)$<''
glPlanRollTwice=: ,(#glPlanID)$<''
glPlanFWWidth=: ,(#glPlanID)$<0 
glPlanFWObstructed=: ,(#glPlanID)$0
glPlanTreeTargObstructed=: ,(#glPlanID)$0
glPlanTreeLZObstructed=: ,(#glPlanID)$0
glPlanTopogStance=: ,(#glPlanID)$<''
glPlanFWVisible=: ,(#glPlanID)$<''
glPlanFWTargVisible=: ,(#glPlanID)$<''
glPlanFWUnpleasant=: ,(#glPlanID)$0
glPlanFWWidthAdj=: ,(#glPlanID)$<''
glPlanDoglegNeg=: ,(#glPlanID)$0
glPlanBunkCarry=: ,(#glPlanID)$<''
)

InitiateCourse=: 3 : 0
NB. =====================================================================
NB. InitiateCourse
NB. =====================================================================
NB. Usage:
NB.    InitiateCourse pi ; 4 4 , 5 5 , ..  (pars)
NB.
NB. 1. Copy seven files from the latest one
NB. 2. Alter glCourseName, glCourseLead, glCourseDate and write to glFilepath
NB. 3. Alter glTeesYards and write to glFilepath
NB. 4. Alter glTees, glTeesName and write to glFilepath
NB. 5. Create kml file in GoogleEarth
NB. 6. Use gpsbabel to convert to unicsv, saving as ".txt" file
NB. 7. Run ReadGPS and save to glFilepath
NB. 8. Run this function InitiateCourse pi (for safety)
NB. 4. Execute:  glTePar=: ((18*$glTees),2)$,1 0 2 |:(($glTees),18 2)$,18 2 $ 4 4, 5 5 , 3 3 5 3 4 ... and write to '.._tee'
'pi par'=. y
if. pi ~: 3.14159 do. return. end.
utFileGet glFilepath
NB. Clear out the plan records
utKeyRead glFilepath,'_plan'
((glPlanHole>:0)#glPlanID) utKeyDrop glFilepath,'_plan' NB. Ignore '_default'
NB. Clear tee altitudes
utKeyRead glFilepath,'_tee'
glTeID utKeyDrop glFilepath,'_tee'
holes=. $Holes ''
glTeUpdateName=: (holes*$glTees)$<''
glTeUpdateTime=: glTeUpdateName
glTeAlt=: ($glTeUpdateName)$0
glTePar=: ((holes*$glTees),2)$,1 0 2 |:(($glTees),holes, 2)$,(holes, 2) $ par
ww=.(3 4 5 i. glTePar){('' ; '.' ; '.')
glTeTree=: (($ww),2)$,ww,"1 ww NB. Have to add extra dimension for the ability
glTeTee=: ($glTeUpdateName)$ ; {. each glTeesName
glTePlayer=: (($glTeUpdateName),2)$1 0
glTeMeasured=: glTePlayer
glTeHole=: , |: (($glTees),holes)$glHoleOffset + i. holes
glTeID=: (,|: (($glTees),holes)$'r<0>2.0' 8!:0 glHoleOffset + i. holes),each ($glTeUpdateName)${. each glTeesName
utKeyPut glFilepath,'_tee'
NB. Clear green 
utKeyRead glFilepath,'_green'
glGrID utKeyDrop glFilepath,'_green'
glGrHole=: glHoleOffset + i. holes
glGrID=: 'r<0>2.0' 8!:0 glHoleOffset + i. holes
glGrAlt=: 0 * glGrAlt
glGrLength=: ($glGrID)$0
glGrWidth=: ($glGrWidth)$0
glGrDiam=: ($glGrID)$0
glGrCircleConcept=: ($glGrID)$0
glGrVisibility=: ($glGrID)$<''
glGrObstructed=: ($glGrID)$0 NB. Not used
glGrTiered=: ($glGrID)$0
glGrFirmness=: ($glGrID)$<''
glGrWaterPercent=: ($glGrID)$<''
glGrWaterDist=: ($glGrID)$0
glGrContour=: ($glGrID)$<''
glGrTee=: ($glGrID)$'W'
glGrOOBDist=: ($glGrID)$0
glGrTreeDist=: ($glGrID)$0
glGrTreeRecov=: ($glGrID)$<''
glGrFrontYards=: ($glGrID)$0
glGrSurfaceUnpleasant=: ($glGrID)$0
glGrRRUnpleasant=: ($glGrID)$0
glGrTree=: ($glGrID)$<''
glGrTreeTween=: ($glGrID)$0
glGrRRInconsistent=: ($glGrID)$<''
glGrRRMounds=: ($glGrID)$0
glGrRRRiseDrop=: ($glGrID)$<''
glGrBunkFraction=: ($glGrID)$<''
glGrBunkDepth=: ($glGrID)$<''
glGrBunkExtreme=: ($glGrID)$<''
glGrOOBBehind=: ($glGrID)$<''
glGrOOBCart=: ($glGrID)$<''
glGrOOBPercent=: ($glGrID)$<''
glGrWaterBehind=: ($glGrID)$<''
glGrWaterCart=: ($glGrID)$<''
glGrWaterPercent=: ($glGrID)$<''
glGrWaterFraction=: ($glGrID)$<''
glGrWaterSurrDist=: ($glGrID)$<''
glGrNotes=: ($glGrID)$<''
utKeyPut glFilepath,'_green'
AugmentGPS glHoleOffset + i. holes
BuildPlan glHoleOffset + i. holes
)

NB. =======================================================
NB. CheckMainFile
NB. =======================================================
NB. Check if extra variables exist
CheckMainFile=: 3 : 0
utFileGet glFilepath
if. 0 ~: 4!:0 <'gl9Hole' do.
	gl9Hole=: 0
	glHoleOffset=: 0
	(cut 'gl9Hole glHoleOffset') utFilePut glFilepath
end.
)


NB. ========================================================
NB. CheckPlanFile
NB. ========================================================
NB. Safe read of plan and checks for new variables
CheckPlanFile=: 3 : 0
utKeyRead y
dict=. >keyread y ; '_dictionary'
CheckFileItem y ; 'glPlanRollDist' ; dict ; (#glPlanID) ; 20
CheckFileItem y ; 'glPlanRollSlope' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanRollExtreme' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanDoglegNeg' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanCrowDist' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanCarryAffectsTee' ; dict ; (#glPlanID) ; ' '
CheckFileItem y ; 'glPlanTransitionAdj' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanTopogStance' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanTransitionOverride' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanFWVisible' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanFWTargVisible' ; dict ; (#glPlanID) ; <,<'' 
CheckFileItem y ; 'glPlanRRMounds' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanBunkLZ' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanBunkLine' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanBunkLZCarry' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanBunkTargCarry' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanBunkExtreme' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanBunkSqueeze' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanOOBPercent' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanOOBLine' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanWaterPercent' ; dict ; (#glPlanID) ; <,<''
CheckFileItem y ; 'glPlanWaterLine' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanTreeTargObstructed' ; dict ; (#glPlanID) ; 0
CheckFileItem y ; 'glPlanTreeLZObstructed' ; dict ; (#glPlanID) ; 0
)

NB. ========================================================
NB. CheckFileItem
NB. ========================================================
CheckFileItem=: 3 : 0
'filename column dict len value'=. y
if. ( -. (<column) e. dict ) do.
	(,<column) utKeyAddColumn filename
	(column)=: len$value
	utKeyPut filename
end.
)

NB. ========================================================
NB. CheckGreenFile
NB. ========================================================
NB. Safe read of plan and checks for new variables
CheckGreenFile=: 3 : 0
utKeyRead y
dict=. >keyread y ; '_dictionary'
CheckFileItem y ; 'glGrRRInconsistent' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrRRRiseDrop' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrRRUnpleasant' ; dict ; (#glGrID) ; 0
CheckFileItem y ; 'glGrRRMounds' ; dict ; (#glGrID) ; 0
CheckFileItem y ; 'glGrBunkFraction' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrBunkDepth' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrBunkExtreme' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrOOBBehind' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrOOBCart' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrOOBPercent' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrWaterBehind' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrWaterFraction' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrWaterSurrDist' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrWaterCart' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrWaterPercent' ; dict ; (#glGrID) ; <,<''
CheckFileItem y ; 'glGrSurfaceUnpleasant' ; dict ; (#glGrID) ; 0
CheckFileItem y ; 'glGrNotes' ; dict ; (#glGrID) ; <,<''
)

NB. ========================================================
NB. CheckTeeFile
NB. ========================================================
NB. Safe read of plan and checks for new variables
CheckTeeFile=: 3 : 0
utKeyRead y
dict=. >keyread y ; '_dictionary'
CheckFileItem y ; 'glTeTree' ; dict ; (#glTeID) ; <1 2 2$<''
)



CheckXLFile=: 3 : 0
NB. =========================================================
NB. CheckXLFile
NB. =========================================================
NB. Create XL file if it does not already exit
if. -. fexist y,'.ijf' do. 
    keycreate y
    2!:0 'chmod 775 ',y,'.ijf'
    (,<' ' cut 'glXLID glXLHole glXLTee glXLGender glXLNum glXLSheet glXLRow glXLColumn glXLString glXLType glXLNull glXLNote') keywrite y ; ,<'_dictionary'
    glXLID=: ,<'_default'
    glXLHole=: ,_1
    glXLTee=: ,' '
    glXLGender=: ,0
    glXLNum=: ,0
    glXLSheet=: ,<''
    glXLRow=: ,0
    glXLColumn=: ,0
    glXLString=: ,<''
    glXLType=: ,' '
    glXLNull=: ,0
    glXLNote=: ,<''
    utKeyPut y
end.
NB. Check for variables
utKeyRead y
dict=. >keyread y ; '_dictionary'
if. ( -. (<'glXLOverwrite') e. dict ) do.
	(,<'glXLOverwrite') utKeyAddColumn y
	glXLOverwrite=: (#glXLID)$0
	utKeyPut y
end.
)

CheckSSFile=: 3 : 0
NB. =========================================================
NB. CheckSSFile
NB. =========================================================
NB. Create SS file if it does not already exit
if. -. fexist y,'.ijf' do. 
    keycreate y
    2!:0 'chmod 775 ',y,'.ijf'
    (,<' ' cut 'glSSID glSSHole glSSTee glSSGender glSSYards glSSPar glSSRoll glSSElevation glSSDogleg glSSWind glSSObstacle glSSObsFactor') keywrite y ; ,<'_dictionary'
    glSSID=: ,<'_default'
    glSSHole=: ,_1
    glSSTee=: ,' '
    glSSGender=: ,_1
    glSSYards=: ,0
    glSSPar=: ,_1
    glSSRoll=: 1 2$0
    glSSElevation=: ,0
    glSSDogleg=: 1 2$0
    glSSWind=: ,0
    glSSObstacle=: 1 10 2$0
    glSSObsFactor=: 1 10 2$0
end.

)

Holes=: 3 : 0
NB. =========================================================
NB. Holes
NB. Usage:
NB.    Holes ''
NB. ---------------------------------------------------------
NB. Generates an array of holes based on <<gl9Hole>> and <glHoleOffset
NB. =========================================================
res=. glHoleOffset + i. gl9Hole { 18 9 
)

jweb_rating_getholes=: 3 : 0
NB. =========================================================
NB. getholes
NB. Usage:
NB.    Holes ''
NB. ---------------------------------------------------------
NB. Returns <<gl9Hole>> and <glHoleOffse
NB. ONLY RUN in batch modet
NB. =========================================================
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
utFileGet glFilepath
stdout dltb ": glHoleOffset,gl9Hole{18 9
)

jweb_rating_gettees=: 3 : 0
NB. =========================================================
NB. gettees
NB. Usage:
NB.    Holes ''
NB. ---------------------------------------------------------
NB. Returns <<glTees>>
NB. ONLY RUN in batch modet
NB. =========================================================
glFilename=: dltb > 0{ y
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
utFileGet glFilepath
stdout dltb glTees
)

ChopFiles=: 3 : 0
NB. =====================================================================
NB. ChopFiles
NB. =====================================================================
NB. Usage:
NB.    InitiateCourse pi ; 4 4 , 5 5 , ..  (pars)
NB.
NB. 1. Copy seven files from the latest one
NB. 2. Alter glCourseName, glCourseLead, glCourseDate and write to glFilepath
NB. 3. Alter glTeesYards and write to glFilepath
NB. 4. Alter glTees and glTeesName and write to glFilepath
NB. 5. Create kml file in GoogleEarth
NB. 6. Use gpsbabel to convert to unicsv, saving as ".txt" file
NB. 7. Run ReadGPS and save to glFilepath
NB. 8. Run this function InitiateCourse pi (for safety)
NB. 4. Execute:  glTePar=: ((18*$glTees),2)$,1 0 2 |:(($glTees),18 2)$,18 2 $ 4 4, 5 5 , 3 3 5 3 4 ... and write to '.._tee'
'pi holes'=. y
if. pi ~: 3.14159 do. return. end.
utFileGet glFilepath
currholes=. Holes ''
glTeesYards=: (currholes i. holes){"1 glTeesYards
glHoleOffset=: 0{holes
gl9Hole=: 9=$holes
utFilePut glFilepath
NB. Clear out the plan records
utKeyRead glFilepath,'_plan'
ww=. (glPlanHole>:0) *. -. glPlanHole e. holes
(ww#glPlanID) utKeyDrop glFilepath,'_plan' NB. Ignore '_default' and drop the other holes
NB. Clear tee altitudes
utKeyRead glFilepath,'_tee'
ww=. (glTeHole>:0) *. -. glTeHole e. holes
(ww#glTeID) utKeyDrop glFilepath,'_tee' NB. Ignore '_default' and drop the other holes
NB. Clear green 
utKeyRead glFilepath,'_green'
ww=. (glGrHole>:0) *. -. glGrHole e. holes
(ww#glGrID) utKeyDrop glFilepath,'_green' NB. Ignore '_default' and drop the other holes
NB. SS green 
utKeyRead glFilepath,'_ss'
ww=. (glSSHole>:0) *. -. glSSHole e. holes
(ww#glSSID) utKeyDrop glFilepath,'_ss' NB. Ignore '_default' and drop the other holes
NB. XL green 
utKeyRead glFilepath,'_xl'
ww=. (glXLHole>:0) *. -. glXLHole e. holes
(ww#glXLID) utKeyDrop glFilepath,'_xl' NB. Ignore '_default' and drop the other holes
)

NB. ============================================
NB. prompt
NB. ============================================

prompt=: 3 : 0
'' prompt y
:
  y 1!:2 (IFWIN+.IFJHS+.IFIOS) { 4 2
  1!:1 ] 1
)

NB. ============================================
NB. prompt_v
NB. --------------------------------------------
NB. Prompt for numeric vector input
NB. Return Q, * or null followed by result in boxed vector
NB. ============================================
prompt_v=: 4 : 0
originaly=. y
label_again.
res=. dltb(' ' cut '_ -') stringreplace ": y
res=. dltb prompt x,': (',res,') : '
if. (({.res) e. 'qQ') do.
	res=. 'Q' ; originaly
	return.
elseif. ('*' = {.res) do.
	NB. One value to be repeated
	res=. (' ' cut '- _') stringreplace }. res
	res=. 0". res
	y=. ($y)$0{res
	goto_again.
elseif. (({.res) e. 'eE') do.
	NB. Loop through each individual value
	for_i. i. #y do.
		res=. (x,'[',(":i),']') prompt_v ,i{y
		if. ('Q'={.>0{res) do.
			res=. 'Q' ; originaly
			return.
		else.
			y=. (''$>1{res) i } y
		end.
	end.
	goto_again.
elseif. (0=$res) do.
	NB. Just pressed Return
	res=. '' ; y
	return.
elseif. 1 do.
	NB. Vector of values
	res=. (' ' cut '- _') stringreplace res
	res=. 0". res
	y=. ($y){.res
	goto_again.
end.
)

NB. ============================================
NB. prompt_s
NB. --------------------------------------------
NB. Prompt for a string input
NB. Return Q, * or null followed by result in boxed vector
NB. ============================================
prompt_s=: 4 : 0
originaly=. y
label_again.
res=. dltb y
res=. dltb prompt x,': (',res,') : '
if. ((tolower 4{.res) -: 'quit') do.
	res=. 'Q' ; originaly
	return.
elseif. ('*' = {.res) do.
	NB. One value to be repeated
	y=.  ($y)$}. res
	goto_again.
elseif. (0=$res) do.
	NB. Just pressed Return
	res=. '' ; y
	return.
elseif. 1 do.
	y=. res
	NB. Vector of values
	goto_again.
end.
)


ReadSwingBySwing=: 3 : 0
NB. Save as <<holes>> from "[" to "]"
require 'convert/json'
require 'files'
ww=. fread y
ww=. dec_json ww NB. Decode json
glGPSName=: 0$<''
glGPSLatLon=: 0$0
glGPSAlt=: 0$0
glGPSMeasured=: 0$0
for_h. i. 18 do.
	green=. (<1 ; 3 4){>h{ww
	glGPSName=: glGPSName,<(;'r<0>2.0' 8!:0 (1+h)),'GC'
	glGPSAlt=: glGPSAlt, 0
	glGPSLatLon=: glGPSLatLon, j. / >green
	glGPSMeasured=: glGPSMeasured, 1
	NB. Tee
	tee=.(<1; 6 7 ){>0{>(<1 12){>h{ww
	glGPSName=: glGPSName,<(;'r<0>2.0' 8!:0 (1+h)),'T',0{glTees
	glGPSAlt=: glGPSAlt, 0
	glGPSLatLon=: glGPSLatLon, j. / >tee
	glGPSMeasured=: glGPSMeasured, 1
end.
