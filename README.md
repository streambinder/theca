# Solus-Project repository

This is a custom `eopkg` (Solus-Project package manager) repository.

## Install

	eopkg add-repo streambinder https://solus.davidepucci.it/eopkg-index.xml.xz

## Uninstall

	eopkg remove-repo streambinder

## Enable / Disable

	eopkg enable-repo streambinder https://solus.davidepucci.it/eopkg-index.xml.xz
	eopkg disable-repo streambinder https://solus.davidepucci.it/eopkg-index.xml.xz

## FAQs

### How do I serve files

I actually configured `solus.davidepucci.it` virtualhost to host two files:

1.  `/index.php`

		<?php

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://github.com/streambinder/eopkg-ashtray/releases/latest');
		curl_setopt($ch, CURLOPT_HEADER, true);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_exec($ch);
		$ch_url = curl_getinfo($ch, CURLINFO_EFFECTIVE_URL);
		$ch_download_url = str_replace('/tag/', '/download/', $ch_url);
		header("location: ".$ch_download_url.$_SERVER['REQUEST_URI']);

		?>

	As easily readable, the code above simply trap all the traffic to the vhost, calculate the redirect URI associated to the `releases/latest` (latest release) of the GitHub project and append the local request URI append to the result of calculation. It just remap all the requests to GitHub.

2.  `/.htaccess`

		RewriteEngine on
		RewriteCond %{REQUEST_FILENAME} !-f
		RewriteCond %{REQUEST_FILENAME} !-d
		RewriteRule ^.*$ /index.php [L,QSA]

	This file is needed to let web server know to forward all request (that do not match with a local file or directory) to the same index.php.
