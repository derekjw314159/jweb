NB. Ordnance Survey functions and conversion utilities
NB. These functions are from the Ordnance Survey web site

load 'trig'

NB. Simple square root function
Sqr=: %:

NB. Simple absolute function
Abs=: | 

NB. =========================================================
Helmert_X=: 3 : 0
NB. Computed Helmert transformed X coordinate.
NB. Input: - _
NB.  cartesian XYZ coords (X,Y,Z), X translation (DX) all in meters 
NB.  Y and Z rotations in seconds of arc (Y_Rot, Z_Rot) and scale in ppm (s)
NB. 	dim sfactor as double, Rady_Rot as double, Radz_Rot as double

'x y Z DX Y_Rot Z_Rot s' =. y
	 
NB. 'Convert rotations to radians and ppm scale to a factor
sfactor =. s * 0.000001
RadY_Rot =. (Y_Rot % 3600) * o. % 180
RadZ_Rot =. (Z_Rot % 3600) * o. % 180
    
NB. 'Compute transformed X coord
result =. x + (x * sfactor) + (-y * RadZ_Rot) + (Z * RadY_Rot) + DX
) 
NB. =========================================================
Helmert_Y=: 3 : 0
NB. Computed Helmert transformed Y coordinate.
NB. Input: -
NB. cartesian XYZ coords (X,Y,Z), Y translation (DY) all in meters ; 
NB. X and Z rotations in seconds of arc (X_Rot, Z_Rot) and scale in ppm (s)

'x y Z DY X_Rot Z_Rot s' =. y
 
NB. 'Convert rotations to radians and ppm scale to a factor
sfactor =. s * 0.000001
RadX_Rot =. (X_Rot % 3600) * o. %180
RadZ_Rot =. (Z_Rot % 3600) * o. %180
    
NB. Compute transformed Y coord
result =. (x * RadZ_Rot) + y + (y * sfactor) + (-Z * RadX_Rot) + DY
)

NB. =========================================================
Helmert_Z=: 3 : 0
NB. 'Computed Helmert transformed Z coordinate.
NB. 'Input: - _
NB.  cartesian XYZ coords (X,Y,Z), Z translation (DZ) all in meters ; _
NB.  X and Y rotations in seconds of arc (X_Rot, Y_Rot) and scale in ppm (s).
NB.  	dim sfactor as double, Radx_ROt as double, Rady_rot as double, RadZ_rot as double, helmert_Y as double 

'x y Z DZ X_Rot Y_Rot s' =. y
NB. 'Convert rotations to radians and ppm scale to a factor
sfactor =. s * 0.000001
RadX_Rot =. (X_Rot % 3600) * o. % 180
RadY_Rot =. (Y_Rot % 3600) * o. % 180
    
NB. 'Compute transformed Z coord
result =. (- x * RadY_Rot) + (y * RadX_Rot) + Z + (Z * sfactor) + DZ
) 

NB. =========================================================
XYZ_to_Lat=: 3 : 0
NB. Function XYZ_to_Lat(x as double, y as double, Z as double, a as double, b as double)
NB. 'Convert XYZ to Latitude (PHI) in Dec Degrees.
NB. 'Input: - _
NB.  XYZ cartesian coords (X,Y,Z) and ellipsoid axis dimensions (a & b), all in meters.
NB. 'THIS FUNCTION REQUIRES THE "Iterate_XYZ_to_Lat" FUNCTION
NB. 'THIS FUNCTION IS CALLED BY THE "XYZ_to_H" FUNCTION

'x y Z a b' =. y	
	
RootXYSqr =. Sqr (*: x) + *: y
e2 =. ((a ^ 2) - (b ^ 2)) % (a ^ 2)
PHI1 =. arctan(Z % (RootXYSqr * (1 - e2)))
PHI =. Iterate_XYZ_to_Lat a ; e2 ; PHI1 ; Z ; RootXYSqr    
result =. PHI * 180 % o. 1
)

NB. =========================================================
Iterate_XYZ_to_Lat=: 3 : 0
NB. 'Iteratively computes Latitude (PHI).
NB. 'Input: - _
NB.  ellipsoid semi major axis (a) in meters; _
NB.  eta squared (e2); _
NB.  estimated value for latitude (PHI1) in radians; _
NB.  cartesian Z coordinate (Z) in meters; _
NB.  RootXYSqr computed from X & Y in meters.

NB. 'THIS FUNCTION IS CALLED BY THE "XYZ_to_PHI" FUNCTION
NB. 'THIS FUNCTION IS ALSO USED ON IT'S OWN IN THE _
NB.  "Projection and Transformation Calculations.xls" SPREADSHEET

'a e2 PHI1 Z RootXYSqr' =. y

V =. a % Sqr 1 - (e2 * ((sin(PHI1)) ^ 2))
PHI2 =. arctan((Z + (e2 * V * (sin(PHI1)))) % RootXYSqr)

while. +. / (|PHI1 - PHI2) > 0.000000001    
do. PHI1 =. PHI2
V =. a % Sqr 1 - (e2 * ((sin(PHI1)) ^ 2))
PHI2 =. arctan((Z + (e2 * V * (sin(PHI1)))) % RootXYSqr)
end.
result =. PHI2
)
NB. =========================================================
XYZ_to_Long=: 3 : 0
NB. Function XYZ_to_Long(x as double, y as double)
NB. 'Convert XYZ to Longitude (LAM) in Dec Degrees.
NB. 'Input: - _
NB.  X and Y cartesian coords in meters.
'x y' =. y
result =. (arctan(y % x)) * (180 % o. 1)
)

NB. =========================================================
XYZ_to_H=: 3 : 0 
NB. 'Convert XYZ to Ellipsoidal Height.
NB. 'Input: - _
NB.  XYZ cartesian coords (X,Y,Z) and ellipsoid axis dimensions (a & b), all in meters.

NB. 'REQUIRES THE "XYZ_to_Lat" FUNCTION

'x y Z a b' =. y

NB. 'Compute PHI (Dec Degrees) first
PHI =. XYZ_to_Lat x ; y ; Z ; a ; b

RadPHI =. o. PHI % 180
    
NB. Compute H
RootXYSqr =. Sqr((x ^ 2) + (y ^ 2))
e2 =. ((a ^ 2) - (b ^ 2)) % (a ^ 2)
V =. a % Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2)))
result =. (RootXYSqr % cos(RadPHI)) - V
)    

NB. =========================================================
Lat_Long_H_to_X=: 3 : 0
NB. 'Convert geodetic coords lat (PHI), long (LAM) and height (H) to cartesian X coordinate.
NB. 'Input: - 
NB.  Latitude (PHI)& Longitude (LAM) both in decimal degrees; 
NB.  Ellipsoidal height (H) and ellipsoid axis dimensions (a & b) all in meters.

'PHI LAM H a b' =. y

NB. Convert angle measures to radians
RadPHI =. o. PHI % 180
RadLAM =. o. LAM % 180

NB. Compute eccentricity squared and nu
e2 =. ((a ^ 2) - (b ^ 2)) % (a ^ 2)
V =. a % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))

NB. Compute X
(V + H) * (cos(RadPHI)) * (cos(RadLAM))
)

NB.  ========================================================
Lat_Long_H_to_Y =: 3 : 0
NB. 'Convert geodetic coords lat (PHI), long (LAM) and height (H) to cartesian Y coordinate.
NB. 'Input: -  NB.  Latitude (PHI)& Longitude (LAM) both in decimal degrees;  NB.  Ellipsoidal height (H) and ellipsoid axis dimensions (a & b) all in meters.
'PHI LAM H a b'  =. y	
NB. 'Convert angle measures to radians

RadPHI  =.  o. PHI % 180
RadLAM  =.  o. LAM % 180

NB. 'Compute eccentricity squared and nu
e2  =.  ((a ^ 2) - (b ^ 2)) % (a ^ 2)
V  =.  a % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))

NB. 'Compute Y
result =.  (V + H) * (cos(RadPHI)) * (sin(RadLAM))
)

NB. ==================================================
NB. Function Lat_H_to_Z(PHI as double, H as double, a as double, b as double)
Lat_H_to_Z=: 3 : 0
'PHI H a b' =. y
NB. 'Convert geodetic coord components latitude (PHI) and height (H) to cartesian Z coordinate.
NB. 'Input: -   Latitude (PHI) decimal degrees;   Ellipsoidal height (H) and ellipsoid axis dimensions (a & b) all in meters.

NB. 'Convert angle measures to radians
    RadPHI  =.  o. PHI % 180

NB. 'Compute eccentricity squared and nu
    e2  =.  ((a ^ 2) - (b ^ 2)) % (a ^ 2)
    V  =.  a % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))

NB. 'Compute X
    result =.  ((V * (1 - e2)) + H) * (sin(RadPHI))
)

NB. ==================================================
NB. Function Lat_Long_to_East(PHI as double, LAM as double, a as double, b as double, _
Lat_Long_to_East=: 3 : 0
'PHI LAM a b e0 f0 PHI0 LAM0' =. y
NB. 'Project Latitude and longitude to Transverse Mercator eastings.
NB. 'Input: -   Latitude (PHI) and Longitude (LAM) in decimal degrees;   ellipsoid axis dimensions (a & b) in meters;   eastings of false origin (e0) in meters;   central meridian scale factor (f0);   latitude (PHI0) and longitude (LAM0) of false origin in decimal degrees.
	
NB. 'Convert angle measures to radians
    RadPHI  =.  o. PHI % 180
    RadLAM  =.  o. LAM % 180
    RadPHI0  =.  o. PHI0 % 180
    RadLAM0  =.  o. LAM0 % 180

    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    n  =.  (af0 - bf0) % (af0 + bf0)
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(RadPHI)) ^ 2))
    eta2  =.  (nu % rho) - 1
    p  =.  RadLAM - RadLAM0
    
    IV  =.  nu * (cos(RadPHI))
    V  =.  (nu % 6) * ((cos(RadPHI)) ^ 3) * ((nu % rho) - (((tan(RadPHI)) ^ 2)))
VI  =.  (nu % 120) * ((cos(RadPHI)) ^ 5) * (5 - (18 * ((tan(RadPHI)) ^ 2)) + ((tan(RadPHI)) ^ 4) + (14 * eta2) - (58 * ((tan(RadPHI)) ^ 2) * eta2))
    
result =.  e0 + (p * IV) + ((p ^ 3) * V) + ((p ^ 5) * VI)
)

NB. ==================================================
NB. Function Lat_Long_to_North(PHI as double, LAM as double, a as double, b as double, _
Lat_Long_to_North=: 3 : 0
'PHI LAM a b e0 n0 f0 PHI0 LAM0' =. y
NB. 'Project Latitude and longitude to Transverse Mercator northings
NB. 'Input: -   Latitude (PHI) and Longitude (LAM) in decimal degrees;   ellipsoid axis dimensions (a & b) in meters;   eastings (e0) and northings (n0) of false origin in meters;   central meridian scale factor (f0);   latitude (PHI0) and longitude (LAM0) of false origin in decimal degrees.

NB. 'REQUIRES THE "Marc" FUNCTION
	
NB. 'Convert angle measures to radians
RadPHI  =.  o. PHI % 180
RadLAM  =.  o. LAM % 180
RadPHI0  =.  o. PHI0 % 180
RadLAM0  =.  o. LAM0 % 180

af0  =.  a * f0
bf0  =.  b * f0
e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
n  =.  (af0 - bf0) % (af0 + bf0)
nu  =.  af0 % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))
rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(RadPHI)) ^ 2))
eta2  =.  (nu % rho) - 1
p  =.  RadLAM - RadLAM0
m  =.  Marc bf0 ; n ; RadPHI0 ; RadPHI

i  =.  m + n0
II  =.  (nu % 2) * (sin(RadPHI)) * (cos(RadPHI))
III  =.  ((nu % 24) * (sin(RadPHI)) * ((cos(RadPHI)) ^ 3)) * (5 + (-(tan(RadPHI)) ^ 2) + (9 * eta2))
IIIA  =.  ((nu % 720) * (sin(RadPHI)) * ((cos(RadPHI)) ^ 5)) * (61 + (-58 * ((tan(RadPHI)) ^ 2)) + ((tan(RadPHI)) ^ 4))

result =.  i + ((p ^ 2) * II) + ((p ^ 4) * III) + ((p ^ 6) * IIIA)
)

NB. ==================================================
NB. Function E_N_to_Lat(east as double, north as double, a as double, b, e0, n0, f0, PHI0, LAM0)
E_N_to_Lat=: 3 : 0
'east north a b e0 n0 f0 PHI0 LAM0' =. y
NB. 'Un-project Transverse Mercator eastings and northings back to latitude.
NB. 'Input: -   eastings (East) and northings (North) in meters;   ellipsoid axis dimensions (a & b) in meters;   eastings (e0) and northings (n0) of false origin in meters;   central meridian scale factor (f0) and   latitude (PHI0) and longitude (LAM0) of false origin in decimal degrees.

NB. 'REQUIRES THE "Marc" AND "InitialLat" FUNCTIONS

NB. 'Convert angle measures to radians
RadPHI0  =.  o. PHI0 % 180
RadLAM0  =.  o. LAM0 % 180

NB. 'Compute af0, bf0, e squared (e2), n and Et
    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    n  =.  (af0 - bf0) % (af0 + bf0)
    Et  =.  east - e0

NB. 'Compute initial value for latitude (PHI) in radians
    PHId  =.  InitialLat north ; n0 ; af0 ; RadPHI0 ; n ; bf0
    
NB. 'Compute nu, rho and eta2 using value for PHId
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(PHId)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(PHId)) ^ 2))
    eta2  =.  (nu % rho) - 1
    
NB. 'Compute Latitude
    VII  =. (tan(PHId)) % (2 * rho * nu)
    VIII  =. ((tan(PHId)) % (24 * rho * (nu ^ 3))) * (5 + (3 * ((tan(PHId)) ^ 2)) + eta2 - (9 * eta2 * ((tan(PHId)) ^ 2)))
    IX  =.  ((tan(PHId)) % (720 * rho * (nu ^ 5))) * (61 + (90 * ((tan(PHId)) ^ 2)) + (45 * ((tan(PHId)) ^ 4)))
    
result =.  (180 % o. 1) * (PHId + (-(Et ^ 2) * VII) + ((Et ^ 4) * VIII) + (-(Et ^ 6) * IX))
)

NB. ==================================================
NB. Function E_N_to_Long(east as double, north as double, a as double, b as double, _
E_N_to_Long=: 3 : 0
'east north a b e0 n0 f0 PHI0 LAM0' =. y
NB. 'Un-project Transverse Mercator eastings and northings back to longitude.
NB. 'Input: -   eastings (East) and northings (North) in meters;   ellipsoid axis dimensions (a & b) in meters;   eastings (e0) and northings (n0) of false origin in meters;   central meridian scale factor (f0) and   latitude (PHI0) and longitude (LAM0) of false origin in decimal degrees.

NB. 'REQUIRES THE "Marc" AND "InitialLat" FUNCTIONS
	
NB. 'Convert angle measures to radians
    RadPHI0  =.  o. PHI0 % 180
    RadLAM0  =.  o. LAM0 % 180

NB. 'Compute af0, bf0, e squared (e2), n and Et
    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    n  =.  (af0 - bf0) % (af0 + bf0)
    Et  =.  east - e0

NB. 'Compute initial value for latitude (PHI) in radians
    PHId  =.  InitialLat north ; n0 ; af0 ; RadPHI0 ; n ; bf0
    
NB. 'Compute nu, rho and eta2 using value for PHId
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(PHId)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(PHId)) ^ 2))
    eta2  =.  (nu % rho) - 1
    
NB. 'Compute Longitude
    X  =.  ((cos(PHId)) ^ -1) % nu
    XI  =.  (((cos(PHId)) ^ -1) % (6 * (nu ^ 3))) * ((nu % rho) + (2 * ((tan(PHId)) ^ 2)))
    XII  =.  (((cos(PHId)) ^ -1) % (120 * (nu ^ 5))) * (5 + (28 * ((tan(PHId)) ^ 2)) + (24 * ((tan(PHId)) ^ 4)))
    XIIA  =.  (((cos(PHId)) ^ -1) % (5040 * (nu ^ 7))) * (61 + (662 * ((tan(PHId)) ^ 2)) + (1320 * ((tan(PHId)) ^ 4)) + (720 * ((tan(PHId)) ^ 6)))

result =. (180 % o. 1) * (RadLAM0 + (Et * X) + (-(Et ^ 3) * XI) + ((Et ^ 5) * XII) + (-(Et ^ 7) * XIIA))
)

NB. ==================================================
NB. Function InitialLat(north as double, n0 as double, afo as double, PHI0 as double, n as double, bfo as double)
InitialLat=: 3 : 0
'north n0 afo PHI0 n bfo' =. y
NB. 'Compute initial value for Latitude (PHI) IN RADIANS.
NB. 'Input: -   northing of point (North) and northing of false origin (n0) in meters;   semi major axis multiplied by central meridian scale factor (af0) in meters;   latitude of false origin (PHI0) IN RADIANS;   n (computed from a, b and f0) and   ellipsoid semi major axis multiplied by central meridian scale factor (bf0) in meters.
 
NB. 'REQUIRES THE "Marc" FUNCTION
NB. 'THIS FUNCTION IS CALLED BY THE "E_N_to_Lat", "E_N_to_Long" and "E_N_to_C" FUNCTIONS
NB. 'THIS FUNCTION IS ALSO USED ON ITS OWN IN THE  "Projection and Transformation Calculations.xls" SPREADSHEET

NB. 'First PHI value (PHI1)
PHI1  =.  ((north - n0) % afo) + PHI0
    
NB. 'Calculate M
m  =.  Marc bfo ; n ; PHI0 ; PHI1
    
NB. 'Calculate new PHI value (PHI2)
PHI2  =.  ((north + (- n0) + (- m)) % afo) + PHI1
    
NB. 'Iterate to get final value for InitialLat
while. *. / (Abs(north - (n0 + m))) > 0.00001 do.
	PHI2  =.  ((north - (n0 + m)) % afo) + PHI1
    m  =.  Marc bfo ; n ; PHI0 ; PHI2
    PHI1  =.  PHI2
end. 
    
result =. PHI2
)

NB. ==================================================
NB. Function Marc(bf0, n, PHI0, PHI)
Marc=: 3 : 0
'bf0 n PHI0 PHI' =. y
NB. 'Compute meridional arc.
NB. 'Input: -   ellipsoid semi major axis multiplied by central meridian scale factor (bf0) in meters;   n (computed from a, b and f0);   lat of false origin (PHI0) and initial or final latitude of point (PHI) IN RADIANS.
NB. 'THIS FUNCTION IS CALLED BY THE -   "Lat_Long_to_North" and "InitialLat" FUNCTIONS
NB. 'THIS FUNCTION IS ALSO USED ON IT'S OWN IN THE "Projection and Transformation Calculations.xls" SPREADSHEET

Marc  =.  bf0 * (((1 + n + ((5 % 4) * (n ^ 2)) + ((5 % 4) * (n ^ 3))) * (PHI - PHI0)) + (-((3 * n) + (3 * (n ^ 2)) + ((21 % 8) * (n ^ 3))) * (sin(PHI - PHI0)) * (cos(PHI + PHI0))) + ((((15 % 8) * (n ^ 2)) + ((15 % 8) * (n ^ 3))) * (sin(2 * (PHI - PHI0))) * (cos(2 * (PHI + PHI0)))) + (-((35 % 24) * (n ^ 3)) * (sin(3 * (PHI - PHI0))) * (cos(3 * (PHI + PHI0)))))
)


NB. ==================================================
NB. Function Lat_Long_to_C(PHI, LAM, LAM0, a, b, f0)
Lat_Long_to_C=: 3 : 0
'PHI LAM LAM0 a b f0' =. y
NB. 'Compute convergence (in decimal degrees) from latitude and longitude
NB. 'Input: -   latitude (PHI), longitude (LAM) and longitude (LAM0) of false origin in decimal degrees;   ellipsoid axis dimensions (a & b) in meters;   central meridian scale factor (f0).

NB. 'Convert angle measures to radians
    RadPHI  =.  o. PHI % 180
    RadLAM  =.  o. LAM % 180
    RadLAM0  =.  o. LAM0 % 180
        
NB. 'Compute af0, bf0 and e squared (e2)
    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    
NB. 'Compute nu, rho, eta2 and p
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(RadPHI)) ^ 2))
    eta2  =.  (nu % rho) - 1
    p  =.  RadLAM - RadLAM0

NB. 'Compute Convergence
    XIII  =.  sin(RadPHI)
    XIV  =.  ((sin(RadPHI) * ((cos(RadPHI)) ^ 2)) % 3) * (1 + (3 * eta2) + (2 * (eta2 ^ 2)))
    XV  =.  ((sin(RadPHI) * ((cos(RadPHI)) ^ 4)) % 15) * (2 - ((tan(RadPHI)) ^ 2))

result =.  (180 % o. 1) * ((p * XIII) + ((p ^ 3) * XIV) + ((p ^ 5) * XV))
)

NB. ==================================================
NB. Function E_N_to_C(east, north, a, b, e0, n0, f0, PHI0)
E_N_to_C=: 3 : 0
'east north a b e0 n0 f0 PHI0' =. y
NB. 'Compute convergence (in decimal degrees) from easting and northing
NB. 'Input: -   Eastings (East) and Northings (North) in meters;   ellipsoid axis dimensions (a & b) in meters;   easting (e0) and northing (n0) of true origin in meters;   central meridian scale factor (f0);   latitude of central meridian (PHI0) in decimal degrees.
 
NB. 'REQUIRES THE "Marc" AND "InitialLat" FUNCTIONS

NB. 'Convert angle measures to radians
    RadPHI0  =.  o. PHI0 % 180
        
NB. 'Compute af0, bf0, e squared (e2), n and Et
    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    n  =.  (af0 - bf0) % (af0 + bf0)
    Et  =.  east - e0
    
NB. 'Compute initial value for latitude (PHI) in radians
    PHId  =.  InitialLat north ; n0 ; af0 ; RadPHI0 ; n ; bf0
    
NB. 'Compute nu, rho and eta2 using value for PHId
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(PHId)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(PHId)) ^ 2))
    eta2  =.  (nu % rho) - 1

NB. 'Compute Convergence
    XVI  =.  (tan(PHId)) % nu
    XVII  =.  ((tan(PHId)) % (3 * (nu ^ 3))) * (1 + ((tan(PHId)) ^ 2) - eta2 - (2 * (eta2 ^ 2)))
    XVIII  =.  ((tan(PHId)) % (15 * (nu ^ 5))) * (2 + (5 * ((tan(PHId)) ^ 2)) + (3 * ((tan(PHId)) ^ 4)))
    
result =.  (180 % o. 1) * ((Et * XVI) + (- (Et ^ 3) * XVII) + ((Et ^ 5) * XVIII))
)

NB. ==================================================
NB. Function Lat_Long_to_LSF(PHI, LAM, LAM0, a, b, f0)
Lat_Long_to_LSF=: 3 : 0
'PHI LAM LAM0 a b f0' =. y
NB. 'Compute local scale factor from latitude and longitude
NB. 'Input: -   latitude (PHI), longitude (LAM) and longitude (LAM0) of false origin in decimal degrees;   ellipsoid axis dimensions (a & b) in meters;   central meridian scale factor (f0).
 
NB. 'Convert angle measures to radians
    RadPHI  =.  o. PHI % 180
    RadLAM  =.  o. LAM % 180
    RadLAM0  =.  o. LAM0 % 180
        
NB. 'Compute af0, bf0 and e squared (e2)
    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    
NB. 'Compute nu, rho, eta2 and p
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(RadPHI)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(RadPHI)) ^ 2))
    eta2  =.  (nu % rho) - 1
    p  =.  RadLAM - RadLAM0

NB. 'Compute local scale factor
   	XIX  =.  ((cos(RadPHI) ^ 2) % 2) * (1 + eta2)
    xx  =.  ((cos(RadPHI) ^ 4) % 24) * (5 + (- 4 * ((tan(RadPHI)) ^ 2)) + (14 * eta2) + ( - 28 * ((tan(RadPHI * eta2)) ^ 2)))
    
result =.  f0 * (1 + ((p ^ 2) * XIX) + ((p ^ 4) * xx))
)

NB. ==================================================
NB. Function E_N_to_LSF(east, north, a, b, e0, n0, f0, PHI0)
E_N_to_LSF=: 3 : 0
'east north a b e0 n0 f0 PHI0' =. y
NB. 'Compute local scale factor from from easting and northing
NB. 'Input: -   Eastings (East) and Northings (North) in meters;   ellipsoid axis dimensions (a & b) in meters;   easting (e0) and northing (n0) of true origin in meters;   central meridian scale factor (f0);   latitude of central meridian (PHI0) in decimal degrees.
 
NB. 'REQUIRES THE "Marc" AND "InitialLat" FUNCTIONS

NB. 'Convert angle measures to radians
    RadPHI0  =.  o. PHI0 % 180
        
NB. 'Compute af0, bf0, e squared (e2), n and Et
    af0  =.  a * f0
    bf0  =.  b * f0
    e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
    n  =.  (af0 - bf0) % (af0 + bf0)
    Et  =.  east - e0
    
NB. 'Compute initial value for latitude (PHI) in radians
    PHId  =.  InitialLat north ; n0 ; af0 ; RadPHI0 ; n ; bf0
    
NB. 'Compute nu, rho and eta2 using value for PHId
    nu  =.  af0 % (Sqr(1 - (e2 * ((sin(PHId)) ^ 2))))
    rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(PHId)) ^ 2))
    eta2  =.  (nu % rho) - 1

NB. 'Compute local scale factor
    XXI  =.  1 % (2 * rho * nu)
    XXII  =.  (1 + (4 * eta2)) % (24 * (rho ^ 2) * (nu ^ 2))
    
result =.  f0 * (1 + ((Et ^ 2) * XXI) + ((Et ^ 4) * XXII))
)

NB. ==================================================
NB. Function E_N_to_t_minus_T(AtEast, AtNorth, ToEast, ToNorth, a, b, e0, n0, f0, PHI0)
E_N_to_t_minus_T=: 3 : 0
'AtEast AtNorth ToEast ToNorth a b e0 n0 f0 PHI0' =. y
NB. 'Compute (t-T) correction in decimal degrees at point (AtEast, AtNorth) to point (ToEast,ToNorth)
NB. 'Input: -   Eastings (AtEast) and Northings (AtNorth) in meters, of point where (t-T) is being computed;   Eastings (ToEast) and Northings (ToNorth) in meters, of point at other end of line to which (t-T) is being computed;   ellipsoid axis dimensions (a & b) and easting & northing (e0 & n0) of true origin in meters;   central meridian scale factor (f0);   latitude of central meridian (PHI0) in decimal degrees.

NB. 'REQUIRES THE "Marc" AND "InitialLat" FUNCTIONS

NB. 'Convert angle measures to radians
RadPHI0  =.  o. PHI0 % 180
    
NB. 'Compute af0, bf0, e squared (e2), n and Nm (Northing of mid point)
af0  =.  a * f0
bf0  =.  b * f0
e2  =.  ((af0 ^ 2) - (bf0 ^ 2)) % (af0 ^ 2)
n  =.  (af0 - bf0) % (af0 + bf0)
nm  =.  (AtNorth + ToNorth) % 2

NB. 'Compute initial value for latitude (PHI) in radians
PHId  =.  InitialLat nm ; n0 ; af0 ; RadPHI0 ; n ; bf0

NB. 'Compute nu, rho and eta2 using value for PHId
nu  =.  af0 % (Sqr(1 - (e2 * ((sin(PHId)) ^ 2))))
rho  =.  (nu * (1 - e2)) % (1 - (e2 * (sin(PHId)) ^ 2))

NB. 'Compute (t-T)
XXIII  =.  1 % (6 * nu * rho)

result =.  (180 % o. 1) * ((2 * (AtEast - e0)) + (ToEast - e0)) * (AtNorth - ToNorth) * XXIII
)

NB. ==================================================
NB. Function TrueAzimuth(AtEast, AtNorth, ToEast, ToNorth, a, b, e0, n0, f0, PHI0)
TrueAzimuth=: 3 : 0
'AtEast AtNorth ToEast ToNorth a b e0 n0 f0 PHI0' =. y
NB. 'Compute true azimuth in decimal degrees at point (AtEast, AtNorth) to point (ToEast,ToNorth)
NB. 'Input: -   Eastings (AtEast) and Northings (AtNorth) in meters, of point where true azimuth is being computed;   Eastings (ToEast) and Northings (ToNorth) in meters, of point at other end of line to which true azimuth is being computed;   ellipsoid axis dimensions (a & b) and easting & northing (e0 & n0) of true origin in meters;   central meridian scale factor (f0);   latitude of central meridian (PHI0) in decimal degrees.

NB. 'REQUIRES THE "Marc", "InitialLat", "t_minus_T" and "E_N_to_C" FUNCTIONS
  
NB. 'Compute eastings and northings differences
    Diffe  =.  ToEast - AtEast
    Diffn  =.  ToNorth - AtNorth

NB. 'Compute grid bearing
    if. Diffe  = 0 do. 
        if. Diffn < 0 do. GridBearing  =. 180
        else. GridBearing  =. 0
        end.
        goto_EndOfComputeBearing.
  	end.
    
    Ratio  =.  Diffn % Diffe
    GridAngle  =.  (180 % o. 1) * arctan(Ratio)
    
    if. Diffe > 0 do. GridBearing  =.  90 - GridAngle
    end.
    
    if. Diffe < 0 do. GridBearing  =.  270 - GridAngle
    end.
label_EndOfComputeBearing.

NB. 'Compute convergence
Convergence  =.  E_N_to_C AtEast ; AtNorth ; a ; b ; e0 ; n0 ; f0 ; PHI0
    
NB. 'Compute (t-T) correction
t_minus_T  =.  E_N_to_t_minus_T AtEast ; AtNorth ; ToEast ; ToNorth ; a ; b ; e0 ; n0 ; f0 ; PHI0

NB. 'Compute true azimuth
result =.  GridBearing + Convergence - t_minus 
)