NB. Used to calculate Stableford Scores for various types of competition
NB. djw Stableford utilities

require 'files'
require 'jfiles'
NB. require 'misc'


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
NB, .. check for non existant names
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
