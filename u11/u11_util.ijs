NB. Utilities for rating programme
NB. Including GPS calculations
NB. and offline updates


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
basename=. 'u11'
NB. Check if basename already created
if. 0~: 4!:0 <'glBasename' do. glBasename=: basename end.
)

basename=.setglobalsfromcurrent ''
ww=. 4!:55 <'setglobalsfromcurrent'

require glDocument_Root,'/jweb/cgi/djwUtilFile.ijs'
NB. require glDocument_Root,'/jweb/cgi/djwGpsRead.ijs'
NB. require glDocument_Root,'/jweb/cgi/djwOrdSurvey.ijs'

NB. ====================================================
NB. CalcAge
NB. ----------------------------------------------------
NB. Calculate age in years and days
NB. Default to today
NB. All dates are in tsrep format
NB. Usage:  today CalcAge dates
NB. ----------------------------------------------------
CalcAge=: 3 : 0
(tsrep 6!:0 '') CalcAge y
:
x=. ''$x NB. Make sure it is a scalar
y=. ,y
y=. x <. y NB. Can't be more recent than today
NB. Remove hours minutes etc.
x=. 1 tsrep x
y=. 1 tsrep y
x=. 6{. (3{. x)
y=. 6{."1 (3{."1 y)

res=. (0{x) - (0{"1 y) 
NB. Change year to this year
y=. (0{x) (,0)}"1 y
NB. Adjust if birthday is later than today
mask=. (tsrep y) > tsrep x
res=. res - mask
y=. ((0{x)-mask) (,0)}"1 y
days=. (tsrep x) - tsrep y NB. miliseconds
days=. <. 0.5 + days % (24 * 60 * 60 * 1000)
res=. res + 0.001 * days
)

NB. ================================================
NB. ReadAll
NB. ------------------------------------------------
NB. Read the file and check for missing variables
NB. Usage: err=. ReadAll filename
ReadAll=: 3 : 0
if. fexist y,'.ijf' do.
	xx=. utFileGet y
	xx=. utKeyRead y,'_player'
	if. 0 ~: 4!:0 <'gl9Hole' do.
	    gl9Hole=: 0
	    ww=. (<'gl9Hole') utFilePut y
	end.
	if. 0 ~: 4!:0 <'glPageDelay' do.
		glPageDelay=: 7 15 7 NB. Start -> Leader -> Prize
		ww=.(<'glPageDelay') utFilePut y
	end.
	if. 0 ~: 4!:0 <'glScrollParam' do.
		glScrollParam=: 5 1 0.05 NB. Initial : ScrollPixels : ScrollTime
		ww=.(<'glScrollParam') utFilePut y
	end.
	err=. ''
else.
	err=. 'No such course'
end.
NB. ================================================
