# Solus-Project repository

This is a custom `eopkg` (Solus-Project package manager) repository.

## Install

```bash
eopkg add-repo streambinder https://solus.davidepucci.it/eopkg-index.xml.xz
```

If you want to point directly to the (specific) GitHub release:

```bash
eopkg add-repo streambinder \
	https://github.com/streambinder/ashtray/releases/download/$TAG/eopkg-index.xml.xz
```

## Uninstall

	eopkg remove-repo streambinder

## Enable / Disable

	eopkg enable-repo streambinder
	eopkg disable-repo streambinder

## FAQs

### How do I build my own

In order to rebuild the whole repository, just enter the folder and run `make`: it'll trigger all the `solbuild` sub-commands in the right order. The whole Solus-recognized repository output will be placed in `bin/` folder.
As a side-note, keep in mind  that lot of this repository packages need each others as dependency to be built: this means you have to configure `solbuild` to use this (local) repository as source for the build process. To do that, just append these lines at the end of `/usr/share/solbuild/main-x86_64.profile` file, before firing the `make` command:

```
[repo.local-repository]
uri = "/path/to/repository/bin"
local = true
autoindex = true
```

### How do I serve files

I actually configured `solus.davidepucci.it` virtualhost to host two files:

1.  `/index.php`

		<?php

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, 'https://github.com/streambinder/ashtray/releases/latest');
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
