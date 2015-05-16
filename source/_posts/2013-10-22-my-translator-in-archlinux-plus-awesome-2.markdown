---
layout: post
title: "My Translator in ArchLinux+Awesome(2)"
date: 2013-10-22 17:23
comments: true
categories: Bash Linux
---
###Prefix
3 days ago I wrote a simple translator on my ArchLinux which could pop-up a notification window when I query a word. But when I use it at company it failed. Becaus the firewall has banned the communication to Google's API. Thus I have to write another version of translator, which could get the result from the local database. 
###Preparation
python-stardict is a great library for querying word from stardict's dictionary, you can get it via:

```
	$ git clone https://github.com/pysuxing/python-stardict.git
```

Also you have to download stardict's dictionary from [http://abloz.com/huzheng/stardict-dic/]("http://abloz.com/huzheng/stardict-dic/" "http://abloz.com/huzheng/stardict-dic/"), you can choose whatever you like dictionary, then uncompress it into your python-stardict located directory.
###Coding
Open stardict.py with your favorite editor, adding a function at the end of the file. The code snippet is listed as following:
{% codeblock stardict.py -stardict.py %}
def my_read_dict_info():
    """
    """
    my_ifo_file = "/home/Trusty/code/python/python-stardict/stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.ifo"
    my_idx_file = "/home/Trusty/code/python/python-stardict/stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.idx"
    my_dict_file = "/home/Trusty/code/python/python-stardict/stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.dict.dz"
    #########Uncomment them for other dictionaries ######
    #my_dict_file = "stardict-dictd_www.dict.org_gcide-2.4.2/dictd_www.dict.org_gcide.dict.dz"
    #my_idx_file = "stardict-dictd_www.dict.org_gcide-2.4.2/dictd_www.dict.org_gcide.idx"
    #my_ifo_file = "stardict-dictd_www.dict.org_gcide-2.4.2/dictd_www.dict.org_gcide.ifo"
    #my_ifo_file = "stardict-longman-2.4.2/longman.ifo"
    #my_idx_file = "stardict-longman-2.4.2/longman.idx"
    #my_dict_file = "stardict-longman-2.4.2/longman.dict.dz"
    my_ifo_reader = IfoFileReader(my_ifo_file)
    my_idx_reader = IdxFileReader(my_idx_file)
    my_dict_reader = DictFileReader(my_dict_file, my_ifo_reader, my_idx_reader, True)
    cmdargs = str(sys.argv) ## args
    result = my_dict_reader.get_dict_by_word(str(sys.argv[1]))  ## Using args[1] for querying
    print result[0].values()[0]		## output result in terminal
    result_str = "\'<span color=\"green\" size=\"14000\">"+result[0].values()[0]+"</span>\'"	## Build the command line for notify-send
    #print result_str
    call(["notify-send", str(sys.argv[1]), result_str])		## Call notify-send to print on screen, last for 5 seconds
    #call(["echo", commandstr])
    #output = subprocess.check_output(["echo", commandstr])
    #p1 = subprocess.Popen(['echo','-e', commandstr], stdout=subprocess.PIPE)
    #p1 = subprocess.Popen(['printf', commandstr], stdout=subprocess.PIPE)
    #p2 = subprocess.Popen(['awesome-client', '-'], stdin=p1.stdout, stdout=subprocess.PIPE)
    #p1.stdout.close()
    #output = p2.communicate()[0]
    #print "*****"
    #print output

# read_ifo_file("stardict-cedict-gb-2.4.2/cedict-gb.ifo")
# read_idx_file("stardict-cedict-gb-2.4.2/cedict-gb.idx")
# read_dict_info()
my_read_dict_info()
{% endcodeblock %}

Clean code:
{% codeblock stardict_clean.py -stardict_clean.py %}
def my_read_dict_info():
    """
    """
    my_ifo_file = "/home/Trusty/code/python/python-stardict/stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.ifo"
    my_idx_file = "/home/Trusty/code/python/python-stardict/stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.idx"
    my_dict_file = "/home/Trusty/code/python/python-stardict/stardict-langdao-ec-gb-2.4.2/langdao-ec-gb.dict.dz"
    my_ifo_reader = IfoFileReader(my_ifo_file)
    my_idx_reader = IdxFileReader(my_idx_file)
    my_dict_reader = DictFileReader(my_dict_file, my_ifo_reader, my_idx_reader, True)
    cmdargs = str(sys.argv) ## args
    result = my_dict_reader.get_dict_by_word(str(sys.argv[1]))  ## Using args[1] for querying
    print result[0].values()[0]		## output result in terminal
    result_str = "\'<span color=\"green\" size=\"14000\">"+result[0].values()[0]+"</span>\'"	## Build the command line for notify-send
    call(["notify-send", str(sys.argv[1]), result_str])		## Call notify-send to print on screen, last for 5 seconds

my_read_dict_info()
{% endcodeblock %}
###Configuration
You can add an alias into your ~/.bashrc

```
	alias mydict='python2 /home/Trusty/code/python/python-stardict/stardict.py'
```

Or you can add an executable file named /bin/mydic which contains:
{% codeblock mydic.sh -mydic.sh %}
#!/bin/bash
python2 /home/Trusty/code/python/python-stardict/stardict.py $@
{% endcodeblock %}
###Result
See the following images for result:  

![Alt text](/images/translator2_0.jpg "translator0")  
![Alt text](/images/translator2_1.jpg "translator1")

The query result will vanished in 5 seconds.
###TBD
- How to automatically record every query?
- How to replace the python-stardict with my own library(Written in C, much more fast?)? 
- How to automatically judge english/chinese, or other languages? 
- Considering Error Handling. 
