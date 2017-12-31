NB. J Utilities for displaying sheet data
NB. 

glPDFoffset=: 8 4
glPDFmult=: (276 % 28), (190 % 46)

boxnonzero=: 3 : 0
NB. =========================================================
NB. boxnonzero
NB. ---------------------------------------------------------
NB. Usage
NB.   boxnonzero y
NB. Returns boxed items, with zeros set to boxed null
NB. =========================================================
res=. (( y~: 0 ) * ($y)$1+i. */$y){ '' ; <"0 ,y
)

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
r=. 'WriteHTMLCell(',(":0{size),', ',(": 1{size),', ',(":0{offset),', ',(":1{offset),', ''',text,''', ',(":border),', 0, true, true, ''',x,''', false);'
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
if. _1 = 4!:0 <'glOldColor' do. glOldColor=: '' ; '' ; '' end.
NB. Is same color?
if. y -: > ('TFD' i. x) { glOldColor do.
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
	case. 'red' do. res=. '(255, 0, 0);'
    end.
    glOldColor=: (<y) ('TFD' i. x) } glOldColor
    res=.LF,'$pdf->', (>('FT' i. x){' ' cut 'setFillColor setTextColor setDrawColor'),res
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
	if. 2 ~: 3!:0 sh do. sh=. ;'b' 8!:0 sh end.
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
	res=.res, 'blue' oN 'white'
	sh=. ((sz_index){_1 + (+/) \ size >: 0 ){array
	if. 1=L. sh do. sh=. >sh end.`
	if. 2 ~: 3!:0 sh do. sh=. ;'p<>' 8!:0 sh end.
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
	res=.res, 'black' oN 'lightblue'
	sh=. ((sz_index){_1 + (+/) \ size >: 0 ){array
	if. 1=L. sh do. sh=. >sh end.`
	if. 2 ~: 3!:0 sh do. sh=. ;'p<>' 8!:0 sh end.
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
NB. rating_reportsingle
NB. =========================================================
NB. Run report PHP in batch mode
jweb_rating_reportsingle=: 3 : 0
1 jweb_rating_report y
)



NB. =========================================================
NB. rating_report
NB. =========================================================
NB. View scores for participant
jweb_rating_report=: 3 : 0
0 jweb_rating_report y
:
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
	CheckXLFile glFilepath,'_xl'  NB. Check existence of XL file
	utKeyRead glFilepath,'_xl'
	CheckSSFile glFilepath,'_ss'
	utKeyRead glFilepath,'_ss'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.


if. x=0 do.
stdout 'Content-type: text/html',LF,LF,'<html>',LF
stdout LF,'<head>'
stdout LF,'<script src="/javascript/pagescroll.js"></script>',LF
djwBlueprintCSS ''
end. 

NB. Error page - No such course
if. 0<#err do.
    djwErrorPage err ; ('No such course name : ',glFilename) ; '/jw/rating/plan/v' ; 'Back to rating plan'
end.

NB. Clear down the XL entries for this page
ww=. glXLHole = hole
ww=. ww *. glXLTee = tee
ww=. ww *. glXLGender = gender
(ww # glXLID) utKeyDrop glFilepath,'_xl'
glXLCount=: _1

NB. Pull / create SS record
ww=. glSSHole = hole
ww=. ww *. glSSTee=tee
ww=. ww *. glSSGender=gender
if. +. /ww do.
    (ww#glSSID) utKeyRead glFilepath,'_ss'
else.
    key=. EnKey hole ; '' ; tee ; gender ; 0 ; 0
    glSSID=: ,<(0 1 2 4 5 6){> key
    glSSHole=: ,hole
    glSSTee=: ,tee
    glSSGender=: ,gender
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
fname fappend~ LF,'$pdf->SetAutoPageBreak(FALSE, PDF_MARGIN_BOTTOM);' NB. Change the default setting
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
psych=. 0 2$0

NB. Title row
glOldColor=: '' ; '' ; '' NB. Need to reset at the start
fname fappend~ LF,'// -------- Title Row -------------'
fname fappend~ 'black' oN 'white'
fname fappend~ LF,'$pdf->',pdfMulti 0 0 ; 4.75 1 ; ('<b>CLUB</b>: ',glCourseName); 1
NB. Need to work out which tees this is serving
meas=. gender{;glTeMeasured
fname fappend~ LF,'$pdf->',pdfMulti 4.75 0 ; 2.25 1 ; ('<b>TEE</b>: ',(>(glTees i. tee){glTeesName)); 1
fname fappend~ LF,'$pdf->',pdfMulti 7 0 ; 2.5 1 ; ('<b>GENDER</b>: ',>gender{'/' cut '/Men/Women'); 1
fname fappend~ LF,'$pdf->',pdfMulti 9.5 0 ; 1.5 1 ; ('<b>HOLE</b>: ',":1+hole); 1
fname fappend~ LF,'$pdf->',pdfMulti 11 0 ; 3 1 ; ('<b>LENGTH</b>: ',":(<t_index,hole){glTeesYards) ; 1
1 write_xl hole ; tee ; gender ; 'Information' ; 25 ; (3+hole) ; 0 ; 'Shot distance input' ; (<t_index,hole){glTeesYards NB. Hole length
write_xl hole ; tee ; gender ; (hole+1) ; 51 ; 6 ; 0 ; 'Hole length' ; (<t_index,hole){glTeesYards NB. Hole length
glSSYards=: , (<t_index,hole){glTeesYards
fname fappend~ LF,'$pdf->',pdfMulti 14 0 ; 2 1 ; ('<b>PAR</b>: ',": gender{,glTePar); 1
write_xl hole ; tee ; gender ; (hole+1) ; 51 ; 8 ; 0 ; 'Hole par' ; gender{,glTePar NB. Hole par 
1 write_xl hole ; tee ; gender ; 'Information' ; 28 ; (3+hole) ; 0 ; 'Information - Par' ; gender{,glTePar NB. Hole par
glSSPar=: ,gender{,glTePar
glSSObsFactor=: (''$glSSPar>3){2 10$0.08 0 0.09 0.13 0.06 0.08 0.13 0.07 0.11 0.05, 0.1 0.11 0.09 0.14 0.07 0.1 0.14 0.09 0.11 0.05 NB. Scratch
glSSObsFactor=: 1 10 2$, glSSObsFactor,. (''$glSSPar>3){2 10$0.08 0 0.07 0.13 0.10 0.07 0.11 0.11 0.09 0.04,0.12 0.09 0.06 0.15 0.10 0.09 0.14 0.14 0.08 0.03 NB. Bogey
fname fappend~ LF,'$pdf->',pdfMulti 16 0 ; 5 1 ; ('<b>DATE RATED</b>: ',glCourseDate) ; 1
fname fappend~ LF,'$pdf->',pdfMulti 21 0 ; 7 1 ; ('<b>T/LEADER</b>: ',glCourseLead) ; 1

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
    NB. Differences from default hit
    if. -. +. / (ww2{glPlanLayupType) e. 'LR' do.
	ww=. (#ww2)$<''
    else.
	ww=. boxnonzero ww2{glPlanHitYards
    end.
    2 write_xl hole ; tee ; gender ; (hole+1) ; (ab{7 9) ; 5 ; 0 ; 'Shot distance input' ; <(ab{3 4){.ww
    write_xl hole ; tee ; gender ; (hole+1) ; (53+ab) ; 5 ; 0 ; 'Shot distance' ; (ab{3 4){.ww2{glPlanHitYards 
    2 write_xl hole ; tee ; gender ; (hole+1) ; 10 ; (ab{6 9) ; 0 ; 'Transition input' ; (+. / 'T'=ww2 {glPlanLayupType)#'Y' NB. Transition y/n
    write_xl hole ; tee ; gender ; (hole+1) ; 55 ; (ab{6 8) ; 0 ; 'Transition' ; (+. / 'T'=ww2 {glPlanLayupType){'NY' NB. Transition y/n
    ww2=. ('' (8!:0) ww2{glPlanHitYards),each <"0 ww2{glPlanLayupType
    fname fappend~ ('C' ; 1) write_input (3, 2+ab) ; (4{.((#ww2)$1.25), 4$_1.25) ; <ww2
end.
fname fappend~ ('R' ; 1) write_cell 0 4 ; 3 ; 'Transition Hole?'
for_ab. i. 2 do.
    txt=. '<b>',(>ab{'/' cut 'Scratch: / Bogey: '),'</b>'
    txt=. txt, >(ab { transition) {' ' cut 'No Yes'
    fname fappend~ write_input ((3+ab*2.5) ,4) ; 2.5 ; txt 
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
NB. Spreadsheet check first
NB. The spreadsheet has weird logic.  "Text" has Level spelled out (for the check row 57)
NB. whereas row 12 has "Desc" with blank for level
NB. BUT par 3 check has blank
lay=. (glRollLevelVal i. >0{ each rolllevel) { glRollLevelDesc
if. 3<(<0,gender){glTePar do.
	write_xl hole ; tee ; gender ; (hole+1) ; 57 ; 5 7 ; 0 ; 'Roll Up/Down' ; < (glRollLevelVal i. >0{ each rolllevel) { glRollLevelText
else.
	write_xl hole ; tee ; gender ; (hole+1) ; 57 ; 5 7 ; 0 ; 'Roll Up/Down' ; < lay
end.
2 write_xl hole ; tee ; gender ; (hole+1) ; 12 ; 5 7 ; 0 ; 'Roll Up/Down' ; <lay
lay=. (glRollSlopeVal i. >0{ each rollslope) { glRollSlopeDesc
ww1=. ( 0 < ; # each > 0{each rolllevel) 
write_xl hole ; tee ; gender ; (hole+1) ; 57 ; 6 8 ; 0 ; 'Roll Severity' ; <ww1 #inv ww1 # lay
2 write_xl hole ; tee ; gender ; (hole+1) ; 12 ; 6 8 ; 0 ; 'Roll Severity' ; <ww1 #inv ww1 # lay
lay=. (glRollLevelVal i. >0{ each rolllevel) { glRollLevelNum
lay=. lay, each (<' '),each (glRollSlopeVal i. >0{ each rollslope) { glRollSlopeNum
NB. Clear the display if it level, ie. rolllevel is null 
lay=. ( 0 < ; # each > 0{each rolllevel) # each lay
lay=. ( 1 >. > #each lay) {. each lay NB. Max of one blank
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
write_xl hole ; tee ; gender ; (hole+1) ; 61 ; 5 7 ; 0 ; 'Roll Rating' ; fwtot NB. Roll Rating
glSSRoll=: 1 2$fwtot

NB. ------------------------
NB. Fairway
NB. ------------------------
fname fappend~ LF,'// -------- Fairway -------------'
fname fappend~ write_title 0 22 ; 3 ; 'FAIRWAY'
ww=. ' ' cut 'S1 S2 B1 B2 B3'
ww=. (<'<b>'), each ww
ww=. ww, each <'</b>'
fname fappend~ 'C' write_cell 3 22 ; 1 ; <ww
NB. Fairway Width and Lookup table
fname fappend~ 'R' write_cell 0 23 ; 3 ; '<i>Width (Yds) at LZ</i>'
fname fappend~ 'R' write_cell 0 24 ; 3 ; 'Table Value'
fairwaywidth=.  'glPlanFWWidth' matrix_pull hole ; tee ; gender
wid=. }: each fairwaywidth
select. z=. j. / > #each wid
    case. 0j0 do.
	sz=. _1 _1, _1 _1 _1
    case. 0j1 do. 
		NB. Bogey can't reach Par 3 is recorded under R&R
		NB. Clear out the reading, but only if it is a Par 3
		NB. It may be a Par 4 which Scratch can reach!!
		if. 3=(<0,gender){glTePar do.
			sz=. _1 _1,  _1 _1 _1
			wid=. (0$0) ; ,999
		else. 
			sz=. _1 _1, 1 _1 _1
		end.
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
fname fappend~ 'C' write_input 3 23 ; sz ; (;wid)  * 999> ;wid NB. Suppress 999
fname fappend~ 'C' write_calc 3 24 ; sz ; (;fwtot) 
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 79 ; 5 6 7 8 9 ; 0 ; 'Fairway width' ; <msk #inv <"0  (+./ msk)#;wid NB. Have to alow for Par 3 can't readh
2 write_xl hole ; tee ; gender ; (hole+1) ; 26 ; 5 6 7 8 9 ; 0 ; 'Fairway width' ; <msk #inv <"0 (+. /msk)# ;wid
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
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 83 ; 5 6 7 8 9 ; 0 ; 'Fairway W+' ; <msk #inv 0 >. ;lay NB. Expand with zeros
2 write_xl hole ; tee ; gender ; (hole+1) ; 28 ; 5 6 7 8 9 ; 0 ; 'Fairway W+' ; <msk #inv <"0  (0 >. ;lay) NB. Expand with null boxes
NB. Fairwidth negative adjustment
fname fappend~ write_row_head 0 28 ; 2.1 0.9; '<i>Width</i>'; '<b>-W</b>'
fname fappend~ 'C' write_input 3 28 ; sz ; (0<.;lay)
write_xl hole ; tee ; gender ; (hole+1) ; 84 ; 5 6 7 8 9 ; 0 ; 'Fairway W-' ; <msk #inv (0 <. ;lay) NB. Expand with zeros
2 write_xl hole ; tee ; gender ; (hole+1) ; 29 ; 5 6 7 8 9 ; 0 ; 'Fairway W-' ; <msk #inv <"0  (0 <. ;lay) NB. Expand with null boxes
NB. Fairway Obstructed
fname fappend~ write_row_head 0 29 ; 2.5 0.5; '<i>Obtructed</i>'; '<b>O</b>'
lay=. _2}. each 0, each 'glPlanFWObstructed' matrix_pull hole ; tee ; gender NB. Push to the shot after
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
NB. Minimum of 1 if par 4 or 5
fwtot=. fwtot >. 3<(<0,gender){glTePar
fname fappend~ 'R' write_footer 0 33 ; 3 ; 'Fairway Rating'
fname fappend~ 'C' write_footer 3 33 ;  2 3 ; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 89 ; 5 7 ; 0 ; 'Fairway' ; fwtot  NB. Fairway

NB. ------------------------
NB. Elevation
NB. -------------------------
fname fappend~ LF,'// -------- Elevation -------------'
fname fappend~ write_title 0 11 ; 3 1 ; 'ELEVATION'
fname fappend~ write_cell 3 11 ; 3 ; 'Tee to Gr (<b>gt 10ft</b>)'
sh=. glGrAlt - glTeAlt
sh=. sh * 10<: |sh NB. Minimum 10ft
sh=. (*sh) * 10 * <.0.5+ 0.1 * (| sh) NB. Round to nearest 10
if. 3=gender{glTePar do. sh=. _40 >. sh <. 40 end.
fname fappend~ 'R' write_input 6 11 ; 1 1 ; <'b<>p<+>' 8!:0 (0 >. sh),0 <. sh 
write_xl hole ; tee ; gender ; (hole+1) ; 68 ; 9 ; 0 ; 'Elevation Change' ; sh NB. Elevation Change
2 write_xl hole ; tee ; gender ; (hole+1) ; 21 ; 9 ; 0 ; 'Elevation Change' ; <(0 ~: sh) { '' ; sh NB. Elevation Change
glSSElevation=: ,sh

NB. ------------------------
NB. Lay-Up
NB. ------------------------
fname fappend~ LF,'// -------- Lay-Up -------------'
fname fappend~ write_title 0 12 ; 3 1 ; 'F/LAY-UP'
fname fappend~ write_cell 3 12 ; 2 ; 'Forc / DLeg'
sh=. 'glPlanDefaultHit' matrix_pull hole ; tee ; gender
NB. Have to do the 0 >. maximum in case of a transition as well as a layup
NB. Also have to drop the last item, replaced by logic to see if the Layup Type is 'L'
NB. sh=. 50 <. >+/ each ('L'=each 'glPlanLayupType' matrix_pull hole; tee ; gender) * each 0 >. each sh - each 'glPlanHitYards' matrix_pull hole ; tee ; gender
sh=. ('L'=each 'glPlanLayupType' matrix_pull hole; tee ; gender) * each 0 >. each sh - each 'glPlanHitYards' matrix_pull hole ; tee ; gender
NB. Look for negative dogleg
NB. sh=. sh - 50 <. >+/ each | each 'glPlanDoglegNeg' matrix_pull hole ; tee ; gender
sh=. sh -  each | each 'glPlanDoglegNeg' matrix_pull hole ; tee ; gender
sh=. (<_50) >. each (<50) <. each sh NB. Make individuals between _50 and 50
NB. ww=. ('Sc: ';'Bo: ') , each 'bp<+>' 8!:0 sh
ww=. ('Sc: ';'Bo: ') , each 'bp<+>' 8!:0 (_50 >. 50 <. >+/each sh) NB. Calc totals, and must be 50 max
fname fappend~ 'C' write_input 5 12 ; 1.5 ;  <(<"0 (0 ~: (>+/each sh)))#each ww
write_xl hole ; tee ; gender ; (hole+1) ; 64 ; 9 ; 0 ; 'Layup Scratch' ; _50 >. 50 <. (+/> 0{sh) NB. Layup scratch total
write_xl hole ; tee ; gender ; (hole+1) ; 66 ; 9 ; 0 ; 'Layup Bogey' ; _50 >. 50 <. (+/> 1{sh) NB. Layup bogey total
NB. Need to pad out zeros and write individual elements
select. z=. j. / > #each sh
    case. 0j0 do. sz=. _1 _1 _1, _1 _1 _1 _1
    case. 0j1 do. sz=. _1 _1 _1,  1 _1 _1 _1
    case. 1j1 do. sz=.  1 _1 _1,  1 _1 _1 _1
    case. 1j2 do. sz=.  1 _1 _1,  1  1 _1 _1
    case. 2j2 do. sz=.  1  1 _1,  1  1 _1 _1
    case. 2j3 do. sz=.  1  1 _1,  1  1  1 _1
    case. 3j3 do. sz=.  1  1  1,  1  1  1 _1
    case. 3j4 do. sz=.  1  1  1,  1  1  1  1
end.
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 64 ; 5 6 7 ; 0 ; 'Layup Scratch' ; (3{. msk) #inv > 0{sh NB. Layup scratch individual
2 write_xl hole ; tee ; gender ; (hole+1) ; 17 ; 5 6 7 ; 0 ; 'Layup Scratch' ; <(3{. msk) #inv <"0 > 0{sh NB. Layup scratch individual
write_xl hole ; tee ; gender ; (hole+1) ; 66 ; 5 6 7 8 ; 0 ; 'Layup Bogey' ; (_4{. msk) #inv > 1{sh NB. Layup bogey individual
2 write_xl hole ; tee ; gender ; (hole+1) ; 19 ; 5 6 7 8 ; 0 ; 'Layup Bogey' ; <(_4{. msk) #inv <"0 > 1{sh NB. Layup bogey individual
glSSDogleg=: 1 2$ > +/each sh
NB. Layup Type
sh=. 'glPlanLayupCategory' matrix_pull hole ; tee ; gender
sh=. (<glLayupCategoryVal) i. each sh
sh=. sh {each <glLayupCategoryText,<''
ww=. 'L'=each 'glPlanLayupType' matrix_pull hole ; tee ; gender NB. Has to be Layuptype = 'L'
sh=. ww (#inv) each ww # each sh 
write_xl hole ; tee ; gender ; (hole+1) ; 65 ; 5 6 7 ; 0 ; 'Layup Scratch' ; <(3{. msk) #inv > 0{sh NB. Layup reason scratch individual
2 write_xl hole ; tee ; gender ; (hole+1) ; 16 ; 5 6 7 ; 0 ; 'Layup Scratch' ; <(3{. msk) #inv > 0{sh NB. Layup reason scratch individual
write_xl hole ; tee ; gender ; (hole+1) ; 67 ; 5 6 7 8 ; 0 ; 'Layup Bogey' ; <(_4{. msk) #inv > 1{sh NB. Layup reason bogey individual
2 write_xl hole ; tee ; gender ; (hole+1) ; 18 ; 5 6 7 8 ; 0 ; 'Layup Bogey' ; <(_4{. msk) #inv > 1{sh NB. Layup reason bogey individual

sh=. ('L'=each 'glPlanLayupType' matrix_pull hole ; tee ; gender) #each sh
sh=. <>{. each sh
fname fappend~ 'R' write_cell 0 13 ; 3 ; 'Layup Type'
fname fappend~ 'C' write_input 3 13 ; 2 3 ; sh
NB. Layup Reason
sh=. 'glPlanLayupReason' matrix_pull hole ; tee ; gender
sh=. ('L'=each 'glPlanLayupType' matrix_pull hole ; tee ; gender) #each sh
sh=. <>{. each sh
fname fappend~ 'R' write_cell 0 14 ; 3 ; 'Layup Reason'
fname fappend~ 'C' write_input 3 14 ; 2 3 ; sh

NB. ------------------------
NB. Topography
NB. ------------------------
fname fappend~ LF,'// -------- Topography -------------'
alt=. (' ' cut 'glPlanAlt glGrAlt') matrix_pull hole; tee ; gender
alt=. (<glTeAlt),each alt NB. Add tee altitude to front for Par 3
fname fappend~ write_title 0 15 ; 3 1 ; 'TOPOGRAPHY'
alt=. >(-&-/) each _2 {. each alt
NB. If less than 10 feet either way, ignore
alt=. alt * 10 <: |alt
NB. alt=. alt * 3<gender{glTePar
NB. Alt has to be multiples of 10ft, and rounding is incorrect for negatives
alt=. (*alt) * 10 * <. 0.5 + 0.1*(|alt)
NB. For Par 3s, 40 is the maximum
NB. if. (gender{glTePar) = 3 do. alt=. _40 >. alt <. 40 end.
alt=. _40 >. alt <. 40 
fname fappend~ (' ' cut 'cell input') write_row_head 3 15 ; 1.2  0.8 ; 'App S:' ; ;'p<+>' 8!:0 (0{alt)
fname fappend~ (' ' cut 'cell input') write_row_head 5 15 ; 2 1 ; 'App Elev B:' ; ;'p<+>' 8!:0 (1{alt)
write_xl hole ; tee ; gender ; (hole+1) ; 73 ; 6 9 ; 0 ; 'Approach elevation' ; |alt
2 write_xl hole ; tee ; gender ; (hole+1) ; 24 ; 6 9 ; 0 ; 'Approach elevation' ; <boxnonzero alt NB. Absolute value
fname fappend~ 'R' write_cell 0 16 ; 3 ; '<i>(LZtoLZ or Appr)</i>'
ww=. ' ' cut 'LZ1-2 Appr LZ1-2 LZ2-3 Appr'
ww=. (<'<b>'), each ww, each <'</b>'
fname fappend~ 'C' write_cell 3 16 ; 1 ; <ww
NB. Topog Level
fname fappend~ 'R' write_cell 0 17 ; 3 ; '<i><b>(MP/MA/SA/EA)<b></i>'
wid=. }: each 'glPlanTopogStance' matrix_pull hole ; tee ; gender
select. z=. j. / > #each wid
    case. 0j0 do. sz=. 2, 3  
		wid=. (2$,<,<'Par3') NB. Append special value for Par 3
		xl=. 0 1, 0 0 1
    case. 0j1 do. sz=. 2, _1 _1  1 NB. Append special value for Par 3
		wid=. (<,<'Par3'),}.wid NB. Append special value for Par 3
		xl=. 0 1 , 0 0 1
    case. 1j1 do. sz=. _1  1,  _1 _1 1
		    xl=. 0 >. sz
    case. 1j2 do. sz=. _1  1,  1 _1  1
		    xl=. 0 >. sz
    case. 2j2 do. sz=.  1  1 , 1 _1  1
		    xl=. 0 >. sz
    case. 2j3 do. sz=.  1  1 , 1  1  1
		    xl=. 0 >. sz
end.
sh=. wid
wid=. (<glTopogStanceVal,<'Par3') i. each wid
fname fappend~ 'C' write_input 3 17 ; sz ; < (;wid) { glTopogStanceText,<'N/A' NB. Could be Par 3 OR scratch reaches short Par 4
write_xl hole ; tee ; gender ; (hole+1) ; 72 ; 5 ; 0 ; 'Stance' ; <xl #inv (;wid) { glTopogStanceXL,<'PAR3'
2 write_xl hole ; tee ; gender ; (hole+1) ; 23 ; 5 ; 0 ; 'Stance' ; <xl #inv (;wid) { glTopogStanceVal,<'PAR3'
fname fappend~ 'R' write_cell 0 18 ; 3 ; 'Table Value'
wid=. lookup_topog_rating alt ; <sh
fname fappend~ 'C' write_calc  3 18 ; sz ; (;wid) 
fname fappend~ 'R' write_cell 0 19 ; 3 ; 'Total Shot Value'
fname fappend~ 'C' write_calc  3 19 ; sz ; (;wid) 
fname fappend~ 'R' write_cell 0 20 ; 3 ; 'Highest Shot Value'
fname fappend~ 'C' write_calc  3 20 ; 2 3 ; (0 >. ;>. / each wid) 
fname fappend~ 'R' write_footer 0 21 ; 3 ; 'Topography'
wid=. 1 2$(0 >. ;>. / each wid)
fname fappend~ 'C' write_footer 3 21 ;  2 3 ; wid
psych=. psych, wid
write_xl hole ; tee ; gender ; (hole+1) ; 77 ; 5 7 ; 0 ; 'Topography' ; wid  NB. Topography

NB. ------------------------
NB. Green Target
NB. ------------------------
fname fappend~ LF,'// -------- Green Target -------------'
fname fappend~ write_title 0 34 ; 3 1 ; '<b>GREEN TARGET</b>' 
fname fappend~ (' ' cut 'cell input') write_row_head 3 34 ; 0.80 0.45 ; 'Circ:' ; <glGrCircleConcept{'ny'
fname fappend~ (' ' cut 'cell input') write_row_head 4.25 34 ; 0.60 0.65 ; 'W:' ; glGrWidth
fname fappend~ (' ' cut 'cell input') write_row_head 5.50 34 ; 0.60 0.65 ; 'L:' ; glGrLength
fname fappend~ (' ' cut 'cell input') write_row_head 6.75 34 ; 0.60 0.65 ; 'Di:' ; glGrDiam
write_xl hole ; tee ; gender ; (hole+1) ; 90 ; 6 8 9 ; 0 ; 'Green dimensions' ; glGrWidth, glGrLength, glGrDiam 
write_xl hole ; tee ; gender ; (hole+1) ; 91 ; 7 ; 0 ; 'Green circle' ; glGrCircleConcept{'NY'
2 write_xl hole ; tee ; gender ; 'Greens Data' ; 7 ; (4+2*hole) ; 0 ; 'Green width' ; glGrWidth
2 write_xl hole ; tee ; gender ; 'Greens Data' ; 8 ; (4+2*hole) ; 0 ; 'Green depth' ; glGrLength
2 write_xl hole ; tee ; gender ; 'Greens Data' ; 9 ; (4+2*hole) ; 0 ; 'Green diameter if circle' ; glGrCircleConcept { '' ; ":glGrDiam
greenval=. >_1 { each hityards
greenval=. lookup_green_target gender ; greenval ; (''$glGrDiam) ; transition
fname fappend~ 'R' write_cell 0 35 ; 3 ; <<'Table Value'
fname fappend~ write_calc 3 35 ; 2.5 2.5 ; greenval
fwtot=. greenval
NB. Transition adjustment
adj=. 'glPlanTransitionAdj' matrix_pull hole ; tee ; gender NB. Tranistion adjustment
adj=. (<glTransitionAdjVal) i. each adj
adj=. adj { each <glTransitionAdjNum
adj=. > +/ each adj
fname fappend~ write_row_head 0 36 ; 2.5 0.5 ; ' ' cut '<i>Adjust</i> <b></b>'
fname fappend~ write_input 3 36 ; 2.5 2.5 ; adj
greenval=. greenval + adj
write_xl hole ; tee ; gender ; (hole+1) ; 93 ; 5 7 ; 0 ; 'Transition adjustment' ; adj
2 write_xl hole ; tee ; gender ; (hole+1) ; 37 ; 5 7 ; 0 ; 'Transition adjustment' ; adj
NB. Visibility
fname fappend~ write_row_head 0 37 ; 2.5 0.5 ; ' ' cut '<i>Visibility</i> <b>V</b>'
fname fappend~ write_input 3 37 ; 2.5 2.5 ; > _1 { each targvisible
write_xl hole ; tee ; gender ; (hole+1) ; 94 ; 5 7 ; 0 ; 'Green target visibility' ;  > _1 { each targvisible
2 write_xl hole ; tee ; gender ; (hole+1) ; 38 ; 5 7 ; 0 ; 'Green target visibility' ; <boxnonzero > _1 { each targvisible
greenval=. greenval + > _1 { each targvisible
NB. Target obstructed
treeobs=. ('glPlanTreeLZObstructed') matrix_pull hole ; tee ; gender NB. Shot TO landing zone
treeobs=. treeobs +.each }:each (<0),each ('glPlanTreeTargObstructed') matrix_pull hole ; tee ; gender NB. OR shot FROM LZ, shifted
fw=. ; _1 { each treeobs
fname fappend~ write_row_head 0 38 ; 2.5 0.5 ; ' ' cut '<i>Obstructed</i> <b>O</b>'
fname fappend~ write_input 3 38 ; 2.5 2.5 ; fw
greenval=. greenval + fw
NB. Tiered green
fname fappend~ write_row_head 0 39 ; 2.5 0.5 ; ' ' cut '<i>Tiered</i> <b>T</b>'
fname fappend~ write_input 3 39 ; 2.5 2.5 ; 2$glGrTiered
greenval=. greenval + 2$glGrTiered
fw=. (glGrFirmnessVal i. glGrFirmness){glGrFirmnessNum
fname fappend~ write_row_head 0 40 ; 2.5 0.5 ; ' ' cut '<i>Firmness</i> <b>F</b>'
fname fappend~ write_input 3 40 ; 2.5 2.5 ; 2$fw
greenval=. greenval + 2$fw
greenval=. 10 <. greenval NB. Can't be bigger than 10
fname fappend~ 'R' write_footer 0 41 ; 3 ; 'Green Target'
fname fappend~ 'C' write_footer 3 41 ;  2.5 2.5 ; greenval
psych=. psych, greenval
write_xl hole ; tee ; gender ; (hole+1) ; 98 ; 5 7 ; 0 ; 'Green Target' ; greenval  NB. Topography

NB. ------------------------
NB. Type of Course
NB. ------------------------
fname fappend~ LF,'// -------- Type of Course -------------'
fname fappend~ write_title 0 42 ; 3 1 ; '<b>TYPE OF COURSE</b>' 
fname fappend~ write_input 3 42 ; 15 ; <<glCourseType
fname fappend~ write_title 0 43 ; 3 1 ; '<b>EXPOSURE</b>' 
fname fappend~ write_input 3 43 ; 8 ; glCourseExposure
fname fappend~ write_cell 11 43 ; 17 ; <<'(Form <b>MUST</b> be used in conjuction with USGA Course Rating System Guide)'
write_xl hole ; tee ; gender ; 'Information' ; 22 ; 5 ; 0 ; 'Exposure' ; glCourseExposure  NB. Wind Exposure
glSSWind=: ,glCourseExposure

NB. ------------------------
NB. Check distances to front of green
NB. -------------------------
fname fappend~ ('L';0) write_cell 0 45 ; 2 ; 'Check dist:'
dist=. glGrFrontYards + -/(<(glTees i. tee ,glGrTee); hole){glTeesYards
fname fappend~ ('C';0) write_input 2 45 ; 1 ; dist
fname fappend~ ('L';0) write_cell 3 45 ; 1 ; '+0.5x'
fname fappend~ ('L';0) write_calc 4 45 ; 1 ; glGrLength
fname fappend~ ('C';0) write_cell 5 45 ; 0.5 ; '='
fname fappend~ ('L';0) write_calc 5.5 45 ; 1 ; <.0.5 + (+/1 0.5 * dist,glGrLength)
fname fappend~ ('C';0) write_cell 5 46 ; 0.5 ; 'vs'
fname fappend~ ('L';0) write_cell 5.5 46 ; 1 ; (<t_index,hole){glTeesYards

NB. ------------------------
NB. Notes
NB. -------------------------
fname fappend~ ('L';0) write_cell 8 46 ; 2 ;  'Notes:'
fname fappend~ ('L';0) write_input 9.5 46 ; 18.5 ;('''' ; '&#39;' ; '"' ; '&#34;' ; '<' ; '&lt;' ; '>' ; '&gt;') stringreplace  (;glGrNotes)
2 write_xl hole ; tee ; gender ; (hole+1) ; 44 ; 7 ; 0 ; 'Notes' ; ( '"' ; '""' ) stringreplace  (;glGrNotes)


NB. ------------------------
NB. Water
NB. ------------------------
NB. Need to do before R&R as there is a dependency
fname fappend~ LF,'// -------- Water -------------'
carryyards=. 'W' carry_yards hole; tee ; gender 
waterdist=. ('glPlanLatWaterDist' ; 'glGrWaterDist') matrix_pull hole ; tee ; gender
fname fappend~ write_title 18 1 ; 3 1 ; '<b>WATER</b>' 
ww=. ' ' cut 'S1 S2 S3 B1 B2 B3 B4'
ww=. (<'<b>'), each ww, each (<'</b>')
fname fappend~ 'C' write_cell 21 1; (7$1) ; <ww
select. z=. j. / > #each waterdist
    case. 0j0 do. sz=. _1 _1 _1, _1 _1 _1 _1
    case. 0j1 do. sz=. _1 _1 _1,  1 _1 _1 _1
    case. 1j1 do. sz=.  1 _1 _1,  1 _1 _1 _1
    case. 1j2 do. sz=.  1 _1 _1,  1  1 _1 _1
    case. 2j2 do. sz=.  1  1 _1,  1  1 _1 _1
    case. 2j3 do. sz=.  1  1 _1,  1  1  1 _1
    case. 3j3 do. sz=.  1  1  1,  1  1  1 _1
    case. 3j4 do. sz=.  1  1  1,  1  1  1  1
end.
fname fappend~ 'R' write_cell 18 2 ; 3 ; '<i>Centre LZ to Lateral</i>' 
fname fappend~ write_input 21 2 ; sz ; (;waterdist)
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 53 ; 30 32 34 36 38 40 42 ; 0 ; 'Water distance' ; <msk #inv boxnonzero  ;waterdist
msk=. (<_1 )+each #each waterdist NB. remove last one
msk=. ; (3;4) {. each msk $ each <1
2 write_xl hole ; tee ; gender ; (hole+1) ; 6 ; 30 32 34 36 38 40 42 ; 0 ; 'Water distance input' ; <msk #inv boxnonzero ;}: each waterdist NB. Drop last one
fname fappend~ 'R' write_cell 18 4 ; 3 ; '<i>Yds to Carry Safely</i>' 
fname fappend~ write_input 21 4 ; sz ; (;carryyards)
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 59 ; 30 32 34 36 38 40 42 ; 0 ; 'Water carry' ; <msk #inv boxnonzero  (;carryyards)
2 write_xl hole ; tee ; gender ; (hole+1) ; 9 ; 30 32 34 36 38 40 42 ; 0 ; 'Water carry input' ; <msk #inv boxnonzero  (;carryyards) NB. Don't drop last one on carry
fname fappend~ 'R' write_cell 18 5 ; 3 ; 'Table Value'
watlat=. lookup_lateral_water gender ; hityards ; <waterdist
tvexists=. watlat >each 0
NB. Behind adjustment for lateral only
fname fappend~ write_row_head 18 3 ; 2.5 0.5 ; '<i>Behind</i>' ; ''
behind=. (' ' cut 'glPlanLayupReason glGrWaterBehind') matrix_pull hole ; tee ; gender
behind=. (<glWaterBehindVal) i. each behind
fw=. behind { each <glWaterBehindNum,0
fname fappend~ 'C' write_input 21 3 ; sz ; <'b' 8!:0 ;fw 
watlat=. 0 >. each watlat + each fw
fname fappend~ 'L' write_calc 21 5 ; sz ; <('bp' 8!:0 ;watlat)
NB. Water carry
watcarry=. lookup_carry_water gender ; <carryyards
fname fappend~ 'R' write_calc 21 5 ; sz ; <('bp' 8!:0 ;watcarry)
fwtot=. watlat >. each watcarry
waterexists=.  +. / 0< ; fwtot NB. Either scratch or bogey
for_i. i. 7 do. 
	if. _1 ~: i{sz do. fname fappend~ pdfDiag ((21.33+i), 5) ; 0.33 1  end.
end.
NB. Cart Path Tilt (not yet implemented)
fname fappend~ write_row_head 18 6 ; 2.0 1.0 ; '<i>Cart Path</i>' ; '<b>+B</b>'
fw=. 0 * each carryyards NB. Temporarily set to zero
fname fappend~ 'C' write_input 21 6 ; sz ; ;fw 
NB. Cart Path Prevent (not yet implemented)
fname fappend~ write_row_head 18 7 ; 2.0 1.0 ; '<i>Prevent</i>' ; '<b>-B</b>'
fw=. 0 * each carryyards NB. Temporarily set to zero
fname fappend~ 'C' write_input 21 7 ; sz ; ;fw 
NB. Percent reduction
fname fappend~ write_row_head 18 8 ; 2.5 0.5 ; '<i>Percent</i>' ; '<b>P</b>'
percent=. (' ' cut 'glPlanWaterPercent glGrWaterPercent') matrix_pull hole ; tee ; gender
percent=. (<glWaterPercentVal) i. each percent
fw=. (;percent) { glWaterPercentDesc
fname fappend~ 'C' write_input 21 8 ; sz ; <fw 
msk=. sz >: 0
write_xl hole ; tee ; gender ; (hole+1) ; 64 ; 30 32 34 36 38 40 42 ; 0 ; 'Water Percentage' ; msk #inv 100 * (;percent) { glWaterPercentNum
2 write_xl hole ; tee ; gender ; (hole+1) ; 13 ; 30 32 34 36 38 40 42 ; 0 ; 'Water Percentage' ; <boxnonzero msk #inv 100 * (;percent) { glWaterPercentNum
fw=. (percent) { each <glWaterPercentNum NB. Round the reduction, not the remaining.  Wrong IMHO.
fw=. <. each (<0.5) + each fwtot * each fw 
fwtot=. fwtot - each fw
fwtot=. fwtot >. each tvexists NB. In case reductions have taken it to zero
NB. Jeopardy (not yet implemented)
fname fappend~ write_row_head 18 9 ; 2.0 1.0 ; '<i>Jeopardy</i>' ; '<b>J</b>'
fw=. 0 * each carryyards NB. Temporarily set to zero
fname fappend~ 'C' write_input 21 9 ; sz ; ;fw 
NB. Squeeze (not yet implemented)
fname fappend~ write_row_head 18 10 ; 2.0 1.0 ; '<i>Squeeze</i>' ; '<b>Q</b>'
fw=. 0 * each carryyards NB. Temporarily set to zero
fname fappend~ 'C' write_input 21 10 ; sz ; ;fw 
NB. Two Ways
NB. Only apply if both original values and the adjusted value is >=5
fw=. (<5) <: each fwtot
fw=. fw *. each (<5) <: each watlat
fw=. fw *. each (<5) <: each watcarry
fname fappend~ write_row_head 18 11 ; 2.5 0.5 ; '<i>Two Ways</i>' ; '<b>Y</b>'
fname fappend~ 'C' write_calc 21 11 ; sz ; <'b<>' 8!:0 ;fw
fwtot=. fwtot + each fw
NB. Water Surround
rr=. (glWaterFractionVal i. glGrWaterFraction)
cc=. (glWaterSurrDistVal i. glGrWaterSurrDist)
fname fappend~ 'C' write_input 18 12; 1.25 ;  <rr{glWaterFractionText
fname fappend~ 'C' write_input 19.25 12; 1.25 ;  <cc{glWaterSurrDistText
fname fappend~ 'R' write_cell 20.5 12 ; 0.5 ; '<b>S</b>'
fw=. lookup_water_surround (rr{glWaterFractionNum) ; (cc{glWaterSurrDistNum) ; greenval ; <hityards
watersurr=. fw
fname fappend~ write_calc 21 12; sz ; <'b<>' 8!:0 (;fw)
fwtot=. fwtot +each fw
fname fappend~ 'R' write_cell 18 13 ; 3 ; 'Total Shot Value'
fname fappend~ write_calc 21 13 ; sz ; <'b<>' 8!:0 (;fwtot)
NB. Calculate in play twice adjustment
wattwice=. fwtot * each (<5) <: each fwtot NB. Add up values greater than or equal to 5
wattwice=. wattwice *each (<2) <: each +/ each (<0) < each wattwice NB. Has to be at least two entries
wattwice=. (; +/ each wattwice)
wattwice=. (wattwice>0) + wattwice > 11
fname fappend~ 'R' write_cell 18 14 ; 3 ; 'Highest Shot Value'
fwtot=. ; >. / each fwtot NB. Max value
fname fappend~ write_calc 21 14 ; 3 4 ; (fwtot)
NB. In Play Twice
fname fappend~ write_row_head 18 15 ; 2.5 0.5 ; '<i>In Play Twice</i>' ; '2'
fname fappend~ 'C' write_calc 21 15 ; 3 4 ; (;wattwice)
fwtot=. fwtot + wattwice
NB. Water anywhere
fname fappend~ 'L' write_cell 18 16 ; 3 ; '<i>On Line of Play</i>' 
waterline=. 'glPlanWaterLine' matrix_pull hole ; tee ; gender
waterline=. ; +. / each waterline
waterline=. waterline >. waterexists NB. Override if not entered as LOP
fname fappend~ 'C' write_input 21 16 ;  3 4  ; <<"0 (;waterline){' y'
2 write_xl hole ; tee ; gender ; (hole+1) ; 18; 34 ; 0 ; 'Water LoP Scratch' ; <(0{waterline) { (<'') ; 'Y'
2 write_xl hole ; tee ; gender ; (hole+1) ; 19; 34 ; 0 ; 'Water LoP Bogey' ; <(1{waterline) { (<'') ; 'Y'
NB. Overall rating
fname fappend~ 'R' write_footer 18 17 ; 3 ; 'Water Rating'
fwtot=. fwtot + (0=fwtot) * +. / ; waterline NB. Minimum of 1 if water exists
fname fappend~ 'C' write_footer 21 17 ;  3 4; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 79 ; 30 36 ; 0 ; 'Water' ; fwtot  NB. Water

NB. ------------------------
NB. Recoverability and Rough
NB. ------------------------
fname fappend~ LF,'// -------- Recoverability and Rough -------------'
carryyards=. 'F' carry_yards hole; tee ; gender 
fname fappend~ write_title 8 1 ; 3 1 ; '<b>RECOV & ROUGH</b>' 
fname fappend~ ('cell' ; 'input') write_row_head 11 1 ; 5 2 ; '<i>Average Hole Rough Height:</i>' ; (":glGrRRRoughLength),'&quot;'
NB. XL has a range
ww=. (+/(''$glGrRRRoughLength) >: 1.5 2 3.001 ){':' cut '< 1.5:< 2.0:2.0 to 3.0:> 3.0 to 3.75'
if. 0=0{;carryyards do. ww=.0 end. NB. Special case if no carry
write_xl hole ; tee ; gender ; (hole+1) ; 58 ; 19 ; 0 ; 'Rough length' ; ww NB. Rough Length 
fname fappend~ write_cell 8 2 ; 3 ; <<' '
ww=. ' ' cut 'S1 S2 S3 B1 B2 B3 B4'
ww=. (<'<b>'), each ww, each (<'</b>')
fname fappend~ 'C' write_cell 11 2; (7$1) ; <ww
fname fappend~ 'R' write_cell 8 3; 3 ; <<'Table Value'
fwtot=. lookup_recoverability gender ; greenval ; glGrRRRoughLength
fname fappend~ write_calc 11 3 ; 3 4 ; fwtot
NB. Fairway Layup
fname fappend~ write_row_head 8 4 ; 2.5 0.5; '<i>Lay-up</i>'; '<b>L</b>'
lay=. - each 'L' =each 'glPlanLayupType' matrix_pull hole ; tee ; gender NB. -1 if Layup
fname fappend~ 'C' write_input 11 4 ; sz ; (;lay)
fwtot=. fwtot + > +/each lay
NB. Inconsistent
fname fappend~ write_row_head 8 5 ; 2.5 0.5 ; '<i>Inconsistent</i>' ; '<b>I</b>'
fw=. 0 * each lay NB. Temporarily set to zero
fname fappend~ 'C' write_input 11 5 ; sz ; ;fw 
NB. Mounds
fname fappend~ write_row_head 8 6 ; 2.5 0.5; '<i>Mounds</i>'; '<b>M</b>'
lay=. ('glPlanRRMounds' ; 'glGrRRMounds') matrix_pull hole ; tee ; gender 
fname fappend~ 'C' write_input 11 6 ; sz ; (;lay)
write_xl hole ; tee ; gender ; (hole+1) ; 56 ; 13 15 17 19 21 23 25 ; 0 ; 'R&R Mounds' ; ; (3;4) {. each lay
2 write_xl hole ; tee ; gender ; (hole+1) ; 7 ; 13 15 17 19 21 23 25 ; 0 ; 'R&R Mounds' ; ; (3;4) {. each }: each lay
fwtot=. fwtot + > +/each lay
NB. Carry
fname fappend~ ('cell' ; 'input') write_row_head 8 7 ; 0.55 0.7 ; '<i>Y</i>' ; ":0{>0{carryyards
fname fappend~ ('cell' ; 'input') write_row_head 9.25 7 ; 0.5 0.75 ; '<i>H</i>'; (":glGrRRRoughLength),'&quot;' 
write_xl hole ; tee ; gender ; (hole+1) ; 57 ; 19 ; 0 ; 'Fairway carry yards' ; 0{;carryyards
2 write_xl hole ; tee ; gender ; (hole+1) ; 8 ; 19 ; 0 ; 'Fairway carry yards' ; (0 ~: 0{;carryyards){'' ; 0{;carryyards
lay=. lookup_carry_rough gender ; carryyards ; glGrRRRoughLength
fname fappend~ 'R' write_cell 10.5 7 ; 0.5 ; '<b>C</b>'
fname fappend~ 'C' write_calc 11 7 ; (_1 _1 _1, 1 _1 _1 _1) ; <'b<>' 8!:0 {. ; 1{lay NB. Only pull out Bogey Value, and the first one
fwtot=. fwtot + ; >. /each lay
NB. Sub-Total
fname fappend~ 'R' write_cell 8 8 ; 3 ; 'Sum of <b><u>all</u></b> Values'
fname fappend~ write_calc 11 8 ; 3 4 ; fwtot
NB. Rise & Drop
lay=. ''$(glRRRiseDropVal i. glGrRRRiseDrop){glRRRiseDropNum
fname fappend~ write_input 8  9 ; 1.25 ; <(*lay ){':' cut 'Frac:&gt;&frac12;'
fname fappend~ write_input 9.25  9 ; 1.25 ; <lay {':' cut 'Ft:5&#39;-10&#39;:&gt;10&#39;'
fname fappend~ write_cell 10.5  9 ; 0.5 ; <<'<b>R</b>'
fname fappend~ write_calc 11  9 ; 3 4 ; 2$lay
write_xl hole ; tee ; gender ; (hole+1) ; 61 ; 13 19 ; 0 ; 'R&R: Rise & Drop' ; <boxnonzero 2$lay
fwtot=. fwtot + lay
NB. Unpleasant
fname fappend~ write_row_head 8 10 ; 2.5 0.5; '<i>Unpleasant</i>'; '<b>U</b>'
lay=. >+. / each (' ' cut 'glPlanRRUnpleasant glGrRRUnpleasant') matrix_pull hole ; tee ; gender 
fname fappend~ 'C' write_input 11 10 ; 3 4 ; (;lay)
fwtot=. fwtot + lay
NB. Calculate in play twice adjustment
twice=. 2$ glGrRRRoughLength > 4 NB. Has to be at least 4 inches long
twice=. twice *. (>#each hityards) >: 2 NB. Has to apply at least twice
twice=. twice *. (2 <: ; +/each 30 >: each }: each fairwaywidth ) NB. At least two points have to be within 30 yards (arbitrary)
fname fappend~ write_row_head 8 11 ; 2.5 0.5; '<i>Twice</i>'; '<b>2</b>'
fname fappend~ 'C' write_input 11 11 ; 3 4 ; twice
fwtot=. fwtot + twice
NB. Par 3 Bogey can't reach
width=. }: each 'glPlanFWWidth' matrix_pull hole ; tee ; gender
z=. j. / > #each width NB. later will check it is 0j1
fname fappend~ write_row_head 8 12 ; 2.5 0.5; '<i>Bgy not reach P3</i>'; '<b>3</b>'
width=.  _1 { ; {: each width
fname fappend~ ('cell' ; 'input') write_row_head 11 12 ; 5 1 ; '<b>LZ cut to FW height</b>' ; (z=0j1) * (3=(<0,gender){glTePar) * width
width=. (z=0j1) * (3=(<0,gender){glTePar) * (width < 20) { 1 2 NB. Zero if not par 3
fname fappend~ write_input 17 12 ; 1 ; width
fwtot=. fwtot + 0,width
NB. Surround
lay=. >(>./ each watersurr)
lay=. ( 2 3 i. lay){1 2 0
fname fappend~ write_row_head 8 13 ; 2.5 0.5 ; '<i>Surr&#39;d (Water)</i>' ; '<b>S</b>'
fname fappend~ write_input 11 13 ; 3 4 ; lay
fwtot=. fwtot + lay
NB. Total
fname fappend~ 'R' write_footer 8 14 ; 3 ; 'Recov & R Rating'
fname fappend~ 'C' write_footer 11 14 ;  3 4 ; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 67 ; 13 19  ; 0 ; 'Recov & Rough' ; fwtot  NB. Recoverability and Rough

NB. ----------------------------------------
NB. Bunkers
NB. ----------------------------------------
fname fappend~ LF,'// -------- Bunkers -------------'
carryyards=. 'B' carry_yards hole; tee ; gender 
fname fappend~ write_title 8 15 ; 3 1 ; '<b>BUNKERS</b>'
fname fappend~ write_cell 8 16 ; 1.5 ; 'Gr Prot:' 
fname fappend~ write_input 9.5 16 ;  1.5  ; <(glBunkFractionVal i. glGrBunkFraction){glBunkFractionText
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
ww=. ' ' cut 'S1 S2 S3 B1 B2 B3 B4'
for_i. ww do.
    fname fappend~ LF,'$pdf->',pdfMulti ((11+i_index),15) ; 1 1 ; ('<span style="text-align: center"><b>',( > i),'</b></span>') ; 1  
end. 
NB. Table Value
lay=. lookup_bunker_rating greenval ; (glBunkFractionVal i. glGrBunkFraction){glBunkFractionNum
greenval=. lay
fname fappend~ write_calc  11 16 ; 3 4 ; lay
fwtot=. lay
NB. Bunker squeeze
fname fappend~ write_row_head 8 17 ; 2.5 0.5; '<i>Squeeze</i>'; '<b>Q</b>'
sq=. 'glPlanBunkSqueeze' matrix_pull hole ; tee ; gender
sq=. ((<glBunkSqueezeVal) i. each sq) { each <glBunkSqueezeNum
fname fappend~ write_input 11 17 ; sz ; (;sq)
fwtot=. fwtot + ; +/each sq
select. z=. j. / > #each }: each sq NB. Drop last items
    case. 0j0 do. ssz=. 0 0 , 0 0 0
    case. 0j1 do. ssz=. 0 0 , 1 0 0
    case. 1j1 do. ssz=. 1 0 , 1 0 0
    case. 1j2 do. ssz=. 1 0 , 1 1 0 
    case. 2j2 do. ssz=. 1 1 , 1 1 0
    case. 2j3 do. ssz=. 1 1 , 1 1 1
end.
write_xl hole ; tee ; gender ; (hole+1) ; 72 ; 13 15 19 21 23  ; 0 ; 'Bunker squeeze' ; ssz #inv ;}: each sq NB. Drop last item
sq=.;  }: each sq
msk=. sq > 0
2 write_xl hole ; tee ; gender ; (hole+1) ; 17 ; 13 15 19 21 23  ; 0 ; 'Bunker squeeze' ; <ssz #inv msk #inv <"0 msk # sq
NB. Carry
bunkcarry=. ('glPlanBunkLZCarry') matrix_pull hole ; tee ; gender NB. Shot TO landing zone
bunkcarry=. bunkcarry +.each }:each (<0),each ('glPlanBunkTargCarry') matrix_pull hole ; tee ; gender NB. OR shot FROM LZ, shifted
NB. Bunker carry scratch must be table value 5 or greater
bunkcarry=. bunkcarry * each  ((-$>0{bunkcarry){.1 1 1 1,(0{greenval)>:5);(($>1{bunkcarry)$1)
fname fappend~ write_row_head 8 18 ; 2.5 0.5 ; '<i>Carry</i>' ; '<b>C</b>'
fname fappend~ 'L' write_input 11 18 ; sz ; (;carryyards)
fname fappend~ 'R' write_input 11 18 ; sz ; (;bunkcarry) 
for_i. i. 7 do. 
	if. _1 ~: i{sz do. fname fappend~ pdfDiag ((11.33+i), 18) ; 0.33 1  end. NB. Diagonal line
end.
fwtot=. fwtot + ; +/ each bunkcarry
msk=. (<_1 )+each #each bunkcarry NB. remove last one
msk=. ; (2;4) {. each msk $ each <1
write_xl hole ; tee ; gender ; (hole+1) ; 73 ; 13 15 19 21 23 25 ; 0 ; 'Bunker carry' ; msk #inv ;}: each bunkcarry NB. Drop the last one
2 write_xl hole ; tee ; gender ; (hole+1) ; 18 ; 13 15 19 21 23 25 ; 0 ; 'Bunker carry input' ; <msk #inv boxnonzero  ;}: each bunkcarry NB. Drop last one
write_xl hole ; tee ; gender ; (hole+1) ; 74 ; 13 19 ; 0 ; 'Bunker carry green' ; ;{: each bunkcarry NB. Just the last one
2 write_xl hole ; tee ; gender ; (hole+1) ; 19 ; 13 19 ; 0 ; 'Bunker carry green input' ; <boxnonzero ;{: each bunkcarry NB. Just the last one
NB. Extreme (not yet implemented)
fname fappend~ write_row_head 8 19 ; 2.5 0.5; '<i>Extreme</i>'; '<b>E</b>'
fw=. ('glPlanBunkExtreme' ; 'glGrBunkExtreme') matrix_pull hole ; tee ; gender
fw=. ( <glBunkExtremeVal ) i. each fw
fw=. fw { each <glBunkExtremeNum
fname fappend~ write_input 11 19 ; sz ; (;fw)
fwtot=. fwtot + ;+/each fw
NB. Sub-Total
fname fappend~ 'R' write_cell 8 20 ; 3 ; <<'Sum of <b><u>all</u></b> Values'
fname fappend~ write_calc  11 20 ; 3 4 ; fwtot
NB. Landing Zones, need all for LoP variable, including shot to green on Par 3
lz=. }: each 'glPlanBunkLZ' matrix_pull hole ; tee ; gender
lop=. }: each 'glPlanBunkLine' matrix_pull hole ; tee ; gender
lzfull=. 'glPlanBunkLZ' matrix_pull hole ; tee ; gender
lopfull=. 'glPlanBunkLine' matrix_pull hole ; tee ; gender
fname fappend~ write_cell 8 21 ; 0.5 ; <<'S'
fname fappend~ 'C' write_input 8.3571 21 ; (2{.((#>0{lz)$0.3571),2$_0.3571) ; <<"0 (>0{lz){' y'
fname fappend~ write_cell 9.0713 21 ; 0.5 ; <<'B'
fname fappend~ 'C' write_input 9.4284 21 ; (3{.((#>1{lz)$0.3571),3$_0.3571) ; <<"0 (>1{lz){' y'
msk=. #each lz 
msk=. ; (2;3) {. each msk $ each <1
2 write_xl hole ; tee ; gender ; (hole+1) ; 21 ; 13 15 19 21 23 ; 0 ; 'Bunker in LZ input' ; <(msk #inv ;lz) { '' ; 'Y'
fname fappend~ write_cell 8 22 ; 2 ; <<'Bog Ln/Play'
fname fappend~ write_input 10 22 ; 0.5 ; (+. / >1{lopfull){' y'
msk=. #>1{lopfull 
msk=.  4 {. msk $ 1
2 write_xl hole ; tee ; gender ; (hole+1) ; 22 ; 19 21 23  25 ; 0 ; 'Bunker in bogey LOP input' ; <(msk #inv >1{lopfull) { '' ; 'Y'
fname fappend~ 'black' oN 'white'
fname fappend~ LF,'$pdf->',pdfMulti 10.5 21 ; 0.5 2 ; ('<b>N</b>') ; 1
NB. Calculate Negative adjustment
greensideexists=. 0<fwtot NB. Is there a positive score
fw=. ((+. / >0{lz) {_1 0 ), ((+. / (>1{lz),(>1{lopfull)){_1 0) 
fw=. _1 >. fw - 0=># each lz NB. Par 3
fw=. fw * 0 ~: fwtot NB. Don't apply -1 adjustment if no bunkers at all
fname fappend~ 'blue' oN 'white'
fname fappend~ LF,'$pdf->',pdfMulti 11 21 ; 3 2 ;  ('<span style="text-align: center">',(;(8!:0) 0{fw),'</span>') ; 1
fname fappend~ LF,'$pdf->',pdfMulti 14 21 ; 4 2 ;  ('<span style="text-align: center">',(;(8!:0) 1{fw),'</span>') ; 1
fwtot=. fwtot + fw
NB. Greenside depth
fname fappend~ write_cell 8 23 ; 1.2 ; <<'Depth' 
fname fappend~ write_input 9.2 23 ; 1.3; <(glBunkDepthVal i. glGrBunkDepth){glBunkDepthText
fname fappend~ write_cell 10.5 23 ; 0.5 ; <<'<b>D</b>'
fw=. lookup_bunker_depth gender ; ''$(glBunkDepthVal i. glGrBunkDepth){glBunkDepthNum 
fname fappend~ write_calc  11 23 ; 3 4 ; 2$fw
fwtot=. fwtot + fw
NB. In play twice
fname fappend~ write_row_head 8 24 ; 2.5 0.5 ; '<i>Twice</i>' ; '<b>2</b>'
fw=. 1< ; +/each lz NB. Must be at least two fairway bunkers in LZ
fname fappend~ write_calc  11 24 ; 3 4 ; fw
fwtot=. fwtot + fw
NB. Does bunker exist for Scratch
fname fappend~ write_row_head 8 25 ; 2.9 0.1 ; '<i>Scratch LoP</i>' ; ''
fw=. 1< ; +/each lz NB. Must be at least two fairway bunkers in LZ
fname fappend~ write_calc  11 25 ; 3 _4 ;  (+. / ;(0{lz),0{lopfull) # 'y'
2 write_xl hole ; tee ; gender ; (hole+1) ; 23 ; 17 ; 0 ; 'Bunker in scratch LOP input' ; (+. / ;(0{lz),0{lopfull) { '' ; 'Y'
NB. Total
fwtot=. fwtot >. ; +./ each lz,each lopfull NB. Must be a minimum of one if it exists
fwtot=. fwtot >. greensideexists
fname fappend~ 'R' write_footer 8 26 ; 3 ; <<'Bunker Rating'
fname fappend~ 'C' write_footer 11 26 ;  3 4 ; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 81 ; 13 19  ; 0 ; 'Bunkers' ; fwtot  NB. Bunkers

NB. ------------------------
NB. OOB / Extreme Rough
NB. ------------------------
fname fappend~ LF,'// -------- OOB / Extreme Rough -------------'
carryyards=. 'R' carry_yards hole; tee ; gender 
oobdist=. (' ' cut 'glPlanOOBDist glGrOOBDist') matrix_pull hole ; tee ; gender
fname fappend~ write_title 8 27 ; 3 1 ; '<b>OUT of BOUNDS / ER</b>' 
ww=. ' ' cut 'S1 S2 S3 B1 B2 B3 B4'
ww=. (<'<b>'), each ww, each (<'</b>')
fname fappend~ 'C' write_cell 11 27 ; (7$1) ; <ww
select. z=. j. / > #each carryyards
    case. 0j0 do. sz=. _1 _1 _1, _1 _1 _1 _1
    case. 0j1 do. sz=. _1 _1 _1,  1 _1 _1 _1
    case. 1j1 do. sz=.  1 _1 _1,  1 _1 _1 _1
    case. 1j2 do. sz=.  1 _1 _1,  1  1 _1 _1
    case. 2j2 do. sz=.  1  1 _1,  1  1 _1 _1
    case. 2j3 do. sz=.  1  1 _1,  1  1  1 _1
    case. 3j3 do. sz=.  1  1  1,  1  1  1 _1
    case. 3j4 do. sz=.  1  1  1,  1  1  1  1
end.
NB. Distance from landing zone
fname fappend~ 'R' write_cell 8 28 ; 3 ; '<i>Centre LZ to OOB/ER</i>' 
fname fappend~ write_input 11 28 ; sz ; (;oobdist)
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 85 ; 13 15 17 19 21 23 25 ; 0 ; 'OOB distance' ; <msk #inv boxnonzero  ;oobdist
msk=. (<_1 )+each #each oobdist NB. remove last one
msk=. ; (3;4) {. each msk $ each <1
2 write_xl hole ; tee ; gender ; (hole+1) ; 28 ; 13 15 17 19 21 23 25 ; 0 ; 'OOB distance' ; <msk #inv boxnonzero  ;}: each oobdist NB. Drop last one
NB. Behind only applies to lateral distance
fname fappend~ write_row_head 8 29 ; 2.5 0.5 ; '<i>Behind</i>' ; ''
fwtot=. lookup_oob gender ; hityards ; <oobdist
ooblat=. fwtot
behind=. (' ' cut 'glPlanLayupReason glGrOOBBehind') matrix_pull hole ; tee ; gender
behind=. (<glOOBBehindVal) i. each behind
behind=. behind { each <glOOBBehindNum,0
fname fappend~ 'C' write_input 11 29 ; sz ; <'b' 8!:0 ; behind
fwtot=. 0 >. each fwtot + each behind NB. Must be at least zero
tvexists=. ooblat >each 0
NB. Distance to carry safely
fname fappend~ 'R' write_cell 8 30 ; 3 ; '<i>Yds to Carry Safely</i>' 
fname fappend~ write_input 11 30 ; sz ; (;carryyards)
NB. Lookup values
fname fappend~ 'R' write_cell 8 31 ; 3 ; 'Table Value'
fname fappend~ 'L' write_calc 11 31 ; sz ; <('bp' 8!:0 ;fwtot)
fw=. lookup_carry_oob gender ; <carryyards
oobcarry=. fw
fname fappend~ 'R' write_calc 11 31 ; sz ; <('bp' 8!:0 ;fw)
fwtot=. fwtot >. each fw
for_i. i. 7 do. 
	if. _1 ~: i{sz do. fname fappend~ pdfDiag ((11.33+i), 31) ; 0.33 1  end.
end.
NB. Cart Path Tilt
fname fappend~ write_row_head 8 32 ; 2.0 1.0 ; '<i>Tilt / Prevent</i>' ; '<b>+/-B</b>'
fw=. 0 * each hityards NB. Temporarily set to zero
fname fappend~ 'C' write_input 11 32 ; sz ; ;fw 
NB. Percent reduction
fname fappend~ write_row_head 8 33 ; 2.5 0.5 ; '<i>Percent</i>' ; '<b>P</b>'
oobpercent=.  (' ' cut 'glPlanOOBPercent glGrOOBPercent') matrix_pull hole ; tee ; gender
oobpercent=. (<glOOBPercentVal) i. each oobpercent
fw=. (;oobpercent) { glOOBPercentDesc
fname fappend~ 'C' write_input 11 33 ; sz ; <fw 
msk=. _1 1 i. sz
write_xl hole ; tee ; gender ; (hole+1) ; 95 ; 13 15 17 19 21 23 25 ; 0 ; 'OOB Percent' ; msk #inv 100*(;oobpercent) { glOOBPercentNum
msk=. (<_1 )+each #each oobpercent NB. remove last one
msk=. ; (3;4) {. each msk $ each <1
2 write_xl hole ; tee ; gender ; (hole+1) ; 35 ; 13 15 17 19 21 23 25 ; 0 ; 'OOB Percent input' ; <msk #inv boxnonzero 100*(;}: each oobpercent) { glOOBPercentNum 
fw=. (oobpercent) { each < glOOBPercentNum
fw=. <. each (<0.5) + each fwtot * each fw NB. Round the reduction, not the total remaining WRONG ANSWER IMHO!
NB. fname fappend~ 'R' write_calc 11 33 ; sz ; <('bm<(>n<)>' 8!:0 ;fw)
fwtot=. fwtot - each fw
fwtot=. fwtot >. each tvexists NB. In case reductions have taken it to zero
NB. Jeopardy
fname fappend~ write_row_head 8 34 ; 2.0 1.0 ; '<i>Jeopardy</i>' ; '<b>J</b>'
fw=. 0 * each hityards NB. Temporarily set to zero
fname fappend~ 'C' write_input 11 34 ; sz ; ;fw 
NB. Squeeze
fname fappend~ write_row_head 8 35 ; 2.0 1.0 ; '<i>Squeeze</i>' ; '<b>Q</b>'
fw=. 0 * each hityards NB. Temporarily set to zero
fname fappend~ 'C' write_input 11 35 ; sz ; ;fw 
NB. Two Ways
NB. Only apply if both original values and the adjusted value is >=5
fw=. (<5) <: each fwtot
fw=. fw *. each (<5) <: each ooblat
fw=. fw *. each (<5) <: each oobcarry
fname fappend~ write_row_head  8 36 ; 2.5 0.5 ; '<i>Two Ways</i>' ; '<b>Y</b>'
fname fappend~ 'C' write_calc 11 36 ; sz ; <'b<>' 8!:0 ;fw
fwtot=. fwtot + each fw
NB. Total shot value
fname fappend~ 'R' write_cell 8 37  ; 3 ; 'Total Shot Value'
fname fappend~ write_calc 11 37 ; sz ; (;fwtot)
fname fappend~ 'R' write_cell 8 38  ; 3 ; 'Highest Shot Value'
fname fappend~ write_calc 11 38 ; 3 4 ; (;>. / each fwtot)
NB. Calculate in play twice adjustment
oobtwice=. fwtot * each (<5) <: each fwtot NB. Add up values greater than or equal to 5
oobtwice=. oobtwice *each (<2) <: each +/ each (<0) < each oobtwice NB. Has to be at least two entries
oobtwice=. (; +/ each oobtwice)
oobtwice=. (oobtwice>0) + oobtwice > 11
NB. In Play Twice
fname fappend~ write_row_head 8 39 ; 2.5 0.5 ; '<i>In Play Twice</i>' ; '2'
fname fappend~ 'C' write_calc 11 39 ; 3 4 ; (;oobtwice)
fwtot=. (; >. / each fwtot) + oobtwice
NB. OOB anywhere
fname fappend~ 'L' write_cell 8 40 ; 3 ; '<i>On Line of Play</i>' 
oobline=. 'glPlanOOBLine' matrix_pull hole ; tee ; gender
oobline=. ; +. / each oobline
fname fappend~ 'C' write_input 11 40 ;  3 4 ; <<"0 (;oobline){' y'
NB. Overall rating
fname fappend~ 'R' write_footer 8 41  ; 3 ; 'OOB/ER Rating'
fwtot=. fwtot >. oobline 
fname fappend~ 'C' write_footer 11 41 ;  3 4 ; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 106 ; 13 19  ; 0 ; 'OOB / ER' ; fwtot  NB. OOB / Extreme Rough

NB. ------------------------
NB. Trees
NB. ------------------------
fname fappend~ LF,'// -------- Trees -------------'
treedist=. (' ' cut 'glPlanTreeDist glGrTreeDist') matrix_pull hole ; tee ; gender
treeobs=. ('glPlanTreeLZObstructed') matrix_pull hole ; tee ; gender NB. Shot TO landing zone
treeobs=. treeobs +.each }:each (<0),each ('glPlanTreeTargObstructed') matrix_pull hole ; tee ; gender NB. OR shot FROM LZ, shifted
fname fappend~ write_title 18 19; 3 1 ; '<b>TREES</b>' 
ww=. ' ' cut 'S1 S2 S3 B1 B2 B3 B4'
ww=. (<'<b>'), each ww, each (<'</b>')
fname fappend~ 'C' write_cell 21 19 ; (7$1) ; <ww
select. z=. j. / > #each treedist
    case. 0j0 do. sz=. _1 _1 _1, _1 _1 _1 _1
    case. 0j1 do. sz=. _1 _1 _1,  1 _1 _1 _1
    case. 1j1 do. sz=.  1 _1 _1,  1 _1 _1 _1
    case. 1j2 do. sz=.  1 _1 _1,  1  1 _1 _1
    case. 2j2 do. sz=.  1  1 _1,  1  1 _1 _1
    case. 2j3 do. sz=.  1  1 _1,  1  1  1 _1
    case. 3j3 do. sz=.  1  1  1,  1  1  1 _1
    case. 3j4 do. sz=.  1  1  1,  1  1  1  1
end.
fname fappend~ 'R' write_cell 18 20 ; 3 ; '<i>Centre LZ to Trees</i>' 
fname fappend~ write_input 21 20 ; sz ; (;treedist)
fname fappend~ write_cell 18 21 ; 3 ; <<'Severity:'
fname fappend~ write_cell 21 21 ; _3 _4 ; 0$<''
fname fappend~ write_cell 18 22 ; 3 ; <<'Min / Mod / Sig / Ext'
fw=. (<0 ; gender ; 0 1) {glTeTree NB. Pick up the two elements
fw=. glTreeVal i. fw
fname fappend~ write_input 21 22 ; 3 4 ; <fw{glTreeSev
fname fappend~ 'R' write_cell 18 23 ; 3 ; 'Table Value'
fname fappend~ write_calc 21 23 ; 3 4 ; fw{glTreeNum
fname fappend~ 'R' write_cell 18 24 ; 3 ; 'Tweener Adj'
fname fappend~ write_calc 21 24 ; 3 4 ; fw{glTreeTweener
fname fappend~ 'R' write_cell 18 25 ; 3 ; '<b>Adjusted Val</b>'
fname fappend~ write_calc 21 25 ; 3 4 ; fw{glTreeTweener+glTreeNum
fwtot=. fw{glTreeTweener+glTreeNum
NB. Tree obstructed
fname fappend~ write_row_head 18 26 ; 2.5 0.5; '<i>Obstruct</i>'; '<b>O</b>'
fname fappend~ write_input 21 26 ; sz ; (;treeobs)
NB. fwtot=. fwtot + > (>. /each treeobs) NB. Removed this adjustment
NB. Tree squeeze (not yet implemented)
fname fappend~ write_row_head 18 27 ; 2.5 0.5; '<i>Squeeze</i>'; '<b>Q</b>'
fname fappend~ write_input 21 27 ; sz ; 0 * ;treeobs
NB. Tree chute (not yet implemented)
'sqdist sqwidth'=. chute_yards hole ; tee ; gender

fname fappend~ ('cell' ; 'input') write_row_head 18 28 ; 0.55 0.7 ; '<i>W</i>' ; ":0{>0{sqwidth
fname fappend~ ('cell' ; 'input') write_row_head 19.25 28 ; 0.5 0.75 ; '<i>D</i>'; ":0{>0{sqdist
fname fappend~ 'R' write_cell 20.5 28 ; 0.5 ; '<b>Q</b>'
fname fappend~ 'C' write_calc 21 28 ;  sz ;  0*;sqdist NB. Haven't impleented the lookup yet
NB. Tree Rating
fname fappend~ 'R' write_footer 18 29 ; 3 ; 'Tree Rating'
fname fappend~ 'C' write_footer 21 29 ;  3 4 ; fwtot
psych=. psych, fwtot
1 write_xl hole ; tee ; gender ; (hole+1) ; 33 ; 30 36 ; 0 ; 'Trees input'  ; fwtot  
write_xl hole ; tee ; gender ; (hole+1) ; 92 ; 30 36 ; 0 ; 'Trees' ; fwtot
 
NB. ------------------------
NB. Green Surface
NB. ------------------------
fname fappend~ LF,'// -------- Green Surface -------------'
fname fappend~ write_title 18 30 ; 3 1 ; '<b>GREEN SURFACE</b>' 
fw=. ":<. glGrStimp NB. Convert to feet and inches
fw=. fw,'&#39; ',": <. 0.5 + 12 * 1|glGrStimp
fw=. fw,'&quot;'
fname fappend~ write_input 21 30 ; 3 ; <<fw
fname fappend~ write_input 24 30 ; 4 ; <(glGrContourVal i. glGrContour){glGrContourDesc
fname fappend~ 'R' write_cell 18 31 ; 3 ; 'Table Value'
fw=. lookup_green_surface glGrStimp ; glGrContourVal i. glGrContour
fname fappend~ write_calc 21 31 ; 3 4 ; fw
fwtot=. fw
NB. Unpleasant
fname fappend~ write_row_head 18 32 ; 2.5 0.5 ; ' ' cut '<i>Unpleasant</i> <b>U</b>'
fname fappend~ write_input 21 32 ; 3 4 ; 2$glGrSurfaceUnpleasant
fwtot=. fwtot + 2$glGrSurfaceUnpleasant
NB. Tiered
fname fappend~ write_row_head 18 33 ; 2.5 0.5 ; ' ' cut '<i>Tiered</i> <b>T</b>'
fname fappend~ write_input 21 33 ; _3 4 ; glGrTiered NB. Bogey only
fwtot=. fwtot + 0,glGrTiered NB. Bogey only
fname fappend~ 'R' write_footer 18 34 ; 3 ; 'Gr Surface Rating'
fname fappend~ 'C' write_footer 21 34 ;  3 4 ; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 98 ; 30 36 ; 0 ; 'Green Surface' ; fwtot  NB. Green Surface

NB. ------------------------
NB. Psychological
NB. ------------------------
fname fappend~ LF,'// -------- Psychological -------------'
fname fappend~ write_title 18 36 ; 3 1 ; '<b>PSYCHOLOGICAL</b>' 
fname fappend~ 'C' write_cell 21 36 ; 3 4 ; <' ' cut '<b>Scratch</b> <b>Bogey</b>' 
fname fappend~ write_row_head 18 37 ; 2.9 0.1 ;  ':' cut 'No. Obstacles &gt;=5: '
fname fappend~ write_calc 21 37 ; 3 4 ; <+ / psych >: 5
fname fappend~ write_row_head 18 38 ; 2.9 0.1 ;  ':' cut 'Sum of Obstacles: '
fname fappend~ write_calc 21 38 ; 3 4 ; <+ / psych * psych >: 5
fname fappend~ 'R' write_cell 18 39 ; 3 ; 'Table Value'
wid=. lookup_psychological psych
fname fappend~ 'C' write_calc  21 39 ; 3 4 ; (;wid) 
NB. Extraordinary rating if any rated 10
fname fappend~ write_row_head 18 40 ; 2.5 0.5 ; 'Extraordinary' ; '<b>X</b>'
fw=. (2 <. +/psych >: 10){ 0 5 9
fname fappend~ write_calc 21 40 ; 3 4 ; <'b<>' 8!:0 fw
fwtot=. wid >. fw
NB. Hole 1 and 18
fname fappend~ 'R' write_cell 18 41 ; 3 ; 'Hole 1 or 18' 
fw=. 2$ 2 * hole e. 0 17 NB. Add two points
fname fappend~ write_calc 21 41 ; 3 4 ; <'b<>' 8!:0 fw
fwtot=. fwtot + fw
fname fappend~ 'R' write_footer 18 42 ; 3 ; 'Psychological'
fname fappend~ 'C' write_footer 21 42 ;  3 4 ; fwtot
psych=. psych, fwtot
write_xl hole ; tee ; gender ; (hole+1) ; 106 ; 30 36 ; 0 ; 'Psychological' ; fwtot  NB. Psychological

NB. ------------------------------
NB. Write out Standard Scratch
NB. ------------------------------
glSSObstacle=: 1 10 2$, 1 0 2 4 5 6 3 7 8 9 {psych
utKeyPut glFilepath,'_ss'

NB. -----------------------------
NB. Altitude
NB. -----------------------------
fname fappend~ LF,'// -------- Altitude -------------'
alt=. (' ' cut 'glPlanAlt glGrAlt') matrix_pull hole; tee ; gender
fname fappend~ 'black' oN 'lightgrey'
fname fappend~ LF,'$pdf->',pdfMulti 8 45 ; 3 1 ; '<b>Altimeter Readings</b>' ; 1
fname fappend~ ('cell' ; 'input') write_row_head 11 45 ; 3 1 ; '<b>On Tee:</b>' ; ":glTeAlt
if. (1< #>0{alt) do.
	fname fappend~ ('cell' ; 'input') write_row_head 15 45 ; 3 1 ; '<b>Scratch Approach:</b>' ; ":_2{>0{alt 
else.
	fname fappend~ write_cell 15 45 ; 4 ; '<b>Scratch Approach:</b>' 
end.
if. (1< #>1{alt) do.
	fname fappend~ ('cell' ; 'input') write_row_head 19 45 ; 3 1 ; '<b>Bogey Approach:</b>' ; ":_2{>1{alt 
else.
	fname fappend~ write_cell 19 45 ; 4 ; '<b>Bogey Approach:</b>' 
end.
fname fappend~ ('cell' ; 'input') write_row_head 23 45 ; 3 1 ; '<b>At Green:</b>' ; ":_1{>0{alt 

NB. -------------------------------
NB. Box in the sections
NB. -------------------------------
fname fappend~ 'D' pdfColor 'red'
fname fappend~  LF,'$pdf->SetLineWidth(0.7);'
fname fappend~ pdfBox 0 0 ; 28 1
fname fappend~ pdfBox 0 1 ; 8 4  
fname fappend~ pdfBox 0 5 ; 8 6
fname fappend~ pdfBox 0 11 ; 8 1  
fname fappend~ pdfBox 0 12 ; 8 3
fname fappend~ pdfBox 0 15 ; 8 7  
fname fappend~ pdfBox 0 22 ; 8 12 
fname fappend~ pdfBox 0 34 ; 8 8 NB. Green Target 
fname fappend~ pdfBox 0 42 ; 18 1
fname fappend~ pdfBox 0 43 ; 11 1
fname fappend~ pdfBox 11 43; 17 1 
fname fappend~ pdfBox 8 1 ; 10 14 NB. Recov and Rough
fname fappend~ pdfBox 8 15 ; 10 12 NB. Bunker
fname fappend~ pdfBox 8 27 ; 10 15 NB. OOB / ER
fname fappend~ pdfBox 18 1 ; 10 17 NB. Water
fname fappend~ pdfBox 18 19 ; 10 11 NB. Trees
fname fappend~ pdfBox 18 30 ; 10 5 NB. Green Surface
fname fappend~ pdfBox 18 36 ; 10 7 NB. Psychological

NB. End of Page
fname fappend~ LF,'// -------- End of Page -------------'
NB. fname fappend~ LF,'$pdf->SetXY(100,100);'
NB. fname fappend~ LF,'$pdf->Write(10,''Return to plan'',''http://jw/rating/plannomap/',glFilename,'/',(":1+hole),''')'
NB. fname fappend~ LF,'$pdf->Output(''/var/www/tcpdf/rating/',shortname,'.pdf'', ''FI'');'
fname fappend~ LF,'$pdf->Output(''',glDocument_Root,'/tcpdf/rating/',shortname,'.pdf'', ''F',((-. x)#'I'),''');'
fname fappend~ LF,'?>'
if. x=0 do.
    stdout '</head><body onLoad="redirect(''/tcpdf/rating/',shortname,'.php'')"'
    stdout LF,'</body></html>'
    exit ''
end.

NB. Need to set the correct permissions on the file
NB. 2!:0 'chmod 775 ',fname
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
		ww1=. I. (ab = glPlanAbility) *. (sh = glPlanShot) *. hole = glPlanHole
NB.		ww1=. I. (ab = glPlanAbility) *. (sh = glPlanShot) 
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
		utKeyRead glFilepath,'_plan'
		ww=. glPlanHole = h
		ww=. ww *. glPlanTee=t
		ww=. ww *. glPlanRecType='P'
		ww=. ww *. glPlanGender = 0
		(ww#glPlanID) utKeyRead glFilepath,'_plan'
		dist=. 'glPlanHitYards' matrix_pull h ; t ; 0 
		lay=. 'glPlanLayupType' matrix_pull h ; t ; 0
		utKeyRead glFilepath,'_tee'
		ww=. I. (glTeHole =h ) *. glTeTee=t
		if. 0=#ww do. continue. end.
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

NB. ==============================================================
merge_pdfs=: 3 : 0
NB. ==============================================================
NB. merge pdfs
NB. ==============================================================
NB. Usage:
NB.   merge_pdfs
NB. y is string of tees ('' does all)
NB. x is whether to restrict to just measured tees (e.g. x=1 will do all yellows, x=0 will just do those flagged)
NB. Returns a LF delimited string of distances
(,<'') merge_pdfs y
:
if. y -: '' do.
    y=. glTees
end.
res=. 'pdftk '
res1=. ''
utKeyRead glFilepath,'_tee'

NB. Sort by gender, tee
ww=: /: glTeHole
ww=: ww /: ww{glTeTee

for_gender. ,0  do.
	for_t.  ww do.
		if. -. (t{glTeTee) e. y do. continue. end. NB. Only the tees specified
		if. (-. (<'all')e.x) *. 0=(<t,gender){glTeMeasured do. continue. end.
		hole=. ''$t{glTeHole 
		tee=. ''$t{glTeTee
		shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole)),(gender{'MW'),tee
		fname=. glDocument_Root,'/tcpdf/',glBasename,'/',shortname,'.pdf'
		NB. Regenerate only if a measured tee
		if. ((<'regen')e. x) *. (<t,gender){glTeMeasured do.
		    NB. Generate the PHP file 
		    stdout LF,'Generating: ',(_4}.fname),'.php'
		    1 jweb_rating_report glFilename ; (":hole)  ; (":gender); tee
		    stdout LF,'Running to create: ',fname
		    res1=. res1,LF,'echo "Running to create: ',fname,'"'
		    res1=. res1,LF,'/usr/bin/php ',(_4}.fname),'.php'
		    utKeyRead glFilepath,'_tee' NB. Need to reload
		end.
		stdout LF,'Append: ', fname
		res=. res,' ',fname
	end.
end.
if. 1=#y do.
    outputname=. '_men_',;(glTees i. y){glTeesName
else.
    outputname=. '_all'
end.
res=. res, ' cat output ',glDocument_Root,'/tcpdf/',glBasename,'/',glFilename,outputname,'.pdf'
res1=. res1,LF,'echo "Catenating files"'
res1=. res1,LF,res

(}.res1) fwrite glDocument_Root,'/tcpdf/',glBasename,'/',glFilename,outputname,'.sh'
)

NB. ==============================================================
NB. merge sheets
NB. ==============================================================
NB. Usage:
NB.   merge_sheets
NB.
NB. Returns a LF delimited string of distances
merge_sheets=: 3 : 0
res=. 'pdftk '
for_hole. i. 18 do.
		shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole))
		fname=. '/home/user/Downloads/',shortname,'.pdf'
		res=. res,' ',fname
end.
res=. res, ' cat output /home/user/Downloads/',glFilename,'_sheets.pdf'
2!:0 res
)

NB. ====================================================================
NB. carry_yards
NB. ====================================================================
NB. Usage:
NB.     carry_yards carry_yards hole ; tee ; gender 
NB. Returns:
NB. Boxed array of two elements for scratch and bogey with carries for each hit
carry_yards=: 4 : 0
'hole tee gender'=. y
hole=. ''$ hole
tee=. ''$ tee
gender=. ''$ gender

yards=: 'glPlanHitYards' matrix_pull hole ; tee ; gender 
NB. Need to read the whole file again
oldid=. glPlanID
utKeyRead glFilepath,'_plan'
NB. Don't restrict for the tee - that is just the arbitrary measurement point - glRemGroundYards controls it
ww=. hole = glPlanHole
ww=. ww *. 'C'=glPlanRecType
ww=. ww *. x=glPlanCarryType
ww=. ww *. glPlanCarryAffectsTee e. ' ',tee NB. New logic for when carry only impacts a single tee (' ' is all tees)

if. (-. +. / ww) do. NB. No Carry
    res=. 0 * each yards
else.
    ww=. I. ww
    NB. Loop round the carries and find the last one
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


NB. ====================================================================
NB. chute_yards
NB. ====================================================================
NB. Usage:
NB.     carry_yards carry_yards hole ; tee ; gender 
NB. Returns:
NB. Boxed array of two elements for scratch and bogey with carries for each hit
chute_yards=: 3 : 0
'hole tee gender'=. y
hole=. ''$ hole
tee=. ''$ tee
gender=. ''$ gender

yards=: 'glPlanHitYards' matrix_pull hole ; tee ; gender 
NB. Need to read the whole file again
oldid=. glPlanID
utKeyRead glFilepath,'_plan'
NB. Don't restrict for the tee - that is just the arbitrary measurement point - glRemGroundYards controls it
ww=. hole = glPlanHole
ww=. ww *. 'Q'=glPlanRecType

if. (-. +. / ww) do. NB. No Carry
    res=. 0 * each yards
    width=. res
else.
    ww=. I. ww
    ww=. ww \: ww{glPlanRemGroundYards NB. Sort by distance from tee
    NB. Loop round the carries and find the last one
    res=. 0 * each yards
    width=. res NB. Need two answers
    totalyards=. (<(glTees i. tee),hole){glTeesYards
    for_ww1. ww do.
	carry=. totalyards - ww1{ glPlanRemGroundYards
	carry=. carry - each 0, each }: each +/ \ each yards
	carry=. 0 >. each carry
	carry=. carry * each  yards >: each carry
	res=. res >. each carry
	width=. width >. each (ww1{glPlanSqueezeWidth) * each 0 < each carry 
    end.
end.
oldid utKeyRead glFilepath,'_plan'
res=. res ; <width
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
NB.   lookup_green_target gender ; yards ; diam ; transition
NB. Returns table value
lookup_green_target=: 3 :  0
'gender yards diam trans'=. y
NB. Make transition yards large
res=. 0$0
for_ab. i. 2 do.
	yy=.(ab{yards)+999*(ab{trans) 
	if. gender=0 do. NB. Men
	    row=. > ab { 60 80 100 120 140 160 180 200 220 241 400 ; 30 45 60 75 90 110 130 150 165 181 400
	    col=. 36 31 26 21 17 12
	    mat=. 12 7 $ 2 2 2 2 2 2 2 , 2 2 2 3 3 3 3 ,2 2 3 3 4 4 4 , 2 2 3 4 4 4 5, 2 3 4 4 4 5 6 , 2 3 4 4 5 6 7, 3 3 4 5 6 7 7 , 3 4 5 5 6 7 8, 3 4 5 6 7 8 9, 4 5 6 7 8 8 9, 4 5 6 7 8 9 10, 3 4 4 5 5 6 6
	else.
	    row=. > ab { 30 50 70 90 110 130 150 170 185 201 400 ; 21 35 50 65 80 95 105 115 125 141 400
	    col=. 36 31 26 21 17 12
	    mat=. 12 7 $ 2 2 2 2 2 2 2 , 2 2 2 3 3 3 3 ,2 2 3 3 4 4 4 , 2 2 3 4 4 4 5, 2 3 4 4 4 5 6 , 2 3 4 4 5 6 7, 3 3 4 5 6 7 7 , 3 4 5 5 6 7 8, 3 4 5 6 7 8 9, 4 5 6 7 8 8 9, 4 5 6 7 8 9 10, 3 4 4 5 5 6 6
	end.
	row=. + / yy >: row
	col=. + / diam <: col
	res=. res, (<row,col) { mat
end.
)

NB. =================================================
NB. lookup_fairway_rating_old (before tweener adj)
NB. =================================================
NB. Usage
NB.   lookup_green_target gender ; abilty ; yards ; width
NB. Returns table value
lookup_fairway_rating_old=: 3 :  0
0 lookup_fairway_rating_old y
:
'gender ab yards width'=. y
if. gender=0 do. NB. Men
    row=. 340 380 426 
    col=. 50 39 29 24 19   
    mat=. 4 6 $ 1 1 2 3 4 5, 1 2 3 3 5 6, 2 3 4 4 6 7, 2 3 4 5 7 8
else.
    row=. 270 310 356 
    col=. 35 30 25 20 19   
    mat=. 4 6 $ 1 1 2 3 4 5, 1 2 3 3 5 6, 2 3 4 4 6 7, 2 3 4 5 7 8
end.
if. x do. NB. Print matrix
	res=. <"0 mat
	res=. ((<'>='),each ":each <"0 (_999,row)),. res
	res=. ((<'Fairway'), (<'<='),each ": each <"0 (999,col)), res
else. NB. else lookup value
	row=. + / yards >: row
	col=. + / width <: col
	res=. (<row,col) { mat
end.
)

NB. =================================================
NB. lookup_fairway_rating
NB. =================================================
NB. Usage
NB.   lookup_green_target gender ; abilty ; yards ; width
NB. Returns table value
lookup_fairway_rating=: 3 :  0
0 lookup_fairway_rating y
:
'gender ab yards width'=. y
NB. Added extra row of zeros for complicated situation when 
NB. Bogey cannot reach Par 3
NB. When the distance will be passed as 999
if. gender=0 do. NB. Men
    row=. 340 380 426 
    col=. 299 50 39 29 25 24 23 19   
    mat=. 4 9 $ 0 1 1 2 3 3 4 4 5, 0 1 2 3 3 4 4 5 6, 0 2 3 4 4 5 5 6 7, 0 2 3 4 5 6 6 7 8
else.
    row=. 270 310 356 
    col=. 299 45 34 29 25 24 23 19
    mat=. 4 9 $ 0 1 1 2 3 3 4 4 5, 0 1 2 3 3 4 4 5 6, 0 2 3 4 4 5 5 6 7, 0 2 3 4 5 6 6 7 8
end.
if. x do. NB. Print matrix
	res=. <"0 mat
	res=. ((<'>='),each ":each <"0 (_999,row)),. res
	res=. ((<'Fairway'), (<'<='),each ": each <"0 (999,col)), res
else. NB. else lookup value
	row=. + / yards >: row
	col=. + / width <: col
	res=. (<row,col) { mat
end.
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

NB. =================================================
NB. lookup_topog_rating
NB. =================================================
NB. Usage
NB.   lookup_roll_topog_rating alt ; stance
NB. Returns table value
NB. Enhanced to add tweener value
lookup_topog_rating=: 3 :  0
'alt stance'=. y
mat=. 5 6 $ 1 2 3 4 5, 0, 2 3 4 5 6, 1, 3 4 5 6 7, 2, 4 5 6 7 8, 3, 5 6 7 8 9, 4
res=. 0$<''
for_ab. i. 2 do.
	rr=. 0$0
	for_sh. >ab{stance do.
		row=. + / (| ab{alt * sh_index=_1+#>ab{stance) >: 10 20 30 40 NB. Only applies to approach (final) shot
		col=. (glTopogStanceVal,<'Par3') i. sh
		rr=. rr, (<row, col){mat
	end.
	res=. res, <rr
end.
)

NB. =================================================
NB. lookup_lateral_water
NB. =================================================
NB. Usage
NB.   lookup_lateral_water gender ; shot ; dist
NB. Returns table value
lookup_lateral_water=: 3 : 0
'gender shot dist'=. y
if. gender=0 do.
	mat=. 7 6 $ 0 1 1 2 2 3, 0 1 1 2 3 4, 0 1 2 3 4 4, 0 1 2 3 4 5, 0 1 2 4 4 5, 0 2 3 4 5 6, 0 2 3 4 5 7
	row=. 90 130 160 190 210 231 ,: 50 80 110 140 160 181
	col=. 50 39 29 19 14
else.
	mat=. 7 6 $ 0 1 1 2 2 3, 0 1 1 2 3 4, 0 1 2 3 4 4, 0 1 2 3 4 5, 0 1 2 4 4 5, 0 2 3 4 5 6, 0 2 3 4 5 7
	row=. 70 100 125 150 175 191 ,: 40 70 85 100 115 131
	col=. 50 39 29 19 14
end.

res=. 0$<''
for_ab. 0 1  do.
	rr=. 0$0
	for_sh. >ab{shot do.
		r=. +/ sh >: (ab{row) 
		c=. (sh_index{>ab{dist) 
		c=. +/ (c + 999*c=0) <: col NB. If zero make maximum distance
		rr=. rr, (<r, c){mat
	end.
	res=. res, <rr
end.
)

NB. =================================================
NB. lookup_carry_water
NB. =================================================
NB. Usage
NB.   lookup_carry_water gender ; carry
NB. Returns table value
lookup_carry_water=: 3 : 0
'gender carry'=. y
if. gender=0 do.
	mat=. 0 1 2 3 4 5 6 0 ,: 0 2 3 4 5 6 7 0 
	row=. 1 90 130 160 190 210 231 ,: 1 50 80 110 140 160 181
else.
	mat=. 0 1 2 3 4 6 8 0 ,: 0 2 3 4 5 7 9 0 
	row=. 1 70 100 125 150 175 191 ,: 1 40 70 85 100 115 131
end.

res=. 0$<''
for_ab. 0 1  do.
	rr=. 0$0
	for_sh. >ab{carry do.
		r=. +/ sh >: (ab{row) 
		rr=. rr, (<ab,r){mat
	end.
	res=. res, <rr
end.
)

NB. =================================================
NB. lookup_water_surround
NB. =================================================
NB. Usage
NB.   lookup_water_surround fraction ; dist ; greenval ; shot
NB. Returns table value
lookup_water_surround=: 3 : 0
'fraction dist greenval shot'=. y
mat=. 3 4 $ 0 0 0 0, 0 0 1 2, 0 1 2 3
res=. (<fraction,dist){mat
NB. Adjust for green value
res=. res * greenval >: 5 _1
NB. Pad out to number of shots
res=. <"0 res
res=. ((-&#)each shot) {. each res
)

NB. =================================================
NB. lookup_recoverabilityold
NB. =================================================
NB. Usage
NB.   lookup_recoverability gender ; greenval ; rrlength
NB. Returns table value
lookup_recoverabilityold=: 3 : 0
'gender greenval rrlength'=. y
if. gender=0 do.
	mat=. 5 5 $ 1 3 4 6 7 , 2 4 5 7 8 , 3 5 6 8 9 , 4 6 7 9 10, 5 7 8 10 10 
	row=. 4 5 7 9 ,: 3 4 6 8
	col=. 2 3.01 4.01 6.01
else.
	mat=. 5 5 $ 1 3 4 6 7 , 2 4 5 7 8 , 3 5 6 8 9 , 4 6 7 9 10, 5 7 8 10 10 
	row=. 4 5 7 9 ,: 3 4 6 8 
	col=. 2 2.51 3.51 5.01
end.

res=. 0$0
for_ab. 0 1  do.
    r=. +/ (ab{greenval) >: (ab{row) 
    res=. res, (<r, +/(''$rrlength) >: col){mat
end.
)

NB. =================================================
NB. lookup_recoverability (with tweener)
NB. =================================================
NB. Usage
NB.   lookup_recoverability gender ; greenval ; rrlength
NB. Returns table value
lookup_recoverability=: 3 : 0
'gender greenval rrlength'=. y
if. gender=0 do.
	mat=. 5 7 $ 1 2 3 4 5 6 7 , 2 3 4 5 6 7 8 , 3 4 5 6 7 8 9 , 4 5 6 7 8 9 10, 5 6 7 8 9 10 10 
	row=. 4 5 7 9 ,: 3 4 6 8
	col=. 1.5 2 3.001 3.751 4.251
else.
	mat=. 5 7 $ 1 2 3 4 5 6 7 , 2 3 4 5 6 7 8 , 3 4 5 6 7 8 9 , 4 5 6 7 8 9 10, 5 6 7 8 9 10 10 
	row=. 4 5 7 9 ,: 3 4 6 8 
	col=. 1.5 2 2.50 3.251 3.751 5.001
end.

res=. 0$0
for_ab. 0 1  do.
    r=. +/ (ab{greenval) >: (ab{row) 
    res=. res, (<r, +/(''$rrlength) >: col){mat
end.
)

NB. =================================================
NB. lookup_carry_rough
NB. =================================================
NB. Usage
NB.   lookup_carry_rough gender ; carryyards ; rrlength
NB. Returns table value
lookup_carry_rough=: 3 : 0
'gender carryyards rrlength'=. y
if. gender=0 do.
	mat=. 2 4 $ 0 0 1 2, 0 1 3 4
	row=. ,161
	col=. 2 3.01 4.01 
else.
	mat=. 2 4 $ 0 0 1 2, 0 1 3 4
	row=. ,121
	col=. 2 2.51 3.51 
end.

res=. <0*>0{carryyards NB. Scratch set to zero
for_ab. ,1  do. NB. Bogey only
    rr=. 0$0
    for_sh. >ab{carryyards do.
	r=. +/ sh >: row
	rr=. rr, (<r, +/(''$rrlength) >: col){mat
    end.
    res=. res, <rr
end.
)

NB. =================================================
NB. lookup_bunker_rating
NB. =================================================
NB. Usage
NB.   lookup_bunker_rating greenval ; bunkfraction
NB. Returns table value
lookup_bunker_rating=: 3 : 0
'greenval bunkfraction'=. y
mat=. 6 5 $ 0 1 2 2 3, 0 2 2 3 4, 0 2 3 4 5, 0 3 4 5 6, 0 4 5 6 7, 0 5 6 7 8
row=. 3 4 5 7 9 ,: 2 3 4 6 8

res=. 0$0
for_ab.  0 1  do. 
	r=. +/  (ab{greenval)  >: ab{row
    res=. res, (<r, bunkfraction){mat
end.
)

NB. =================================================
NB. lookup_bunker_depth
NB. =================================================
NB. Usage
NB.   lookup_bunker_depth gender ; bunkdepth
NB. Returns table value
lookup_bunker_depth=: 3 : 0
'gender bunkdepth'=. y
mat=. 0 1 2 3 4
if. gender=0 do.
	col=. 3.01 6.01 10.01 15.01
else.
	col=. 2.01 5.01 8.01 12.01
end.
col=. +/ bunkdepth >: col
res=. col{mat
)

NB. =================================================
NB. lookup_oobold
NB. =================================================
NB. Usage
NB.   lookup_oobold gender ; shot ; dist
NB. Returns table value
lookup_oobold=: 3 : 0
'gender shot dist'=. y
if. gender=0 do.
	mat=. 7 5 $ 0 1 1 1 2, 0 1 2 2 3, 0 1 2 3 4, 0 1 2 4 5, 0 1 2 4 6, 0 2 3 5 7, 0 2 4 6 8
	row=. 90 130 160 190 210 231 ,: 50 80 110 140 160 181
	col=. 50 39 29 19 
else.
	mat=. 7 5 $ 0 1 1 1 2, 0 1 2 2 3, 0 1 2 3 4, 0 1 2 4 5, 0 1 2 4 6, 0 2 3 5 7, 0 2 4 6 8
	row=. 70 100 125 150 175 191 ,: 40 70 85 100 115 131
	col=. 50 39 29 19 
end.

res=. 0$<''
for_ab. 0 1  do.
	rr=. 0$0
	for_sh. >ab{shot do.
		r=. +/ sh >: (ab{row) 
		c=. (sh_index{>ab{dist) 
		c=. +/ (c + _*c=0) <: col NB. If zero make maximum distance of infinity
		rr=. rr, (<r, c){mat
	end.
	res=. res, <rr
end.
)

NB. =================================================
NB. lookup_oob
NB. =================================================
NB. Usage
NB.   lookup_oob gender ; shot ; dist
NB. Returns table value
NB. Expanded for several tweener columns
lookup_oob=: 3 : 0
'gender shot dist'=. y
if. gender=0 do.
	mat=. 7 11 $ 0 1 1 1 1 1 1 1 1 2 2 , 0 1 1 1 2 2 2 2 2 3 3 , 0 1 1 1 2 2 3 3 3 4 4, 0 1 1 1 2 3 3 4 4 5 5, 0 1 1 1 2 3 3 4 5 5 6, 0 2 2 2 3 4 4 5 6 6 7, 0 2 3 3 4 5 5 6 7 7 8
	row=. 90 130 160 190 210 231 ,: 50 80 110 140 160 181
	col=. 50 40 39 38 30 29 28 20 19 18
else.
	mat=. 7 11 $ 0 1 1 1 1 1 1 1 1 2 2 , 0 1 1 1 2 2 2 2 2 3 3 , 0 1 1 1 2 2 3 3 3 4 4, 0 1 1 1 2 3 3 4 4 5 5, 0 1 1 1 2 3 3 4 5 5 6, 0 2 2 2 3 4 4 5 6 6 7, 0 2 3 3 4 5 5 6 7 7 8
	row=. 70 100 125 150 175 191 ,: 40 70 85 100 115 131
	col=. 50 40 39 38 30 29 28 20 19 18
end.

res=. 0$<''
for_ab. 0 1  do.
	rr=. 0$0
	for_sh. >ab{shot do.
		r=. +/ sh >: (ab{row) 
		c=. (sh_index{>ab{dist) 
		c=. +/ (c + _*c=0) <: col NB. If zero make maximum distance of infinity
		rr=. rr, (<r, c){mat
	end.
	res=. res, <rr
end.
)
NB. =================================================
NB. lookup_carry_oob
NB. =================================================
NB. Usage
NB.   lookup_carry_oob gender ; carry
NB. Returns table value
lookup_carry_oob=: 3 : 0
'gender carry'=. y
if. gender=0 do.
	mat=. 0 1 2 3 4 5 6 0 ,: 0 2 3 4 5 6 7 0 
	row=. 1 90 130 160 190 210 231 ,: 1 50 80 110 140 160 181
else.
	mat=. 0 1 2 3 4 6 8 0 ,: 0 2 3 5 6 8 9 0 
	row=. 1 70 100 125 150 175 191 ,: 1 40 70 85 100 115 131
end.

res=. 0$<''
for_ab. 0 1  do.
	rr=. 0$0
	for_sh. >ab{carry do.
		r=. +/ sh >: (ab{row) 
		rr=. rr, (<ab,r){mat
	end.
	res=. res, <rr
end.
)

NB. =========================================================
NB. lookup_green_surface
NB. =========================================================
NB. Usage
NB.   lookup_green_surface stimp ; contour
lookup_green_surface=: 3 : 0
'stimp contour'=. y
res=. 0$0
row=. 7 8.5 10 11 12
for_ab. 0 1 do.
	if. ab=0 do.
		mat=. 6 3$3 4 5, 4 5 6, 5 6 7, 6 7 8, 7 8 9, 8 9 10
	else.
		mat=. 6 3$ 3 4 5, 4 5 6, 5 6 8, 6 8 9, 7 9 10, 8 10 10
	end.
	res=. res, ( <(+/ (''$stimp) >: row), contour){mat
end.
)

NB. =========================================================
NB. lookup_psychological
NB. =========================================================
NB. Usage
NB.   lookup_psychological psych
lookup_psychological=: 3 : 0
'psych'=. y
res=. 0$0
count=. +/psych >: 5
tot=. +/psych * psych >:5
for_ab. 0 1 do.
    select. ab{count
	case. 0 ; 1 ; 2 do. res=. res, 0
	case. 3 do. res=. res, (+/(ab{tot)>: 20 22 24 26 99 28 99 29 30){0 2 3 4 5 6 7 8 9 10
	case. 4 do. res=. res, (+/(ab{tot)>: 20 22 25 28 31 34 99 37 38){0 2 3 4 5 6 7 8 9 10
	case. 5 do. res=. res, (+/(ab{tot)>: 25 27 29 31 34 37 40 43 46){0 2 3 4 5 6 7 8 9 10
	case. 6 do. res=. res, (+/(ab{tot)>: 30 30 32 34 37 40 43 46 49){0 2 3 4 5 6 7 8 9 10
	case. 7 do. res=. res, (+/(ab{tot)>: 35 35 35 37 40 43 46 49 52){0 2 3 4 5 6 7 8 9 10
	case. 8 do. res=. res, (+/(ab{tot)>: 40 40 40 42 44 46 49 52 55){0 2 3 4 5 6 7 8 9 10
	case. 9 do. res=. res, (+/(ab{tot)>: 45 45 45 45 47 49 52 55 58){0 2 3 4 5 6 7 8 9 10
    end.
end.
)

write_xl=: 3 : 0
NB. =========================================================
NB. write_xl
NB. =========================================================
NB. Usage:
NB.    write_xl hole ; tee ; gender ; sheet ; row ; column ; null ; note ; value
NB.    x is whether to overwrite
NB.    x=0 is check only
NB.    x=1 is check and input
NB.    x=2 is input only
0 write_xl y
:
'hole tee gender sheet row column null note value'=. y
NB. Check if boxed or literal
select. 3!:0 value
    case. 32 do.
	value=. ,value NB. Already boxed, just ravel
    case. 2 do.
	value=. ,<value NB. If text/literal box and ravel
end.
value=. ,value NB. All other cases are numeric
key=. EnKey hole ; '' ; tee ; gender ; 0 ; 0
key=. (0 1 2 4 5 6){> key

for_vv. value do.
    glXLCount=: 1 + glXLCount
    glXLID=: ,<key,'-', ;'r<0>3.0' 8!:0 glXLCount
    glXLHole=: ,hole
    glXLTee=: ,tee
    glXLGender=: ,gender
    glXLOverwrite=: ,x
    if. 2 = 3!:0 sheet do.
	glXLSheet=: ,<sheet
    else. 
	glXLSheet=: ,<'H',":sheet
    end.
    glXLRow=: ,row
    NB. Column can be scalar or vector of columns
    if. 1=#,column do.
	glXLColumn=: ,column+vv_index
    else.
	glXLColumn=: ,vv_index{column
    end.
    NB. Each element can be different string/value
    select. 3!:0 vv
	case. 32 do. NB. boxed
	    if. 2=3!:0 >vv do. NB. literal
		glXLString=: ,vv
		glXLNum=: ,0
		glXLType=: ,'S'
	    elseif. 0=#>vv do.
		glXLString=: ,<''
		glXLNum=: ,0
		glXLType=: ,'S'
	    elseif. 1 do.
		glXLString=: ,<''
		glXLNum=: ,>vv
		glXLType=: ,'N'
	    end.
	case. do. NB. Numbers
	    glXLString=: ,<''
	    glXLNum=: ,vv
	    glXLType=: ,'N'
    end.
    glXLNull=: , null
    glXLNote=: ,<note
    utKeyPut glFilepath,'_xl'
end.
)
