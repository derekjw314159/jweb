NB. Set of utilities for J
NB. to peform Sqlite database functions from the operating system
NB. and to manipulate the answer into J arrays

NB. =========================================================
NB. djwSqliteR
NB. =========================================================
NB. Execute SQL and return result
NB. x is the database name
NB. y is the sql command to execute
djwSqliteR=: 4 : 0
sql=. y
sql=. 'echo "',sql,'" | sqlite3 -header ',x
answer=. 2!:0 sql

NB. answer=. fixcsv 2!:0 answer
answer=. >(<;._1) each (<'|'),each }: <;._1 LF,answer
NB. Walk through each of the columns
for_col. i. {: $answer do.
    val=. col {"1 answer
    head=. {. val
    val=. }.val
    NB. Check if they are all numbers by running dyadic execute
    NB. Must be a null, or a single valid number
    execval=. _ ". each val
    if. *. / ( 2 > > # each execval ) *. (-. >(_ e. each execval) ) do.
	NB. Do extra append of zero in case all null
	answer=. ( ,. head,  <"0 }. , > 7 ; execval)  (,col) }"1 answer
    end.
end.
answer=.answer
)

NB. =========================================================
NB. djwSqliteSplit 
NB. =========================================================
NB. Takes the sql array returned from <djwSqliteR> and assign
NB. to global variables
djwSqliteSplit=: 4 : 0
vars=. {. y
vars=. (<x,'_'),each vars
(vars)=: <"1 |: }. y
for_col. vars do.
    val=. ". > col
    if. *. / 2 ~: >(3!:0) each val do.
	(col)=: }. , > 0 ; val
    end.
end.
)

NB. =========================================================
NB. djwBuildArray
NB. =========================================================
NB. Builds a columnar array of all the variables prefixed
NB. by the names in <y>
NB. For example djwBuildArray 'tbl_course_par'
NB. will make a single array <tbl_course_par> where each
NB. column was made from <tbl_course_par00>, <par01> etc
NB. The original variables are deleted
djwBuildArray=: 3 : 0
xx=.4!:55 <y
res=. (4!:1) 0
ix=.(#y) {. each res
ix=. I. ix = <y
res=. ix { res
res=. res /: res
NB. Need to loop round and fix any which are not boxed
NB. for_j. res do.
NB.     if. 32 ~: (3!:0) ".>j do.
NB.		(>j)=: <"0 ".>j 
NB.     end.
NB. end.
xx=.4!:55 <y
(y)=:  ". 4 }. ; (<' ,  '),each res 
NB. Delete first
xx=.4!:55 res
)

NB. =========================================================
NB. djwSplitArray
NB. =========================================================
NB. This reverses the process in <djwBuildArray>
NB. e.g. 'fred' djwSplitArray mat -> fred00, fred01
NB. based on the columns.  If more than 99 columns it is fred000 etc.
djwSplitArray=: 3 : 0
x=. y
name=.y
y=. ". y
if. 99 < {: $ y do. form=. 'r<0>3.0' else. form=. 'r<0>2.0' end.
res=. <"1 |:  y
x=. (<x),each form (8!:0) i. {: $ y
(x)=: res
xx=. 4!:55 <name
)

NB. ============================================================
NB. djwSqliteUpdate
NB. ============================================================
NB. Build an SQL statement based variables with names specified
NB. <y> is a list of boxed variable names which will form the
NB. columns.  The key has to be the first one listed
NB. and duplicate columns are removed with the nub function
NB. If present <x> is the index of rows
djwSqliteUpdate=: 3 : 0
(i. 0) djwSqliteUpdate y
:
if. 0=L. y do. y=. <y end.
y=. , y
x=. ,x
tablename=. >0 { y
tableprefix=. > 1 { y
y=. 2 }. y
columns=. 0$a:
for_col. y do.
    res=. (4!:1) 0
    ix=.(#>col) {. each res
    ix=. I. ix = col
    res=. ix { res
    columns=. columns, res /: res
end.
columns=. ~. columns
NB. Check the value of x based ont he first
if. 0=#x do.
    x=. i. # ". > {. columns
end.
NB. Loop round with the values
res=. ((1 + #x),0) $ a:
for_col. columns do.
    val=. x { ". >col
    if. 0 = L. val do. val=. <"0 val end.
    res=. res,. col,val
end.
str=. ''
for_rr. }. i. # res do.
    str=. str, 'UPDATE ',tablename,' SET '
    for_col. }.columns do. NB. Drop first column which is the key
	if. 0< col_index do. str=.str, ', ' end.
	if. 1={. tableprefix E. >col do. 
	    str=. str, (#tableprefix) }. >col
	else.
	    str=. str, >col
	end.
	str=. str,'='
	val=. (<rr,1+col_index) { res
	if. 2= (3!:0) >val do.
    	    NB. Need to stringreplace single quote
	    str=. str, '''', ( (''''; '''''' ) stringreplace >val), ''''
	else.
	    str=. str, ": >val
	end.
    end.
    str=. str,' WHERE '
    if. 1={. tableprefix E. >{.columns do. 
        str=. str, (#tableprefix) }. >{.columns
    else.
        str=. str, >col{.columns
    end.
    str=. str,'='
    val=. 0 { rr { res
    if. 2= (3!:0) >val do.
	str=. str, '''', (>val), ''''
    else.
	str=. str, ": >val
    end.
    str=. str, ';', LF
end.
str=. str
)

NB. ============================================================
NB. djwSqliteInsert
NB. ============================================================
NB. Build an SQL statement based variables with names specified
NB. <y> is a list of boxed variable names which will form the
NB. columns.  The key has to be the first one listed
NB. and duplicate columns are removed with the nub function
NB. If present <x> is the index of rows
djwSqliteInsert=: 3 : 0
(i. 0) djwSqliteInsert y
:
if. 0=L. y do. y=. <y end.
y=. , y
x=. ,x
tablename=. >0 { y
tableprefix=. > 1 { y
y=. 2 }. y
columns=. 0$a:
for_col. y do.
    res=. (4!:1) 0
    ix=.(#>col) {. each res
    ix=. I. ix = col
    res=. ix { res
    columns=. columns, res /: res
end.
columns=. ~. columns
NB. Check the value of x based ont he first
if. 0=#x do.
    x=. i. # ". > {. columns
end.
NB. Loop round with the values
res=. ((1 + #x),0) $ a:
for_col. columns do.
    val=. x { ". >col
    if. 0 = L. val do. val=. <"0 val end.
    res=. res,. col,val
end.
str=. ''
for_rr. }. i. # res do.
    str=. str, 'INSERT into ',tablename,' ('
    for_col. columns do.
	if. 0< col_index do. str=.str, ', ' end.
	if. 1={. tableprefix E. >col do. 
	    str=. str, (#tableprefix) }. >col
	else.
	    str=. str, >col
	end.
    end.
    str=. str, ') VALUES ('
    for_val. rr { res do.
	if. val_index>0 do. str=. str, ', ' end.
	if. 2= (3!:0) >val do.
	    str=. str, '''', (>val), ''''
	else.
	    str=. str, ": >val
	end.
    end.
    str=. str,');', LF
end.
str=. str
)

NB. =========================================================
NB. djwCGIPost
NB. =========================================================
NB. Take matrix of names and values and assign to variables
NB. y is a boxed array
NB. The first element is the names and values
NB. and any subsequent columns are names to be converted to 
NB. values (vector length one)
NB. Otherwise each name is boxed vector length one
djwCGIPost=: 3 : 0
NB. Correct y if it just a two-column box and there are a
if. 1=L. y do. y=. ,<y end.
names=. ,0{"1 >0{y
vals=. ,1{"1 >0{y
vals=. ,each vals
y=. }. y
columns=. i. 0
for_col. y do.
    ix=.(#>col) {. each names
    ix=. I. ix = col
    columns=. columns, ix
end.
columns=. ~. columns
NB. Correct the chosen items to numbers
res=.  (<0) ".each columns { vals
res=. }. each (<2) {.each (<0),each res
NB. reset to scalar
res=. (<'') $each res
vals=. (res)  (columns)}vals 
NB. and box the others
columns=. (i. # vals) -. columns
res=. <each columns { vals
NB. res=. ,each res this was killing the assigments
vals=. (res) (columns)}vals
NB. finally do the assignment
(names)=: vals
)

NB. =============================================================
NB. utKeyPut
NB. =============================================================
NB. Put variables to the keyfile <y>
NB. x holds a subset of the keys, but if it is not present
NB. then update all the items in the dictionary

NB. Assumes the dictionary starts with the key as the first entry
NB. Usage:  subset utKeyPut filename
NB. =============================================================
utKeyPut=: 3 : 0
key=. >keyread y ; '_dictionary'
key=. >0{ key
if. -. 0 -: 4!:0 <key do.
	stderr 'No key data : ',key,' to write to ',y
	return.
end.
(". key) utKeyPut y NB. Write them all
: 
res=. ((#x),0)$a:
for_col. (>keyread y ; '_dictionary') do.
	val=. ". >col
	NB. If not boxed, box now
	if. 0=L. val do. val=. <val end.
	res=. res,. val
end. 
NB. returns the matrix of values
)
