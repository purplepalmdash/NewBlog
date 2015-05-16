---
layout: post
title: "My Reading Digest For Git"
date: 2014-04-22 16:12
comments: true
categories: git
---
###View Git LOG
git log for view your activities:    

```sh run.sh
$ git log --pretty=oneline
1f7ec5eaa8f37c2770dae3b984c55a1531fcc9e7 Added a comment
582495ae59ca91bca156a3372a72f88f6261698b Added a default value
323e28d99a07d404c04f27eb6e415d4b8ab1d615 Using ARGV
94164160adf8faa3119b409fcfcd13d0a0eb8020 First Commit

```
git log controlling items:    

```sh run.sh
$ git log --pretty=oneline --max-count=2
$ git log --pretty=oneline --since='5 minutes ago'
$ git log --pretty=oneline --until='5 minutes ago'
$ git log --pretty=oneline --author=<your name>
$ git log --pretty=oneline --all

```
try man git-log for more details.     
For searching last 7 days' modification:    
	$ git log --all --pretty=format:'%h %cd %s (%an)' --since='7 days ago'
Final command:     

```sh run.sh
	$ git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short'
	$ git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short
	* 1f7ec5e 2013-04-13 | Added a comment (HEAD, master) [Jim Weirich]
	* 582495a 2013-04-13 | Added a default value [Jim Weirich]
	* 323e28d 2013-04-13 | Using ARGV [Jim Weirich]
	* 9416416 2013-04-13 | First Commit [Jim Weirich]

```
Explanation: 

```sh run.sh
	--pretty="..." 定义输出的格式
	%h 是提交 hash 的缩写
	%d 是提交的装饰（如分支头或标签）
	%ad 是创作日期
	%s 是注释
	%an 是作者姓名
	--graph 使用 ASCII 图形布局显示提交树
	--date=short 保留日期格式更好且更短

```
Other tools:  gitx (Mac) 和 gitk (任意平台) 在浏览日志历史时十分有用。    
###Add Git TAG
Add tag for the specified release: "git tag v1-data", "git tag" to view all of the tags.     
Revert the change via;     

```
	git revert HEAD

```
这将带你到编辑器中。你可以编辑默认的提交信息，或直接 离开它。保存并关闭文件。Or Using the following with no editing:     

```
	$ git revert HEAD --no-edit

```
Using tag for reverting the changes:    

```
	$ git tag oops
	$ git reset --hard v1
	$ git tag -d oops

```
More than one modification but commit once:     	

```
	$ git add hello.rb
	$ git commit --amend -m "Add an author/email comment"

```
Change the directory structure:     

```
	git mv hello.rb lib
	git commit -m "Moved hello.rb to lib"

```
View the directory tree:     

```
	git cat-file -p 4ee1119fb7519dc8298fe5d8e9329f52566afaed

```
###Merge
Merge the branch with master:     

```
	git merge master

```
when conflicts happens, you will manually merge it.     

Revert to specified version:     

```
	git reset --hard <hash>

```
Clone the remote repository to local, using git clone:    

```
	$ git clone hello cloned_hello
	$ git branch -a
	* master
	  remotes/origin/HEAD -> origin/master
	  remotes/origin/greet
	  remotes/origin/master

```

git fetch 命令的结果将从远程仓库取得新的提交，但它不会将这些提交合并到本地分支中。If we wnat to sync, then try following:        

```sh run.sh
	[Trusty@~/code/git_learn/git_tutorial/cloned_hello]$ git merge origin/master
	Updating 5de15b7..105a3d0
	Fast-forward
	 README | 1 +
	 1 file changed, 1 insertion(+)
	[Trusty@~/code/git_learn/git_tutorial/cloned_hello]$ cat README 
	This is the Hello World example from the git tutorial.
	(Changed in original)

```
Clone the directory structure, mainly for backup:    

```
	$ git clone --bare hello hello.git
	Cloning into bare repository hello.git...
	done.
	$ ls hello.git
	HEAD
	config
	description
	hooks
	info
	objects
	packed-refs
	refs

```
If we want to push changes to the remote, just git push.    
迅速跳过克隆仓库，且让我们拉下刚才推送到共享仓库的更改。

```
	$ cd ../cloned_hello
	$ git remote add shared ../hello.git
	$ git branch --track shared master
	$ git pull shared master
	$ cat README

```
###On Daemon
####启动 Git 服务器    

```
	# (From the work directory)
	$ git daemon --verbose --export-all --base-path=.

```
现在，在分开的终端窗口中，转到你的工作目录。    

```
	# (From the work directory)
	$ git clone git://localhost/hello.git network_hello
	$ cd network_hello
	$ ls

```
你应当看到 hello 项目的拷贝。    
####推送到 Git daemon     
如果你想要推送到 Git daemon 仓库，添加 --enable=receive-pack 到 git daemon 命令。小心，因为此服务器没有授权，任何人 都能推送到你的仓库。
