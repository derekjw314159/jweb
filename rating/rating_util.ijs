NB. slope_util.ijs

NB. =====================================================
NB. slope_calc
NB. -----------------------------------------------------
NB. Calculate the number of tees required for a list of
NB. yardages
NB. Usage: gap slope_calc tees
NB. Return: list of best options
NB.
NB. If y is boxed, the first element is the list of given
NB. yardages, typically after the ladies tees have been
NB. determined
NB. -----------------------------------------------------
slope_calc=: 3 : 0
25 slope_calc y
:
NB. Unbox if necessary
if. 0 < (L. y) do.
    'given ww'=. y
    y=. ww -. given NB. Remove any already given
else.
    given=. 0$0
end.

y=. y /: y
NB. List all the options
list=. |. #: i. 2 ^ (#y)
found=. 0
gap=. _
for_ii. i. (1+#y) do. NB. Loop round with 1, 2, 3 elements etc.
	list2=. (ii= +/"1 list) # list NB. list with 1, 2, 3 elements etc.
	for_ll. list2 do.
		diff=. given, ll # y
		diff=. <./ (|(diff -/ y))
		diff=. >./diff
		if. diff <: x do. NB. found an answer
			found=. 1
			if. diff < gap do.
				gap=. diff
				ans=. given, ll # y
			end.
		end.
	end.
	if. found do. break. end.
end.
ans=. ans /: ans
)

