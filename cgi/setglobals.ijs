NB. ==============================================
NB. setglobals
NB. ----------------------------------------------
NB. Sets the global variables for paths etc.
NB. Only use this in offline mode, from the 
NB. database directory, e.g. /var/www/jweb/<zzz>    
NB. ==============================================
setglobals=: 3 : 0
if. 0 < # 1!:0 <'/Users' do. glHome=: '/Users' else. glHome=: '/home' end.
if. 0 < # 1!:0 <glHome,'/djw' do. glHome=: glHome, '/djw' else. glHome=: glHome,'/ubuntu' end.
if. 0 < # 1!:0 <'/Users' do. glDocument_Root=: '/Library/WebServer/Documents' else. glDocument_Root=: '/var/www' end.
glBasename=: > _1 { (<;._1) 1!:43 ''
glDbFile=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glBasename,'.db'
glDbRoot=: '/yii/',glBasename,'/protected/data'
glJPath=: _4 }. BINPATH_z_
NB. glJPath=: glHome,'/j602'
)

x=.setglobals ''

4!:55 <'setglobals'
