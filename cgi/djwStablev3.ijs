NB. Used to calculate Stableford Scores for various types of competition
NB. djw Stableford utilities

require 'files'
require 'jfiles'
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




ReadAll=: 3 : 0
glCourses=: >jread 'stable' ; 0
glPlayers=: >jread 'stable' ; 1
glCoName=: >jread 'stable' ; 2
glCoCSS=: >jread 'stable' ; 3
glCoPar=: >jread 'stable' ; 4
glCoIndex=: >jread 'stable' ; 5
glPlName=: >jread 'stable' ; 6
glPlCourse=: >jread 'stable' ; 7
glPlTeam=: >jread 'stable' ; 8
glPlHandicap=: >jread 'stable' ; 9
glPlAllowance=: >jread 'stable' ; 10
glPlRound=: >jread 'stable' ; 11
glPlGross=: >jread 'stable' ; 12
glPlNett=: >jread 'stable' ; 13,,
glPlPoints=: >jread 'stable' ; 14
)

WriteAll=: 3 : 0
(<glCourses) jreplace 'stable' ; 0
(<glPlayers) jreplace 'stable' ; 1
(<glCoName) jreplace 'stable' ; 2
(<glCoCSS) jreplace 'stable' ; 3
(<glCoPar) jreplace 'stable' ; 4
(<glCoIndex) jreplace 'stable' ; 5
(<glPlName) jreplace 'stable' ; 6
(<glPlCourse) jreplace 'stable' ; 7
(<glPlTeam) jreplace 'stable' ; 8
(<glPlHandicap) jreplace 'stable' ; 9
(<glPlAllowance) jreplace 'stable' ; 10
(<glPlRound) jreplace 'stable' ; 11
(<glPlGross) jreplace 'stable' ; 12
(<glPlNett) jreplace 'stable' ; 13
(<glPlPoints) jreplace 'stable' ; 14
)

NB. ====================================================
NB. Default variables
NB. ====================================================
defCourse=: 'DenhamW'
defPlayer=: _1
defAllowance=: 1
defRound=: 1

CalcAll=: 3 : 0
nett=: glPlGross 			NB. Start with gross scores
handicap=: (glPlHandicap * -. glPlRound) + glPlRound * <. 0.5+glPlHandicap NB. Rounds handicap  

nett=: nett - <. handicap % 18			NB. remove multiples of 18, 36
course=: glCoName i. glPlCourse
stroke=: course { glCoIndex

glPlNett=: nett - handicap >: stroke
glPlPoints=: 0 >. 2 + (course { glCoPar) - glPlNett
)		

Holes=: 3 : 0
gross=: >6 {"1 glPlayers
gross=: y {."1 gross
glPlayers=: ( ,.<"1 gross) ( ,6) }"1 glPlayers 
CalcAll 0
)

Totals=: 3 : 0
Holes=: {: $ > 6 {"1 glPlayers
)

Add=: 3 : 0
if. 0= L. y do. y=. y ; y ; 18 end.
glPlName=: glPlName, 0 { y
glPlCourse=: glPlCourse, <defCourse
glPlTeam=: glPlTeam, 1 { y
glPlHandicap=: glPlHandicap,> 2 { y
glPlAllowance=: glPlAllowance,defAllowance
glPlRound=: glPlRound, defRound
glPlGross=: glPlGross, _
glPlNett=: glPlNett, _
glPlPoints=: glPlPoints, 0
defPlayer=: _1 + #glPlName
CalcAll ''
View defPlayer
)

View=: 3 : 0
out=. ,: '=============================='
out=. out,  >y { glPlName
out=. out, '=========================='
out=. out, 'Team= ',>y { glPlTeam
out=. out, 'Handicap= ', ": y{glPlHandicap
out=. out, 'Allowance= ',( ": y{glPlAllowance),  '  Round=. ', ": y{glPlRound
sco=. (1+ i. 18), (y { glPlGross) ,: y { glPlPoints
sco=. 2 9 ($"1) sco
sco=. 0 2 |: sco
out, ": ((<"2) sco) , <|: +/"1 sco
)
