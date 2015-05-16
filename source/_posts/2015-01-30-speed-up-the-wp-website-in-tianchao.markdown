---
layout: post
title: "Speed-Up the WP website in TianChao"
date: 2015-01-30 23:09
comments: true
categories: web
---
Since our Great Fire Wall forbidden the google, thus all of the google related service becomes available in china, this leads to access to wordpress based website which uses google online fonts pretty slow. Following is how to speedup your website without too many changes:     
First go to your website's folder, find the files which calls `fonts.googleapis.com`:    

```
$ grep -i "fonts.googleapis.com" ./ -r
./wp-content/themes/twentytwelve/functions.php:		$font_url = add_query_arg( $query_args, "$protocol://fonts.googleapis.com/css" );
./wp-content/themes/twentyfifteen/functions.php:		), '//fonts.googleapis.com/css' );
./wp-content/themes/twentyfourteen/functions.php:		$font_url = add_query_arg( 'family', urlencode( 'Lato:300,400,700,900,300italic,400italic,700italic' ), "//fonts.googleapis.com/css" );
./wp-content/themes/tdpersona/functions.php:	wp_enqueue_style( 'tdpersona-googlefonts', '//fonts.googleapis.com/css?family=Source+Sans+Pro:300,400,600,700' );
./wp-content/themes/twentythirteen/functions.php:		$fonts_url = add_query_arg( $query_args, "//fonts.googleapis.com/css" );
./wp-includes/script-loader.php:		$open_sans_font_url = "//fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,300,400,600&subset=$subsets";
./wp-includes/js/tinymce/plugins/compat3x/css/dialog.css:@import url(//fonts.googleapis.com/css?family=Open+Sans:300italic,400italic,600italic,300,400,600&subset=latin-ext,latin);


```
Replace all of the `fonts.googleapis.com` with `fonts.useso.com`, this could be done via scripts.   
After modification, your website will be much more faster than before.    
