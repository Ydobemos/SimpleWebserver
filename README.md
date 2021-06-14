# SimpleWebserver
A simple Webserver (HTTP 1.0) for multiple Plattforms and Operating Systems. Based only on tcp-Sockets. It is a Multithreading (non-blocking) Server which can handle UTF-8. It is portable, so you don't need to install it and can use it directly. The Server don't need much configuration, so it can be "fired up" fastly.
It may be handy, if you are on the same (local) network and want to share files fast, because it can activate an integrated FTP-view option for folders.

## Releases
[Actual Stable Version is 1.7 (click me to go to Release Page)](https://github.com/Ydobemos/SimpleWebserver/releases/tag/1.7)

On the Release page you find already compiled Versions for:
- Windows 32 Bit
- Windows 64 Bit
- Linux 64 Bit (tested on Ubuntu)
- Linux ARM for Raspberry Pi 3 (tested on Raspberry Pi 3 with Raspbian, could also work on other Raspberry Pi's)

They are all portable and ready to go/use.
For Linux you may set the user permissions for execution before you can use it.

## My Website
My Website, more Information will be added later here:
http://soenke-berlin.de/

## Introduction
This is a simple http 1.0 Webserver for Delphi and Lazarus. It only needs Indy 10. The Webserver is basically build on the tcp Socket, so i more or less implement the http 1.0 protocol myself. Therefore, it is highly portable and can be easily compiled on different systems! I implemented the most important http 1.0 stuff myself so that it works easily. If you need a reliable and secure Webserver, i recommend you to use Nginx or Apache Webserver. For Apache Webserver, there is also xampp (a ready to go solution), if you need a fast setup for testing purposes.
You can compile with Lazarus on all Systems and of course in Delphi.
Tested with Delphi 10.3 and different Lazarus Versions on different Plattforms and Operating Systems.


## Compiling the Source
You need Indy 10 Library for the TCP-Socket handling.

### Windows
On Windows you can use Delphi (I tested: Delphi 10.3 Community Edition, older Versions should also work) or the Lazarus IDE with Free Pascal Compiler (FPC) (I tested with Lazarus Version 2.06 and FPC Version 3.0.4). The code is optimized to work with Delphi and Lazarus.

### Linux
For Linux I only tested with Lazarus (on Ubuntu and on Raspbian), but should work for any Linux-flavor and architecture. 
One big thing to mention for Linux: The Forms looks a bit dfifferent than on Windows, so i recommend to change 
unit1_linux.lfm  to unit1.lfm
and unit2_linux.lfm to unit2.lfm 
so the Forms also looks good on Linux Systems. Otherwise, some Text from the Labels are outside the Form...
For Windows Systems no change is required.

### Mac
Should also compile on a Mac without a problem. I don't have a Mac so i can not test it right now. I may ask a friend in the future to compile it for me...
Or just do it by your own ;)

### In General
My Comments on the Source Code are in German and English, sorry that i mixed it...

## Screenshots
The Webserver after starting:

![Example screenshot 1](http://soenke-berlin.de/webserver/simpleWebserver1_7_example1.png)

You can start right away without making a lot of configurations.


An example request to the web server:

![example screenshot 2](http://soenke-berlin.de/webserver/simpleWebserver1_7_example2.png)

## Licence
GPL-3.0 License 

For more information see the Licence file...
