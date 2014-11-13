NB. J Utilities for Denhambowl
<<<<<<< HEAD
NB. Central functions
=======
NB. 
>>>>>>> e33f0c2c63e909c0461e7f5153711e1230b832dd

NB. Standard input field behaviours
NB. ================================
NB. InputField
NB. ================================
InputField=: 3 : 0
r=. ' class="normal" style="font-size: 8pt; height: 16px; width: ',(":y),'em;" type="text"'
)

InputFieldnum=: 3 : 0
('nam';'wid')=. y
r=. ' class="normal" style="font-size: 8pt; height: 16px; margin: 0px; width: ',(":wid),'em;" type="text" name="',nam,'" id="',nam,'" onkeyup="validatenum2(''',nam,''')"'
)

NB. ===================================
NB. CSS Standards
NB. djwBlueprintCSS
NB. ===================================
djwBlueprintCSS=: 3 : 0
stdout LF,'<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">'
stdout LF,'<link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">'
stdout LF,'<!--[if lt IE 8]>'
stdout LF,TAB,'<link rel="stylesheet" href="/css/blueprint/ie.css" type="text/css" media="screen, projection">'
stdout LF,'<![endif]-->'
)

<<<<<<< HEAD
NB. =========================================================
NB. denhambowl_check_db
NB. =========================================================
NB. Check the columns are all present
NB. in the database
denhambowl_check_db=: 3 : 0
NB. Check for update columns
sql=. 'select sql from sqlite_master where name=''tbl_course'';'
sql=. 'echo "',sql,'" | sqlite3 -header ',glDbFile
answer=.; 2!:0 sql NB. Raze the answer
answer=. +. / 'updatename' E. answer
if. -.answer do. NB. Need to add columns
    sql=. 'ALTER TABLE tbl_course ADD COLUMN updatename VARCHAR(20);'
    sql=. 'echo "',sql,'" | sqlite3 -header ',glDbFile
    answer=. 2!:0 sql
    sql=. 'ALTER TABLE tbl_course ADD COLUMN updatetime VARCHAR(20);'
    sql=. 'echo "',sql,'" | sqlite3 -header ',glDbFile
    answer=. 2!:0 sql
end.
NB. Update the date
sql=. 'UPDATE  tbl_course set updatename=''system'', updatetime=''1990-01-01'' WHERE updatename IS NULL;'
sql=. 'echo "',sql,'" | sqlite3 -header ',glDbFile
answer=. 2!:0 sql
)

NB. Need to run it
denhambowl_check_db ''

=======
>>>>>>> e33f0c2c63e909c0461e7f5153711e1230b832dd