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
glRollLevelDesc=: ':' cut 'Downhill:Level:Uphill'
glRollLevelNum=: ':' cut 'Down:Level:Up'
glRollSlopeVal=:  (<''),':' cut 'Mod:Sig'
glRollSlopeDesc=: ':' cut 'Minor Slope (5y):Moderate Slope (10y):Significant Slope (15y)'
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
glTopogStanceVal=: (<''),':' cut 'MA:SA:EA'
glTopogStanceDesc=: ':' cut 'Minor Problem:Moderately Awkward:Signif Awkward:Extremely Awkward'
glTopogStanceText=: ':' cut 'MP:MA:SA:EA'
glTopogStanceNum=: 1 2 3 4
glBunkFractionVal=: (<''),':' cut '<1/4:<1/2:<3/4:>3/4'
glBunkFractionDesc=: ':' cut 'Zero:0 - 1/4:1/4 - 1/2:1/2 - 3/4:Greater than 3/4'
glBunkFractionNum=: 0 1 2 3 4
glBunkFractionText=: ':' cut 'Zero:&lt;&frac14;:&frac14;-&frac12;:&frac12;-&frac34;:&gt;&frac34;'
glBunkDepthVal=: (<''),':' cut '2-3:3-5:5-6:6-8:8-10:10-12:12-15:>15'
glBunkDepthDesc=: ':' cut '<2'':2'' - 3'':3'' - 5'':5'' - 6'':6'' - 8'':8'' - 10'':10'' - 12'':12'' - 15'':>15'''
glBunkDepthText=:':' cut '&lt;2&#39;:2&#39;-3&#39;:3&#39;-5&#39;:5&#39;-6&#39;:6&#39;-8&#39;:8&#39;-10&#39;:10&#39;-12&#39;:12&#39;-15&#39;:&gt;15&#39;'
glBunkDepthNum=: 0 2.5 4 5.5 7 9 11 13.5 16
glBunkExtremeVal=: (<''),':' cut '+1:+2'
glBunkExtremeDesc=: ':' cut 'Zero:+1:+2'
glOOBCartVal=: (<''),':' cut '+1:-1'
glOOBCartDesc=: ':' cut 'None:+1 Bounce away:-1 Bounce towards'
glOOBPercentVal=: (<''),':' cut '25%:50%:75%:100%'
glOOBPercentDesc=: ':' cut '-:-25%:-50%:-75%:-100%'
glOOBPercentNum=: 0 0.25 0.5 0.75 1
glOOBBehindVal=: (<''),':' cut '-1:-2'
glOOBBehindDesc=: ':' cut '-:-1 Behind:-2 Behind'
glOOBBehindNum=: 0 _1 _2
glRRInconsistentVal=: (<''),':' cut '+1:-1'
glRRInconsistentDesc=: ':' cut 'None:+1 Harder:-1 Easier'
glWaterFractionVal=: (<''),':' cut '1/4-<1/2:>1/2'
glWaterFractionDesc=: ':' cut '0 - 1/4:1/4 - 1/2:>1/2'
glWaterFractionNum=: 0 1 2
glWaterFractionText=: (<''),':' cut '&lt;&frac12;:&gt;&frac12;'
glWaterSurrDistVal=: (<''),':' cut '1-4:5-10:11-20:>20'
glWaterSurrDistDesc=: ':' cut 'None:1 - 4:5 - 10:11 - 20:>20'
glWaterSurrDistNum=: 0 3 2 1 0
glWaterSurrDistText=: (<''),':' cut '1&#39;-4&#39;:5&#39;-10&#39;:11&#39;-20&#39;:&gt;20&#39;'
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
glLayupCategoryVal=: (<''), ':' cut 'dogleg:forced:choice'
glLayupCategoryDesc=: ':' cut 'None:Dogleg:Forced Layup:Layup by Choice'
glLayupCategoryText=: ':' cut 'None:Dogleg:Forced:Choice'
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
NB. Check_dogleg
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
    else.
	    radius2=. ''$ defaulthit
	    glPlanLayupType=: ,' '
    end.
    ww=. InterceptPath path ; start ; radius2
    NB. New logic for transition within 10 yards of 
	NB. of the green for a Par 3 or 20 for Par 4/5
	trans_dist=. shot { 10 20 20 20 20 20 
	rem=. remgroundyards - <. 0.5 + 1{ww
	if. ( 0 < rem) *. (trans_dist >: rem) *. (glPlanLayupType=' ') do.
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
	ClearPlanRecord '' NB. Zero numerics
	glPlanHitYards=: , <. 0.5+ 1{ww
	cumgroundyards=. <. 0.5 + cumgroundyards + 1{ww
	remgroundyards=. <. 0.5  + remgroundyards - 1{ww
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
'holes tees genders abilities'=. y
holes=. ,<. 0.5 + holes
holes=. (holes e. i. 18) # holes

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

NB. =====================================================================
NB. InitiateCourse
NB. =====================================================================
NB. Usage:
NB.    InitiateCourse ''
NB.
NB. 1. Copy seven files from the latest one
NB. 2. Alter glCourseName, glCourseLead, glCourseDate and write to glFilepath
NB. 3. Alter glTeesYards and write to glFilepath
NB. 4. Write pars:  glTePar=: 54 2$,|:6 18$4 4 5 3 4 ... and write to '.._tee'
NB. 5. Create kml file in GoogleEarth
NB. 6. Use gpsbabel to convert to unicsv, saving as ".txt" file
NB. 7. Run ReadGPS and save to glFilepath
NB. 8. Run this function InitiateCourse pi (for safety)
InitiateCourse=: 3 : 0
if. y ~: 3.14159 do. return. end.
utFileGet glFilepath
NB. Clear out the plan records
utKeyRead glFilepath,'_plan'
((glPlanHole>:0)#glPlanID) utKeyDrop glFilepath,'_plan' NB. Ignore '_default'
NB. Clear tee altitudes
utKeyRead glFilepath,'_tee'
glTeAlt=: 0 * glTeAlt
ww=.(3 4 5 i. glTePar){('' ; '.' ; '.')
glTeTree=. (($ww),2)$,ww,"1 ww NB. Have to add extra dimension for the ability
utKeyPut glFilepath,'_tee'
NB. Clear green 
utKeyRead glFilepath,'_green'
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
glGrOOBBehind=: ($glGrID)$0
glGrOOBCart=: ($glGrID)$<''
glGrOOBPercent=: ($glGrID)$<''
glGrWaterBehind=: ($glGrID)$0
glGrWaterCart=: ($glGrID)$<''
glGrWaterPercent=: ($glGrID)$<''
glGrWaterFraction=: ($glGrID)$<''
glGrWaterSurrDist=: ($glGrID)$<''
glGrNotes=: ($glGrID)$<''
utKeyPut glFilepath,'_green'
AugmentGPS i. 18
BuildPlan i. 18
)

NB. ========================================================
NB. CheckPlanFile
NB. ========================================================
NB. Safe read of plan and checks for new variables
CheckPlanFile=: 3 : 0
utKeyRead y
dict=. >keyread y ; '_dictionary'
if. ( -. (<'glPlanOOBPercent') e. dict ) do.
	(,<'glPlanOOBPercent') utKeyAddColumn y
	glPlanOOBPercent=: (#glPlanID)$<''
	utKeyPut y
end.
if. ( -. (<'glPlanWaterPercent') e. dict ) do.
	(,<'glPlanWaterPercent') utKeyAddColumn y
	glPlanWaterPercent=: (#glPlanID)$<''
	utKeyPut y
end.
if. ( -. (<'glPlanWaterLine') e. dict ) do.
	(,<'glPlanWaterLine') utKeyAddColumn y
	glPlanWaterLine=: (#glPlanID)$0
	utKeyPut y
end.
if. ( -. (<'glPlanOOBLine') e. dict ) do.
	(,<'glPlanOOBLine') utKeyAddColumn y
	glPlanOOBLine=: (#glPlanID)$0
	utKeyPut y
end.
if. ( -. (<'glPlanRollDist') e. dict ) do.
	(,<'glPlanRollDist') utKeyAddColumn y
	glPlanRollDist=: 2 * glPlanMeasDist - glPlanRemGroundYards NB. Should default to 20
	utKeyPut y
end.
if. ( -. (<'glPlanCrowDist') e. dict ) do.
	(,<'glPlanCrowDist') utKeyAddColumn y
	glPlanCrowDist=: (#glPlanID)$0
	utKeyPut y
end.
if. ( -. (<'glPlanCarryAffectsTee') e. dict ) do.
	(,<'glPlanCarryAffectsTee') utKeyAddColumn y
	glPlanCarryAffectsTee=: (#glPlanID)$' '
	utKeyPut y
end.
if. ( -. (<'glPlanTreeTargObstructed') e. dict ) do.
	(,<'glPlanTreeTargObstructed') utKeyAddColumn y
	glPlanTreeTargObstructed=: (#glPlanID)$0
	utKeyPut y
end.
if. ( -. (<'glPlanTreeLZObstructed') e. dict ) do.
	(,<'glPlanTreeLZObstructed') utKeyAddColumn y
	glPlanTreeLZObstructed=: (#glPlanID)$0
	utKeyPut y
end.
)

NB. ========================================================
NB. CheckGreenFile
NB. ========================================================
NB. Safe read of plan and checks for new variables
CheckGreenFile=: 3 : 0
utKeyRead y
dict=. >keyread y ; '_dictionary'
if. ( -. (<'glGrOOBBehind') e. dict ) do.
	(,<'glGrOOBBehind') utKeyAddColumn y
	glGrOOBBehind=: (#glGrID)$<''
	utKeyPut y
end.
if. ( 32 ~: 3!:0 glGrOOBBehind ) do.
	glGrOOBBehind=: glGrOOBBehind { glOOBBehindVal
	utKeyPut y
end.
if. ( -. (<'glGrWaterBehind') e. dict ) do.
	(,<'glGrWaterBehind') utKeyAddColumn y
	glGrWaterBehind=: (#glGrID)$<''
	utKeyPut y
end.
if. ( 32 ~: 3!:0 glGrWaterBehind ) do.
	glGrWaterBehind=: glGrWaterBehind { glWaterBehindVal
	utKeyPut y
end.
if. ( -. (<'glGrNotes') e. dict ) do.
	(,<'glGrNotes') utKeyAddColumn y
	glGrNotes=: (#glGrID)$<''
	utKeyPut y
end.
)
