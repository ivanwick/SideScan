SideScan
========

![ScreenShot](/quickstart-diagram.png)
Running the Application
-----------------------
Build the PcapSandbox application in XCode.

1. Click "auth" and enter your password to authorize yourself to run tcpdump.
2. Click "tcpdump" to bring up the capture config sheet.
3. The default tcpdump filter will give you web traffic, but the expression can be modified as described in the tcpdump(1) and pcap(3) man pages.  Most users will probably want to change the monitored network interface to "Wi-Fi".  Click "Run tcpdump".
4. Cause some network traffic or wait for your interface to capture someone else's.  You can check the state of live datastream assemblies by clicking "status".


Visualizing the Extracted Data
------------------------------
The checkboxes at the bottom of the main window control the visibility of subwindows that display the extracted data.

- **Images Collection**: An orderly grid of captured images that updates as each image is extracted.
- **Image Detail**: Resizable view of the image selected in the collection view.
- **FlyingImagesView**: Animates each image as it is extracted.
- **Animation settings**: Use these sliders to adjust the time parameters of the FlyingImagesView's animation.  A test animation can be triggered by clicking on the FlyingImagesView.

All data is lost when the application quits.


Notes
-----
The application uses tcpdump/libpcap to monitor unencrypted network traffic to and from your computer as well as any other hosts transmitting on a shared medium (e.g. wireless or old-style ethernet).  When testing it with the default filter, try loading a web page and see if the images are captured.  Your browser probably already has some images cached, so not everything you see on a web page may have gone over the network.

A lot of status messages are printed to the console.

You should get fairly complete extraction of images from your own traffic, since tcpdump will tend to capture it completely and in the correct order.  Results for peer traffic may vary.

Based on [EtherPEG](http://www.etherpeg.org/) and [Driftnet](http://www.ex-parrot.com/~chris/driftnet/).
