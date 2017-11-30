<?php

/* =============================================================
 * rating_report_summary
 * =============================================================
 */

function rating_report_summary($params, $url, $post) {
	header('Content-Type: text/html' . PHP_EOL . PHP_EOL); 
// ---
?>
<html>
<head>
<script src="/javascript/pagescroll.js"></script>

<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css">
<style>a:link:after, a:visited:after{
		 content: normal;
	}</style>
<!--[if lt IE 8]>
	<link rel="stylesheet" href="/css/blueprint/ie.css" type="text/css" media="screen, projection">
<![endif]-->
</head>
<body>
<div class="container">
<?php
// ---
	list($course , $g, $tee) = $params ;
	switch ($g) {
		case '0' :
			$gender = 'M';
			break;
		case '1' :
			$gender = 'W';
			break;
		}
			
	echo '<h2>Course : ' . $course . '  Gender : ' . $gender . '  Tee : ' . $tee . '</h2><h3>All holes</h3>' ;
// ---
?>
<table>
	<thead>
	<tr>
		<th>Hole</th>
		<th>Filename</th>
		<th>Last written</th>
		<th>View</th>
		<th>Regen</th>
	</tr>
	</thead>
	<tbody>
<?php 
// ---
	// Loop round holes
	date_default_timezone_set('Europe/London');
	for($h=0; $h<18; $h++){
		echo "\t\t<tr>" . PHP_EOL;
		echo "\t\t\t<td>" . (sprintf('%02d', 1+$h)) . '</td>' . PHP_EOL;
		$webname = '/tcpdf/rating/' . $course . '_' . (sprintf('%02d' , 1+$h)) . $gender . $tee . '.pdf';
		$filename = $GLOBALS['document_root'] . $webname ;
		if(file_exists($filename)){
			echo "\t\t\t<td>" . $webname . "</td>" . PHP_EOL ;
			echo "\t\t\t<td>" . (date('D d M Y H:i:s', filemtime($filename))) . "</td>" .PHP_EOL;
			echo "\t\t\t<td><a href=\"" . $webname , '" target="_blank">View</a></td>' . PHP_EOL ;
			}
		else{
			echo "\t\t\t<td></td><td></td><td></td>" . PHP_EOL ;
			}
		echo "\t\t\t<td><a href=\"/pw/rating/report/single/" . $course . "/$h/$g/$tee\">Regen</a></td>" . PHP_EOL ; 
		echo "\t\t</tr>" . PHP_EOL;
		}
	// Summary file
	echo "\t\t<tr>" . PHP_EOL;
	echo "\t\t\t<td>All</td>" . PHP_EOL;
	$webname = '/tcpdf/rating/' . $course . '_all_' . $gender . $tee . '.pdf';
	$filename = $GLOBALS['document_root'] . $webname ;
	if(file_exists($filename)){
		echo "\t\t\t<td>" . $webname . "</td>" . PHP_EOL ;
		echo "\t\t\t<td>" . (date('D d M Y H:i:s', filemtime($filename))) . "</td>" .PHP_EOL;
		echo "\t\t\t<td><a href=\"" . $webname , '" target="_blank">View</a></td>' . PHP_EOL ;
		}
	else{
		echo "\t\t\t<td></td><td></td><td></td>" . PHP_EOL ;
		}
	echo "\t\t\t<td><a href=\"/pw/rating/report/collate/" . $course . "/$g/$tee\">Re-collate</a></td>" . PHP_EOL ; 
	echo "\t\t</tr>" . PHP_EOL;
	// Regen all
// ---
?>
</tbody>
</table>
<?php
// ---
	echo "<a href=\"/pw/rating/report/regen/" . $course . "/$g/$tee\">*** GENERATE ALL - VERY SLOW ***</a><br>" . PHP_EOL ; 
// ----
?>
</div>
</body>
</html>
<?php
// ---
	} // end of function
// -------------------------------------------------------------

/* =============================================================
 * rating_report_single
 * =============================================================
 * Runs the J-software function to generate the report PHP
 * file, then executes it
 */

function rating_report_single($params, $url, $post) {
	// Running J-software program to create PHP file
	exec(($GLOBALS['ijconsole'] . ' ' . $GLOBALS['document_root'] . '/jweb/cgi/simulate.ijs r=rating/reportsingle/' . (implode('/', $params)) . ' PHP'), $res);
	// Then executing PHP to create PDF
	list($course , $h, $g, $tee) = $params ;
	switch ($g) {
		case '0' :
			$gender = 'M';
			break;
		case '1' :
			$gender = 'W';
			break;
		}
	$webname = '/tcpdf/rating/' . $course . '_' . (sprintf('%02d' , 1+$h)) . $gender . $tee . '.php';
	$filename = $GLOBALS['document_root'] . $webname ;
	chdir($GLOBALS['document_root'] . '/tcpdf/rating');
	include($filename);
	header( 'Location: /pw/rating/report/summary/' . $course . '/' . $g . '/' . $tee) ;
	} // end of function
// ---------------------------------------------------------------

/* =============================================================
 * rating_report_regen
 * =============================================================
 * Runs the J-software function to generate the report PHP
 * file, then executes it
 */

function rating_report_regen($params, $url, $post) {
	// Running J-software program to create PHP file
	list($course, $g, $tee) = $params;
	switch ($g) {
		case '0' :
			$gender = 'M';
			break;
		case '1' :
			$gender = 'W';
			break;
		}
	header('Content-Type: text/html' . PHP_EOL . PHP_EOL); 
// ---
?>
<html>
<head>
<script src="/javascript/pagescroll.js"></script>
<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css">
<style>a:link:after, a:visited:after{
		 content: normal;
	}</style>
<!--[if lt IE 8]>
	<link rel="stylesheet" href="/css/blueprint/ie.css" type="text/css" media="screen, projection">
<![endif]-->
</head>
<body>
<div class="container">
<?php
// ---

	for($h=0; $h<18 ; $h++){
		echo 'About to build PHP file for hole ' . (1+$h) . '<br>' . PHP_EOL;
		ob_flush();
		flush();
		exec(($GLOBALS['ijconsole'] . ' ' . $GLOBALS['document_root'] . '/jweb/cgi/simulate.ijs r=rating/reportsingle/' . "$course/$h/$g/$tee" . ' PHP'), $res);
		echo 'PHP file built<br>' . PHP_EOL;
		ob_flush();
		flush();
		// Then executing PHP to create PDF
		$webname = '/tcpdf/rating/' . $course . '_' . (sprintf('%02d' , 1+$h)) . $gender . $tee . '.php';
		$filename = $GLOBALS['document_root'] . $webname ;
		echo "Running PHP routing to create PDF - filename= $filename<br>" . PHP_EOL;
		ob_flush();
		flush();
		chdir($GLOBALS['document_root'] . '/tcpdf/rating');
		include($filename);
		echo "PDF built<br>" . PHP_EOL;
		ob_flush();
		flush();
		}
	echo '<br><br>' . PHP_EOL;
	echo "<a href=\"/pw/rating/report/summary/$course/$g/$tee\">Return to report summary</a>" ;
// ---
?>
</div>
</body>
</html>
<?php
// ---
	} // end of function
// ---------------------------------------------------------------

/* =============================================================
 * rating_report_collate
 * =============================================================
 * Runs the J-software function to generate the collated report PHP
 * file, then executes it
 */

function rating_report_collate($params, $url, $post) {
	// Running J-software program to create PHP file
	list($course, $g, $tee) = $params;
	switch ($g) {
		case '0' :
			$gender = 'M';
			break;
		case '1' :
			$gender = 'W';
			break;
		}
	if (file_exists('/usr/local/bin/PDFconcat')){
		$collate= '/usr/local/bin/PDFconcat -o ';
		}
	else{
		$collate= 'pdftk cat output ';
		}
	$webname = '/tcpdf/rating/' . $course . '_all_' . $gender . $tee . '.pdf';
	$filename = $GLOBALS['document_root'] . $webname ;
	$collate .= $filename;
	

	for($h=0; $h<18 ; $h++){
		// Then executing PHP to create PDF
		$webname = '/tcpdf/rating/' . $course . '_' . (sprintf('%02d' , 1+$h)) . $gender . $tee . '.pdf';
		$filename = $GLOBALS['document_root'] . $webname ;
		if(file_exists($filename)){
			$collate .= ' ' . $filename;
			}
		}
	// Run the collation
	exec($collate, $res);
	header( 'Location: /pw/rating/report/summary/' . $course . '/' . $g . '/' . $tee) ;
	
	} // end of function
// ---------------------------------------------------------------

?>
