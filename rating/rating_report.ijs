NB. J Utilities for displaying sheet data
NB. 

glPDFoffset=: 8 4
glPDFmult=: (276 % 28), (183 % 48)

NB. =========================================================
NB. pdfMulti
NB. =========================================================
pdfMulti=: 3 : 0
'L' pdfMulti y
:
'offset size text border'=. y
offset=. glPDFoffset + offset * glPDFmult
size=. size * glPDFmult
NB. r=. 'MultiCell(',(":0{size),', ',(": 1{size),', ''',text,''', ',(":border),', ''J'', true, 0,',(":0{offset),', ',(":1{offset),', false, 0, true, true, ',(":0 * 1{size),',''M'',false);'
r=. 'WriteHTMLCell(',(":0{size),', ',(": 1{size),', ',(":0{offset),', ',(":1{offset),', ''',text,''', ',(":border),', 0, true, false, ''',x,''', false);'
)

NB. =========================================================
NB. pdfLine
NB. =========================================================
NB. Usage:
NB.   pdfLine offset ; size
pdfLine=: 3 : 0
'offset size'=. y
offset=. glPDFoffset + offset * glPDFmult
size=. size * glPDFmult
res=. LF,'$pdf->Line(',(":0{offset),', ',(": 1{offset),', ',(":0{offset+size),', ',(":1{offset+size),', '''');'
)

NB. =========================================================
NB. pdfBox
NB. =========================================================
NB. Usage:
NB.   pdfBox offset ; size
NB. Need to draw as four lines because the standard box function fills
NB. and we need a hollow box
pdfBox=: 3 : 0
'offset size'=. y
res=. pdfLine offset ; 0 1 * size
res=. res, pdfLine (offset + 0 1 * size) ; 1 0 * size
res=. res, pdfLine offset ; 1 0 * size
res=. res, pdfLine (offset + 1 0 * size) ; 0 1 * size
)

NB. =========================================================
NB. pdfDiag
NB. =========================================================
NB. Usage:
NB.   pdfDiag offset ; size
NB. Draws diagnoal from bottom left to top right
pdfDiag=: 3 : 0
'offset size'=. y
res=. pdfLine (offset + 0 1 * size) ; 1 _1 * size
)


NB. =========================================================
NB. pdfColor
NB. =========================================================
NB. Usage:
NB.   'fore_or_back' pdfColor color
pdfColor=: 3 : 0
'T' pdfColor y
:
NB. Keep record of old color to avoid too many lines being written
if. _1 = 4!:0 <'glOldColor' do. glOldColor=: '' ; '' end.
NB. Is same color?
if. y -: > ('TF' i. x) { glOldColor do.
    NB. No change
    res=. ''
else.
    select. y
	case. 'black' do. res=. '(0, 0, 0);'
	case. 'white' do. res=. '(255, 255, 255);'
	case. 'grey' do. res=. '(127, 127, 127);'
	case. 'lightgrey' do. res=. '(180, 180, 180);'
	case. 'blue' do. res=. '( 35,  83, 216);'
	case. 'lightyellow' do. res=. '(247, 253, 156);'
	case. 'lightblue' do. res=. '(176, 224, 230);'
    end.
    glOldColor=: (<y) ('TF' i. x) } glOldColor
    res=.LF,'$pdf->', (>('FT' i. x){' ' cut 'setFillColor setTextColor'),res
end.
)

NB. =========================================================
NB. oN
NB. =========================================================
NB. Usage:
NB.    textcolor on fillcolor
oN=: 4 : 0
res=. 'T' pdfColor x
res=. res,'F' pdfColor y
)

NB. =========================================================
NB. write_title
NB. =========================================================
NB. Write out title block, white on black
NB. Puts the text in bold
write_title=: 3 : 0
'offset size text'=. y
text=. '<b>',text,'</b>'
res=. 'white' oN 'black'
res=. res,LF,'$pdf->', pdfMulti offset ; size ; text ; 1
)

NB. =========================================================
NB. write_row_head
NB. =========================================================
NB. Write out title block, white on black
NB. Puts the text with the second element right element
NB. Need to write in several steps because the box may be overwritten
write_row_head=: 3 : 0
NB. Format for each one
('cell' ; 'cell' ; 1) write_row_head y
:
NB. Defaults
if. 0=L. x do. x=. ,<x end.
x=. ,x
if. 1=#x do. x=. x,x,<1 end.
if. 2=#x do. x=. x,<1 end.
". 'fn1=: write_',>0{x
". 'fn2=: write_',>1{x
bx=. >2{x
'offset size t1 t2'=. y
res=. ('R' ; 0) fn2 (offset + 2{. 0{size) ; (1{size) ; t2
res=. res, ('L' ; 0) fn1 offset  ; (0{size) ; t1
if. 0<bx do.
	res=. res, pdfBox  offset ; ((+/size), 1)
end.
if. 2=bx do.
	res=. res, pdfLine ((offset+0{size),0) ; 0 1
end. 
)

NB. =========================================================
NB. write_cell
NB. =========================================================
NB. Write out ordinary call, black on white
NB. Usage
NB. (justify box) write_cell offset ; size ; array
NB. If size contains negative elements, they are padded with grey cells
write_cell=: 3 : 0
('L' ; 1) write_cell y
:
NB. Unpick the array
'offset size array'=. y
if. 0=L. x do. x=. x ; 1 end.
'just boxe'=. x
if. 2 =  3!:0 array do.
    array=. <array NB. box a text string
end.
array=. ,array NB. Make a vector
NB. Pad the size to the right width
size=. (({:$size)>. {:$array)$size
res=. ''
for_sz. size do.
    NB. May be a grey call
    if. sz<0 do.
	res=. res, write_lightgrey (offset+2{. sz_index{+/ \0,|size); |sz
    else.
	res=.res, 'black' oN 'white'
	sh=. ((sz_index){_1 + (+/) \ size >: 0 ){array
	if. 1=L. sh do. sh=. >sh end.`
	if. 2 ~: 3!:0 sh do. sh=. ;'p<+>' 8!:0 sh end.
	res=. res,LF,'$pdf->', just pdfMulti (offset+2{. sz_index{+/ \0,|size); (sz,1) ; sh ; boxe
    end.
end.
)

NB. =========================================================
NB. write_input
NB. =========================================================
NB. Usage
NB.    (justify box) write_cell offset ; size ; array
NB. Write out input cell, black on lightyellow if it is a value
NB. or blank if not
NB. If size contains negative elements, they are padded with grey cells
write_input=: 3 : 0
('C' ; 1) write_input y
:
NB. Unpick the array
'offset size array'=. y
if. 0=L. x do. x=. x ; 1 end.
'just boxe'=. x
if. 2 =  3!:0 array do.
    array=. <array NB. box a text string
end.
array=. ,array NB. Make a vector
NB. Pad the size to the right width
size=. (({:$size)>. {:$array)$size
res=. ''
for_sz. size do.
    NB. May be a grey call
    if. sz<0 do.
	res=. res, write_lightgrey (offset+2{. sz_index{+/ \0,|size); |sz
    else.
	sh=. ((sz_index){_1 + (+/) \ size >: 0 ){array
	if. 1=L. sh do. sh=. >sh end.`
	if. 2 ~: 3!:0 sh do. sh=. ;'bp<+>' 8!:0 sh end.
	if. 0=#sh do.
	    res=. res, 'black' oN 'white'
	else.
	    res=. res, 'black' oN 'lightyellow'
	end.
	res=. res,LF,'$pdf->', just pdfMulti (offset+2{. sz_index{+/ \0,|size); (sz,1) ; sh ; boxe
    end.
end.
)

NB. =========================================================
NB. write_calc
NB. =========================================================
NB. Write out calculated call, blue on lightblue
NB. Usage
NB. (justify box) write_calc offset ; size ; array
NB. If size contains negative elements, they are padded with grey cells
write_calc=: 3 : 0
('C' ; 1) write_calc y
:
NB. Unpick the array
'offset size array'=. y
if. 0=L. x do. x=. x ; 1 end.
'just boxe'=. x
if. 2 =  3!:0 array do.
    array=. <array NB. box a text string
end.
array=. ,array NB. Make a vector
NB. Pad the size to the right width
size=. (({:$size)>. {:$array)$size
res=. ''
for_sz. size do.
    NB. May be a grey call
    if. sz<0 do.
	res=. res, write_lightgrey (offset+2{. sz_index{+/ \0,|size); |sz
    else.
	res=.res, 'blue' oN 'lightblue'
	sh=. ((sz_index){_1 + (+/) \ size >: 0 ){array
	if. 1=L. sh do. sh=. >sh end.`
	if. 2 ~: 3!:0 sh do. sh=. ;'p<+>' 8!:0 sh end.
	res=. res,LF,'$pdf->', just pdfMulti (offset+2{. sz_index{+/ \0,|size); (sz,1) ; sh ; boxe
    end.
end.
)

NB. =========================================================
NB. write_footer
NB. =========================================================
NB. Write out calculated call, blue on lightblue
NB. Usage
NB. (justify box) write_calc offset ; size ; array
NB. If size contains negative elements, they are padded with grey cells
write_footer=: 3 : 0
('L' ; 1) write_footer y
:
NB. Unpick the array
'offset size array'=. y
if. 0=L. x do. x=. x ; 1 end.
'just boxe'=. x
if. 2 =  3!:0 array do.
    array=. <array NB. box a text string
end.
array=. ,array NB. Make a vector
NB. Pad the size to the right width
size=. (({:$size)>. {:$array)$size
res=. ''
for_sz. size do.
    NB. May be a grey call
    if. sz<0 do.
	res=. res, write_lightgrey (offset+2{. sz_index{+/ \0,|size); |sz
    else.
	res=.res, 'white' oN 'blue'
	sh=. ((sz_index){_1 + (+/) \ size >: 0 ){array
	if. 1=L. sh do. sh=. >sh end.`
	if. 2 ~: 3!:0 sh do. sh=. ;'p<+>' 8!:0 sh end.
	sh=. '<b>',sh,'</b>'
	res=. res,LF,'$pdf->', just pdfMulti (offset+2{. sz_index{+/ \0,|size); (sz,1) ; sh ; boxe
    end.
end.
)

NB. =========================================================
NB. write_lightgrey
NB. =========================================================
NB. Write out a lightgrey cell, boxed
NB. Usage:
NB. write_lightgray offset ; grid
NB. <grid> should be a rank two array of the width of the cells to be written
write_lightgrey=: 3 : 0
NB. Unpick the array
'offset size'=. y
NB. Make a rank two array of sizes
size=. (_2{. $ ,: ,: size)$ ;size
res=. 'white' oN 'lightgrey'
for_rr. size do.
    for_sh. rr do.
	res=. res,LF,'$pdf->',pdfMulti (offset+(sh_index{+/ \0,rr),rr_index) ; ((sh_index{rr),1) ; '' ; 1
    end.
end.
)


NB. =========================================================
NB. rating_report
NB. =========================================================
NB. View scores for participant
jweb_rating_report=: 3 : 0
'filename hole gender tee'=. y
hole=. ''$ ".hole
tee=. ''$ tee
gender=. ''$ ". gender
glFilename=: dltb filename
glFilepath=: glDocument_Root,'/yii/',glBasename,'/protected/data/',glFilename
shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole)),(gender{'MW'),tee
fname=. glDocument_Root,'/tcpdf/',glBasename,'/',shortname,'.php'

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	utKeyRead glFilepath,'_green'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
ww=. glPlanRecType e. 'P'
ww=. ww *. glPlanHole=hole
ww=. ww *. glPlanTee=tee
ww=. I. ww *. glPlanGender=gender

if.  (0=#ww) do.
    djwErrorPage err ; ('No such sheet : ',}. ; (<'/'),each y) ; ('/jw/rating/plannomap/v/',glFilename) ; 'Back to rating plan'
end.

NB. Need to work out which tees this is serving
t=. I. glTeHole=hole
t=. glTeTee= tee
t=. t *. glTeHole=hole
(t#glTeID) utKeyRead glFilepath,'_tee'
t_index=. glTees i. tee

NB. Read the Green
((hole=glGrHole)#glGrID) utKeyRead glFilepath,'_green'

NB. Order by ability, shot and re-read the plan
ww=. ww /: ww{glPlanShot
ww=. ww /: ww{glPlanAbility
(ww{glPlanID) utKeyRead glFilepath,'_plan'

fname fwrite~ '<?php'
fname fappend~ LF,'require_once(''tcpdf_include.php'');'
fname fappend~ LF,'$pdf = new TCPDF(PDF_PAGE_ORIENTATION, PDF_UNIT, PDF_PAGE_FORMAT, true, ''UTF-8'', false);'
fname fappend~ LF,'$pdf->SetCreator(PDF_CREATOR);'
fname fappend~ LF,'$pdf->SetAuthor(''BB&O'');'
fname fappend~ LF,'$pdf->SetTitle(''',shortname,''');'
fname fappend~ LF,'$pdf->SetSubject(''Course Rating'');'
fname fappend~ LF,'$pdf->SetKeywords(''Rating, ',glFilename,''');'
fname fappend~ LF,'$pdf->setPrintHeader(false);'
fname fappend~ LF,'$pdf->setPrintFooter(false);'
fname fappend~ LF,'$pdf->SetDefaultMonospacedFont(PDF_FONT_MONOSPACED);'
fname fappend~ LF,'$pdf->SetMargins(PDF_MARGIN_LEFT, PDF_MARGIN_TOP, PDF_MARGIN_RIGHT);'
fname fappend~ LF,'$pdf->SetAutoPageBreak(TRUE, PDF_MARGIN_BOTTOM);'
fname fappend~ LF,'$pdf->setImageScale(PDF_IMAGE_SCALE_RATIO);'
fname fappend~ LF,'if (@file_exists(dirname(__FILE__).''/lang/eng.php'')) {'
fname fappend~ LF,'	  require_once(dirname(__FILE__).''/lang/eng.php'');'
fname fappend~ LF,'   $pdf->setLanguageArray($l);'
fname fappend~ LF,'   }'
fname fappend~ LF,'$pdf->SetFont(''helvetica'', '''',  8);'
fname fappend~ LF,'// -------- New Page -------------'
fname fappend~ LF,'$pdf->AddPage(''L'');'

NB. Build the data
hityards=. 'glPlanHitYards' matrix_pull hole ; tee ; gender
transition=. 'glPlanLayupType' matrix_pull hole ; tee ; gender
transition=.  +. /"1'T' = >transition
targvisible=. ((<glTargVisibleVal) i. each 'glPlanFWTargVisible' matrix_pull hole ; tee ; gender) { each <glTargVisibleNum
visible=. 'glPlanFWVisible' matrix_pull hole ; tee ; gender
targvisible=. 0, each }: each targvisible NB. Push to the shot after
targvisible=. visible >. each targvisible
rolllevel=. 'glPlanRollLevel' matrix_pull hole ; tee ; gender
rollslope=. 'glPlanRollSlope' matrix_pull hole ; tee ; gender

NB. Title row
fname fappend~ LF,'// -------- Title Row -------------'
fname fappend~ 'black' oN 'white'
fname fappend~ LF,'$pdf->',pdfMulti 0 0 ; 5 1 ; ('<b>CLUB</b>: ',glCourseName); 1
NB. Need to work out which tees this is serving
meas=. gender{;glTeMeasured
fname fappend~ LF,'$pdf->',pdfMulti 5 0 ; 4.5 1 ; ('<b>COURSE</b>: ',(>gender{'/' cut '/Men /Women '),>((glTees i. tee){glTeesName)); 1
fname fappend~ LF,'$pdf->',pdfMulti 9.5 0 ; 1.5 1 ; ('<b>HOLE</b>: ',":1+hole); 1
fname fappend~ LF,'$pdf->',pdfMulti 11 0 ; 2 1 ; ('<b>PAR</b>: ',":gender{,glTePar); 1
fname fappend~ LF,'$pdf->',pdfMulti 13 0 ; 3 1 ; ('<b>LENGTH</b>: ',":(<t_index,hole){glTeesYards); 1
fname fappend~ LF,'$pdf->',pdfMulti 16 0 ; 5 1 ; '<b>DATE RATED</b>:' ; 1
fname fappend~ LF,'$pdf->',pdfMulti 21 0 ; 7 1 ; '<b>T/LEADER</b>:' ; 1

fname fappend~ pdfDiag  3 2 ; 1.25 1

NB. ---------------------------
NB. Shots Played
NB. ---------------------------
fname fappend~ LF,'// -------- Shots Played -------------'
fname fappend~ write_title 0 1 ; 3 1; 'SHOTS PLAYED'
sh=. ' ' cut 'T 2 3 4'
sh=. (<'<b>'), each sh, each <'</b>'
fname fappend~ 'C' write_cell 3 1 ; 1.25; <sh
for_ab. i. 2 do.
    fname fappend~ LF,('R' ; 1) write_cell (0 ,2+ab) ; 3 ; ('<i>',(>ab{' ' cut 'Scratch Bogey'),'</i>')
    ww2=. I. (ab=glPlanAbility) 
    ww2=. ('' (8!:0) ww2{glPlanHitYards),each <"0 ww2{glPlanLayupType
    fname fappend~ ('C' ; 1) write_calc (3, 2+ab) ; (4{.((#ww2)$1.25), 4$_1.25) ; <ww2
end.
fname fappend~ ('R' ; 1) write_cell 0 4 ; 3 ; 'Transition Hole?'
for_ab. i. 2 do.
    txt=. '<b>',(>ab{'/' cut 'Scratch: / Bogey: '),'</b>'
    txt=. txt, >(ab { transition) {' ' cut 'No Yes'
    fname fappend~ write_calc ((3+ab*2.5) ,4) ; 2.5 ; txt 
end.

NB. ----------------
NB. Roll
NB. ----------------
fname fappend~ LF,'// -------- Roll -------------'
fname fappend~ write_title 0 5 ; 3 1 ; 'TEE ROLL'
ww=. ' ' cut '<b>S1</b> <b>B1</b>'
fname fappend~ 'C' write_cell 3 5 ; 2.5 ; <ww
NB. Roll Slope
fname fappend~ write_cell 0 6 ; 3 ; '<i>Slope in Tee Shot LZ</i>'
lay=. (glRollLevelVal i. >0{ each rolllevel) { glRollLevelNum
lay=. lay, each (<' '),each (glRollSlopeVal i. >0{ each rollslope) { glRollSlopeNum
fname fappend~ ('C'; 1) write_input 3 6 ; 2.5 ;  <lay
NB. Roll lookup table
fname fappend~ LF,('R' ; 1) write_cell 0 7 ; 3 ; '<i>Table Value</i>'  
fwtot=. 0 0 
fw=. 0$0
for_ab. 0 1 do.
    sh=. 0{ > ab { rolllevel
    sh=.  sh ; <0{ > ab { rollslope
    sh=. lookup_roll_rating sh
    fname fappend~ ('C' ; 1) write_calc ((3+ 2.5 *ab),7) ; 2.5 ;  sh  
    fw=. fw, sh
end.
fwtot=. fwtot + fw
NB. Roll Extreme
fname fappend~ write_row_head 0 8 ; 2.5 0.5 ; '<i>Extreme</i>'; '<b>E</b>' 
lay=. 'glPlanRollExtreme' matrix_pull hole ; tee ; gender
sh=. >0{ each lay
sh=. (glRollExtremeVal i. sh){glRollExtremeNum
fname fappend~ ('C' ; 1) write_input 3 8 ; 2.5 ; sh
fwtot=. fwtot + sh
NB. Roll Twice
fname fappend~ write_row_head 0 9 ; 2.5 0.5; '<i>Twice</i>'; '<b>2</b>'
lay=. 'glPlanRollTwice' matrix_pull hole ; tee ; gender
sh=. >each (#each) each lay NB. Find first of length >0
sh=. 0< each sh
sh=. >{. each sh # each lay
sh=. (glRollTwiceVal i. sh){glRollTwiceNum
fname fappend~ ('C' ; 1) write_input 3 9 ; 2.5 ; sh
fwtot=. fwtot + sh
NB. Roll Overall rating
fname fappend~ ('R'; 1 ) write_footer 0 10 ; 3  ; 'Roll Rating'
fname fappend~ ('C'; 1 ) write_footer 3 10 ; 2.5 ; fwtot

NB. ------------------------
NB. Fairway
NB. ------------------------
fname fappend~ LF,'// -------- Fairway -------------'
fname fappend~ write_title 0 22 ; 3 ; 'FAIRWAY'
ww=. ' ' cut 'S1 S2 B1 B2 B3'
ww=. (<'<b>'), each ww
ww=. ww, each <'</b>'
fname fappend~ 'C' write_cell 3 22 ; 1 ; <ww
NB. Fairway Width
fname fappend~ 'R' write_cell 0 23 ; 3 ; '<i>Width (Yds) at LZ</i>'
fname fappend~ 'R' write_cell 0 24 ; 3 ; 'Table Value'
wid=. }: each 'glPlanFWWidth' matrix_pull hole ; tee ; gender
select. z=. j. / > #each wid
    case. 0j0 do. sz=. _1 _1, _1 _1 _1
    case. 0j1 do. sz=. _1 _1,  1 _1 _1
    case. 1j1 do. sz=.  1 _1,  1 _1 _1
    case. 1j2 do. sz=.  1 _1,  1  1 _1
    case. 2j2 do. sz=.  1  1 , 1  1 _1
    case. 2j3 do. sz=.  1  1 , 1  1  1
end.
fwtot=. 0$<''
for_ab. 0 1 do.
    fw=. 0$0
    for_sh. >ab{wid do.
	fw=. fw, lookup_fairway_rating gender ; ab ; (+/>ab{hityards) ; sh 
    end.
    fwtot=. fwtot, <fw
end.
fname fappend~ 'C' write_input 3 23 ; sz ; (;wid) 
fname fappend~ 'C' write_calc 3 24 ; sz ; (;fwtot) 
NB. Fairway Layup
fname fappend~ write_row_head 0 25 ; 2.5 0.5; '<i>Lay-up</i>'; '<b>L</b>'
lay=. - each 'L' =each }: each 'glPlanLayupType' matrix_pull hole ; tee ; gender NB. -1 if Layup
fname fappend~ 'C' write_input 3 25 ; sz ; (;lay)
fwtot=. fwtot +each lay
NB. Fairway Visibility
fname fappend~ write_row_head 0 26 ; 2.5 0.5; '<i>Visibility</i>'; '<b>V</b>'
lay=. }: each targvisible
fname fappend~ 'C' write_input 3 26 ; sz ; (;lay)
fwtot=. fwtot +each lay
NB. Fairway Width
fname fappend~ write_row_head 0 27 ; 2.1 0.9; '<i>Width</i>'; '<b>+W</b>'
lay=.  }: each 'glPlanFWWidthAdj' matrix_pull hole ; tee ; gender
lay=. ((<glFWWidthAdjVal) i. each lay) { each <glFWWidthAdjNum
fname fappend~ 'C' write_input 3 27 ; sz ; (0>. ; lay)
fwtot=. fwtot +each lay NB. Only need to add once
fname fappend~ write_row_head 0 28 ; 2.1 0.9; '<i>Width</i>'; '<b>-W</b>'
fname fappend~ 'C' write_input 3 28 ; sz ; (0<.;lay)
NB. Fairway Obstructed
fname fappend~ write_row_head 0 29 ; 2.5 0.5; '<i>Obtructed</i>'; '<b>O</b>'
lay=. _2}. each 0, each 'glPlanFWObstructed' matrix_pull hole ; tee ; gender
lay=. (<"0 (0 1)) *each lay NB. Bogey only, so set to zero for scratch
fwtot=. fwtot +each lay
lay=. (0;1) #each lay NB. Suppress bogey
fname fappend~ 'C' write_input 3 29 ; (_1 _1, 2}.sz) ; (;lay)
NB. Total shot value
fname fappend~ LF, 'R' write_cell 0 30 ; 3  ; 'Total Shot Value'
fname fappend~ 'C' write_calc 3 30 ; sz ; (;fwtot)
NB. Highest shot value
fname fappend~ LF, write_cell 0 31 ; 3  ; 'Highest Shot Value'
fwtot=. > ( >. / each 0, each fwtot) NB. Beware empty on par threes so tack on zero
fname fappend~ 'C' write_calc 3 31 ; 2 3 ; (;fwtot)
NB. Fairway Unpleasant
fname fappend~ write_row_head 0 32 ; 2.5 0.5; '<i>Unpleasant</i>'; '<b>U</b>'
lay=. 'glPlanFWUnpleasant' matrix_pull hole ; tee ; gender NB. One number for all shots
lay=. +. /"1 > lay 
fname fappend~ 'C' write_input 3 32 ;  2 3 ; (;lay)
fwtot=. fwtot + lay
NB. Fairway Overall rating
fname fappend~ 'R' write_footer 0 33 ; 3 ; 'Fairway Rating'
fname fappend~ 'C' write_footer 3 33 ;  2 3 ; fwtot

NB. ------------------------
NB. Elevation
NB. -------------------------
fname fappend~ LF,'// -------- Elevation -------------'
fname fappend~ write_title 0 11 ; 3 1 ; 'ELEVATION'
fname fappend~ write_cell 3 11 ; 3 ; 'Tee to Gr (<b>gt 10ft</b>)'
sh=. glGrAlt - glTeAlt
sh=. sh * 10<: |sh NB. Minimum 10ft
fname fappend~ 'R' write_input 6 11 ; 1 1 ; (0 >. sh),0 <. sh 

NB. ------------------------
NB. Lay-Up
NB. ------------------------
fname fappend~ LF,'// -------- Lay-Up -------------'
fname fappend~ write_title 0 12 ; 3 1 ; 'F/LAY-UP'
fname fappend~ write_cell 3 12 ; 2 ; 'Forc / DLeg'
sh=. 'glPlanDefaultHit' matrix_pull hole ; tee ; gender
NB. Have to do the 0 >. maximum in case of a transition as well as a layup
NB. Also have to drop the last item, replaced by logic to see if the Layup Type is 'L'
sh=. 50 <. >+/ each ('L'=each 'glPlanLayupType' matrix_pull hole; tee ; gender) * each 0 >. each sh - each 'glPlanHitYards' matrix_pull hole ; tee ; gender
NB. Look for negative dogleg
sh=. sh - 50 <. >+/ each | each 'glPlanDoglegNeg' matrix_pull hole ; tee ; gender
ww=. ('Sc: ';'Bo: ') , each 'bp<+>' 8!:0 sh
fname fappend~ 'C' write_input 5 12 ; 1.5 ;  <(<"0 (0 ~: sh))#each ww
NB. Layup Type
sh=. 'glPlanLayupCategory' matrix_pull hole ; tee ; gender
sh=. (<glLayupCategoryVal) i. each sh
sh=. sh {each <glLayupCategoryDesc,<''
sh=. ('L'=each 'glPlanLayupType' matrix_pull hole ; tee ; gender) #each sh
sh=. <>{. each sh
fname fappend~ 'R' write_cell 0 13 ; 3 ; 'Layup Type'
fname fappend~ 'C' write_input 3 13 ; 3   2   ; sh
NB. Layup Reason
sh=. 'glPlanLayupReason' matrix_pull hole ; tee ; gender
sh=. ('L'=each 'glPlanLayupType' matrix_pull hole ; tee ; gender) #each sh
sh=. <>{. each sh
fname fappend~ 'R' write_cell 0 14 ; 3 ; 'Layup Reason'
fname fappend~ 'C' write_input 3 14 ; 3   2   ; sh

NB. ------------------------
NB. Topography
NB. ------------------------
fname fappend~ LF,'// -------- Topography -------------'
alt=. (' ' cut 'glPlanAlt glGrAlt') matrix_pull hole; tee ; gender
fname fappend~ write_title 0 15 ; 3 1 ; 'TOPOGRAPHY'
alt=. >(-&-/) each _2 {. each alt
alt=. alt * 3<gender{glTePar
fname fappend~ (' ' cut 'cell input') write_row_head 3 15 ; 1.2  0.8 ; 'App S:' ; 0{alt
fname fappend~ (' ' cut 'cell input') write_row_head 5 15 ; 2 1 ; 'App Elev B:' ; 1{alt
fname fappend~ 'R' write_cell 0 16 ; 3 ; '<i>(LZtoLZ or Appr)</i>'
ww=. ' ' cut 'LZ1-2 Appr LZ1-1 LZ2-3 Appr'
ww=. (<'<b>'), each ww
ww=. ww, each <'</b>'
fname fappend~ 'C' write_cell 3 16 ; 1 ; <ww
NB. Topog Level
fname fappend~ 'R' write_cell 0 17 ; 3 ; '<i><b>(MP/MA/SA/EA)<b></i>'
wid=. }: each 'glPlanTopogStance' matrix_pull hole ; tee ; gender
select. z=. j. / > #each wid
    case. 0j0 do. sz=. _1 _1, _1 _1 _1
    case. 0j1 do. sz=. _1 _1, _1 _1  1
    case. 1j1 do. sz=. _1  1,  1 _1 _1
    case. 1j2 do. sz=. _1  1,  1 _1  1
    case. 2j2 do. sz=.  1  1 , 1 _1  1
    case. 2j3 do. sz=.  1  1 , 1  1  1
end.
wid=. (<glTopogStanceVal) i. each wid
fname fappend~ 'C' write_input 3 17 ; sz ; < (;wid) { glTopogStanceText
fname fappend~ 'R' write_cell 0 18 ; 3 ; 'Table Value'
wid=. wid {each <glTopogStanceNum
fname fappend~ 'C' write_calc  3 18 ; sz ; (;wid) 
fname fappend~ 'R' write_cell 0 19 ; 3 ; 'Total Shot Value'
fname fappend~ 'C' write_calc  3 19 ; sz ; (;wid) 
fname fappend~ 'R' write_cell 0 20 ; 3 ; 'Highest Shot Value'
fname fappend~ 'C' write_calc  3 20 ; 2 3 ; (0 >. ;>. / each wid) 
fname fappend~ 'R' write_footer 0 21 ; 3 ; 'Topography'
fname fappend~ 'C' write_footer 3 21 ;  2 3 ; (0 >. ;>. / each wid)

NB. ------------------------
NB. Recoverability and Rough
NB. ------------------------
fname fappend~ LF,'// -------- Recoverability and Rough -------------'
carryyards=. 'F' carry_yards hole; tee ; gender 
fname fappend~ write_title 8 1 ; 3 1 ; '<b>RECOV & ROUGH</b>' 
fname fappend~ ('cell' ; 'input') write_row_head 8 8 ; 0.7 0.55 ; '<i>Yd:</i>' ; ":0{>0{carryyards
fname fappend~ ('cell' ; 'input') write_row_head 9.25 8 ; 0.7 0.55 ; '<i>Ht:</i>'; (":glGrRRRoughLength) 
fname fappend~ 'R' write_cell 10.5 8 ; 0.5 ; '<b>C</b>'

NB. Bunkers
fname fappend~ LF,'// -------- Bunkers -------------'
carryyards=. 'B' carry_yards hole; tee ; gender 
fname fappend~ LF,'$pdf->SetFillColor(0, 0, 0);'
fname fappend~ LF,'$pdf->SetTextColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 8 16 ; 3 1 ; '<b>BUNKERS</b>' ; 1
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
fname fappend~ LF,'$pdf->',pdfMulti 11 16 ; 3 1 ; 'Green Protection:' ; 1
fname fappend~ LF,'$pdf->SetFillColor(247, 253, 156);'
fname fappend~ LF,'$pdf->',pdfMulti 14 16; 4 1 ; (; > (glBunkFractionVal i. glGrBunkFraction){glBunkFractionDesc) ; 1  
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 8 17; 3 1 ; '' ; 1 
ww=. ' ' cut 'S1 S2 S3 B1 B2 B3 B4'
for_i. ww do.
    fname fappend~ LF,'$pdf->',pdfMulti ((11+i_index),17) ; 1 1 ; ('<span style="text-align: center">',( > i),'</span>') ; 1  
end. 
fname fappend~ LF,'$pdf->',pdfMulti 8 18 ; 3 1 ; '<span style="text-align: right">Table Value</span>' ; 1 
fname fappend~ LF,'$pdf->',pdfMulti 11 18 ; 3 1 ; '' ; 1 
fname fappend~ LF,'$pdf->',pdfMulti 14 18 ; 4 1 ; '' ; 1 

fname fappend~ LF,'$pdf->',pdfMulti 8 20 ; 2.5 1 ; '<i>Carry</i>' ; 1
fname fappend~ LF,'$pdf->',pdfMulti 10.5 20 ; 0.5 1 ; '<b>C</b>'; 1
fname fappend~ LF,'$pdf->SetFillColor(127, 127, 127);' NB. Grey out boxes
fname fappend~ LF,'$pdf->',pdfMulti 11 20 ; 7 1 ; '' ; 1
for_ab. 0 1 do.
    for_sh. >ab_index { carryyards do.
	if. sh>0 do.
	    fname fappend~ LF,'$pdf->SetFillColor(247, 253, 156);'
	    fname fappend~ LF,'$pdf->',pdfMulti (( 11 +(3* ab) + sh_index),20) ;  1 1   ; (":sh) ; 1
	    fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
	else.
	    fname fappend~ LF,'$pdf->SetFillColor(127, 127, 127);'
	    fname fappend~ LF,'$pdf->',pdfMulti (( 11 +(3* ab) + sh_index),20) ;  1 1   ; '' ; 1
	    fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
	end.	    
    end.
end.

NB. -----------------------------
NB. Altitude
NB. -----------------------------
fname fappend~ LF,'// -------- Altitude -------------'
alt=. (' ' cut 'glPlanAlt glGrAlt') matrix_pull hole; tee ; gender
fname fappend~ 'black' oN 'lightgrey'
fname fappend~ LF,'$pdf->',pdfMulti 3 46 ; 4 1 ; '<b>Altimeter Readings</b>' ; 1
fname fappend~ ('cell' ; 'input') write_row_head 7 46 ; 3 1.5 ; '<b>On Tee:</b>' ; ":glTeAlt
if. glTePar>3 do.
	fname fappend~ ('cell' ; 'input') write_row_head 11.5 46 ; 3 1.5 ; '<b>Scratch Approach:</b>' ; ":_2{>0{alt 
	fname fappend~ ('cell' ; 'input') write_row_head 16   46 ; 3 1.5 ; '<b>Bogey Approach:</b>' ; ":_2{>1{alt 
else.
	fname fappend~ write_cell 11.5 46 ; 4.5 ; '<b>Scratch Approach:</b>' 
	fname fappend~ write_cell 16   46 ; 4.5 ; '<b>Bogey Approach:</b>' 
end.
fname fappend~ ('cell' ; 'input') write_row_head 20.5 46 ; 3 1.5 ; '<b>At Green:</b>' ; ":_1{>0{alt 


NB. End of Page
fname fappend~ LF,'// -------- End of Page -------------'
NB. fname fappend~ LF,'$pdf->SetXY(100,100);'
NB. fname fappend~ LF,'$pdf->Write(10,''Return to plan'',''http://jw/rating/plannomap/',glFilename,'/',(":1+hole),''')'
fname fappend~ LF,'$pdf->Output(''',shortname,'.pdf'', ''I'');'
fname fappend~ LF,'?>'

stdout '</head><body onLoad="redirect(''/tcpdf/rating/',shortname,'.php'')"'
stdout LF,'</body></html>'
exit ''
)

NB. =========================================================
NB. matrix_pull
NB. =========================================================
NB. Usage variable matrix_pull hole ; tee ; gender 
NB. or
NB. (variabe variable_green) matrix_pull hole ; tee ; gender 
NB.
NB. Returns a two element boxed array with the shot values for scratch, bogey
NB. Assume the glFilepath,'_plan' is already read
matrix_pull=: 4 : 0
'hole tee gender'=. y
hole=. ''$ hole
tee=. ''$ tee
gender=. ''$ gender
shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole)),(gender{'MW'),tee

if. 0 =L. x do.
    x1=. x
    x2=. ''
else.
    'x1 x2'=.x
end.

NB. file exists if we have got this far
NB. Need to check this is a valid shot
ww=. glPlanRecType='P'
ww=. ww *. glPlanHole=hole
ww=. ww *. glPlanTee=tee
ww=. I. ww *. glPlanGender=gender

NB. Need to work out which tees this is serving
t=. glTeTee= tee
t=. t *. glTeHole=hole
(t#glTeID) utKeyRead glFilepath,'_tee'
t_index=. glTees i. tee

NB. Pull the green variables
((hole=glGrHole)#glGrID) utKeyRead glFilepath,'_green'

NB. Order by ability, shot and re-read the plan
ww=. ww /: ww{glPlanShot
ww=. ww /: ww{glPlanAbility

box=. 0< L. ". x1
res=. 0$a:
for_ab. i. 2 do.
    if. box do.
	rr=. 0$a:
    else.
	rr=. ''
    end.
    for_sh. i. 4 do.
	ww1=. I. (ab = glPlanAbility) *. (sh = glPlanShot) 
	if. 0<#ww1 do.
	    rr=. rr, ww1{ ".x1
	end.

    end.
    NB. Drop the last and pull the tee variable if both variables were requested
    if. 0<#x2 do.
	rr=. }: rr
	rr=. rr, ". x2
    end.
    res=. res, <rr
end.
res=. res
)

NB. ==============================================================
NB. Distance Report
NB. ==============================================================
NB. Usage:
NB.    distance_report ''
NB.
NB. Returns a LF delimited string of distances
distance_report=: 3 : 0
res=. ''
for_h. i. 18 do.

    for_t. glTees do.
	dist=. 'glPlanHitYards' matrix_pull h ; t ; 0 
	lay=. 'glPlanLayupType' matrix_pull h ; t ; 0
	if. 0<# >0{dist do.
	    res=. res, LF, 'Hole ',(":1+h),' Men '
	    res=. res, >(glTees i. t){glTeesName
	    res=. res, ' Scratch: '
	    for_sh. >0{dist do.
		res=. res, , ": sh_index{>(0{dist)
		res=. res, sh_index{>0{lay
		res=. res, ' '
	    end.
	    res=. res, ' Bogey: '
	    for_sh. >1{dist do.
		res=. res, ": sh_index{>(1{dist)
		res=. res, sh_index{>1{lay
	    end.
	end.
    end.
end.
res=. res
)

NB. ====================================================================
NB. Carry_Yards
NB. ====================================================================
NB. Usage:
NB.     carrytype carry_yards hole ; tee ; gender 
NB. Returns:
NB. Boxed array of two elements for scratch and bogey with carries for each hit
carry_yards=: 4 : 0
'hole tee gender'=. y
hole=. ''$ hole
tee=. ''$ tee
gender=. ''$ gender

yards=: 'glPlanHitYards' matrix_pull hole ; tee ; gender 
NB. Need to read the hole file again
oldid=. glPlanID
utKeyRead glFilepath,'_plan'
ww=. hole = glPlanHole
ww=. ww *. 'C'=glPlanRecType
ww=. ww *. x=glPlanCarryType

if. (-. +. / ww) do. NB. No Carry
    res=. 0 * each yards
else.
    ww=. I. ww
    NB. Loop round the carries
    res=. 0 * each yards
    totalyards=. (<(glTees i. tee),hole){glTeesYards
    for_ww1. ww do.
	carry=. totalyards - ww1{ glPlanRemGroundYards
	carry=. carry - each 0, each }: each +/ \ each yards
	carry=. 0 >. each carry
	carry=. carry * each  yards >: each carry
	res=. res >. each carry
    end.
end.
oldid utKeyRead glFilepath,'_plan'
res=. res
)

NB. =================================================
NB. lookup_bunker
NB. =================================================
NB. Usage:
NB.   lookup_bunker 

NB. =================================================
NB. lookup_green_target
NB. =================================================
NB. Usage
NB.   lookup_green_target gender ; abilty ; yards ; diam ; transition
NB. Returns table value
lookup_green_target=: 3 :  0
'gender ab yards diam trans'=. y
NB. Make transition yards large
yards=. (trans){(yards, 999)
if. gender=0 do. NB. Men
    row=. > ab { 60 80 100 120 140 160 180 200 220 241 400 ; 30 45 60 75 90 110 130 150 165 181 400
    col=. 36 31 26 21 17 12
    mat=. 12 7 $ 2 2 2 2 2 2 2 , 2 2 2 3 3 3 3 ,2 2 3 3 4 4 4 , 2 2 3 4 4 4 5, 2 3 4 4 4 5 6 , 2 3 4 4 5 6 7, 3 3 4 5 6 7 7 , 3 4 5 5 6 7 8, 3 4 5 6 7 8 9, 4 5 6 7 8 8 9, 4 5 6 7 8 9 10, 3 4 4 5 5 6 6
else.
    row=. > ab { 30 50 70 90 110 130 150 170 185 201 400 ; 21 35 50 65 80 95 105 115 125 141 400
    col=. 36 31 26 21 17 12
    mat=. 12 7 $ 2 2 2 2 2 2 2 , 2 2 2 3 3 3 3 ,2 2 3 3 4 4 4 , 2 2 3 4 4 4 5, 2 3 4 4 4 5 6 , 2 3 4 4 5 6 7, 3 3 4 5 6 7 7 , 3 4 5 5 6 7 8, 3 4 5 6 7 8 9, 4 5 6 7 8 8 9, 4 5 6 7 8 9 10, 3 4 4 5 5 6 6

end.
row=. + / yards >: row
col=. + / diam <: col
res=. (<row,col) { mat
)
NB. =================================================
NB. lookup_fairway_rating
NB. =================================================
NB. Usage
NB.   lookup_green_target gender ; abilty ; yards ; width
NB. Returns table value
lookup_fairway_rating=: 3 :  0
'gender ab yards width'=. y
if. gender=0 do. NB. Men
    row=. 340 380 426 
    col=. 50 39 29 24 19   
    mat=. 4 6 $ 1 1 2 3 4 5, 1 2 3 3 5 6, 2 3 4 4 6 7, 2 3 4 5 7 8
else.

end.
row=. + / yards >: row
col=. + / width <: col
res=. (<row,col) { mat
)

NB. =================================================
NB. lookup_roll_rating
NB. =================================================
NB. Usage
NB.   lookup_roll_rating level ; slope
NB. Returns table value
lookup_roll_rating=: 3 :  0
'level slope'=. y
row=. glRollLevelVal i. level
col=. glRollSlopeVal i. slope
mat=. 3 3 $ _1 _2 _3, 0 0 0 , 1 2 3
res=. (<row,col) { mat
)

