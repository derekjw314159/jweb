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
NB. Utility to blank out elements from a component file
NB. y is the file
vars=.>jread y ; 0
x=. dltb each x
ix=. vars i. x
NB, .. check for non existant names 
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

