<?php 
	system("git pull --force");
	system("git lfs pull");
	/* TODO: 確定這列是不是需要的 */
	system("git lfs checkout");
	
?>