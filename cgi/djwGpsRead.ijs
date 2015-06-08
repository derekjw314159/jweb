NB. GPS utilities to read Pathaway file
NB. and manipulate it

load 'files'
load 'dates'
load 'text'
load 'strings'
NB. load 'format'
NB. load 'system\packages\files\csv.ijs'

NB. ====================================================
NB. ReadPathaway2
NB. ====================================================
ReadPathaway2=: 3 : 0
NB. Reads pdb file directly without conversion to text file
NB. fil=. wd 'mbopen  "Select PDB file" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "Pathaway(*.pdb)|*.pdb" ofn_filemustexist'
fil=. y
yy =. '' fread fil
recct =. 256 #. a. i. (76+ i. 2) { yy  NB. Record count
recst =. 256 #.  a. i. ((78 + 8 * i. recct) +/ i. 4) { yy  NB. Offset to ToC
reclen =. >. / recst -~ }. recst, $yy
x =. ((_1+#yy)<.recst+/i.80){yy  NB. Get the data
x=. > 0{"1 < (;. _1)"1   (0{a.)(,"1) x  NB. Delimit at QuadAV[0]
x=. 7{."1 < (;. _1)"1   ','(,"1) x  NB. Delimit at comma
NB. May need to remove some double quotes
x=.x -. each <'"'
x=.dltb each x

for_axis. i. 2 do.
lat =. >axis{"1 x
sign =. 1 _1 {~ +. /"1 'SW' e."1 lat
lat =. lat,"1 ' 0' NB. make sure at least two numbers on each row
latitude=: lat
lat =. 2{."1 ("."1 (lat -."1 'NSEW'))
lat =. sign * lat +/ . * 1,%60
x=. (,. <"0 lat) (,axis) }"1 x
end.
NB. Pull out the coordinates
coord=.  > (0 1) {"1 x
coord=. ,. <"0 j./"1 coord
x=.coord (,"1) 2 }."1 x NB. replace first two columns with coord

NB. Convert feet to Metres
lat =. 1 {"1 x
sign =. I. a: ~: lat
lat =. ,. <"0 ("."1 sign { >lat) % 3.2808398950131
x=. lat (<sign  ; ,1) } x

NB. Date manipulation, including adjustment to Excel base date
NB. Format can be HHMMSS YYYYMMDD or HHMMSS DDMMYY
yearfirst =. 1
dat=.> 2{"1 x
NB. try first of all DDMMYYYY format
dat=. 5 4 3 0 1 2  {"1 (100 100 100 100 100 10000) #: 100000000 #. >". each 2{"1 x
if. ( 12 +./ . < 1 {"1 dat ) +. ( 31 +./ . < 2 {"1 dat ) do.
	NB. Then try YYYYMMDD format
	dat=. 3 4 5 0 1 2  {"1 (100 100 100 10000 100 100) #: 100000000 #. >". each 2{"1 x
end.
dat2=. <"0 ((tsrep dat) - tsrep 1899 12 30 0 0 0 ) % 24*60*60*1000 NB. use rather than todayno to cover hours etc.
dat2=.  (a:) (( */"1 dat=0) # i. # dat) } dat2 NB. replace zeros with null

x=. (,. dat2) (,2)}"1 x
x
)

NB. =========================================================
NB. WritePathaway2
NB. =========================================================
WritePathaway2=: 3 : 0
NB. Writes pdb file directly without interim conversion to text file
NB. Because the format is the same, need to specify the Type of object
'R' WritePathaway2 y
:
fil=. wd 'mbsave "Select PDB file" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "Pathaway(*.pdb)|*.pdb" ofn_overwriteprompt'
NB. Header information
recct=. #y
head=.(1+{: I. '\' E. fil) }. fil
head=.({: (#head),I. '.' E. head) {. head
head=. 32{. head, 32$ 0{a.
head=. head, 0 8 0 3 { a. NB. Type and version
NB. Header timestamp
NB. 37-40 and 41-44 are timestamp, seconds since 1904/1/1
head=.head, (8 $ 256 256 256 256 #: <. 0.001 * (tsrep 6!:0 '') - tsrep 1904 1 1 0 0 0 ) { a.
head=.head, 4$0{a. NB. null date
NB. Header modify, infosize, sort info
NB. 49-60 application info size etc
head=.head, 0 0 0 150 0 0 2 152 0 0 0 0 { a. 
if. x='W' do.
	head=.head, 'PoLiKnWr', 128 124 176 73 0 0 0 0{a.  NB. Waypoint
else.
	head=.head, 'UsTrKnWr',128 124 176 73 0 0 0 0 {a.  NB. Route or Track
end.
head=.head,(256 256 #: recct){a.

NB. ---Appinfo structure
appinfo=. 277$0{a. NB. in theory adds two extra 0's
if. x='T' do.
	appinfo=.appinfo, 0 0 0{a. NB. Track
else.
	appinfo=.appinfo, 1 0 0{a. NB. Route
end.
appinfo=. appinfo, 200{. 'Vehicles:Car', 200$ 0{ a.

NB. <<y>> holds the file data to be written
NB. Data is manipulated using the the PathtoTxt function
NB. and reading it back again
y=. 'temp.txt' WritePathtoTxt y
y=. 'b' fread 'temp.txt'
y=. y,each <0 255{a. NB. add null,FF to each record

NB. Offsets for record read
offset=. +/ \ 0, }: ># each y
offset=. offset + ''$($head) + ($appinfo) +8*recct
offset=. (256 256 256 256 #: offset) (,"1) 64(,"1) 256 256 256 #: 100+i.#offset
offset=. (,8 {."1 offset) { a.

(head,offset,appinfo,(; y), 255{a.) fwrite fil
fil
) 

NB. ==================================================
NB. WritePathtoTxt
NB. ==================================================
WritePathtoTxt=: 3 : 0
NB. Writes pdb file directly without interim conversion to text file
NB. Because the format is the same, need to specify the Type of object
fil=. wd 'mbsave "Select PDB file" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "Pathaway(*.pdb)|*.pdb" ofn_overwriteprompt'
fil WritePathtoTxt y
:
(PathtoTxt y) writecsv x
) 


NB. ==================================================
NB. ReadTxttoPath
NB. ==================================================
ReadTxttoPath=: 3 : 0
NB. Writes pdb file directly without interim conversion to text file
NB. Because the format is the same, need to specify the Type of object
if. 0=#y do.
	y=. wd 'mbopen "Select TXT file to open" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "Text(*.txt)|*.txt" ofn_overwriteprompt'
end.
y=.readcsv y
y=.TxttoPath y 
)

NB. =======================================================
NB. PathtoTxt
NB. =======================================================
PathtoTxt=: 3 : 0
NB. Converts J format Pathaway object (route etc.) to txt
NB. still in boxed format
yy=. <"0 +. > 0 {"1 y
yy=. yy ,. <"0 (>1 {"1 y) * 3.2808398950131
yy=. yy ,. <"1 ;"1 'r<0>2.0,r<0>2.0,r<0>2.0,3.0,r<0>2.0,r<0>4.0' (8!:0) 3 4 5 2 1 0 {"1 XLdatetoTS > 2 {"1 y
yy=. yy ,. 3 }."1 y
) 

NB. =======================================================
NB. TxttoPath
NB. =======================================================
TxttoPath=: 3 : 0
NB. Converts J format Pathaway object (route etc.) to txt
NB. still in boxed format
yy=. <"0 j./"1 >(".) each (0 1) {"1 y
yy=. yy ,. <"0 (>(".) each 2 {"1 y) % 3.2808398950131
yy=. yy (,"1 0) <"0 TStoXLdate 5 4 3 0 1 2  {"1 (100 100 100 100 100 10000) #: 100000000 #. >". each 3{"1 y
yy=. yy (,"1) 4 }."1 y
yy=. 6 {."1 yy
) 


NB. =========================================================
NB. Fixed KMLHead
NB. =========================================================
KMLHead=: 0 : 0
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2" xmlns:gx="http://www.google.com/kml/ext/2.2" xmlns:kml="http://www.opengis.net/kml/2.2" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:xlink="http://www.w3/org/1999/xlink">
<Document>
	<name>!NAME!</name>
	<open>1</open>
	<Style id="track">
		<icon xlink:href="root://icons/bitmap-4.png?x=128&amp;y=0&amp;w=32&amp;h=32">
  root://icons/bitmap-4.png?x=128<![CDATA[&]]>y=0<![CDATA[&]]>w=32<![CDATA[&]]>h=32
</icon>
	</Style>
	<Style id="sn_ylw-pushpin">
		<LabelStyle>
			<color>ff0055ff</color>
		</LabelStyle>
		<IconStyle>
			<scale>0.8</scale>
		</IconStyle>
		<icon xlink:href="root://icons/bitmap-4.png?x=160&amp;y=0&amp;w=32&amp;h=32">
  root://icons/bitmap-4.png?x=160<![CDATA[&]]>y=0<![CDATA[&]]>w=32<![CDATA[&]]>h=32
</icon>
	</Style>
	<StyleMap id="msn_ylw-pushpin">
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_ylw-pushpin</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="route">
		<icon xlink:href="root://icons/bitmap-4.png?x=160&amp;y=0&amp;w=32&amp;h=32">
  root://icons/bitmap-4.png?x=160<![CDATA[&]]>y=0<![CDATA[&]]>w=32<![CDATA[&]]>h=32
</icon>
	</Style>
	<Style id="sn_grn-blank">
		<IconStyle>
			<scale>0.5</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/paddle/grn-blank.png</href>
			</Icon>
			<hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>
		</IconStyle>
		<ListStyle>
			<ItemIcon>
				<href>http://maps.google.com/mapfiles/kml/paddle/grn-blank-lv.png</href>
			</ItemIcon>
		</ListStyle>
	</Style>
	<StyleMap id="msn_grn-blank">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_grn-blank</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_grn-blank</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="sn_placemark_circle">
		<IconStyle>
			<scale>0.5</scale>
			<Icon>
				<href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href>
			</Icon>
		</IconStyle>
		<ListStyle>
		</ListStyle>
	</Style>
	<StyleMap id="msn_placemark_circle">
		<Pair>
			<key>normal</key>
			<styleUrl>#sn_placemark_circle</styleUrl>
		</Pair>
		<Pair>
			<key>highlight</key>
			<styleUrl>#sh_placemark_circle_highlight</styleUrl>
		</Pair>
	</StyleMap>
	<Style id="lineStyle">
		<LineStyle>
			<color>64eeee17</color>
			<width>6</width>
		</LineStyle>
	</Style>
	<Style id="waypoint">
		<icon xlink:href="root://icons/bitmap-4.png?x=160&amp;y=0&amp;w=32&amp;h=32">
  root://icons/bitmap-4.png?x=160<![CDATA[&]]>y=0<![CDATA[&]]>w=32<![CDATA[&]]>h=32
</icon>
	</Style>
)

NB. =========================================================
NB. Fixed KMLHeadShort
NB. =========================================================
KMLHeadShort=: 0 : 0
<?xml version="1.0" encoding="ISO-8859-1"?>
<kml xmlns="http://earth.google.com/kml/2.0" version="2.0" src="PathAway">
<Document>
<name>!NAME!</name>
  <Style id="TrackStyle">
    <LineStyle>
      <color>7FFF0000</color>)
      <width>4</width>
    </LineStyle>
  </Style>
  <Style id="RouteStyle">
    <LineStyle>
      <color>7F0000FF</color>)
      <width>4</width>
    </LineStyle>
  </Style>
  <Style id="sn_grn-blank">
    <IconStyle>
	  <scale>0.7</scale>
	  <Icon>
	    <href>http://maps.google.com/mapfiles/kml/paddle/grn-blank.png</href>
	  </Icon>
	  <hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>
	</IconStyle>
  </Style>
  <StyleMap id="msn_grn-blank">
    <Pair>
	  <key>normal</key>
	  <styleUrl>#sn_grn-blank</styleUrl>
	</Pair>
	<Pair>
	  <key>highlight</key>
	  <styleUrl>#sn_grn-blank</styleUrl>
	</Pair>
  </StyleMap>
  <Style id="sn_placemark_circle">
    <IconStyle>
	  <scale>0.5</scale>
	  <Icon>
	    <href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href>
	  </Icon>
	</IconStyle>
  </Style>
  <StyleMap id="msn_placemark_circle">
    <Pair>
	  <key>normal</key>
	  <styleUrl>#sn_placemark_circle</styleUrl>
	</Pair>
	<Pair>
	  <key>highlight</key>
	  <styleUrl>#sn_placemark_circle</styleUrl>
	</Pair>
  </StyleMap>
)

NB. ====================================================
NB. PullXML
NB. ====================================================
PullXML=: 4 : 0
NB. Pull String <<y>> within XML quote specified by <<x>>
i=. I. x E. y
if. 0=#i do.
	r=.''
else.
	r=. ((#x)+{.i) }. y
	i=. I. (({.x),'/',}.x) E. r
	r=. ({.i) {. r
end.
r
)

NB. ===================================================
NB. Global Variables
NB. ===================================================
KMLHead=: ; ( (LF=KMLHead) <;._1 KMLHead) ,each <CRLF
KMLHeadShort=: ; ( (LF=KMLHeadShort) <;._1 KMLHeadShort) ,each <CRLF
KMLTail=: '</Document>',CRLF,'</kml>'

NB. ===================================================
NB. WriteKMLRoute2
NB. ===================================================
WriteKMLRoute2=: 3 : 0
NB. Writes pdb file directly without interim conversion to text file
NB. Because the format is the same, need to specify the Type of object
'R' WriteKMLRoute2 y
:
fil=. wd 'mbsave "Select KML file" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "KML(*.kml)|*.kml" ofn_overwriteprompt'
KMLHeadShort fwrite fil
('!NAME!' ; fil) fstringreplace fil
('<Folder>',CRLF) fappend fil
if. 'R'=x do.
	(TAB,'<name>Routes</name>',CRLF) fappend fil
elseif. 'T'=x do.
	(TAB,'<name>Tracks</name>',CRLF) fappend fil
elseif. 1. do.
	(TAB,'<name>Waypoints</name>',CRLF) fappend fil
end.
('<Folder>',CRLF) fappend fil
(TAB,'<name>',fil,'</name>',CRLF) fappend fil
NB. (TAB,'<open>1</open>',CRLF) fappend fil

for_xx. y do.
	'lat alt date name symbol desc'=. xx
	if. 0 <#date do.
		date=.XLdatetoXML >date
	else. date=. ''
	end.
	
	if. 0 <#alt do.
		alt=. ": alt
	else. alt=. ''
	end.

	lat=. ;1 0 2 0 3 {"1 (<','),"1 ": each (<"0) 1 0 2 {"1 , >+. each 0 1 {"1 xx
	lat=. '-' (I. lat='_') } lat

	((TAB),'<Placemark>',CRLF) fappend fil		
	((2$TAB),'<name>',name,'</name>',CRLF) fappend fil
NB.	((2$TAB),'<Icon>Landmark</Icon>',CRLF) fappend fil
	if. (;symbol)-:(;'2') do.
		((2$TAB),'<styleUrl>msn_grn-blank</styleUrl>',CRLF) fappend fil
	elseif. (;symbol)-:(;'4') do.
		((2$TAB),'<styleUrl>msn_placemark_circle</styleUrl>',CRLF) fappend fil
	end.
	desc=. ( ; desc) -. '<>"'
	if. 0< #desc do.
		((2$TAB),'<description>',desc,'</description>',CRLF) fappend fil
	end.
	((2$TAB),'<Point>',CRLF) fappend fil
	((3$TAB),'<coordinates>') fappend fil
    (lat) fappend fil
	('</coordinates>',CRLF) fappend fil
	((3$TAB),'<Timestamp><when>',date,'</when></Timestamp>',CRLF) fappend fil
	((2$TAB),'</Point>',CRLF) fappend fil
	((TAB),'</Placemark>',CRLF) fappend fil							
end.
NB. ('</Folder>',CRLF) fappend fil

if. x e. 'RT' do.

# Write out the Path
NB. ('<Folder>',CRLF) fappend fil
	((TAB),'<Placemark>',CRLF) fappend fil
	((2$TAB),'<name>Path</name>',CRLF) fappend fil
	if. x='R' do.
		((2$TAB),'<styleUrl>#RouteStyle</styleUrl>',CRLF) fappend fil
	else.
		((2$TAB),'<styleUrl>#TrackStyle</styleUrl>',CRLF) fappend fil
	end.
	((2$TAB),'<MultiGeometry>',CRLF) fappend fil
	((3$TAB),'<LineString>',CRLF) fappend fil
	((4$TAB),'<coordinates>',CRLF) fappend fil
	xx=. ;(5$<TAB)(,"1) 2 0 3 0 4 1 {"1 (',' ; CRLF),"1 ": each (<"0) 1 0 2 {"1 ,. >+. each 0 1 {"1 y
	xx=. '-' (I. xx='_') } xx
	(xx,(4$TAB),'</coordinates>',CRLF) fappend fil
	((3$TAB),'</LineString>',CRLF) fappend fil
	((2$TAB),'</MultiGeometry>',CRLF) fappend fil
	((TAB),'</Placemark>',CRLF) fappend fil
end.
('</Folder>',CRLF) fappend fil
('</Folder>',CRLF) fappend fil
KMLTail fappend fil
) 



NB. ======================================
NB. ReadKMLAll
NB. ======================================
ReadKMLAll=: 3 : 0
'' ReadKMLAll y
:
if. 0=#y do.
	y=. wd 'mbopen "KML file to Open" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "KML(*.kml)|*.kml" ofn_overwriteprompt'
end.
if. 0=#x do.
	x=. wd 'mbsave "Txt file to Save" "d:\documents and settings\djw\My Documents\05-Waypoints"  ""  "TXT(*.txt)|*.txt" ofn_overwriteprompt'
end.
dat=. fread y
dat=. ('<Folder>' E. dat) <;.1 dat
('') fwrite x
res=. 0 6$ ' '
name=.0 5$' '
ct=._1
for_j. i. #dat do.
	xx=. >j{dat
	pl=. ( '<Placemark>' E. xx) i. 1
	nm=.  I. '<name>' E. xx
	nm=. (nm < pl) # nm
	for_n. nm do. 
		name=.  name, '<name>' PullXML n }. xx
	end.
	if. (pl<#xx) do.
	
	yy=.>('<Placemark>' E. xx) <;.1 xx
	NB. Delete multigeometry or Polygon
	NB. yy=. (-. +./"1 '<MultiGeometry>' E."1 1 yy) # yy
	yy=. (-. +./"1 '<LineString>' E."1 1 yy) # yy
	yy=. (-. +./"1 '<Polygon>' E."1 1 yy) # yy
	if. 0<#yy do.
		nm=.  '<name>' PullXML"1 1 (yy)
		nm=. dltb each <"1 nm
		coord=. '<coordinates>' PullXML"1 1 (yy)
		coord=. >". each dltb each 3{."1 <;._1"1 ',',"1 coord
		coord=. ((j./"1) 1 0{"1 coord),. 2{"1 coord
		coord=. <"0 coord 
		date=.<"0 XMLtoXLdate '<when>' PullXML"1 1 (yy)
		NB. Write out local variables by shuffling to file
		ct=.ct+1
		res=. res, (":ct),'_', }. ; dltb each <"1 '_',"1 name	
		('kml_',": ct)=: (coord,"1 0 date),"1 0 nm
		(CRLF,',,,,,==============',CRLF) fappend x
		(',,,,,',(":ct),'_', }. ; dltb each <"1 '_',"1 name) fappend x
		(CRLF,',,,,,==============',CRLF) fappend x
		'temp.txt' WritePathtoTxt (coord,"1 0 date),"1 0 nm
		(; fread 'temp.txt') fappend x
	end.

	yy=.>('<Placemark>' E. xx) <;.1 xx
	yy=. ( +./"1 ('<LineString>' E."1 1 yy) +. ('<Polygon>' E."1 1 yy)) # yy
	
	for_yy0. yy do.
		zz=.'<coordinates>' PullXML yy0
		zz=. (+/ *./ \ zz e. ' ',CRLF) }. zz NB. Delete leading
		zz=. (zz e. ' ',CRLF) <;._2 zz NB. cut at blanks
		zz=. (0< ># each zz) # zz NB. Delete nulls
		zz=.(<',') , each zz
		zz=. > <;._1 each zz
		zz=. ". each zz
		NB. Need to ravel because sometimes is nn x 2 x 1
		zz=.  (<"0 j./"1 (;"_1) >1 0 {"1 zz),. 2 {"1 zz
		zz=. zz,"1 ('' ; ''; '4' ; '')
		ct=.ct+1
		name=. (}: name), 'LineString'		
		(CRLF,',,,,,==============',CRLF) fappend x
		(',,,,,',(":ct),'_', }. ; dltb each <"1 '_',"1 name) fappend x
		(CRLF,',,,,,==============',CRLF) fappend x
		'temp.txt' WritePathtoTxt zz
		(; fread 'temp.txt') fappend x
		res=. res, (":ct),'_', }. ; dltb each <"1 '_',"1 name	
		('kml_',": ct)=: zz
	end.
		
	else.
label_endloop.
	NB. name=. (- +./ '</Folder>' E. ; xx) }. name
	end.
	name=. (- +/ '</Folder>' E. ; xx) }. name
end.
	res
)

NB. =========================================================
NB. FullOStoLatLon
NB. =========================================================
FullOStoLatLon=: 3 : 0
North1 =. +. y
East1 =. 0 {"1 North1
North1 =. 1 {"1 North1

NB. ' Set the parameters
a  =.  6377563.396
b  =.  6356256.91
f0  =.  0.999601272
e0  =.  400000
n0  =.  -100000
PHI0  =.  49
LAM0  =.  -2
 
lat1  =.  E_N_to_Lat East1 ; North1 ; a ; b; e0 ; n0 ; f0 ; PHI0 ; LAM0
lon1  =.  E_N_to_Long East1 ; North1 ; a ; b ; e0 ; n0 ; f0 ; PHI0 ; LAM0
    
x1  =.  Lat_Long_H_to_X lat1 ; lon1 ; 0 ; a ; b
y1  =.  Lat_Long_H_to_Y lat1 ; lon1 ; 0 ; a ; b
z1  =.  Lat_H_to_Z lat1 ; 0 ; a ; b

DX  =.  446.448
DY  =.  -125.157
DZ  =.  542.06
s  =.  -20.4894
X_Rot  =.  0.1502
Y_Rot  =.  0.247
Z_Rot  =.  0.8421

x2  =.  Helmert_X x1 ; y1; z1; DX; Y_Rot; Z_Rot; s
y2  =.  Helmert_Y x1; y1; z1; DY; X_Rot; Z_Rot; s
z2  =.  Helmert_Z x1; y1; z1; DZ; X_Rot; Y_Rot; s

a  =.  6378137
b  =.  6356752.313

lat1  =.  XYZ_to_Lat x2; y2; z2; a; b
lon1  =.  XYZ_to_Long x2; y2

result =. lat1 j. lon1
)

NB. =========================================================
NB. LatLontoFullOS
NB. =========================================================
LatLontoFullOS=: 3 : 0
NB. Convert complex number with Lat.Lon to OS format East.North
a =. 6378137
b =. 6356752.313
height =. 0

lat1 =. +. y
lon1 =. 1 {"1 lat1
lat1 =. 0 {"1 lat1
    
x1 =. Lat_Long_H_to_X lat1 ; lon1 ; height ; a ; b
y1 =. Lat_Long_H_to_Y lat1 ; lon1 ; height ; a ; b
z1 =. Lat_H_to_Z lat1 ; height ; a ; b
    
DX =. -446.448
DY =. 125.157
DZ =. -542.06
s =. 20.4894
X_Rot =. -0.1502
Y_Rot =. -0.247
Z_Rot =. -0.8421
    
x2 =. Helmert_X x1 ; y1 ; z1 ; DX ; Y_Rot ; Z_Rot ; s
y2 =. Helmert_Y x1 ; y1 ; z1 ; DY ; X_Rot ; Z_Rot ; s
z2 =. Helmert_Z x1 ; y1 ; z1 ; DZ ; X_Rot ; Y_Rot ; s
    
a =. 6377563.396
b =. 6356256.91
lat1 =. XYZ_to_Lat x2 ; y2 ; z2 ; a ; b
lon1 =. XYZ_to_Long x2 ; y2
height =. XYZ_to_H x2 ; y2 ; z2 ; a ; b
    
NB. Set the parameters
a =. 6377563.396
b =. 6356256.91
f0 =. 0.999601272
e0 =. 400000
n0 =. -100000
PHI0 =. 49
LAM0 =. -2

East1 =. Lat_Long_to_East lat1 ; lon1 ; a ; b ; e0; f0 ; PHI0 ; LAM0
North1 =. Lat_Long_to_North lat1 ; lon1 ; a ; b ; e0 ; n0 ; f0 ; PHI0 ; LAM0

East1 j. North1
)    
