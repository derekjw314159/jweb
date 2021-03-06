NB. J Utilities for displaying sheet data
NB. 

NB. =========================================================
NB. rating_ss
NB. =========================================================
NB. View scores for participant
jweb_rating_ss_e=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename gender tee'=. y
gender=. ''$0 ". gender
tee=. ''$tee
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	CheckSSFile glFilepath,'_ss'
	utKeyRead glFilepath,'_ss'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<!DOCTYPE html>',LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
NB. Extra styles
stdout LF,'<style>'
stdout LF,'td {'
stdout LT1,'text-align: center ;'
stdout LT1,'color: inherit;'
stdout LF,'}'
stdout LF,'th { text-align: center ; }'
stdout LF,'td.total {'
stdout LT1,'font-weight: bold;'
stdout LF,'}'
stdout LF,'td.grandtotal {'
stdout LT1,'font-weight: bold;'
stdout LT1,'border: 1px solid red;'
stdout LT1,'color: red;'
stdout LF,'}'
stdout LF,'td .subtotal {'
stdout LT1,'font-style: italic;'
stdout LT1,'font-weight: normal;'
stdout LT1,'color: darkgray;'
stdout LF,'}'
stdout LF,'</style>'
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
end.

stdout LF,'<h2>SS Reckoner : ', glCourseName,' : ',(;(glTees i. tee){glTeesName),' : ',(>gender{' ' cut 'Men Women'),'</h2>'
tab=. ;4$<'&nbsp;'
NB. file exists if we have got this far
NB. Work out the unique values and loop round by hole, tee and gender
utKeyRead glFilepath,'_ss'
ww=. I. tee=glSSTee
ww=. (gender=ww{glSSGender)#ww
ww=. ww /: ww{glSSHole
(ww{glSSID) utKeyRead glFilepath,'_ss'

NB. Error page - No such course
holes=. Holes ''
f9=. 9{. holes
b9=. 9}. holes
ww=.  (-. holes e. glSSHole ) # 1+holes
if. 0<#ww do.
    djwErrorPage err ; ('Missing analysis for holes : ',glFilename,' Holes : ', ":ww) ; ('/jw/rating/plan/v/',glFilename) ; 'Back to rating plan'
	exit 2
end.

NB. Values
stdout LF,'<h3>Rating Values</h3>'
stdout LF,'<table>',LT2,'<thead><tr>'
stdout LT3,'<th style="text-align: left; width: 7%;">Dist Factors</th>'
for_hole. holes do.
    stdout LT3,'<th>',(":1+hole),'</th>'
end.
stdout LT3,'<th>Front9</th><th>Back9</th><th>Total</th>'
stdout LT2,'</tr></thead><tbody>'
NB. Yards
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Yards</td>'
for_hole. holes do.
    stdout LT3,'<td>',(":(glSSHole i. hole){glSSYards),'</td>'
end.
stdout LT3,'<td>',(": +/ (glSSHole e. f9) # glSSYards),'</td>'
stdout LT3,'<td>',(": +/ (glSSHole e. b9) # glSSYards),'</td>'
stdout LT3,'<td>',(": +/ glSSYards),'</td>'
stdout LT2,'</tr>'
NB. Par
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Par</td>'
for_hole. holes do.
    stdout LT3,'<td>',(":(glSSHole i. hole){glSSPar),'</td>'
end.
stdout LT3,'<td>',(": +/ (glSSHole e. f9) # glSSPar),'</td>'
stdout LT3,'<td>',(": +/ (glSSHole e. b9) # glSSPar),'</td>'
stdout LT3,'<td>',(": +/ glSSPar),'</td>'
stdout LT2,'</tr>'
NB. Roll
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Roll</td>'
for_hole. holes do.
    ww=. ;'b<>0.0' 8!:0 (<(glSSHole i. hole),0){glSSRoll
    ww=. ww,' / ',;'b<>0.0' 8!:0 (<(glSSHole i. hole),1){glSSRoll
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. f9) ; 0){glSSRoll
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. f9) ; 1){glSSRoll
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. b9) ; 0){glSSRoll
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. b9) ; 1){glSSRoll
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/0{"1 glSSRoll
ww=. ww,' / ',;'0.0' 8!:0 +/1{"1 glSSRoll
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Elevation
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Elevation</td>'
for_hole. holes do.
    stdout LT3,'<td>',(;'b<>0.0' 8!:0(glSSHole i. hole){glSSElevation),'</td>'
end.
stdout LT3,'<td>',(;'b<>0.0' 8!:0 +/ (glSSHole e. f9) # glSSElevation),'</td>'
stdout LT3,'<td>',(;'b<>0.0' 8!:0 +/ (glSSHole e. b9) # glSSElevation),'</td>'
stdout LT3,'<td>',(;'b<>0.0' 8!:0 +/ glSSElevation),'</td>'
stdout LT2,'</tr>'
NB. Dogleg
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Layup</td>'
for_hole. holes do.
    ww=. ;'b<>0.0' 8!:0 (<(glSSHole i. hole),0){glSSDogleg
    ww=. ww,' / ',;'b<>0.0' 8!:0 (<(glSSHole i. hole),1){glSSDogleg
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. f9) ; 0){glSSDogleg
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. f9) ; 1){glSSDogleg
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. b9) ; 0){glSSDogleg
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. b9) ; 1){glSSDogleg
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/0{"1 glSSDogleg
ww=. ww,' / ',;'0.0' 8!:0 +/1{"1 glSSDogleg
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Wind
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Wind</td>'
for_hole. holes do.
    stdout LT3,'<td>',(":(glSSHole i. hole){glSSWind),'</td>'
end.
stdout LT3,'<td>',(;'b<>0.0' 8!:0 +/ (glSSHole e. f9) # glSSWind),'</td>'
stdout LT3,'<td>',(;'b<>0.0' 8!:0 +/ (glSSHole e. b9) # glSSWind),'</td>'
stdout LT3,'<td>',(;'b<>0.0' 8!:0 +/ glSSWind),'</td>'
stdout LT2,'</tr></tbody><thead>'
NB. Obstacle value ----------------
stdout LT2,'<tr>'
stdout LT3,'<th style="text-align: left;">Obstacles</th>'
for_hole. holes do.
    stdout LT3,'<th>',(":1+hole),'</th>'
end.
stdout LT3,'<th>Front9</th><th>Back9</th><th>Total</th>'
stdout LT2,'</tr></thead><tbody>'
ob=. 0
for_ob. i. 10 do.
NB. Obstacle <ob>
    stdout ,LT2,'<tr>'
    ww=. ' ' cut 'Topog F/way Gr/Targ R&R Bunk OOB/ER Water Trees Gr/Surf Pysch'
    stdout LT3,'<td style="text-align: left;">',(>ob{ww),'</td>'
    for_hole. holes do.
		ww=. ;'b<>0.0' 8!:0 (<(glSSHole i. hole),ob,0){glSSObstacle
		ww=. ww,' / ',;'b<>0.0' 8!:0 (<(glSSHole i. hole),ob,1){glSSObstacle
		stdout LT3,'<td>',ww,'</td>'
    end.
    ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. f9) ; ob ; 0){glSSObstacle
    ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. f9) ; ob ; 1){glSSObstacle
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. b9) ; ob ; 0){glSSObstacle
    ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. b9) ; ob ; 1){glSSObstacle
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.0' 8!:0 +/ ob {"1 (0{"1 glSSObstacle)
    ww=. ww,' / ',;'0.0' 8!:0 +/ ob{"1 (1{"1 glSSObstacle)
    stdout LT3,'<td>',ww,'</td>'
    stdout LT2,'</tr>'
end.
stdout LT2,'</tr></thead><tbody>'
stdout LF,'</tbody></table>'

total3=. 2 2$0

NB. SS by ability
for_ab. 0 1 do.
    stdout LF,'<h3>',(>ab{' ' cut 'Scratch Bogey'),'</h3>'
    stdout LF,'<table>',LT2,'<thead><tr>'
    stdout LT3,'<th style="text-align: left;">Distances</th>'
    for_hole. holes do.
		stdout LT3,'<th>',(":1+hole),'</th>'
    end.
    stdout LT3,'<th>Front9</th><th>Back9</th><th>Total</th>'
    stdout LT2,'</tr></thead><tbody>'
    NB. Yards
    stdout ,LT2,'<tr>'
    stdout LT3,'<td style="text-align: left;">Yards</td>'

    for_hole. holes do.
		stdout LT3,'<td>',(5j3 ": ab ss_calc_yards (glSSHole i. hole){glSSYards),'</td>'
    end.
    stdout LT3,'<td>',(6j3 ": ab ss_calc_yards (glSSHole e. f9) # glSSYards),'</td>'
    stdout LT3,'<td>',(6j3 ": ab ss_calc_yards (glSSHole e. b9) # glSSYards),'</td>'
    stdout LT3,'<td>',(6j3 ": ab ss_calc_yards glSSYards),'</td>'
    stdout LT2,'</tr>'
    NB. Roll
    stdout ,LT2,'<tr>'
    stdout LT3,'<td style="text-align: left;">Roll</td>'
    for_hole. holes do.
		ww=. ;'b<>0.3' 8!:0 (3.5%ab{220 160)*(<(glSSHole i. hole),ab){glSSRoll
		stdout LT3,'<td>',ww,'</td>'
    end.
    ww=. ;'0.3' 8!:0 (3.5%ab{220 160)*+/(<(I. glSSHole e. f9) ; ab){glSSRoll
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.3' 8!:0 (3.5%ab{220 160)*+/(<(I. glSSHole e. b9) ; ab){glSSRoll
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.3' 8!:0 (3.5%ab{220 160)*+/ab{"1 glSSRoll
    stdout LT3,'<td>',ww,'</td>'
    stdout LT2,'</tr>'
    NB. Elevation
    stdout ,LT2,'<tr>'
    stdout LT3,'<td style="text-align: left;">Elevation</td>'
    for_hole. holes do.
		ww=. ;'b<>0.3' 8!:0 (0.23%ab{220 160)*(glSSHole i. hole){glSSElevation
		stdout LT3,'<td>',ww,'</td>'
    end.
    ww=. ;'0.3' 8!:0 (0.23%ab{220 160)*+/(I. glSSHole e. f9){glSSElevation
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.3' 8!:0 (0.23%ab{220 160)*+/(I. glSSHole e. b9){glSSElevation
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.3' 8!:0 (0.23%ab{220 160)*+/glSSElevation
    stdout LT3,'<td>',ww,'</td>'
    stdout LT2,'</tr>'
    NB. Dogleg
    stdout ,LT2,'<tr>'
    stdout LT3,'<td style="text-align: left;">Layup</td>'
    for_hole. holes do.
		ww=. ;'b<>0.3' 8!:0 (%ab{220 160)*(<(glSSHole i. hole),ab){glSSDogleg
		stdout LT3,'<td>',ww,'</td>'
    end.
    ww=. ;'0.3' 8!:0 (%ab{220 160)*+/(<(I. glSSHole e. f9) ; ab){glSSDogleg
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.3' 8!:0 (%ab{220 160)*+/(<(I. glSSHole e. b9) ; ab){glSSDogleg
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.3' 8!:0 (%ab{220 160)*+/ab{"1 glSSDogleg
    stdout LT3,'<td>',ww,'</td>'
    stdout LT2,'</tr>'
    NB. Wind
    stdout ,LT2,'<tr>'
    stdout LT3,'<td style="text-align: left;">Wind</td>'
    for_hole. holes do.
		stdout LT3,'<td>',(5j3 ": ab ss_calc_wind (glSSHole i. hole){glSSWind),'</td>'
    end.
    stdout LT3,'<td>',(6j3 ": ab ss_calc_wind (glSSHole e. f9) # glSSWind),'</td>'
    stdout LT3,'<td>',(6j3 ": ab ss_calc_wind (glSSHole e. b9) # glSSWind),'</td>'
    stdout LT3,'<td>',(6j3 ": ab ss_calc_wind glSSWind),'</td>'
    stdout LT2,'</tr>'
    NB. Total
    mat=. ;ab ss_calc_yards each (glSSHole i. holes){glSSYards
    mat=. mat,: (3.5%ab{220 160) * (<(glSSHole i. holes) ; ab){glSSRoll
    mat=. mat, (0.23%ab{220 160) * (glSSHole i. holes) {glSSElevation
    mat=. mat, (%ab{220 160) * (<(glSSHole i. holes) ; ab){glSSDogleg
    mat=. mat, ;ab ss_calc_wind each (glSSHole i. holes){glSSWind
    stdout ,LT2,'<tr>'
    stdout LT3,'<td class="total" style="text-align: left; width: 7%;">Dist SS</td>'
    for_hole. holes do.
		stdout LT3,'<td><b>',(5j3 ": hole{ +/mat),'</td>'
    end.
    adj=. ab{40.9 50.7
    total=. 1 round 0.5 * adj+(2 round ((-adj)+2* +/9{.+/mat))
    total=. total, 1 round 0.5 * adj+(2 round ((-adj)+2* +/9}.+/mat))
    stdout LT3,'<td class="grandtotal">',(4j1 ": 0{total) ,'<br><span class="subtotal">',(0j3 ": +/9{.+/mat),'</span></td>'
    stdout LT3,'<td class="grandtotal">',(4j1 ": 1{total) ,'<br><span class="subtotal">',(0j3 ": +/9}.+/mat),'</span></td>'
    stdout LT3,'<td class="grandtotal">',(4j1 ": +/total) ,'</td>'
    stdout LT2,'</tr></tbody><thead>'
    NB. Obstacle Factors
    stdout LT3,'<th style="text-align: left;">Obstacles</th>'
    for_hole. holes do.
		stdout LT3,'<th>',(":1+hole),'</th>'
    end.
    stdout LT3,'<th>Front9</th><th>Back9</th><th>Total</th>'
    stdout LT2,'</tr></thead><tbody>'
    NB. Obstacles one by one
    for_ob. i. 10 do.
	stdout ,LT2,'<tr>'
	ww=. ' ' cut 'Topog F/way Gr/Targ R&R Bunk OOB/ER Water Trees Gr/Surf Pysch'
	stdout LT3,'<td style="text-align: left;">',(>ob{ww),'</td>'
	    for_hole. holes do.
			ww=. ;'b<>0.3' 8!:0 (<(glSSHole i. hole);ob;ab){glSSObstacle * glSSObsFactor * (ab{0.11 0.26)
			stdout LT3,'<td>',ww,'</td>'
	    end.
	ww=. ;'b<>0.3' 8!:0 +/(<(glSSHole i. holes);ob; ab) {glSSObstacle * glSSObsFactor * ab{0.11 0.26
	stdout LT3,'<td>',ww,'</td>'
	ww=. ;'b<>0.3' 8!:0 +/(<(glSSHole i. holes);ob; ab) {glSSObstacle * glSSObsFactor * ab{0.11 0.26
	stdout LT3,'<td>',ww,'</td>'
	ww=. ;'b<>0.3' 8!:0 +/(<((<'') ;ob; ab)) {glSSObstacle * glSSObsFactor * ab{0.11 0.26
	stdout LT3,'<td>',ww,'</td>'
	stdout LT2,'</tr>'
    end. NB. End of obstacle loop
    mat2=.|: (<(glSSHole i. holes) ; (<'') ; ab) { glSSObstacle * glSSObsFactor * ab{ 0.11 0.26
    mat2=. mat2, ($holes)$,(-ab{4.9 11.5)%(18)
    stdout LT2,'<tr>'
    stdout LT3,'<td style="text-align: left">Fixed</td>'
    for_hole. holes do.
		ww=. ;'b<>0.3' 8!:0 (<_1 ; hole ){mat2 
		stdout LT3,'<td>',ww,'</td>'
    end.
    ww=. ;'b<>0.3' 8!:0 +/9{._1{mat2
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'b<>0.3' 8!:0 +/9}._1{mat2
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'b<>0.3' 8!:0 +/_1{mat2
    stdout LT3,'<td>',ww,'</td>'
    stdout LT2,'</tr>'
    NB. Total obstacle
    stdout ,LT2,'<tr>'
    stdout LT3,'<td class="total" style="text-align: left; width: 7%">Obst SS</td>'
    for_hole. holes do.
		stdout LT3,'<td><b>',(;'b<>0.3' 8!:0 hole{ +/mat2),'</td>'
    end.
    total2=. 1 round +/9{.+/mat2
    total2=. total2,1 round +/9}.+/mat2
    stdout LT3,'<td class="grandtotal">',(4j1 ": 0{total2),'<br><span class="subtotal">',(0j3 ": +/9{.+/mat2),'</span></td>' 
    stdout LT3,'<td class="grandtotal">',(4j1 ": 1{total2),'<br><span class="subtotal">',(0j3 ": +/9}.+/mat2),'</span></td>'
    stdout LT3,'<td class="grandtotal">',(4j1 ": +/total2) ,'</td>'
    stdout LT2,'</tr>'
    NB. Grand total
    stdout LT2,'<tr>'
    stdout LT3,'<td class="total" style="text-align: left; width: 7%">Total ',(>ab{' ' cut 'Scr Bgy'),'</td>'
    for_hole. holes do.
		stdout LT3,'<td><b>',(;'b<>0.3' 8!:0 hole{ +/mat,mat2),'</td>'
    end.
    
    stdout LT3,'<td class="grandtotal">',(4j1 ": 0{total+total2) ,'</td>'
    stdout LT3,'<td class="grandtotal">',(4j1 ": 1{total+total2) ,'</td>'
    stdout LT3,'<td class="grandtotal" style="background-color: yellow;">',(4j1 ": +/total,total2) ,'</td>'
    stdout LT2,'</tr>'
    stdout LT1,'</tbody></table>'

    total3=. (total+total2) ab}total3
end. NB. End ability loop

stdout LF,'<table style="width: 30%;"><thead>'
stdout LT2,'<tr>'
stdout LT3,'<th style="text-align: left; width: 7%;"></th><th>Front9</th><th>Back9</th><th>Total</th>'
stdout LT2,'</tr>'
stdout LT1,'</thead>',LT1,'<tbody>',LT2,'<tr>'
stdout LT3,'<td class="total" style="text-align: left;">Slope</td>'
total3=. 0 round 2 * 5.381 * (- -/total3)
stdout LT3,'<td class="grandtotal">',(0j0 ": 0{total3 ),'</td>'
stdout LT3,'<td class="grandtotal">',(0j0 ": 1{total3 ),'</td>'
stdout LT3,'<td class="grandtotal" style="background-color: yellow;">',(0j0 ": 0 round 0.5 * +/total3 ),'</td>'
stdout LT2,'</tr>',LT1,'</tbody>',LF,'</table>'


stdout LF,'<a href="/jw/rating/plannomap/v/',(glFilename),'">Return to plan</a>'
stdout LF,'</div>' NB. end main container
stdout '</body></html>'
res=. 1
exit ''
)

ss_calc_yards=: 4 : 0
NB. Calculate yardage
yards=. y
ab=. x
yards=. , yards
res=. ((ab{40.9 50.7) + ((18%#yards) * +/yards) % ab{220 160) % 18%#yards
)

ss_calc_wind=: 4 : 0
NB. Calculate wind factor
wind=. y
wind=. , wind
ab=. x
res=. (+/wind { 180 144 120 96 72 54) % (18) * ab{220 160 
)

round=: 4 : 0
res=.(<. 0.5 + (10^x) * y) % 10^x
)
