<?php 
	system("git pull --force >> 拉入最新版本.php.log");
	system("git lfs pull >> 拉入最新版本.php.log");
	/* TODO: 確定這列是不是需要的 */
	system("git lfs checkout >> 拉入最新版本.php.log");
	
?>