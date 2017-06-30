# UAClientService
Support DLNA and airplay protocol to transfer media content from one device to another like TV, etc.


##Airplay

AirPlay is supported on iOS 4.3 or later and iTunes 10.2 or later on OS X and Windows. AirPlay can enrich your apps and games by allowing users to extend content from an iOS device to a high-definition TV with Apple TV or to an AirPlay-enabled sound system.


There are two ways to use AirPlay, following the apple developer documentation about AirPlay is the simplest way to use it. Check it here: [Provide an AirPlay Picker](https://developer.apple.com/library/content/documentation/AudioVideo/Conceptual/AirPlayGuide/EnrichYourAppforAirPlay/EnrichYourAppforAirPlay.html#//apple_ref/doc/uid/TP40011045-CH6-SW3). You can simply add an AirPlay picker to your media playback controls by using MPVolumeView. When user tap the MPVolumeView control, the AirPlay picker is visible only when there is an AirPlay output device available. The MPVolumeView control may be not visible when there's no AirPlay device on iOS9 and below system, it's always visible on iOS10+. So if you want to customize the style of MPVolumeView, you should judge whether the iOS system version is iOS 9 or above. 


The another way to use AirPlay is to follow the AirPlay protocol, implement all the functions yourself. You can customize the UI all yourself, without using MPVolumeView. Here is an [Unofficial AirPlay Protocol Specification](http://nto.github.io/AirPlay.html) . This document is awesome, with this detailed protocol specification, we can implement AirPlay functions freely.


##DLNA

DLNA(DIGITAL LIVING NETWORK ALLIANCE), is set up by Sony, Intel and Microsoft. It's not a protocol, it's just a solution, a standard rule to extend musics, photos and videos from a device to another. The aim of this alliance is 'enjoy your music, photos and videos, anywhere anytime'. DLNA is based on [SOAP](https://en.wikipedia.org/wiki/SOAP) protocol to transmit data. DLNA is a more popular solution and widely used through devices.


Goods resources to learn how to implement functions like AirPlay with DLNA:

[基于DLNA实现iOS，Android投屏：SOAP控制设备](http://ios.jobbole.com/84519/)
[基于DLNA实现iOS投屏，SSDP发现设备及SOAP控制设备](https://github.com/ClaudeLi/DLNA_UPnP)
