NB. =========================================================
NB. CompressRoute
NB. =========================================================
CompressRoute=:  3  : 0
NB. Walk through the track file and work out the compressed set of points
NB. We keep a point if there is a change in route angle > 10 degrees,
NB. ' or if the distance from the track is > 200 yards
'W' CompressRoute y
:
if. x = 'W' do.
	NB. Walking parameters
	minturn =. 10	NB. degress
	mindevn =. 30	NB. meters
else.	
	NB. Driving parameters
	minturn =. 15
	mindevn =. 150
end.

NB. <msk> = results mask, starting with first point
msk =. (#y) {. 1
turn =. (#y) # 0
NB. <fixed> = last fixed point, starting with point 0
fixed =. 0   

ospts =. <. 0.5 + LatLontoFullOS >0 {"1 y NB. round to nearest mtr
    
for_row. y do.

	NB. If first row, nothing to do
	if. row_index = 0 do. continue. end.
	NB. if one after last fixed row, nothing to do
	if. row_index = (1+fixed) do. continue. end.
	NB. if equal to the previous element, nothing to do
	if. 0 = -/ (row_index + _1 0) { ospts do. continue. end.
	
	NB. ---Check if the angle of turn at this point is too much
	NB. Work out the vector from last fixed point to previous point
	vec=. - -/(fixed, _1+row_index) { ospts
	NB. Then work out vector from previous point to this
	newvec=. - -/((_1+row_index), row_index) { ospts
	NB. Scary bit to work out the scalar product of the standard
	NB. length vectors, and then apply to cosine law
	angle=. ( 180 % o. 1) *  _2 o. (0 { +. vec * + newvec) % */ | vec, newvec
	if. angle>minturn do.
		msk =. 1 (_1+row_index) } msk
		turn =. angle (_1+row_index) } turn
		fixed =. _1 + row_index
		continue.
	end.
     
    NB. ----The final bit of logic deals with the situation
    NB. 	where the angles are OK, but there is a gradual shift
    NB. 	e.g. moving round a large circle
    NB. 	The logic checks whether a segment to the current point
    NB. 	would mean any previous point would be more than 200m from the path
    NB. 	This requires looping round each previous point, so is pretty slow
            
	NB.	The wonders of J mean that the line formula can be done in one go
	NB.	Initially write as y = mx + c
	NB. and then convert to Ax + By + c = 0
	NB. by setting          mx -  y + c = 0
	pts =. fixed }. row_index {. ospts
	vec =. -/ _1 0 { pts
	NB. Need to be aware of the case where <m> is infinite
	if. 0 = 0 { +. vec do.
		m =. 1
		A =. 1
		B =. 0
		c =. - 0 { +. 0 { pts
	else.
		m =. % / |. +. vec
		A =. m
		B =. _1
		c =. ((-m), 1) +/ . * +. 0 { pts
	end.
	NB. The distance of the point (x0,y0) from the line is
	NB. |Ax0 + By0 + c| / sqr( A^2 + B^2)
	pts =.  | ((+. pts ),"1 (1)) +/ . * A, B, c
	pts =. pts % | A j. B
	if. mindevn +./ . < pts do.
		msk =. 1 (_1+row_index) } msk
		fixed = _1 + row_index
		continue.
	end.
end.
            
NB. Last point is always fixed
msk =. 1 ( _1 ) } msk 
msk
)

NB. ================================
NB. Analyse
NB. ================================
NB. Analyse a Pathaway file
Analyse=: 3 : 0
os=. <. 0.5 + LatLontoFullOS >0 {"1 y
mtr=. {: os =. +/ \ 0, | (}.os) - }: os
ret=. mtr
str=. 'Meters=',": mtr
str=. str, LF, 'Yards=', ": yds=. mtr * 3.2808398950131 % 3
ret=. ret, yds
str=. str, LF, 'Miles=', ": mls=. yds % 1760
ret=. ret, mls
NB. msk finds the range of valid dates and calculates
NB. the mph over this range
msk=. I. 0 < ># each 2 {"1 y
if. 2 <: #msk do.
	msk=. ({. msk) , ({: msk)
	mtr=. | -/ msk { os
	mls=. mtr * 3.2808398950131 % 3 * 1760
	hr=. 24 * - -/ >(<msk ; 2) { y
	mph=. mls % hr
    start=. >(<({. msk),2) { y
	start=. start - ((({. msk) { os) * 3.2808398950131 % 3 * 1760) % mph * 24
	ret=. ret, ((2 { ret) % mph), mph, start
	str=. str, LF, 'MPH=', (": mph), ' [',(": mls), ' miles over ', (":hr), ' hours]'
else. 
	str=. str, LF, '[No Times]'
	ret=. ret, 0 0 0
end.
str
ret
)

NB. ================================
NB. SetStart
NB. ================================
NB. Set the start time of a Pathaway boxed array
SetStart=: 3 : 0
yy=. Analyse y
if. 0 = {: yy do.
	yy=. 2001 1 1 9 0 0 
else.
	yy=. ,XLdatetoTS {: yy
end.
yy SetStart y
:
(< TStoXLdate x) (<0 2) } y
)

NB. ================================
NB. SetMPH
NB. ================================
NB. Set the start time of a Pathaway boxed array
SetMPH=: 3 : 0
(4 { Analyse y) SetMPH y
:
yy=.SetStart y
start=. >(<0 2) { yy
os=. <. 0.5 + LatLontoFullOS >0 {"1 y
os =. +/ \ 0, | (}.os) - }: os
start=. start +  (os * 3.2808398950131 % 3 * 1760) % x * 24
(<"0 start) 2 }"0 0 1 yy
)

NB. ================================
NB. SetMilestones
NB. ================================
NB. Walks throught the file and returns a set of 
NB. waypoints at each of the milestones
SetMilestones=: 3 : 0
'M' SetMilestones y
:
os=. <. 0.5 + LatLontoFullOS >0 {"1 y NB. convert to meters
os=. +/ \ 0, | (}.os) - }: os  NB. running total
os=. os * 3.2808398950131 % 3 * 1760 NB. cumulative miles

ms=. 1+ i. <. {: os
ind=.(_1 + +/"1 ms >:/ os) 
NB. os=. ind |."0 0 _ os
lambda=. (1 0 + / ind) { os
lambda=. (ms - 1{lambda) % - / lambda
col=. > 0 1 2 {"1 y
res=. <"0 ((1-lambda)*ind { col) + lambda*(1+ind){col
res=. 6{."1 res
res=. 'MS' SetName res
res=. (0{y), res
res=. (<'MS000') (<0 3) } res
res=. (<2) 4 }"1 res
res=. (<'') 5 }"1 res

)


NB. ================================
NB. SetName
NB. ================================
NB. Walks throught the file and returns a set of 
NB. waypoints at each of the milestones
SetName=: 3 : 0
'Rt' SetName y
:
xx=.(<,x) ,"1 each 'r<0>3.0' 8!:0 ,. 1 + i. #y
xx (,3) }"1 y
)

NB. ================================
NB. SetNameMiles
NB. ================================
NB. Walks throught the file and returns a set of 
NB. waypoints at each of the milestones
SetNameMiles=: 3 : 0
'Rt' SetNameMiles y
:
os=. <. 0.5 + LatLontoFullOS >0 {"1 y NB. convert to meters
os=. +/ \ 0, | (}.os) - }: os  NB. running total
os=. os * 3.2808398950131 % 3 * 1760 NB. cumulative miles

xx=.(<,x) ,"1 each 'r<0>8.4' 8!:0 ,. os
xx (,3) }"1 y
)

NB. ===================================
NB. SetAltitude
NB. ===================================
NB. Works out the altitude of the elements in <y> by finding
NB. the nearest match in <x>
NB. First of all tries to find the four closest points in <x>
NB. on either side of the target point.  Then pick the nearest 
NB. three points, and falls back to the nearest points if it
NB. can't surround the target point
NB. Finally, uses as least squares fit (matrix divide) to
NB. interpolate the altitude from the latitude and longitude
NB. coordinates.
NB. Obviously only works if <x> is in close proximity to <y>
NB. so it is worth storing a ref-height table in Pathaway
SetAltitude=: 4 : 0
x=.(0<#1{"1 x) # x NB. Remove those with zero altitude
x=.( ( =>0{"1 x) i."1 (1)) { x  NB. Remove duplicates
if. (4>#x) do.
	'ERROR: Need at least four points in <x> argument'
	return.
end.
x=.>0 1{"1 x
coord_x=. 0{"1 x
x=. (+. coord_x),"1 0 (1{"1 x)
coord_y=. >0{"1 y 
alt_y=. i. 0
for_j. y do.
	ind=. i. 0
	delta=.(j_index { coord_y) - coord_x
	latlon=. +. delta
	sorted=. /: | delta 
	NB. Loop round trying for find the four nearest points
	NB. which surround the point
	if. (+./ z=.0<: (<sorted ; 0) { latlon) *. (0<: (<sorted ; 1) { latlon) do.
		ind=. ind, {. z # sorted
		sorted=.sorted -. ind
	end.
	if. (+./ z=.0<: (<sorted ; 0) { latlon) *. (0>: (<sorted ; 1) { latlon) do.
		ind=. ind, {. z # sorted
		sorted=.sorted -. ind
	end.
	if. (+./ z=.0>: (<sorted ; 0) { latlon) *. (0<: (<sorted ; 1) { latlon) do.
		ind=. ind, {. z # sorted
		sorted=.sorted -. ind
	end.
	if. (+./ z=.0>: (<sorted ; 0) { latlon) *. (0>: (<sorted ; 1) { latlon) do.
		ind=. ind, {. z # sorted
		sorted=.sorted -. ind
	end.
	NB. Need just the nearest three, tack the other ones on first
	if. (4 > # ind) do. ind=. 4{. ind, sorted end.
	ind=. ( 3 {. /: | ind { delta) { ind
	NB. Need the coordinates of the plane through these nearest three points
	regress=. ((< ind ; 2){x) %. (<ind ; 0 1 3) { x,"1 (1)
	alt_y=. alt_y, regress +/ . * (+. j_index { coord_y), 1
end.
alt_y
)

NB. ================================================
NB. PlotPath
NB. ================================================
PlotPath=: 3 : 0
0 PlotPath y
:
if. 1= L. y do.
	y=. 'Plot' ; <y
end.

pd 'reset'
key=. (2* i. -:#y) { y
key=. (<'"'), each key, each <'"'
pd 'key', ;(<' '),each key
pd 'type line'
for_j. (1+ 2* i. -: #y) { y do.
	pd LatLontoFullOS >0{"1 >j
end.
pd 'type marker'
for_j. (1+ 2* i. -: #y) { y do.
	pd LatLontoFullOS >0{"1 >j
end.
pd 'show'
)
	