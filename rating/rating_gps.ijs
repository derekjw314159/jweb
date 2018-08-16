NB. J Utilities for Rating Courses
NB. 

NB. =========================================================
NB. jweb_rating_gps_e
NB. =========================================================
jweb_rating_gps_e=: 3 : 0
NB. y=.cgiparms ''
if. 2=#y do. NB. Passed as parameter
    rating_gps_edit y
elseif. 1 do.
    pagenotfound ''
end.
)

NB. =========================================================
NB. rating_gps_edit
NB. =========================================================
rating_gps_edit=: 3 : 0
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
BuildGPSMap ,hole

stdout LF,'</head>',LF,'<body>'
stdout LF,'<div class="container" width="100%">'
NB. Control map display
stdout LT1,'  <div id="map-canvas"></div>'
NB. stdout LF,'<div class="container" width="100%">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to course list'
end.

NB. Print course yardage and measurements
stdout LF,'<h2>Course : ', glCourseName,'</h2><h3>Hole : ',(":1+ ; hole),'</h3>'
stdout LF,TAB,'<div class="span-24 last">'

NB. Form
stdout LT1,'<form action="/jw/rating/gps/editpost/',(;glFilename),'" method="post">'
NB. Hidden variables
stdout LT2,'<input type="hidden" name="hole" value="',(":hole),'">'
stdout LT2,'<input type="hidden" name="filename" value="',(;glFilename),'">'

NB. Table of positions
stdout LT1,'<table>',LT2,'<thead>',LT3,'<tr>'
stdout LT4,'<th>Name</th><th>Latitude</th><th>Longitude</th><th>Meas</th><th>Add</th><th>Del</th></tr>',LT2,'</thead>',LT2,'<tbody>'

	for_t. glTees  do.
		stdout LT3,'<tr>'
		stdout LT4,'<td>',(>(glTees i. t){glTeesName),'</td>'
		markername=. 'marker',(":hole),'T',>t
		path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hole)),'T',t
		meas=. path { glGPSMeasured, 0
		path=. +. path { glGPSLatLon
		ww=. 9!:11 (9)  NB. Print precision
		stdout LT4,'<td><input value="',(;'m<->9' 8!:0 (0{path)),'" ',(InputFieldnum (markername,'lat'); 12),'></td>'
		stdout LT4,'<td><input value="',(;'m<->9' 8!:0 (1{path)),'" ',(InputFieldnum (markername,'lng'); 12),'></td>'
		stdout LT4,'<td><input name="',(markername,'meas'),'" id="',(markername,'meas'),'" value="',(meas{'-y'),'" ',(InputField 2),'></td>'
		stdout LT4,'<td></td>'
		stdout LT4,'<td></td>'
		stdout LT3,'</tr>'
	end.

	for_p. 1+i. 5  do.
		stdout LT3,'<tr>'
		stdout LT4,'<td>Pivot point',(":p),'</td>'
		markername=. 'marker',(":hole),'P',":p
		path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hole)),'P',":p
		meas=. path { glGPSMeasured, 0
		path=. +. path { glGPSLatLon,91j181
		ww=. 9!:11 (9)  NB. Print precision
		stdout LT4,'<td><input value="',(;'m<->9' 8!:0 (0{path)),'" ',(InputFieldnum (markername,'lat'); 12),'></td>'
		stdout LT4,'<td><input value="',(;'m<->9' 8!:0 (1{path)),'" ',(InputFieldnum (markername,'lng'); 12),'></td>'
		stdout LT4,'<td><input name="',(markername,'meas'),'" id="',(markername,'meas'),'" value="',(meas{'-y'),'" ',(InputField 2),'></td>'
		stdout LT4,'<td><button type="button" onclick="addPivot(''',markername,''')">Add</button></td>'
		stdout LT4,'<td><button type="button">Del</button></td>'
		stdout LT3,'</tr>'
	end.

	stdout LT3,'<tr>'
	stdout LT4,'<td>Green centre</td>'
	markername=. 'marker',(":hole),'GC'
	path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hole)),'GC'
	meas=. path { glGPSMeasured, 0
	path=. +. path { glGPSLatLon,91j181
	ww=. 9!:11 (9)  NB. Print precision
	stdout LT4,'<td><input value="',(;'m<->9' 8!:0 (0{path)),'" ',(InputFieldnum (markername,'lat'); 12),'></td>'
	stdout LT4,'<td><input value="',(;'m<->9' 8!:0 (1{path)),'" ',(InputFieldnum (markername,'lng'); 12),'></td>'
	stdout LT4,'<td><input name="',(markername,'meas'),'" id="',(markername,'meas'),'" value="',(meas{'-y'),'" ',(InputField 2),'></td>'
	stdout LT4,'<td></td>'
	stdout LT4,'<td></td>'
	stdout LT3,'</tr>'

stdout LT2,'</tbody></table>'
stdout LF,'<input type="submit" name="control_calc" value="Calc">'
stdout LF,'     <input type="submit" name="control_done" value="Done">'
stdout LT1,'</form>'

stdout LF,'</div>' NB. main span

if. hole>0{Holes '' do.
	stdout ' <a href="https://',(": ,getenv 'SERVER_NAME'),'/jw/rating/gps/e/',glFilename,'/',(": hole),'">&lt;&lt;</a>'
end.
for_h. (Holes '') do.
	if. h=hole do.
		stdout ' ',(": 1+h)
	else.
		stdout ' <a href="https://',(": ,getenv 'SERVER_NAME'),'/jw/rating/gps/e/',glFilename,'/',(": 1+h),'">',(":1+h),'</a>'
	end.
end.
if. hole<_1{Holes '' do.
	stdout ' <a href="https://',(": ,getenv 'SERVER_NAME'),'/jw/rating/gps/e/',glFilename,'/',(": 2+hole),'">&gt;&gt;</a>'
end.
	
stdout LF,'</div>' NB. container
stdout '</body></html>'
exit ''
)

NB. =======================================================================
NB. BuildGPSMap
NB. -----------------------------------------------------------------------
NB. Builds the script logic for one or more holes
NB.
BuildGPSMap=: 3 : 0
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
centre=. path
ww=. 9!:11 (9)  NB. Print precision
stdout LF,'var myCenter=new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),');'
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
NB. Loop round the points for this hold
    NB. Add the various points here, starting with tees
	hh=. 0{, hole
	for_t. i.#glTees  do.
		stdout LF,'   var marker',(":hh),'T',(t{glTees),'=new google.maps.Marker({'
		path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'T',t{glTees
		path=. +. path { glGPSLatLon
		stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
		rgb=. t{glTeesRGB
		rgb=. (0{"1 glRGB) i. rgb
		rgb=. >(<rgb,1) { glRGB
		rgb=. '#',rgb
		markername=. 'marker',(":hh),'T',>t{glTees
		NB.	stdout LF,'      icon: dyncircle( ''white'', ''white''),'
		stdout LF,'       icon: dyncircle( ''',rgb,''', ''',rgb,'''),'
		stdout LF,'       title: ''Hole ',(":hh+1),' Tee ',(>t{glTeesName),''','
		stdout LF,'       draggable: true'
		stdout LF,'       });'
		stdout LF,'    ',markername,'.setMap(map);'
		NB. Add event handler
		stdout LF,'    /* Event handler */'
		stdout LF,'    google.maps.event.addListener(',markername,', ''dragend'', function (event) {'
		stdout LF,'        document.getElementById("',markername,'lat','").value = event.latLng.lat();'
		stdout LF,'        document.getElementById("',markername,'lng','").value = event.latLng.lng();'
		stdout LF,'        document.getElementById("',markername,'meas").value = "y";'
		stdout LF,'        });'
	end. 

	NB. Write out pivot points

	for_p. 1+i.5  do.
		stdout LF,'   var marker',(":hh),'P',(":p),'=new google.maps.Marker({'
		path=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'P',": p
		path=. +. path { glGPSLatLon, 91j181
		stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{path)),',',(>'' 8!:0 (1{path)),'),'
		markername=. 'marker',(":hh),'P',": p
		stdout LF,'       icon: dyncircle( ''black'', ''white''),'
		stdout LF,'       title: ''Pivot point ',(":hh+1),' P',(":p),''','
		stdout LF,'       draggable: true'
		stdout LF,'       });'
		stdout LF,'    ',markername,'.setMap(map);'
		NB. Add event handler
		stdout LF,'    /* Event handler */'
		stdout LF,'    google.maps.event.addListener(',markername,', ''dragend'', function (event) {'
		stdout LF,'        document.getElementById("',markername,'lat','").value = event.latLng.lat();'
		stdout LF,'        document.getElementById("',markername,'lng','").value = event.latLng.lng();'
		stdout LF,'        document.getElementById("',markername,'meas").value = "y";'
		stdout LF,'        });'
	end. 
	
    NB. Green marker 
    stdout LF,'   var marker',(":hh),'GC=new google.maps.Marker({'
    rr=. glGPSName i. <(>'r<0>2.0' 8!:0 (1+hh)),'GC'
    rr=. +. rr { glGPSLatLon, 91j181
    stdout LF,'      position: new google.maps.LatLng(',(>'' 8!:0  (0{rr)),',',(>'' 8!:0 (1{rr)),'),'
	markername=. 'marker',(":hh),'GC'
    stdout LF,'      icon: "https://chart.apis.google.com/chart?chst=d_map_spin&chld=0.5|0|FF99CC|8|_|',(":1+hh),'",'
	stdout LF,'      draggable: true'
    stdout LF,'      });'
    stdout LF,'   marker',(":hh),'GC.setMap(map);'
	NB. Add event handler
	stdout LF,'    /* Event handler */'
	stdout LF,'    google.maps.event.addListener(',markername,', ''dragend'', function (event) {'
	stdout LF,'        document.getElementById("',markername,'lat','").value = event.latLng.lat();'
	stdout LF,'        document.getElementById("',markername,'lng','").value = event.latLng.lng();'
	stdout LF,'        document.getElementById("',markername,'meas").value = "y";'
	stdout LF,'        });'

	NB. Flightpath
	NB. Loop round each tee to draw the "crow's feet"
	path=. 0$0
	for_t. }. glTees do. NB. All bar first tee
		path=. path, 0 1 0{ PathTeeToGreen hh ; t
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

	stdout LF,'    }'

	stdout LF,'    function addPivot(name){'
	stdout LF,'        document.getElementById(name + "lat").value = "', (;'' 8!:0 (0{centre)),'";'
	stdout LF,'        document.getElementById(name + "lng").value = "', (;'' 8!:0 (1{centre)),'";'
	stdout LF,'        document.getElementById(name + "meas").value = "";'
	stdout LF,'        var latlng = new google.maps.LatLng(',(;'' 8!:0 (0{centre)),', ',(;'' 8!:0 (1{centre)),');'
    stdout LF,'        name.setPosition(latlng);'
	stdout LF,'        }'
NB. End of hh loop
    stdout LF,'google.maps.event.addDomListener(window, ''load'', initialize);'
    stdout LF,'</script>'
)

NB. =========================================================
NB. jweb_rating_gps_editpost
NB. =========================================================
NB. Process entries after edits to landing 
NB. based on the contents after the "post"
jweb_rating_gps_editpost=: 3 : 0
y=. cgiparms ''
y=. }. y NB. Drop the URI GET string
NB. Perform security checks
NB. This page can only be accessed by landing/e/
httpreferer=. getenv 'HTTP_REFERER'
https=. getenv 'HTTPS'
servername=. getenv 'SERVER_NAME'
httphost=. getenv 'HTTP_HOST'
if. -. glSimulate do.
	if. (-. +. / 'rating/gps/e/' E. httpreferer) +. (-. 'on'-: https) +. (-.  servername -: httphost) +. (-. +. / servername E. httpreferer) do.
		pagenotvalid ''
	end.
end.

NB. Assign to variables
NB. Leave them all as text
hole=: 0
xx=. djwCGIPost y ; ' ' cut 'hole hole'
glFilename=: dltb ;filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

NB. Read the current values and assign to global variables
ww=. utFileGet glFilepath
NB. Delete them, then re-instate
ix=. (2{. each glGPSName) ~: ('r<0>2.0' 8!:0 (1+hole))
glGPSName=: ix # glGPSName
glGPSLatLon=: ix # glGPSLatLon
glGPSAlt=: ix # glGPSAlt
glGPSMeasured=: ix # glGPSMeasured

	for_t. glTees  do.
		markername=. 'marker',(":hole),'T',>t
		glGPSName=: glGPSName,  <(>'r<0>2.0' 8!:0 (1+hole)),'T',t
		glGPSAlt=: glGPSAlt, 0
		glGPSLatLon=: glGPSLatLon, (91". ;". markername,'lat') j. 181". ;". markername,'lng'
		glGPSMeasured=: glGPSMeasured, 'y' e. ;".markername,'meas'
	end.

	for_p. 1+i. 5  do.
		markername=. 'marker',(":hole),'P',":p
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+hole)),'P',":p
		glGPSAlt=: glGPSAlt, 0
		glGPSLatLon=: glGPSLatLon, (91". ;". markername,'lat') j. 181". ;". markername,'lng'
		glGPSMeasured=: glGPSMeasured, 'y' e. ;".markername,'meas'
	end.

		markername=. 'marker',(":hole),'GC'
		glGPSName=: glGPSName, <(>'r<0>2.0' 8!:0 (1+hole)),'GC'
		glGPSAlt=: glGPSAlt, 0
		glGPSLatLon=: glGPSLatLon, (91". ;". markername,'lat') j. 181". ;". markername,'lng'
		glGPSMeasured=: glGPSMeasured, 'y' e. ;".markername,'meas'

NB. Delete any infeasible
msk=. +. glGPSLatLon
msk=. (90 >: 0{"1 msk) *. (180 >: 1{"1 msk) *. (0 <: 0{"1 msk) *. (_180 <: 1{"1 msk)
glGPSName=: msk # glGPSName
glGPSLatLon=: msk # glGPSLatLon
glGPSAlt=: msk#glGPSAlt
glGPSMeasured=: msk # glGPSMeasured

NB. Write to files
utFilePut glFilepath
AugmentGPS ,hole
BuildPlan ,hole

stdout 'Content-type: text/html',LF,LF
stdout LF,'<!DOCTYPE html>',LF,'<html><head>' 
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
NB. Choose page based on what was pressed
	if. 0= 4!:0 <'control_calc' do.
		stdout '</head><body onLoad="redirect(''',(":httpreferer),''')"'
	elseif. 1 do.
		stdout '</head><body onLoad="redirect(''/jw/rating/plannomap/v/',glFilename,'/',(;":1+hole),''')"'
    end.
stdout LF,'</body></html>'
NB. exit ''
)

