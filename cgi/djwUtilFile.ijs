require 'files'
require 'jfiles'

NB. =============================================================
NB. utDirRead
NB. -------------------------------------------------------------
NB. Read a directory recursively
NB. <x> is the boxed list of specifications
NB. <y> is the boxe list of directories to sear
utDirRead=: 3 : 0
(,<'*') utDirRead y
:
NB. <flist> is the list of directories still to search
NB. We will loop round picking off the bottom directoryi
if. 0=#y do. y=.,jcwdpath '' end.
if. 0=L. y do. y=.,<y end.
if. 0=L. x do. x=.,<x end.
x=.,x
flist =. y
result =. 0 5 $ ,a: 

currwd=. jcwdpath''

while.	(0 < #flist) do.
    fil =. >_1 { flist
    fil =. dltb fil
    NB. removing any trailing slashes from the directory name
    fil =. (- +/ *./ \ |. fil = '/') }. fil
		
    NB. Remove this directory from the stack
    flist=. , }: flist
    
    NB. Check for any subdirectories that the directory exists
    if. 0<#subdir=. fdir (fil, '/*') do.
	subdir=. ('d'= 0{"1 > 5 {"1 subdir) # 0 {"1 subdir
	subdir=. (<fil,'/'),each subdir
	flist=.flist,subdir
    end.

    for_spec. x do.
	NB. Check for each filespec at this level and remove any weird directories with the same name
	subdir=. fdir fil,'/',dltb >spec
	if. 0<#subdir do.
		subdir=. ('d'~: 0{"1 > 5 {"1 subdir) # 0 1 2 5 {"1 subdir
		result =. result, (<fil,'/') ,"1 subdir
	end.
    end.
end.
result
)

NB. ===========================================================
NB. utDBCompress
NB. -----------------------------------------------------------
NB. Compress a number of variables
NB. x is compression vector
NB. y is prefix for the variables
utDBCompress=: 4 : 0
nams=. y nl 0
for_i. nams do.
	(i)=: x # ".>i
end.
)

NB. require 'misc'

utFilePut=: 3 : 0
NB. =====================================================
NB. utFilePut
NB. =====================================================
NB. Utility to put a number of variables to a file
NB. y is the file
NB. x is the list of variables, which defaults to the existing list
(>jread y ; 0) utFilePut y
:
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
NB, .. check for non existent names and add any not found
vars=. vars, (ix >: #vars) # x
(<vars) jreplace y; 0
ix=. vars i. x
NB. .. need to add some null entries
for. i. 0>. 1 + (>. / ix) - (1 { jsize y) do.
(<'') jappend y
end. 
NB. Loop round to write or it is too heavy a single line
NB. for_k. ix do.
NB.	(". >k_index{x) jreplace y; 1+k
NB. end.
(". each x) jreplace y; 1+ix
)

utFileSafePut=: 3 : 0
NB. =====================================================
NB. utFileSafePut
NB. =====================================================
NB. Utility to put a number of variables to a file
NB. but throw an error if the variables are not already there
NB. y is the file
NB. x is the list of variables, which defaults to the existing list
(>jread y ; 0) utFilePut y
:
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
NB. .. check for non existant names
if. +. / ix >: #vars do.
	err=. '**** FAILED : no variable ', ;(<' '),each (ix >: #vars) # x
	return.
end.
NB. Loop round to write or it is too heavy a single line
NB. for_k. ix do.
NB. 	(". >k_index{x) jreplace y; 1+k
NB. end.
(". each x) jreplace y; 1+ix
)

utFileGet=: 3 : 0
NB. =======================================================
NB. utFileGet
NB. =======================================================
NB. Utility to retrieve a number of variables from a file
NB. y is the file
NB. x is the list of variables, which defaults to the existing list
(>jread y ; 0) utFileGet y
:
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
if. +. / ix >: #vars do.
	err=. '**** FAILED : no variable ', ;(<' '),each (ix >: #vars) # x
	return.
end.
(x)=: jread y; 1+ix
)

utFileCompress=: 3 : 0
NB. =======================================================
NB. utFileCompress
NB. =======================================================
NB. Utility to compress blank elements from a component file
NB. y is the file
vars=.>jread y ; 0
ix=.vars ~: <''
dat=.jread y ; 1 + i. #vars
num=. + / ix
NB. compress the elements
( (ix # vars) ; ix # dat ) jreplace y ; 0 , 1+i. num
NB. .. make any other variables null, which isn't strictly necessary
ix=. (1+num) }.  i. 1{ jsize y
( (# ix) $ <'' ) jreplace y ; ix 
)

utFileDrop=: 4 : 0
NB. =======================================================
NB. utFileDrop
NB. =======================================================
NB. Utility to remove elements from a component file
NB. y is the file
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
NB. .. check for non existent names 
if. +. / ix >: #vars do.
	err=. '**** FAILED : no variable ', ;(<' '),each (ix >: #vars) # x
	return.
end.
vars=.(<'') (ix)} vars 
(<vars) jreplace y ; 0
utFileCompress y
)


utFileView=: 3 : 0
NB. =======================================================
NB. utFileView
NB. =======================================================
NB. Utility to retrieve a number of variables from a file
NB. and display them as a nested array
NB. y is the file
NB. x is the list of variables, which defaults to the existing list
(>jread y ; 0) utFileView y
:
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
if. +. / ix >: #vars do.
	err=. '**** FAILED : no variable ', ;(<' '),each (ix >: #vars) # x
	return.
end.
res=. jread y; 1+ix
x,. ($ each $ each res),. ($ each res),. (3!:0 each res),.(L. each res) ,.   ": each (5<.#res){.res NB. restrict to viewing 5
)

utFileViewShort=: 3 : 0
NB. =======================================================
NB. utFileViewShort
NB. =======================================================
NB. Utility to retrieve a number of variables from a file
NB. and display their properties
NB. y is the file
NB. x is the list of variables, which defaults to the existing list
(>jread y ; 0) utFileViewShort y
:
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
if. +. / ix >: #vars do.
	err=. '**** FAILED : no variable ', ;(<' '),each (ix >: #vars) # x
	return.
end.
res=. jread y; 1+ix
x,. ($ each $ each res),. ($ each res),. (3!:0 each res),.(L. each res)
)

utVarsView=: 3 : 0
NB. =======================================================
NB. utVarsView
NB. =======================================================
NB. Utility to retrieve a number of variables from a file
NB. and display them as a nested array
NB. y is the file
NB. x is the list of variables, which defaults to the existing list
(4!:1 ,y) utVarsView y
:
vars=.4!:1 ,y
x=. dltb each x
ix=. vars i. x
if. +. / ix >: #vars do.
	err=. '**** FAILED : no variable ', ;(<' '),each (ix >: #vars) # x
	return.
end.
res=. ". each x
x,. ($ each $ each res),. ($ each res),. (3!:0 each res),. (L. each res) ,. ": each res
)


NB. =============================================================
NB. utKeyPut
NB. -------------------------------------------------------------
NB. Put variables to the keyfile <y>
NB. x holds a subset of the keys, but if it is not present
NB. then update all the items in the dictionary

NB. Assumes the dictionary starts with the key as the first entry
NB. Usage:  subset utKeyPut filename
NB. =============================================================
utKeyPut=: 3 : 0
key=. >keyread y ; '_dictionary'
key=. >0{ key NB. First element is the variable holding the keys
if. -. 0 -: 4!:0 <key do.
	stderr 'No key data : ',key,' to write to ',y
	return.
end.
(". key) utKeyPut y NB. Write them all
:
res=. ((#x),0)$a:
varnames=. >keyread y; '_dictionary'
for_col. varnames do.
	NB. Added a safety feature to write a default value to protect
	NB. against the case where we are adding a single row and not
	NB. all the variables are properly added 
	if. (0 ~: 4!:0 col) do.
		val=. (#x)$a: NB. Set to null if doesn't exit
	else. 
		val=. ". >col NB. Take the global variable value
	end.
	if. (1=#x) *. (1<#val) do.
		val=. ,a: NB. Protection case for single, new added
	end.

	if. col_index=0 do. key=. val end.
	NB. If not boxed, box now
	if. 0=L. val do. val=. <"_1 val end.
	res=. res,. val
end. 
NB. box each row
res=. <"1 res
res keywrite y ; <key
NB. returns the matrix of values
)
 
NB. =============================================================
NB. utKeyClear
NB. -------------------------------------------------------------
NB. Clears down all the variables with the exception of the
NB. key in the first column
NB. It is useful in the case where we are adding a new row
NB. and want to protect against some old values hanging around
NB. When the record is "put" any missing variables are set to the
NB. default values by the utKeyPut function.
NB. Usage:  utKeyClear filename
NB. =============================================================
utKeyClear=: 3 : 0
key=. >keyread y ; '_dictionary'
key=. }. key NB. First element is the key itself
4!:55 key
NB. returns the matrix of values
)

NB. =============================================================
NB. utKeyRead
NB. -------------------------------------------------------------
NB. Reads the keyfile <y>
NB. x holds a subset of the keys, but if it is not present
NB. then read all the items in the dictionary

NB. Assumes the dictionary starts with the key as the first entry
NB. Usage:  subset utKeyRead filename
NB. =============================================================
utKeyRead=: 3 : 0
x=. keydir y
x=. (-. x = <'_dictionary')#x
x utKeyRead y NB. Read them all
: 
x=. ,x
res=. keyread y ; <x
res=. >res
key=. >keyread y; '_dictionary'
if. 0=#x do. res=. (0,#key)$a: end. NB. Special case if no rows
NB. Fix the width in case a column has been added
res=. (#key) {."1 res
NB. transpose and box by row
for_col. key do.
	(>col)=: col_index{"1 res
	NB. If boxed number, unbox
	if. (3!:0 >". (>col)) e. 1 4 8 16 do. (>col)=: >". (>col) 
	NB. If single characters, open
	elseif.  0=+/; ($&$) each ". > col do.
		(>col)=: >". (>col)
	end.
end. 
ww=. $res
)

NB. =============================================================
NB. utKeyDrop
NB. -------------------------------------------------------------
NB. Drop keys 
NB. x holds a subset of the keys, but if it is not present
NB. then read all the items in the dictionary

NB. Assumes the dictionary starts with the key as the first entry
NB. Usage:  keys utKeyDrop filename
NB. =============================================================
utKeyDrop=: 4 : 0
x=. ,x
if. 0 < # x do.
	keydrop y ; <x
end.
)

NB. =============================================================
NB. utKeyAddColumn
NB. -------------------------------------------------------------
NB. Add columns to a keyed file
NB. Left argument should be boxed list of columns
NB. Usage:  column utKeyAddColumn filename
NB. =============================================================
utKeyAddColumn=: 4 : 0
x=. ,x
if. 0=L. x do. x=. ,<x end.
key=. >keyread y ; '_dictionary'
(<key, x) keywrite y ; <'_dictionary'
)

NB. =============================================================
NB. utKeyDropColumn
NB. -------------------------------------------------------------
NB. Deletes columns to a keyed file
NB. Left argument should be boxed list of columns
NB. Usage:  column utKeyDropColumn filename
NB. =============================================================
utKeyDropColumn=: 4 : 0
x=. ,x
if. 0=L. x do. x=. ,<x end.
dict=. >keyread y ; '_dictionary'
key=. keydir y NB. Including directory
mask=. -. dict e. x
for_rec. key do.
	xx=. > keyread y ; rec
	xx=. mask # ($mask) {. xx NB. Need to check the length 'cos could have added a column
	(<xx) keywrite y ; rec
end.
)

NB. ==============================================================
NB. utPlanDisplay
NB. --------------------------------------------------------------
NB. Displays the items in a file
NB. Usage: (hole ; tee ; player ; ability) utKeyDisplay filename
NB. ==============================================================
utPlanDisplay=: 3 : 0
'hole tee gender ability'=. y
ix=. glPlanHole e. hole
NB. Either a planned item, or it matches
ix2=. glPlanRecType='P'
ix2=. ix2 *. glPlanTee e. tee
ix2=. ix2 *. glPlanGender e. gender
ix2=. ix2 *. glPlanAbility e. ability
ix2=. ix2 +. glPlanRecType ~: 'P'

ix=. ix *. ix2
res=. |: > keyread (glFilepath,'_plan')  ; <'_dictionary' ; ix # glPlanID
)

NB. ==============================================================
NB. utLayupDisplay
NB. --------------------------------------------------------------
NB. Displays the items in a file
NB. Usage: (hole ; tee ; player ; ability) utKeyDisplay filename
NB. ==============================================================
utLayupDisplay=: 3 : 0
'hole tee gender ability'=. y
ix=. glLayupHole e. hole
NB. Either a planned item, or it matches
ix2=. glLayupTee e. tee
ix2=. ix2 *. glLayupGender e. gender
ix2=. ix2 *. glLayupAbility e. ability

ix=. ix *. ix2
res=. |: > keyread (glFilepath,'_layup')  ; <'_dictionary' ; ix # glLayupID
)


