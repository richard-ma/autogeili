这个项目停止维护
The project is dead. -- richard\_ma

Autogeili 安装及使用说明

1.1 简介

	autogeili是一个开源项目，主要用于为Gnome桌面用户提供壁纸的更新服务。
	
	autogeili的名称来源于提供壁纸的网站（http://www.wordsmotivate.me/ -- 给力壁纸），由于是自动更新，故以auto作为前缀。这个项目目前只有一名开发者，不过有很多测试者，借此机会感谢这些热衷与开源的朋友们，也希望以后开源的团队能够发展壮大。
　　
	开源不单单要给大家提供软件上的选择和便捷，更要输出一种态度和价值观。 -- Richard Ma
	
	如果你使用Windows系统，可以使用如下软件实现autogeili的功能：
	Motivate Desktop： http://www.wordsmotivate.me/motivatedesktop
	这里还有以前壁纸的打包下载，如果你喜欢，可以一起搬到你的硬盘上。

1.2 安装需求

	1. 装有Gnome桌面环境的任何Linux系统 (目前只在Ubuntu 10.04下测试通过)；
	2. 有bash脚本运行环境；
	3. 能够链接互联网；
	4. 1MB以上的空闲磁盘空间。

1.3 安装
	
 1.3.1 下载压缩包
 	
 	您可以使用任何下载工具下载本软件的压缩包。
 	
 1.3.2 压缩包解压
 
 	在命令行状态下，可以使用如下命令解压压缩包：
 	$ tar -xvzf autogeili.tar.gz
 	
 	或者可以使用Ubuntu提供的图形化软件。
 	
 1.3.3 安装依赖软件包（Ubuntu专用）
 	
 	打开解压后的文件夹，可以看到名为install.sh的bash脚本文件，使用如下命令可以运行此脚本：
 	$ ./install.sh
 	
 	在其他路径下，可以使用如下命令运行：
 	$ path/to/autogeili/install.sh
 	
 	这里的path/to/autogeili为你解压后的文件夹路径。程序运行完毕后，所有依赖的软件包就会装好。
 	
 	** 其他Linux发行版可以自行安装依赖的软件包。
 	
 	Ubuntu依赖如下包：
		gconf2
		libnotify-bin
		x11-xserver-utils
		
 1.3.4 给autogeili脚本赋予运行权限
 
 	使用如下命令即可：
 	$ chmod 755 path/to/autogeili/autogeili
	
 1.3.5 创建软链 
 	
 	sudo ln -s path/to/autogeili/autogeili.sh /usr/local/bin/autogeili
 	
 	* 这样在任何路径下均可以使用如下命令运行autogeili更新壁纸：
 	$ autogeili [date]
        * 不带第一参数的时候默认更新当天的壁纸
        $ example
        `autogeili 2012.6.18`
 	
 1.3.6 安装完毕
 	
 	至此安装过程完毕，由于autogeili是一个脚本，所以放置在任何地方均可以运行，也不需要ROOT权限。
 	
1.4 使用方法

 1.4.1 命令行下运行
 	
 	1. 没有设置PATH变量运行
 	使用如下命令即可：
 	$ path/to/autogeili/autogeili
 	
 	2. 设置PATH后运行
 	如果已经设置了PATH变量，可以使用更加简略的命令形式：
 	$ autogeili
 	
 1.4.2 使用ALT + F2运行
 	在Gnome下，使用ALT + F2的运行窗口也可以输入：
 	path/to/autogeili/autogeili
 	即可运行本程序。
 	
 	设置PATH后可以直接使用：
 	autogeili
 	运行。
 	
 1.4.3 开机自动运行
 	开机启动这种方式可能是最为常见的，可以在Gnome的System->Preference->Startup Applications中添加设置：
 	
 	Name: Autogeili
 	Command: path/to/autogeili/autogeili
 	Comment: 自动更新桌面壁纸
 	
 	填写好信息后，保存即可。

 1.4.4 命令行参数
  1.4.4.1 延时下载 -d
    使用-d选项来延迟下载壁纸，后接需要延迟的时间(s-second 秒, m-minute 分, h-hour 小时, d-day 天)。

    例如：延时启动5秒 autogeili -d 5s
 	
1.5 卸载

 1.5.1 删除相关运行文件
 
 	autogeili在运行时会产生一些运行文件，请首先使用如下命令删除运行文件：
 	$ rm -rf ~/.autogeili
	$ rm ~/.autogeilirc
 	
 1.5.2 删除Autogeili
 
 	删除本文件夹即可。
 	
 1.5.3 卸载依赖软件包（Ubuntu专用）
 
 	使用如下命令可自动卸载依赖软件包：
 	$ sudo apt-get autoremove
 	
 	** 如果使用其他发行版，请自行卸载相关软件包。

##- 相关链接 -##

	作者: Richard Ma (richard_ma)
	Email: 	richard.ma.19850509@gmail.com
	Blog:	http://www.richardma.org

	Autogeili 项目首页：
	http://www.richardma.org/blog/funnies/autogeili/
	https://github.com/richard-ma/autogeili (git)
	http://code.google.com/p/autogeili/ (svn 停滞在1.0.0代码)
	
##- 鸣谢 -##
	
	壁纸提供： WordsMotivate -- 给力壁纸
	http://www.wordsmotivate.me/
	
	代码托管： 

	GitHub
 	https://github.com/richard-ma/autogeili

	Google Code
	http://code.google.com/ (已停止更新)
	
	以及所有为开源做出贡献的人们！

    sailxjx - v1.7 添加对Gnome-shell v3的支持

##- 升级提示 -##

update to 1.6:
    * autogeili.sh改名为autogeili，如需使用原名，请自行创建符号链接。
    * ln -s path/to/autogeili path/to/autogeili.sh
