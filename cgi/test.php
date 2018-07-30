<?php
// test.php
// Cover function for PHP CGI

/* ---------------------------------------------
 * Set up global variables
 */
// HOME variable
if (file_exists('/Users')) { 
    $GLOBALS['home'] = '/Users';
    }
else {
    $GLOBALS['home'] = '/home';
    }
if (file_exists($GLOBALS['home'] . '/djw')) {
    $GLOBALS['home'] = $GLOBALS['home'] . '/djw'; #this is a comment
    }
else {
    $GLOBALS['home'] = $GLOBALS['home'] . '/ubuntu';
    }
// Document_Root
if (file_exists('/Users')) {
    $GLOBALS['document_root'] = '/Library/WebServer/Documents';
    }
else {
    $GLOBALS['document_root'] = '/var/www';
    }
// Parameters
if ( php_sapi_name() == 'cli')  { // command line
    # print_r($argv);
    $params = $argv[1]; 
    $params = substr($params, 2); 
    $params = explode('/' , $params);
    $url = $argv[2];
    $post = $argv[3];
    }
else { // webpage
    $params = $_SERVER['QUERY_STRING']; 
    $i = strpos($params, '&');
    if ( $i === FALSE ) {
	$url = '';
	$params = substr($params, 2);
	$params = explode('/' , $params);
	}
    else {
	$url = substr($params, $i+1);
	$params = substr($params, 2, ($i-2));
	$params = explode('/', $params);
	}
    $post = $_POST;
    }
$GLOBALS['params'] = $params;
$GLOBALS['url'] = $url;
$GLOBALS['post'] = $post;

/* -----------------------------------------------------------------
 * Location of <<ijconsole>>
 */
if (file_exists('/usr/bin/ijconsole')){
    $GLOBALS['ijconsole'] = '/usr/bin/ijconsole';
    }
else{
    $GLOBALS['ijconsole'] = '/usr/local/bin/ijconsole';
    }   

/* -----------------------------------------------------------------
 * Loop round potential files and include any which should be there
 */
$dirname= array();
$filename= array();
$filefound= FALSE;
$functionfound= FALSE;
for($i= 0 ;  $i < sizeof($params) ; $i++) {
    if ($i === 0){
	$dirname[0] = $GLOBALS['document_root'] . '/jweb/' . $params[0];
	$filename[0] = $params[0];
	}
    else {
	$dirname[$i] = $dirname[$i-1] . '/' . $params[$i];
	$filename[$i] = $filename[$i-1] . '_' . $params[$i];
	}
    }
// Loop round paths and files
for($i= 0 ;  $i < sizeof($params) ; $i++) {
    // If directory does not exist, can break loop because subdirectories can't exist either
    if (! file_exists($dirname[$i]) ) break; 
    for ($j= 0  ; $j < sizeof($params) ; $j++) {
	$filepath=  (($dirname[$i] . '/' . $filename[$j]) . '.php'); 
	// echo ("Trying to include $filepath" . '<br>' . PHP_EOL ); 
	if (file_exists($filepath) ) {
	    // echo ('<b>Including file: ' . $filepath . '</b><br>' . PHP_EOL);
	    include_once($filepath);
	    $filefound= TRUE;
	    }
	}
    }

/* -----------------------------------------------------
 * Throw error if no file has been loaded
 */
if ($filefound == FALSE) {
    pagenotvalid();

    }

$functionfound= FALSE;

/* -----------------------------------------------------
 * Loop round function names in reverse
 */
for($i= (sizeof($params)-1) ; $i >= 0 ; $i--) {
    $filepath= '';
    for ($j = 0 ; $j <= $i ; $j++) {
	if ($j === 0) {
	    $filepath= $params[$j];
	    }
	else {
	    $filepath.= '_' . $params[$j];
	    }
	}
    // echo ("Trying function $filepath" . '<br>' . PHP_EOL) ;
    if (function_exists($filepath) ){
	if (isset($arg)){
	    unset($arg);
	    }
	$arg= array();
	if ($i < sizeof($params)-1) {
	    for ($j = $i + 1 ; $j<sizeof($params) ; $j++){
		$arg[$j - $i - 1]= $params[$j];
		}
	    }
	# echo ('About to run: ' . ($filepath) . '($arg, $url) <br>' . PHP_EOL);
	# echo ('$arg=' . (serialize($arg)) . '<br>' . PHP_EOL); 
	# echo ('$url=' . (serialize($url)) . '<br>' . PHP_EOL); 
	# echo ('$post=' . (serialize($post)) . '<br>' . PHP_EOL); 
	$filepath($arg, $url, $post); # KILLER LINE TO EXECUTE FUNCTION
	$functionfound= TRUE;
	break 1;
	}
    }

/* ------------------------------------------------------
 * If we get this far, function does not exist
 */
if ($functionfound == FALSE) {
    pagenotvalid();
    }
exit();

/* ================================================================
 * pagenotvalid
 * ================================================================
 */
function pagenotvalid() {
    header('Status: 404 Not Found');
    header('Content-Type: text/html');
    echo (PHP_EOL . PHP_EOL . '<head>');
    echo (PHP_EOL . '<link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">');
    echo (PHP_EOL . '<link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">');
    echo PHP_EOL . '</head><title>404 Not Found</title><body class="error loud">' ;
    echo PHP_EOL . '<h1>404 This is not a valid page for direct loading</h1>';
    echo PHP_EOL . '<br>QUERY_STRING='. $_SERVER['QUERY_STRING'];
    echo PHP_EOL . '<br>HTTP_REFERER='. $_SERVER['HTTP_REFERER'];
    echo PHP_EOL . '<br>HTTP HOST='. $_SERVER[ 'HTTP_HOST'];
    echo PHP_EOL . '<br>SERVER ADMIN='. $_SERVER[ 'SERVER_ADMIN'];
    echo PHP_EOL . '<br>SERVER NAME='. $_SERVER[ 'SERVER_NAME'];
    echo PHP_EOL . '<br>REQUEST URI='. $_SERVER[ 'REQUEST_URI'];
    echo PHP_EOL . '<br>HTTPS='. $_SERVER[ 'HTTPS'];
    echo PHP_EOL . '<br>REMOTE USER='. $_SERVER[ 'REMOTE_USER'];
    echo PHP_EOL . '</body>';
    exit();
}

?>
