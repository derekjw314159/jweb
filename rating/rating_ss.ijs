NB. J Utilities for displaying sheet data
NB. 

NB. =========================================================
NB. rating_ss
NB. =========================================================
NB. View scores for participant
jweb_rating_ss_e=: 3 : 0
NB. Retrieve the details

NB. y has two elements only

'filename tee gender'=. y
gender=. ''$0 ". gender
tee=. ''$tee
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	CheckXLFile glFilepath,'_ss'
	utKeyRead glFilepath,'_ss'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
stdout LF,'<style>'
stdout LF,'td { text-align: center ; }'
stdout LF,'th { text-align: center ; }'
stdout LF,'</style>'
stdout LF,'</head><body>'
stdout LF,'<div class="container">'

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

stdout LF,'<h2>SS Reckoner : ', glCourseName,' : ',(;(glTees i. tee){glTeesName),' : ',(>gender{' ' cut 'Men Women'),'</h2>'
tab=. ;4$<'&nbsp;'
NB. file exists if we have got this far
NB. Work out the unique values and loop round by hole, tee and gender
utKeyRead glFilepath,'_ss'
ww=. I. tee=glSSTee
ww=. ww /: ww{glSSHole
(ww{glSSID) utKeyRead glFilepath,'_ss'
NB. Values
stdout LF,'<h3>Rating Values</h3>'
stdout LF,'<table>',LT2,'<thead><tr>'
stdout LT3,'<th style="text-align: left;">Distances</th>'
for_hole. i. 18 do.
    stdout LT3,'<th>',(":1+hole),'</th>'
end.
stdout LT3,'<th>Front9</th><th>Back9</th><th>Total</th>'
stdout LT2,'</tr></thead><tbody>'
NB. Yards
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Yards</td>'
for_hole. i. 18 do.
    stdout LT3,'<td>',(":(glSSHole i. hole){glSSYards),'</td>'
end.
stdout LT3,'<td>',(": +/ (glSSHole e. i. 9) # glSSYards),'</td>'
stdout LT3,'<td>',(": +/ (glSSHole e. 9 + i. 9) # glSSYards),'</td>'
stdout LT3,'<td>',(": +/ glSSYards),'</td>'
stdout LT2,'</tr>'
NB. Par
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Par</td>'
for_hole. i. 18 do.
    stdout LT3,'<td>',(":(glSSHole i. hole){glSSPar),'</td>'
end.
stdout LT3,'<td>',(": +/ (glSSHole e. i. 9) # glSSPar),'</td>'
stdout LT3,'<td>',(": +/ (glSSHole e. 9 + i. 9) # glSSPar),'</td>'
stdout LT3,'<td>',(": +/ glSSPar),'</td>'
stdout LT2,'</tr>'
NB. Roll
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Roll</td>'
for_hole. i. 18 do.
    ww=. ;'b<>0.0' 8!:0 (<(glSSHole i. hole),0){glSSRoll
    ww=. ww,' / ',;'b<>0.0' 8!:0 (<(glSSHole i. hole),1){glSSRoll
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. i. 9) ; 0){glSSRoll
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. i. 9) ; 1){glSSRoll
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. 9 + i. 9) ; 0){glSSRoll
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. 9 + i. 9) ; 1){glSSRoll
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/0{"1 glSSRoll
ww=. ww,' / ',;'0.0' 8!:0 +/1{"1 glSSRoll
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Elevation
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Elevation</td>'
for_hole. i. 18 do.
    stdout LT3,'<td>',(;'b<>0.0' 8!:0(glSSHole i. hole){glSSElevation),'</td>'
end.
stdout LT3,'<td>',(": +/ (glSSHole e. i. 9) # glSSElevation),'</td>'
stdout LT3,'<td>',(": +/ (glSSHole e. 9 + i. 9) # glSSElevation),'</td>'
stdout LT3,'<td>',(": +/ glSSElevation),'</td>'
stdout LT2,'</tr>'
NB. Dogleg
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Layup</td>'
for_hole. i. 18 do.
    ww=. ;'b<>0.0' 8!:0 (<(glSSHole i. hole),0){glSSDogleg
    ww=. ww,' / ',;'b<>0.0' 8!:0 (<(glSSHole i. hole),1){glSSDogleg
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. i. 9) ; 0){glSSDogleg
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. i. 9) ; 1){glSSDogleg
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. 9 + i. 9) ; 0){glSSDogleg
ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. 9 + i. 9) ; 1){glSSDogleg
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.0' 8!:0 +/0{"1 glSSDogleg
ww=. ww,' / ',;'0.0' 8!:0 +/1{"1 glSSDogleg
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Wind
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Wind</td>'
for_hole. i. 18 do.
    stdout LT3,'<td>',(":(glSSHole i. hole){glSSWind),'</td>'
end.
stdout LT3,'<td></td><td></td><td></td>'
stdout LT2,'</tr></tbody><thead>'
NB. Obstacle value ----------------
stdout LT2,'<tr>'
stdout LT3,'<th style="text-align: left;">Obstacles</th>'
for_hole. i. 18 do.
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
    for_hole. i. 18 do.
	ww=. ;'b<>0.0' 8!:0 (<(glSSHole i. hole),ob,0){glSSObstacle
	ww=. ww,' / ',;'b<>0.0' 8!:0 (<(glSSHole i. hole),ob,1){glSSObstacle
	stdout LT3,'<td>',ww,'</td>'
    end.
    ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. i. 9) ; ob ; 0){glSSObstacle
    ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. i. 9) ; ob ; 1){glSSObstacle
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.0' 8!:0 +/(<(I. glSSHole e. 9 + i. 9) ; ob ; 0){glSSObstacle
    ww=. ww,' / ',;'0.0' 8!:0 +/(<(I. glSSHole e. 9 + i. 9) ; ob ; 1){glSSObstacle
    stdout LT3,'<td>',ww,'</td>'
    ww=. ;'0.0' 8!:0 +/ ob {"1 (0{"1 glSSObstacle)
    ww=. ww,' / ',;'0.0' 8!:0 +/ ob{"1 (1{"1 glSSObstacle)
    stdout LT3,'<td>',ww,'</td>'
    stdout LT2,'</tr>'
end.
stdout LT2,'</tr></thead><tbody>'
stdout LF,'</tbody></table>'

NB. SS by ability
ab=. 0
stdout LF,'<h3>',(>ab{' ' cut 'Scratch Bogey'),'</h3>'
stdout LF,'<table>',LT2,'<thead><tr>'
stdout LT3,'<th style="text-align: left;">Distances</th>'
for_hole. i. 18 do.
    stdout LT3,'<th>',(":1+hole),'</th>'
end.
stdout LT3,'<th>Front9</th><th>Back9</th><th>Total</th>'
stdout LT2,'</tr></thead><tbody>'
NB. Yards
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Yards</td>'

for_hole. i. 18 do.
    stdout LT3,'<td>',(5j3 ": ab ss_calc_yards (glSSHole i. hole){glSSYards),'</td>'
end.
stdout LT3,'<td>',(6j3 ": ab ss_calc_yards (glSSHole e. i. 9) # glSSYards),'</td>'
stdout LT3,'<td>',(6j3 ": ab ss_calc_yards (glSSHole e. 9 + i. 9) # glSSYards),'</td>'
stdout LT3,'<td>',(6j3 ": ab ss_calc_yards glSSYards),'</td>'
stdout LT2,'</tr>'
NB. Roll
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Roll</td>'
for_hole. i. 18 do.
    ww=. ;'b<>0.3' 8!:0 (3.5%ab{220 160)*(<(glSSHole i. hole),ab){glSSRoll
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.3' 8!:0 (3.5%ab{220 160)*+/(<(I. glSSHole e. i. 9) ; ab){glSSRoll
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.3' 8!:0 (3.5%ab{220 160)*+/(<(I. glSSHole e. 9 + i. 9) ; ab){glSSRoll
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.3' 8!:0 (3.5%ab{220 160)*+/ab{"1 glSSRoll
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Elevation
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Elevation</td>'
for_hole. i. 18 do.
    ww=. ;'b<>0.3' 8!:0 (0.23%ab{220 160)*(glSSHole i. hole){glSSElevation
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.3' 8!:0 (0.23%ab{220 160)*+/(I. glSSHole e. i. 9){glSSElevation
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.3' 8!:0 (0.23%ab{220 160)*+/(I. glSSHole e. 9 + i. 9){glSSElevation
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.3' 8!:0 (0.23%ab{220 160)*+/glSSElevation
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Dogleg
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Layup</td>'
for_hole. i. 18 do.
    ww=. ;'b<>0.3' 8!:0 (%ab{220 160)*(<(glSSHole i. hole),ab){glSSDogleg
    stdout LT3,'<td>',ww,'</td>'
end.
ww=. ;'0.3' 8!:0 (%ab{220 160)*+/(<(I. glSSHole e. i. 9) ; ab){glSSDogleg
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.3' 8!:0 (%ab{220 160)*+/(<(I. glSSHole e. 9 + i. 9) ; ab){glSSDogleg
stdout LT3,'<td>',ww,'</td>'
ww=. ;'0.3' 8!:0 (%ab{220 160)*+/ab{"1 glSSDogleg
stdout LT3,'<td>',ww,'</td>'
stdout LT2,'</tr>'
NB. Wind
stdout ,LT2,'<tr>'
stdout LT3,'<td style="text-align: left;">Wind</td>'
for_hole. i. 18 do.
    stdout LT3,'<td>',(5j3 ": ab ss_calc_wind (glSSHole i. hole){glSSWind),'</td>'
end.
stdout LT3,'<td>',(6j3 ": ab ss_calc_wind (glSSHole e. i. 9) # glSSWind),'</td>'
stdout LT3,'<td>',(6j3 ": ab ss_calc_wind (glSSHole e. 9 + i. 9) # glSSWind),'</td>'
stdout LT3,'<td>',(6j3 ": ab ss_calc_wind glSSWind),'</td>'
stdout LT2,'</tr>'
mat=. ;ab ss_calc_yards each (glSSHole i. i. 18){glSSYards
mat=. mat,: (3.5%ab{220 160) * (<(glSSHole i. i. 18) ; ab){glSSRoll
mat=. mat, (0.23%ab{220 160) * (glSSHole i. i. 18) {glSSElevation
mat=. mat, (%ab{220 160) * (<(glSSHole i. i. 18) ; ab){glSSDogleg
mat=. mat, ;ab ss_calc_wind each (glSSHole i. i. 18){glSSWind
NB. Total
stdout ,LT2,'<tr>'
stdout LT3,'<b><td style="text-align: left;">Total</td>'
for_hole. i. 18 do.
    stdout LT3,'<td><b>',(5j3 ": hole{ +/mat),'</b></td>'
end.
stdout LT3,'<td>',(4j1 ": 1 round +/9{.+/mat) ,'</td>'
stdout LT3,'<td>',(4j1 ": 1 round +/9{.9}.+/mat) ,'</td>'
stdout LT3,'<td>',(4j1 ": +/1 round +/"1 (2 9)$,+/mat) ,'</td>'
stdout LT2,'</b></tr>'



stdout LT1,'</tbody></table>'

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
res=. (+/wind { 180 144 120 96 72 54) % 18 * ab{220 160 
)

round=: 4 : 0
res=.(<. 0.5 + (10^x) * y) % 10^x
)
