# Serialise
<?php
	$var = array(
		array(
			NULL,
			1,
			array(2, 3, 4),
			array(
				array( 0, 1),
				array( 2 ,3),
				),
			array(0.1,0.2)
			),
		array(
			NULL,
			'a',
			'abc',
			array(
				'ab', 'cd'
				),
			"a{'\"(\t\n"
			)
		);

	echo print_r($var);
	echo PHP_EOL . '----' . PHP_EOL;
	echo strlen($var[1][4]);
	echo PHP_EOL . '----' . PHP_EOL;
	echo serialize($var);
	echo PHP_EOL;
?>
