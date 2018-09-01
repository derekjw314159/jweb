NB. =========================================================
NB. rating_plan_view
NB. View scores for participant
NB. =========================================================
batchedit=: 3 : 0
NB. Retrieve the details
NB. y has two elements, coursename & hole (+1)
hole=. ''$ y
hole=. <. 0.5 + hole
hole=. hole-1 
hole=. 0 >. 17 <. hole

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_plan'
	xx=. utKeyRead glFilepath,'_tee'
	xx=. utKeyRead glFilepath,'_green'
end.

NB. Tees 
ww=. I. (glTeHole=hole)
ww=. ww /: glTees i. ww{glTeTee
(ww{glTeID) utKeyRead glFilepath,'_tee'

res=. ('Hole ',(":1+hole),' Tee altitudes') prompt_v glTeAlt
if. ('Q'={.>0{res) do.
	return.
else.
	glTeAlt=: >1{res
	utKeyPut glFilepath,'_tee'
end.

NB. Tree Value
par=. (4 <. 0{; glTePar) 
num=. (par=glTreePar)#glTreeNum + glTreeTweener
val=. (par=glTreePar)#glTreeVal
res=. ('Hole ',(":1+hole),' Trees') prompt_v (val i. ,glTeTree){num, (3 4 i. par){1 2 NB. Default
if. ('Q'={.>0{res) do.
	return.
else.
	glTeTree=: (num i. ($glTeTree)$>1{res){val
	utKeyPut glFilepath,'_tee'
end.

NB. Green Data
utFileGet glFilepath,'_green'
rr=. I. hole=glGrHole
(rr{glGrID) utKeyRead glFilepath,'_green' NB. Just read for this hole

NB. Green Front
res=. ('Hole ',(":1+hole),' Green front yards') prompt_v ;glGrFrontYards
if. ('Q'={.>0{res) do.
	return.
else.
	glGrFrontYards=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Green Alt
res=. ('Hole ',(":1+hole),' Green altitude') prompt_v ;glGrAlt
if. ('Q'={.>0{res) do.
	return.
else.
	glGrAlt=: ;>1{res
	utKeyPut glFilepath,'_green'
end.



NB. Carry Points
rr=. I. glPlanHole = hole
rr=. ('C' = rr{glPlanRecType) # rr
for_c. rr do.
	tee=. c{glPlanTee
	t_index=. glTees i. tee
	dist=. (<t_index, hole){glTeesYards
	res=. ('Hole ',(":1+hole),' Carry distance {',(c{glPlanCarryType),'}') prompt_s tee,":dist - c{glPlanMeasDist
	if. ('Q'={.>0{res) do.
		return.
	else.
		glPlanTee=: (''${.>1{res) c } glPlanTee
		dist=. dist - 0". }.>1{res
		glPlanRemGroundYards=: (''$dist) c } glPlanRemGroundYards
		glPlanMeasDist=: (''$dist) c } glPlanMeasDist
		utKeyPut glFilepath,'_plan'
	end.
end.

	



NB. Sort the records and re-read
utKeyRead glFilepath,'_plan'
rr=. I. glPlanHole=hole
rr=. (rr{glPlanRecType e. 'PM')#rr
rr=. rr /: rr { glPlanShot
rr=. rr /: rr { glPlanAbility
rr=. rr /: rr { glPlanGender
rr=. rr /: glTees i. rr { glPlanTee
rr=. rr /: 'CPM' i. rr { glPlanRecType
rr=. (rr { glPlanID) \: rr { glPlanMeasDist
rr utKeyRead glFilepath,'_plan'

NB. Plan Altitude
res=. ('Hole ',(":1+hole),' Plan altitudes') prompt_v glPlanAlt
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanAlt=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. Fairway width
res=. ('Hole ',(":1+hole),' Fairway width') prompt_v glPlanFWWidth
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanFWWidth=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. Bunke in LZ
res=. ('Hole ',(":1+hole),' Bunker in LZ') prompt_v glPlanBunkLZ
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanBunkLZ=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. Bunker in LoP
res=. ('Hole ',(":1+hole),' Bunker in LoP') prompt_v glPlanBunkLine
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanBunkLine=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. OOB Distance
res=. ('Hole ',(":1+hole),' OOB/ER Distance') prompt_v glPlanOOBDist
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanOOBDist=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. OOB Distance
res=. ('Hole ',(":1+hole),' OOB/ER %age reduction {0/25/50/75/100}') prompt_v (glOOBPercentVal i. glPlanOOBPercent){0 25 50 75 100
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanOOBPercent=: (0 25 50 75 100 i. >1{res){glOOBPercentVal
	utKeyPut glFilepath,'_plan'
end.


NB. Lateral Water Distance
res=. ('Hole ',(":1+hole),' Water Distance') prompt_v glPlanLatWaterDist
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanLatWaterDist=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. Roll Level
res=. ('Hole ',(":1+hole),' Roll Level {d/./u}') prompt_s (glRollLevelVal i. glPlanRollLevel){'d.u'
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanRollLevel=: ('d.u' i. >1{res){glRollLevelVal
	utKeyPut glFilepath,'_plan'
end.

NB. Roll SLope
res=. ('Hole ',(":1+hole),' Roll Slope {m/M/s}') prompt_s (glRollSlopeVal i. glPlanRollSlope){'mMs'
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanRollSlope=: ('mMs' i. >1{res){glRollSlopeVal
	utKeyPut glFilepath,'_plan'
end.

NB. Stance
res=. ('Hole ',(":1+hole),' Stance {./+/m/s/e}') prompt_s (glTopogStanceVal i. glPlanTopogStance){'.+mse'
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanTopogStance=: ('.+mse' i. >1{res){glTopogStanceVal
	utKeyPut glFilepath,'_plan'
end.

NB. FW Adj
res=. ('Hole ',(":1+hole),' Fairway Adjustment') prompt_v (glFWWidthAdjVal i. glPlanFWWidthAdj){0 1 2 _1 _1 _2
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanFWWidthAdj=: (0 1 2 _1 _1 _2 i. >1{res){glFWWidthAdjVal
	utKeyPut glFilepath,'_plan'
end.

NB. RR Mounds
res=. ('Hole ',(":1+hole),' RR Mounds') prompt_v glPlanRRMounds
if. ('Q'={.>0{res) do.
	return.
else.
	glPlanRRMounds=: >1{res
	utKeyPut glFilepath,'_plan'
end.

NB. Roll SLope
res=. ('Hole ',(":1+hole),' Notes') prompt_s ;glGrNotes 
if. ('Q'={.>0{res) do.
	return.
else.
	glGrNotes=:  1{res
	utKeyPut glFilepath,'_green'
end.

)




NB. =========================================================
NB. rating_plan_view
NB. View scores for participant
NB. =========================================================
gds=: 3 : 0
NB. Retrieve the details
NB. y has two elements, coursename & hole (+1)
hole=. y
hole=. <. 0.5 + hole
hole=. 0 >. 17 <. hole

if. fexist glFilepath,'.ijf' do.
	xx=. utFileGet glFilepath
	xx=. utKeyRead glFilepath,'_green'
	xx=. utKeyRead glFilepath,'_tee'
end.

NB. Sort the holes
rr=. I. (glGrHole e. hole)
rr=. rr /: hole i. rr{glGrHole
(rr{glGrID) utKeyRead glFilepath,'_green'

NB. Green width
res=. ('Hole ',(":1+hole),' Green width') prompt_v ;glGrWidth
if. ('Q'={.>0{res) do.
	return.
else.
	glGrWidth=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Green length
res=. ('Hole ',(":1+hole),' Green length') prompt_v ;glGrLength
if. ('Q'={.>0{res) do.
	return.
else.
	glGrLength=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Green tiered
res=. ('Hole ',(":1+hole),' Green tiered') prompt_v ;glGrTiered
if. ('Q'={.>0{res) do.
	return.
else.
	glGrTiered=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Green firmness
res=. ('Hole ',(":1+hole),' Green firmness {./f/s}') prompt_s (glGrFirmnessVal i. glGrFirmness){'.fs'
if. ('Q'={.>0{res) do.
	return.
else.
	glGrFirmness=: ('.fs' i. >1{res){glGrFirmnessVal
	utKeyPut glFilepath,'_green'
end.

NB. Green contours
res=. ('Hole ',(":1+hole),' Green contours {./m/h}') prompt_s (glGrContourVal i. glGrContour){'.mh'
if. ('Q'={.>0{res) do.
	return.
else.
	glGrContour=: ('.mh' i. >1{res){glGrContourVal
	utKeyPut glFilepath,'_green'
end.

NB. Green RR Mounds
res=. ('Hole ',(":1+hole),' Green RR mounds') prompt_v ;glGrRRMounds
if. ('Q'={.>0{res) do.
	return.
else.
	glGrRRMounds=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Green RR Rise and Drop
res=. ('Hole ',(":1+hole),' Green RR rise & drop {0/5/10}') prompt_v (glRRRiseDropVal i. glGrRRRiseDrop){0 5 10
if. ('Q'={.>0{res) do.
	return.
else.
	glGrRRRiseDrop=:  (0 5 10 i. >1{res){glRRRiseDropVal
	utKeyPut glFilepath,'_green'
end.

NB. Green bunker fraction
res=. ('Hole ',(":1+hole),' Green bunker fractioni {0 0.25 0.5 0.75 1}') prompt_v ;(glBunkFractionVal i. glGrBunkFraction){0 0.25 0.5 0.75 1
if. ('Q'={.>0{res) do.
	return.
else.
	glGrBunkFraction=:  (0 0.25 0.5 0.75 1 i. >1{res){glBunkFractionVal
	utKeyPut glFilepath,'_green'
end.

NB. Green bunker depth
res=. ('Hole ',(":1+hole),' Green bunker depth {0/2-3/3-5/5-6/6-8/8-10/10-12/12-15/15+}') prompt_v ;(glBunkDepthVal i. glGrBunkDepth){0 2 3 5 6 8 10 12 15
if. ('Q'={.>0{res) do.
	return.
else.
	glGrBunkDepth=:  (0 2 3 5 6 8 10 12 15 i. >1{res){glBunkDepthVal
	utKeyPut glFilepath,'_green'
end.

NB. Green OOB Dist
res=. ('Hole ',(":1+hole),' Green OOB distance') prompt_v ;glGrOOBDist
if. ('Q'={.>0{res) do.
	return.
else.
	glGrOOBDist=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Green OOB Behind
res=. ('Hole ',(":1+hole),' Green OOB behind {0/-1/-2}') prompt_v (glOOBBehindVal i. glGrOOBBehind){0 _1 _2
if. ('Q'={.>0{res) do.
	return.
else.
	glGrOOBBehind=:  (0 _1 _2 i. >1{res){glOOBBehindVal
	utKeyPut glFilepath,'_green'
end.

NB. OOB Percentage
res=. ('Hole ',(":1+hole),' OOB/ER %age reduction {0/25/50/75/100}') prompt_v (glOOBPercentVal i. glGrOOBPercent){0 25 50 75 100
if. ('Q'={.>0{res) do.
	return.
else.
	glGrOOBPercent=: (0 25 50 75 100 i. >1{res){glOOBPercentVal
	utKeyPut glFilepath,'_green'
end.

NB. Green Water Dist
res=. ('Hole ',(":1+hole),' Green Water distance') prompt_v ;glGrWaterDist
if. ('Q'={.>0{res) do.
	return.
else.
	glGrWaterDist=: ; >1{res
	utKeyPut glFilepath,'_green'
end.

NB. Tees 
for_hh. hole do.
	utKeyRead glFilepath,'_tee'
	ww=. I. (glTeHole=hh)
	ww=. ww /: glTees i. ww{glTeTee
	(ww{glTeID) utKeyRead glFilepath,'_tee'

	NB. Tree Value
	par=. (4 <. 0{; glTePar) 
	num=. (par=glTreePar)#glTreeNum + glTreeTweener
	val=. (par=glTreePar)#glTreeVal
	res=. ('Hole ',(":1+hh),' Trees') prompt_v (val i. ,glTeTree){num, (3 4 i. par){1 2 NB. Default
	if. ('Q'={.>0{res) do.
		return.
	else.
		glTeTree=: (num i. ($glTeTree)$>1{res){val
		utKeyPut glFilepath,'_tee'
	end.

end.


)

NB. ============================================
NB. FixAltitude  
NB. --------------------------------------------
FixAltitude=: 3 : 0
require 'tables/csv'
ww=. readcsv glFilepath,'actual.txt'
res=. (0{ww) i. 'Latitude' ; 'Longitude' ; 'Altitude' ; 'Time' ; 'Name' ; 'Icon' ; 'Description'
res=. res {"1 (ww,"1 a:) NB. Order the columns
res=. }. res NB. Drop the row titles
latlon=. j. /"1 >(". each 0 1{"1 res)
latlon=. LatLontoFullOS latlon
alt=. 3 * glMY * >". each 2{"1 res

NB. Tee
utKeyRead glFilepath,'_tee'
msk=. glTeAlt=0
(msk#glTeID) utKeyRead glFilepath,'_tee'
NB. We don't store the Tee LatLon separately
ll=. LatLontoFullOS  (glGPSName i. ('r<0>2.0' 8!:0 (1+glTeHole)),each 'T', each <"0 glTeTee){glGPSLatLon
res=. 0$0
for_i. i. #ll do.
	idx=. 4{. /: |(i{ll)-latlon
	reg=. (idx{alt) %. 1,"1 +. idx{latlon
	res=. res, <. 0.5 + +/reg * 1,+. i{ll
end.
glTeAlt=: res
utKeyPut glFilepath,'_tee'

NB. Plan
utKeyRead glFilepath,'_plan'
msk=. (glPlanAlt=0) *. (glPlanHole>: 0)
(msk#glPlanID) utKeyRead glFilepath,'_plan'
ll=. LatLontoFullOS glPlanLatLon
res=. 0$0
for_i. i. #ll do.
	idx=. 4{. /: |(i{ll)-latlon
	reg=. (idx{alt) %. 1,"1 +. idx{latlon
	res=. res, <. 0.5 + +/reg * 1,+. i{ll
end.
glPlanAlt=: res
utKeyPut glFilepath,'_plan'

NB. Green
utKeyRead glFilepath,'_green'
msk=. (glGrAlt=0) *. (glGrHole>: 0)
(msk#glGrID) utKeyRead glFilepath,'_green'
res=. 0$0
ll=. LatLontoFullOS  (glGPSName i. ('r<0>2.0' 8!:0 (1+glGrHole)),each <'GC'){glGPSLatLon
for_i. i. #ll do.
	idx=. 4{. /: |(i{ll)-latlon
	reg=. (idx{alt) %. 1,"1 +. idx{latlon
	res=. res, <. 0.5 + +/reg * 1,+. i{ll
end.
glGrAlt=: res
utKeyPut glFilepath,'_green'

)

