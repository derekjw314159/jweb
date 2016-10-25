NB. J Utilities for displaying sheet data
NB. 

glPDFoffset=: 8 4
glPDFmult=: (276 % 28), (183 % 48)

NB. =========================================================
NB. pdfMulti
NB. =========================================================
pdfMulti=: 3 : 0
'offset size text border'=. y
offset=. glPDFoffset + offset * glPDFmult
size=. size * glPDFmult
NB. r=. 'MultiCell(',(":0{size),', ',(": 1{size),', ''',text,''', ',(":border),', ''J'', true, 0,',(":0{offset),', ',(":1{offset),', false, 0, true, true, ',(":0 * 1{size),',''M'',false);'
r=. 'WriteHTMLCell(',(":0{size),', ',(": 1{size),', ',(":0{offset),', ',(":1{offset),', ''',text,''', ',(":border),', 0, true, false, '''', false);'
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
ww=. glPlanRecType='P'
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

((hole=glGrHole)#glGrID) utKeyRead glFilepath,'_green'

NB. Order by ability, shot
ww=. ww /: ww{glPlanShot
ww=. ww /: ww{glPlanAbility

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

NB. Title row
fname fappend~ LF,'// -------- Title Row -------------'
fname fappend~ LF,'$pdf->SetFillColor(255,255,255);'
fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
fname fappend~ LF,'$pdf->',pdfMulti 0 0 ; 5 1 ; ('<b>CLUB</b>: ',glCourseName); 1
NB. Need to work out which tees this is serving
meas=. gender{;glTeMeasured
fname fappend~ LF,'$pdf->',pdfMulti 5 0 ; 4.5 1 ; ('<b>COURSE</b>: ',(>gender{'/' cut '/Men /Women '),>((glTees i. tee){glTeesName)); 1
fname fappend~ LF,'$pdf->',pdfMulti 9.5 0 ; 1.5 1 ; ('<b>HOLE</b>: ',":1+hole); 1
fname fappend~ LF,'$pdf->',pdfMulti 11 0 ; 2 1 ; ('<b>PAR</b>: ',":gender{,glTePar); 1
fname fappend~ LF,'$pdf->',pdfMulti 13 0 ; 3 1 ; ('<b>LENGTH</b>: ',":(<t_index,hole){glTeesYards); 1
fname fappend~ LF,'$pdf->',pdfMulti 16 0 ; 5 1 ; '<b>DATE RATED</b>:' ; 1
fname fappend~ LF,'$pdf->',pdfMulti 21 0 ; 7 1 ; '<b>T/LEADER</b>:' ; 1

NB. Shots Played
fname fappend~ LF,'// -------- Shots Played -------------'
fname fappend~ LF,'$pdf->SetFillColor(0,0,0);'
fname fappend~ LF,'$pdf->SetTextColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 0 1 ; 3 1 ; '<b>SHOTS PLAYED</b>'; 1
fname fappend~ LF,'$pdf->SetFillColor(255,255,255);'
fname fappend~ LF,'$pdf->SetTextColor(0,0,0);'
for_sh. i. 4 do.
    fname fappend~ LF,'$pdf->',pdfMulti ((3+sh*1.25), 1) ; 1.25 1 ; ('<span style="text-align:center"><b>',(sh{'T234'),'</b></span>'); 1
end.
for_ab. i. 2 do.
    fname fappend~ LF,'$pdf->SetFillColor(255,255,255);'
    fname fappend~ LF,'$pdf->',pdfMulti (0 ,2+ab) ; 3 1 ; ('<span style="text-align:right"><i>',(>ab{' ' cut 'Scratch Bogey'),'</i></span>'); 1
    for_sh. i. 4 do.
	ww1=. ( (ab = ww{glPlanAbility) *. (sh = ww{glPlanShot)) # ww
	if. 0=#ww1 do.
	    fname fappend~ LF,'$pdf->SetFillColor(127,127,127);'
	    fname fappend~ LF,'$pdf->',pdfMulti ((3+sh*1.25) ,2+ab) ; 1.25 1 ; ' '; 1
	else.
	    fname fappend~ LF,'$pdf->SetFillColor(255,255,255);'
	    fname fappend~ LF,'$pdf->SetTextColor( 35, 83, 216);'
	    fname fappend~ LF,'$pdf->',pdfMulti ((3+sh*1.25) ,2+ab) ; 1.25 1 ; ('<span style="text-align:center">',((": ww1{glPlanHitYards),(''$'T'=ww1{glPlanLayupType)#'T'),'</span>') ; 1
	    fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
	end.
    end.
end.
fname fappend~ LF,'$pdf->SetFillColor(255,255,255);'
fname fappend~ LF,'$pdf->',pdfMulti (0 ,4) ; 3 1 ; ('<span style="text-align:center">Transition Hole?</span>'); 1
for_ab. i. 2 do.
    ww1=. (ab = ww{glPlanAbility) # ww
    txt=. '<span style="text-align:center"><b>',(>ab{'/' cut 'Scratch: / Bogey: '),'</b>'
    txt=. txt, >(+. / 'T' =ww1{glPlanLayupType) {' ' cut 'No Yes'
    txt=. txt,'</span>'
    fname fappend~ LF,'$pdf->SetTextColor( 35, 83, 216);'
    fname fappend~ LF,'$pdf->',pdfMulti ((3+ab*2.5) ,4) ; 2.5 1 ; txt ; 1
    fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
end.

NB. Roll
fname fappend~ LF,'// -------- Roll -------------'
fname fappend~ LF,'$pdf->SetFillColor(0,0,0);'
fname fappend~ LF,'$pdf->SetTextColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 0 5 ; 3 1 ; '<b>ROLL</b>'; 1
fname fappend~ LF,'$pdf->SetFillColor(255,255,255);'
fname fappend~ LF,'$pdf->SetTextColor(0,0,0);'
fname fappend~ LF,'$pdf->',pdfMulti 3 5 ; 2.5 1 ; '<span style="text-align:center"><b>S1</b></span>'; 1
fname fappend~ LF,'$pdf->',pdfMulti 5.5 5 ; 2.5 1 ; '<span style="text-align:center"><b>S2</b></span>'; 1
fname fappend~ LF,'$pdf->',pdfMulti 0 6 ; 3 1 ; '<i>Downhill/Level/Uphill</i>'; 1

NB. Fairway Carry
fname fappend~ LF,'// -------- Recoverability and Rough -------------'
carryyards=. 'F' carry_yards hole; tee ; gender 
fname fappend~ LF,'$pdf->SetFillColor(0, 0, 0);'
fname fappend~ LF,'$pdf->SetTextColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 8 1 ; 3 1 ; '<b>RECOV & ROUGH</b>' ; 1
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
fname fappend~ LF,'$pdf->',pdfMulti 8 8 ; 1.25 1 ; '<i>Yd:</i>' ; 1
fname fappend~ LF,'$pdf->SetFillColor(247, 253, 156);'
fname fappend~ LF,'$pdf->',pdfMulti 8.5 8 ; 0.75 1   ; (":0{>0{carryyards) ; 0
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 9.25 8 ; 1.25 1 ; '<i>Ht:</i>'; 1
fname fappend~ LF,'$pdf->SetFillColor(247, 253, 156);'
fname fappend~ LF,'$pdf->',pdfMulti 9.75 8 ; 0.75 1   ; (":glGrRRRoughLength) ; 0
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->',pdfMulti 10.5 8 ; 0.5 1 ; '<b>C</b>'; 1

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

NB. Altitude
fname fappend~ LF,'// -------- Altitude -------------'
alt=. (' ' cut 'glPlanAlt glGrAlt') matrix_pull hole; tee ; gender
fname fappend~ LF,'$pdf->SetFillColor(127, 127, 127);'
fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
fname fappend~ LF,'$pdf->',pdfMulti 3 46 ; 4 1 ; '<b>Altimeter Readings</b>' ; 1
fname fappend~ LF,'$pdf->SetFillColor(255, 255, 255);'
fname fappend~ LF,'$pdf->SetTextColor(0, 0, 0);'
fname fappend~ LF,'$pdf->',pdfMulti 7 46 ; 4.5 1 ; '<b>On Tee:</b>' ; 1
fname fappend~ LF,'$pdf->',pdfMulti 11.5 46 ; 4.5 1 ; '<b>Scratch Approach:</b>' ; 1
fname fappend~ LF,'$pdf->',pdfMulti 16.0 46 ; 4.5 1 ; '<b>Bogey Approach:</b>' ; 1
fname fappend~ LF,'$pdf->',pdfMulti 20.4 46 ; 4.5 1 ; '<b>At Green:</b>' ; 1
fname fappend~ LF,'$pdf->SetFillColor(247, 253, 156);'
fname fappend~ LF,'$pdf->',pdfMulti 10 46 ; 1.3 1 ; (":glTeAlt); 0 NB. Tee
if. glTePar>3 do.
    fname fappend~ LF,'$pdf->',pdfMulti 14.5 46 ; 1.3 1 ; (":_2{>0{alt); 0 NB. Scratch
    fname fappend~ LF,'$pdf->',pdfMulti 19 46 ; 1.3 1 ; (":_2{>1{alt); 0 NB. Bogey
end.
fname fappend~ LF,'$pdf->',pdfMulti 23.5 46 ; 1.3 1 ; (":_1{>0{alt); 0 NB. Green

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
matrix_pull=: 4 : 0
'hole tee gender'=. y
hole=. ''$ hole
tee=. ''$ tee
gender=. ''$ gender
shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole)),(gender{'MW'),tee

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	utKeyRead glFilepath,'_green'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

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

NB. Order by ability, shot
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
	ww1=. ( (ab = ww{glPlanAbility) *. (sh = ww{glPlanShot)) # ww
	if. 0<#ww1 do.
	    rr=. rr, ww1{ ".x1
	end.

    end.
    NB. Drop the last and pull the tree variable
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
shortname=. glFilename,'_',(;'r<0>2.0' 8!:0 (1+hole)),(gender{'MW'),tee

if. fexist glFilepath,'.ijf' do.
	ww=.utFileGet glFilepath
	utKeyRead glFilepath,'_plan'
	utKeyRead glFilepath,'_tee'
	utKeyRead glFilepath,'_green'
	err=. ''
else.
	err=. 'No such course : ',glFilename
end.

yards=: 'glPlanHitYards' matrix_pull hole ; tee ; gender 
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
res=. res
)
