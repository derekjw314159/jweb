NB. slope_util.ijs

NB. =====================================================
NB. slope_calc
NB. -----------------------------------------------------
NB. Calculate the number of tees required for a list of
NB. yardages
NB. Usage: gap slope_calc tees
NB. -----------------------------------------------------
slope_calc=: 3 : 0
25 slope_calc y
:
y=. y /: y
NB. List all the options
list=. |. #: i. 2 ^ (#y)
found=. 0
gap=. _
for_ii. i. #y do.
	list2=. (ii= +/"1 list) # list
	for_ll. list2 do.
		diff=. ll # y
		diff=. <./ (|(diff -/ y))
		diff=. >./diff
		if. diff <: x do. NB. found an answer
			found=. 1
			if. diff < gap do.
				gap=. diff
				ans=. ll # y
			end.
		end.
	end.
	if. found do. break. end.
end.
ans=. ans
)


