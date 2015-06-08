NB. slope_util.ijs

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
NB. Augment GPS
NB. =============================================
NB. Augment the GPS file with missing tee and
NB. green information
NB. =============================================




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

