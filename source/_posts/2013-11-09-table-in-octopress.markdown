---
layout: post
title: "Table in Octopress"
date: 2013-11-09 14:17
comments: true
categories: Markdown
---
###Table in Markdown
Table in markdown can be represent like following:

```
	| Tables        | Are           | Cool  |
	| ------------- |:-------------:| -----:|
	| col 3 is      | right-aligned | $1600 |
	| col 2 is      | centered      |   $12 |
	| zebra stripes | are neat      |    $1 |
```

Or we can use the pure html code:

```
	<table>
	    <tr>
	        <td>Foo</td>
	    </tr>
	</table>
```

By both method we can create our own table.
###Display Table in Octopress
By default, table won't be displayed in octopress, this is because we don't provide the corresponding css file to table. we have first to add the css file under source/sytlesheets/data-table.css:
{% codeblock data-table.css-data-table.css %}
* + table {
  border-style:solid;
  border-width:1px;
  border-color:#e7e3e7;
}
 
* + table th, * + table td {
  border-style:Trustyed;
  border-width:1px;
  border-color:#e7e3e7;
  padding-left: 3px;
  padding-right: 3px;
}
 
* + table th {
  border-style:solid;
  font-weight:bold;
  background: url("/images/noise.png?1330434582") repeat scroll left top #F7F3F7;
}
 
* + table th[align="left"], * + table td[align="left"] {
  text-align:left;
}
 
* + table th[align="right"], * + table td[align="right"] {
  text-align:right;
}
 
* + table th[align="center"], * + table td[align="center"] {
  text-align:center;
}
{% endcodeblock %}
Then we can add the following line in source/\_includes/head.html:

```
	  <link href="/stylesheets/data-table.css" media="screen, projection" rel="stylesheet" type="text/css" />
```

By now we can see the tables as following:


![Table 1](/images/table1.jpg)


### Table Processing in vim
Install htmltidy via:

```
	$ pacman -S tidyhtml
```

Add following lines into your own ~/.vimrc

```
	:vmap ,x :%!tidy -q -i --show-errors 0<CR>
	:command Thtml :%!tidy -q -i --show-errors 0
	:command Txml  :%!tidy -q -i --show-errors 0 -xml
```

Open your vim and type in:

```
	:Thtml
```

by now you can get tidy html. 
