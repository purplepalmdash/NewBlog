---
layout: post
title: "Add video in Octopress"
date: 2013-12-30 18:30
comments: true
categories: Octopress
---
###Add mp4 videos
From the link [http://octopress.org/docs/blogging/plugins/](http://octopress.org/docs/blogging/plugins/) we can easily see HTML5 Video has been suported by octopress by-default, we add the video following this format. The details, click the upper link .    
###Add Youtube Links
Download the plugin from [https://github.com/manojlds/octopress-plugins](https://github.com/manojlds/octopress-plugins), copy it under the folder plugins.     

```
	\{\% youtube 3dNDUNYT1fY \%\}
```
Or specify its size via:

```
	\{\% youtube 3dNDUNYT1fY 640 480 \%\}
```
###Add Youku Links
First download the plugin from [https://gist.github.com/liuhui998/455504954d1c6134ca57](https://gist.github.com/liuhui998/455504954d1c6134ca57),  Copy it to plugins folder, add its executable priviledge.     
Add following for adding the video in size of 480x320

```
	\{\% youku  XMzM3MDM0Mjg0 480 320 \%\}
```
###An example of Leonard Cohen's song:
{% youku XNTc4MDQyODky 480 320 %}     

```
	A thousand kisses deep
	You came to me this morning
	清晨你来到我身边 
	And you handled me like meat.
	像触摸一块肉一般触摸我 
	You′d have to be a man to know
	你得是个男人才会明白 
	How good that feels, how sweet.
	那感觉多么甜蜜，多么美妙 
	My mirror twin, my next of kin, 
	我的镜中人啊，我的至亲，
	I′d know you in my sleep. 
	我在睡梦中也认得你的模样。
	And who but you would take me in 
	除了你没人会将我收留 
	A thousand kisses deep?
	你的爱如同一千个吻那么深 
	
	I loved you when you opened 
	我爱你，当你像朵百合
	Like a lily to the heat. 
	向着炎热盛开的样子
	You see, I′m just another snowman 
	但我却像个雪人
	Standing in the rain and sleet, 
	伫立在雨雪之中
	Who loved you with his frozen love 
	用他冰冻的爱
	His second-hand physique,
	和他身不由己的身体去爱你
	With all he is, and all he was
	用他现在和曾经的全部 
	A thousand kisses deep. 
	他的爱如同一千个吻那么深
	
	I know you had to lie to me
	我知道你不得不撒谎
	I know you had to cheat 
	我知道你不得不撒下谎言
	To pose all hot and high 
	透过哄骗的面纱
	Behind The veils of sheer deceit 
	你努力装得无比性感和骄傲 
	Our perfect porn aristocrat 
	我们完美的肉欲之爱
	So elegant and cheap 
	如此优雅而低俗
	I’m old but I’m still into that
	我老了，但我依然深深怀念
	A thousand kisses deep. 
	当年一千个吻那么深的爱情 
	
	I'm good at love, I'm good at hate,
	我,爱之深也恨之切， 
	It's in between I freeze. 
	爱恨交织于是我不知所措 
	Been working out, but it's too late, 
	我试着走出，但为时晚矣
	It's been too late for years. 
	一切都太晚了。
	But you look good, you really do, 
	不过你看上去不错，真的不错 
	They love you on the street, 
	走在街上依然有人为你神魂颠倒
	If you were here, I'd kneel for you 
	如果你在我面前，我会为你跪倒，
	A thousand kisses deep. 
	以一千个吻般深刻的爱。
	
	The Autumn moved across your skin, 
	秋天掠过你的肌肤 
	Got something in my eye, 
	也给我的眼睛里带进了某些物事。
	A light that doesn't need to live, 
	那是一道无需存在
	And doesn't need to die. 
	也无需消失的光 
	A riddle in the book of love, 
	一个爱之书里的谜
	Obscure and obsolete 
	晦涩而陈腐
	Till witnessed here in time and blood 
	唯有用时间与鲜血方可证实
	A thousand kisses deep.
	如同一千个吻般深刻的爱意
	
	And I’m still working with the wine 
	我还在借酒浇愁
	Still dancing cheek to cheek 
	依然放荡不羁
	The band is playing Auld Lang Syne 
	乐队还在唱着霏靡之音
	But the heart will not retreat 
	而我的心依然不懂得退却
	I ran with Diz, I sang with Ray, 
	我和迪吉及但丁一起混 
	I never had their sweep 
	我从未有威风之时
	But once or twice they let me play
	但偶尔他们也会让我露两手
	A thousand kisses deep.
	唱上这首《A thousand kissed deep》 
	
	I loved you when you opened 
	我爱你，当你像朵百合 
	Like a lily to the heat. 
	向着炎热盛开之时
	You see, I′m just another snowman 
	看看我吧，我仍然像个雪人
	Standing in the rain and sleet, 
	伫立在雨雪之中 
	Who loved you with his frozen love 
	用他冰冻的心脏深深爱着你
	His second-hand physique,
	用他冰冻的不由自主的身体爱着你 
	With all he is, and all he was
	用他的过往、他的现在 
	A thousand kisses deep.
	如同一千个吻般深深爱着你
	
	But you don’t need to hear me now, 
	但现在你已无需再听 
	And every word I speak,
	我说的每句话 
	It counts against me anyhow 
	也许都会让你厌恶
	A thousand kisses deep.
	然而我的爱意，依然如同一千个吻般那么深。 
```
