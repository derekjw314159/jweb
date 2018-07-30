NB. serialize.ijs
NB. Take a J array and output in PHP serialize format

NB. ========================================================
NB. serialize
NB. ========================================================
serialize=: 3 : 0
res=. ''
if. 0< L. y do.
	res=. res, 'a:',(":$y),':{'
	for_sub. y do.
		res=. res,'i:',(":sub_index),';',(serialize >sub)
	end.
	res=. res, '}'
	return.
end.

NB. If got this far it is not boxed
if. 0=#y do.
	NB. Null
	res=. 'N;'
	return.
elseif.  2 = 3!:0 y do.
	NB. Literal / string
	res=. 's:',(":#y),':"',y,'";' NB. Doesn't matter if scalar or vector
	return.
end.

NB. If got this far it is a number

NB. If it is 2-dim or greater, another recursion
if. 1<$$ y do.
	res=. 'a:',(":0{$y),':{'
	for_sub. i. 0{$y do.
		res=. res,'i:',(":sub),';',serialize sub{y
	end.
	res=. res,'}'
	return.
end.

NB. If it is a vector, have to treat like an array
if. 1=$$ y do.
	res=. 'a:',(":$y),':{'
	for_sub. y do.
		res=. res, 'i:',(":sub_index),';',serialize sub
	end.
	res=. res, '}'
	return.
end.

NB. If we are this far, it is a scalar number
if. (y e. 0 1) do.
	NB. Boolean
	res=. 'b:',(":y),';'
	return.
elseif. (0j0 ~: y - (+y)) do.
	NB. Complex, tested using conjugate
	NB. Have to test for this before the integer test
	y=. +. y
	NB. Treat as array
	res=. serialize y
	return.
elseif. (y = <. 0.5 + y) do.
	NB. Integer
	res=. 'i:',(;'' 8!:0 y),';'
	return.
elseif. 1=1 do.
	NB. Decimal
	res=. 'd:',(;'' 8!:0 y),';'
	return.
end.
)

NB. If a filename is passed, output the array of names and values
fileoutput=: 3 : 0
if. 2>: $ARGV do.
	return.
end.
require './djwUtilFile.ijs'
if. 'get' -: >2{ARGV do.
	NB. Normal get/put file
	filename=. >3{ARGV
	names=. >jread filename ; 0
	utFileGet filename
	mat=. 0 2$<''
	for_i. names do.
		ww=. i, <serialize ".>i NB. name, value pair
		mat=. mat, ww
	end.

	NB.res=. serialize names
end.
)

xx=: fileoutput ''

