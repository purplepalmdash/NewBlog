---
layout: post
title: "烤派宝典(序)"
date: 2013-11-08 20:38
comments: true
categories: Linux Raspberry PI
---
#烤派宝典-操作系统开发
欢迎来到烤派宝典之操作系统开发！这门课由[Alex Chadwick](mailto:awc32@cam.ac.uk)撰写，当前版本为V1.0c(2013年7月)。   

本宝典将指引你在[Raspberry Pi](www.raspberrypi.org)上开发出一个非常基本的操作系统！本宝典主要针对16岁以上读者，当然对未满16岁的小朋友我们也未作访问限制，你可以在助手的引导下访问本网站。适当时候本课程将增加更多的内容。    

本宝典将指引你用汇编语言构建出一个基本的操作系统。我们假定手持本宝典的诸位大侠都是初出江湖之辈，之前从未接触过操作系统开发和汇编语言的知识。有编程经验固然可以让你如虎添翼，但是本宝典的设计门槛应该是针对一穷二白完全没有经验的读者。Raspberry Pi论坛中藏龙卧虎，遍布着热心之极的人们，一个个望穿秋水般等着随时给予你以援手，所以当你碰到问题时，尽管去提问好了。本宝典被划分为一系列“章节”，按顺序列举如下。每一“章节”里在介绍理论的同时也将给出一些实际的练习，双管齐下助你事半功倍多快好省的掌握武功秘籍。    

本宝典不会涉及到过于细节的内容，也不会顾及到关于创建操作系统知识的方方面面，本宝典中的一系列指南将关注于完成一系列小的任务。我们希望读者在通读并完成本宝典练习的最后，能融汇贯通自己所学，最终具备独立创建一个个性化的操作系统的“神功”。尽管本宝典的章节大多关注于特定的功能实现，但其中也留有大片空间供读者自行发挥。比如，在学习完关于函数的章节后，你可以构思出一种更好的汇编代码组织方式。比如，在阅读完有关图形的章节后，你可以设想下如何开发一个3D操作系统。因为本宝典是讲述操作系统的牛逼内容，你完全可以拥有设计出你喜爱的事情的能力。如果你有了灵光一闪的瞬间，抓住并实现它！计算机科学仍然是一门新兴学科，有的是空间任君遨游。     

## 内容   

1 [要求](#headrequirement)    
2 [章节](#chapter)     

## 1 要求<a name="headrequirement"></a>
你需要具备下列物品以完成本宝典：一块附带有SD卡的Raspberry Pi及电源, 一台运行Linux, Microsoft Windows或Mac OS X的开发机， SD卡读写器及读写软件。如果你的Raspberry Pi能连接屏幕就更好了，当然这不是必需条件。    

软件方面，你需要准备基于ARMv6的GNU编译工具链。在[下载页面](http://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/downloads.html)里你可以找到下载链接，该页面中也提供了所有练习的参考答案。   

## 2 章节<a name="chapter"></a>

<table border="1">
  <caption>
    表 2.1 - 章节列表
  </caption>

  <thead>
    <tr>
      <th></th>

      <th>名称</th>

      <th>描述</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td>0</td>

      <td><a href="introduction.html">介绍</a></td>

      <td>本章节不包含实战环节，主要用于介绍一个操作系统所涉及到的基本概念、什么是汇编语言,以及其他重要的基础性概念。如果你想一步到位直接进入实战环节，你可以忽略掉这一章。
      </td>
    </tr>

    <tr>
      <th colspan="3">OK LED 系列 (初级)</th>
    </tr>

    <tr>
      <td>1</td>

      <td><a href="ok01.html">OK01</a></td>

      <td>OK01 这一章内容涉及了如何起步，并将教会你如何点亮Raspberry PI开发板上的'OK'或是'ACT' LED灯，这个LED灯靠近RCA和USB口。
      </td>
    </tr>

    <tr>
      <td>2</td>

      <td><a href="ok02.html">OK02</a></td>

      <td>OK02 这一章建立在OK01的基础上，将反复点亮/熄灭'OK'或'ACT' LED。
      </td>
    </tr>

    <tr>
      <td>3</td>

      <td><a href="ok03.html">OK03</a></td>

      <td>OK03 这一章基于OK02,将教会你在汇编语言中如何使用函数，函数的引入将使得汇编代码可用性大大提升，并提升代码的可读性。
      </td>
    </tr>

    <tr>
      <td>4</td>

      <td><a href="ok04.html">OK04</a></td>

      <td>OK04 这一章基于OK03，将教会你如何使用定时器(timer)来精确控制'OK'或'ACT'灯的闪烁频率。
      </td>
    </tr>

    <tr>
      <td>5</td>

      <td><a href="ok05.html">OK05</a></td>

      <td>OK05这一章基于OK04, 将教会你如何根据摩尔斯码来控制LED的闪烁。LED的闪烁将发出SOS信号，此信号的格式如下：(...---...).</td>
    </tr>

    <tr>
      <th colspan="3">屏幕系列 (高阶)</th>
    </tr>

    <tr>
      <td>6</td>

      <td><a href="screen01.html">Screen01</a></td>

      <td>Screen01这一章讲述了一些基本的图像处理理论，我们将在这一章里，在屏幕上或是电视机（TV）上显示出一个渐变颜色的格式。
      </td>
    </tr>

    <tr>
      <td>7</td>

      <td><a href="screen02.html">Screen02</a></td>

      <td>Screen02这一章基于Screen01，将教会你如何在屏幕上画直线，还将教会你一个如何生成随机数的技巧。
      </td>
    </tr>

    <tr>
      <td>8</td>

      <td><a href="screen03.html">Screen03</a></td>

      <td>Screen03这一章基于Screen02，本章将教会你如何在屏幕上画出字符，还将介绍给你内核命令行的概念。
      </td>
    </tr>

    <tr>
      <td>9</td>

      <td><a href="screen04.html">Screen04</a></td>

      <td>Screen04这一章基于Screen03，将教会你如何操纵字符，并将计算出来的值显示在屏幕上。
      </td>
    </tr>

    <tr>
      <th colspan="3">Input 系列(高阶)</th>
    </tr>

    <tr>
      <td>10</td>

      <td><a href="input01.html">Input01</a></td>

      <td>Input01这一章将教给你关于设备驱动的理论，如何链接驱动程序库，比如键盘。本章过后你将可以在屏幕上看到输入的字符。</td>
    </tr>

    <tr>
      <td>11</td>

      <td><a href="input02.html">Input02</a></td>

      <td>Input02这一章基于Input01，将教会你如何创建一个和操作系统打交道的命令行接口。
      </td>
    </tr>
  </tbody>
</table>
