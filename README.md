# MediaView

[![CI Status](http://img.shields.io/travis/andrewboryk/MediaView.svg?style=flat)](https://travis-ci.org/andrewboryk/MediaView)
[![Version](https://img.shields.io/cocoapods/v/MediaView.svg?style=flat)](http://cocoapods.org/pods/MediaView)
[![License](https://img.shields.io/cocoapods/l/MediaView.svg?style=flat)](http://cocoapods.org/pods/MediaView)
[![Platform](https://img.shields.io/cocoapods/p/MediaView.svg?style=flat)](http://cocoapods.org/pods/MediaView)

## Description

MediaView can display images, videos, as well as now GIFs and Audio! It subclasses UIImageView, and has functionality to lazy-load images from the web. In addition, it can also display videos, downloaded via URL from disk or web. Videos contain a player with a timeline and scrubbing. GIFs can also be displayed in an MediaView, via lazy-loading from the web, or set via NSData. The GIF that is downloaded is saved as a UIImage object for easy storage. Audio can also be displayed in the player by simply providing a url from the web or on disk. A major added functionality is that this mediaView has a queue and can present mediaViews in fullscreen mode. There is functionality which allows the view to be minimized by swiping, where it sits in the bottom right corner as a thumbnail. Videos can continue playing and be heard from this position. Afterwards, the user can choose to swipe the view away to dismiss. Alternatively, one can set the mediaView to dismiss immediately when swiping down instead of minimizing. In addition, automated caching is available. There are various different functionality that can be toggled on and off to customize the view to one's choosing.

![alt tag](ABMediaViewScrubScreenshot.gif)

## Table of Contents
* [Description](#description)
* [Example](#example)
* [Requirements](#requirements)
* [Features](#features)
* [Future Features](#future-features)
* [Installation](#installation)
* [Usage](#usage)
* [Calling the Manager](#calling-the-manager)
* [Initialization](#initialization)
* [Customization](#customization)
* [Caching](#caching)
* [Delegate](#delegate)
* [Complimentary Libraries](#complimentary-libraries)
* [Author](#author)
* [License](#license)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

* Requires iOS 9.0 or later
* Requires Automatic Reference Counting (ARC)

## Features

* Display for image, video, GIF, and Audio
* Easy Lazy-loading for images, videos, and GIFs
* Fullscreen display with minimization and dismissal
* Queue for presenting mediaViews in fullscreen
* Track for buffer, progress, and scrubbing
* Automated caching

## Future Features

- [ ] Progress and Loading views
- [ ] Zoom
- [ ] Tap to show details option (instead of tap to pause)

Tweet me [@TrepIsLife](https://twitter.com/TrepIsLife) if you have further feature suggestions!

## Installation

MediaView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MediaView"
```

You can add import MediaView to your classes with the following line:

```swift
import MediaView
```

## Usage
### Calling the manager
MediaViews can be presented and dismissed using the shared instance of the MediaQueue:

```swift
MediaQueue.shared
```


There are several functions, availabled through the MediaQueue shared instance, that can be used to queue, present, and dismiss MediaViews. This first of these functions is used to add a new MediaView to the queue. If there are no MediaViews in the queue at the time that the view is added, then the newly-queued view will be presented. In addition, one can remove a MediaView from the queue using the dequeue method.

```swift
// Add mediaView to the queue, and present if queue was previously empty
MediaQueue.shared.queue(mediaView: mediaView)

// Check if mediaView is in queue, and if so, remove it
MediaQueue.shared.dequeue(mediaView: mediaView)
```


Secondly, if one is looking to present a MediaView and jump the queue, then this can be done by utilizing the 'present' function. Calling this function will dismiss whatever MediaView is being currently presented, move the provided MediaView to the front of the queue, and present it.

```swift
// Present the mediaView with animation
MediaQueue.shared.present(mediaView: mediaView)

// Present the mediaView with the option to animate
MediaQueue.shared.present(mediaView: mediaView, animated: false)
```


On the other hand, if one is looking to dismiss the currently displayed MediaView, then the 'dismissCurrent' function can be called. If the view is minimized, this will make it move and disappear offscreen. If not, the view will just disappear. It comes with a completion closure so that actions can be taken after the disappearance.

```swift
MediaQueue.shared.dismissCurrent(animated: true) {
    // Perform action after dismissal
}
```


The following combines the functionality of the previous two functions. If the queue has multiple MediaViews in it, then the next view can be displayed by calling the 'presentNext' function on the sharedManager. This function will dismiss the current MediaView, and present the next view in the queue. If there are no other MediaViews in the queue, no further action is taken after dismissal.

```swift
MediaQueue.shared.presentNext()
```


***
### Initialization
A MediaView can be initilized programmatically, or by subclassing a UIImageView in the interface builder.

```swift
// MediaView initiliazed using frame
let mediaView = MediaView(frame: view.frame)
```


MediaView lazy-loads its media, where all that is needed to be provided is the source URL string. There is also a completion block where the downloaded media is returned for caching.

```swift
// Set the image to be displayed in the mediaView, which will be downloaded and available for caching
mediaView.setImage(url: "http://yoursite.com/yourimage.jpg")

// Similar to the preview method, with a completion handler for when the image has completed downloading
mediaView.setImage(url: "http://yoursite.com/yourimage.jpg") { (image) in
    // Take action after image has been downloaded and set to the mediaView
}

// Set the video to be displayed in the mediaView, which will be downloaded and available for caching
mediaView.setVideo(url: "http://yoursite/yourvideo.mp4")

// Set both the video url, and the thumbnail image for the mediaView, downloading both and making both available for caching
mediaView.setVideo(url: "http://yoursite/yourvideo.mp4", thumbnailUrl: "http://yoursite.com/yourimage.jpg")

// Set the video url for the mediaView, downloading it and making it available for caching, as well as the thumbnail image
mediaView.setVideo(url: "http://yoursite/yourvideo.mp4", thumbnail: UIImage(named: "image.png"))
```

If a file is being loaded off of the documents directory, (let's say you downloaded a video from the web and now want to display it), sourcing the content's URL from the directory can be specified by setting the 'fileFromDirectory' variable on the MediaView.

```swift
// Designates that the file is sourced from the Documents Directory of the user's device
mediaView.isFileFromDirectory = true
```


GIF support has also been made available for MediaView. To set a GIF to an MediaView, simply set it via URL string or Data, where it will be downloaded and set to the view. GIFs are made available as UIImages for easy storage.

```swift
// GIFs can be displayed in MediaView, where the GIF is sourced from the internet
mediaView.setGIF(url: "http://yoursite/yourgif.gif")

// GIFs can also be displayed via Data
mediaView.setGIF(data: data)
```

In addition, Audio support has also been made available for MediaView. To set Audio to a MediaView, simply set it via URL string, where it will be downloaded and set to the view.

```swift
// Set the audio to be displayed in the mediaView
mediaView.setAudio(url: "http://yoursite/youraudio.mp4")

// Set both the audio and thumbnail url for the mediaView
mediaView.setAudio(url: "http://yoursite/youraudio.mp4", thumbnailUrl: "http://yoursite.com/yourimage.jpg")

// Set the audio url for the mediaView, as well as the thumbnail image
mediaView.setAudio(url: "http://yoursite/youraudio.mp4", thumbnail: UIImage(named: "thumbnail.png"))
```

In terms of playback throughout the app, functionality has been added where you can ensure that audio will play for the user, even if their device is on vibrate. These variables are set so that audio will either be enabled or disabled when media begins and ends playing in a MediaView, and can be set using the MediaView class methods:


```swift
// Toggle this functionality to enable/disable sound to play when an MediaView begins playing, and the user's app is on silent
MediaView.audioTypeWhenPlay = .playWhenSilent

// In addition, toggle this functionality to enable/disable sound to play when an MediaView ends playing, and the user's app is on silent
MediaView.audioTypeWhenStop = .standard
```


*BONUS FUNCTIONALITY:* GIFs can also be used as the thumbnail for video and audio.

```swift
// Set video for mediaView by URL, and set GIF as thumbnail by URL
mediaView.setVideo(url: "www.video.com/urlHere", thumbnailGIFUrl: "http://yoursite/yourgif.gif")

// Set video for mediaView by URL, and set GIF as thumbnail using Data
mediaView.setVideo(url: "www.video.com/urlHere", thumbnailGIFData: gifData)

// Set audio for mediaView by URL, and set GIF as thumbnail by URL
mediaView.setAudio(url: "www.video.com/urlHere", thumbnailGIFUrl: "http://yoursite/yourgif.gif")

// Set audio for mediaView by URL, and set GIF as thumbnail using Data
mediaView.setAudio(url: "www.video.com/urlHere", thumbnailGIFData: gifData)
```

Another bonus functionality has been added, where if a user presses and holds on an MediaView, a GIF preview is shown. This function is currently available for videos, and can be implemented using the following methods:

```swift
let thumbnailImage: UIImage = ...
let gifData: Data = ...

// Set video for the MediaView, then the thumbnail UIImage, and the url for the preview GIF
mediaView.setVideo(url: "www.video.com/urlHere", thumbnail: thumbnailImage, previewGIFUrl: "http://yoursite/yourgif.gif")

// Set video for the MediaView, then the thumbnail UIImage, and the Data for the preview GIF
mediaView.setVideo(url: "www.video.com/urlHere", thumbnail: thumbnailImage, previewGIFData: gifData)

// Set video for the MediaView, then the url for the thumbnail image, and the url for the preview GIF
mediaView.setVideo(url: "www.video.com/urlHere", thumbnailUrl: "http://yoursite.com/yourimage.jpg", previewGIFUrl: "http://yoursite/yourgif.gif")

// Set video for the MediaView, then the url for the thumbnail image, and the Data for the preview GIF
mediaView.setVideo(url: "www.video.com/urlHere", thumbnailUrl: "http://yoursite.com/yourimage.jpg", previewGIFData: gifData)
```

![alt tag](ABMediaViewVideoPreviewUsingGIFScreenshot.gif)

**VERY IMPORTANT** If your application supports device rotation, the MediaViews throughout your app need to receive the rotation notifications. Thus, you need to implement something along the lines of what can be found [here](https://stackoverflow.com/questions/25666269/how-to-detect-orientation-change). Here are a couple of example implementations that I found best:

Method 1: Place the following block of code in your application's rootviewcontroller, or in the view controller which is intializing the MediaView. This will allow the MediaView to know when the user's device is rotating, and will enable it to rotate accordingly.
```swift
// If 'viewWillTransitionToSize' is already implemented in your code, add the two MediaViewNotifications to your 'animate:alongsideTransition' block
override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)

    coordinator.animate(alongsideTransition: { _ in
        Notification.post(.mediaViewWillRotateNotification)
    }) { _ in
        Notification.post(.mediaViewDidRotateNotification)
    }
}
```

Method 2: Add a notification inside your AppDelegate's didFinishLaunchingWithOptions for capturing rotation. I'm not crazy about this implementation because it can't capture will rotate notifications, so it will delay mediaView rotation.
```swift
// Notification which should be added to AppDelegate
NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)


// Function called from notification
func rotated() {
    Notification.post(.mediaViewWillRotateNotification)
    Notification.post(.mediaViewDidRotateNotification)
}
```

In relation to screen rotation, if your application's UI requires Portrait orientation, but you want the MediaView to be viewable in Landscape mode, methodology for handling this case has been included in the Example project. This is popular functionality, so it is included to make developing easier for such a functionality. The method leverages the delegate methods for MediaView to determine when the app should restrict rotation.


Lastly, when one is done with an MediaView and wishes to wipe it clean to make room for new content to be displayed (such as with reusable cells), a few methods are available for easily handling this task.

```swift
// Removes image, video, audio and GIF data from the MediaView
- (void) resetMediaInView;

// Calls resetMediaInView and also resets the configurations in the MediaView
- (void) resetVariables;
```


***
### Customization
MediaView also comes with an option for toggling the functionality which would allow the mediaView to be swiped away, to either dismiss or minimized to the bottom right corner. Minimization allows the user to interact with the underlying interface while the mediaView sits minimized. Video and audio continues to play if already playing, and the user can swipe right to dismiss the minimized view. These settings can be set by setting the 'swipeMode' value on the MediaView.

```swift
// User can swipe down to dismiss the MediaView
mediaView.swipeMode = .dismiss

// User can swipe down to minimize the MediaView
mediaView.swipeMode = .minimize

// MediaView should only be dismissed if the 'X' close button is pressed, and not swipable.
mediaView.swipeMode = .none
```

MediaView also comes with a few playback options for video and audio. One option, 'allowLooping', toggles whether media should replay after reaching the end. Another option, 'autoPlayAfterPresentation', toggles whether media should play automatically after presenting. By default, MediaView has 'shouldAutoPlayAfterPresentation' set to true.

```swift
// Toggle looping functionality
mediaView.allowLooping = true

// Toggle functionality to automatically play videos after presenting
mediaView.shouldAutoPlayAfterPresentation = true
```


If you are looking for the functionality to have a fullscreen mediaView dismiss after its video finished playing, you can set the value 'shouldDismissAfterFinish' to true on the mediaView. This functionality will take precedence over 'allowLooping' for fullscreen MediaViews.

```swift
mediaView.shouldDismissAfterFinishedPlaying = true
```


MediaView has several options for enabling and editing the progress track that shows when displaying videos and audio.

```swift
// Enable progress track to show at the bottom of the MediaView
mediaView.shouldShowTrack = true

// Toggles the funtionality which would show remaining time instead of total time on the right label on the track
mediaView.shouldDisplayRemainingTime = true

// Change the font for the labels on the track
let font: UIFont = ...
mediaView.trackFont = font
```


MediaView has a theme color which changes the color of the track as well as the color of the play button and failed indicator.

```swift
// Changing the theme color changes the color of the play and failed indicators as well as the progress track
mediaView.themeColor = .red
```


MediaView will display images, videos, and GIFs according to the contentMode set on the view. However, there is also functionality to have the contentMode be set to aspectFill while the videoGravity is set to aspectFit.

```swift
// Setting the contentMode to aspectFit will set the videoGravity to aspectFit as well
mediaView.contentMode = .scaleAspectFit

// If you desire to have the image to fill the view, however you would like the videoGravity to be aspectFit, then you can implement this functionality
mediaView.contentMode = .scaleAspectFill
mediaView.videoAspectFit = true
```


To have fullscreen functionality on a MediaView, the 'shouldDisplayFullscreen' value needs to be set to true on the respective MediaView. By default, this value is false.

```swift
mediaView.shouldDisplayFullscreen = true
```


If you would like to use a custom play button or failed indicator for a MediaView, you should set the 'customPlayButton', 'customFailedButton', and 'customMusicButton' variables on the MediaView.

```swift
// Set a custom image for the play button visible on MediaView's with video or audio
mediaView.customPlayButton = UIImage(named: "play.png")

// Set a custom image for when the mediaView fails to play media
mediaView.customFailButton = UIImage(named: "failed.png")

// Set a custom image for the play button visible for MediaView's specifically with audio, supercedes the customPlayButton
mediaView.customMusicButton = UIImage(named: "playMusic.png")
```


There is functionality to toggle hiding the close button, that way it does not show up in a fullscreen pop-up mediaView. This functionality is only allowed if 'swipeMode' is set to '.minimize' or 'dismiss', or else there would be no other way to close the pop-up. In addition, the close button remains visible when the view is held in landscape orientation, due to swiping being disabled during landscape.

```swift
mediaView.shouldHideCloseButton = true
```


Similarly, there is functionality to have the play button hidden on media that can be played (video/audio). This functionality is useful if one is looking to use MediaView as a background video player.

```swift
mediaView.shouldHidePlayButton = true
```


In the case that there is a UIStatusBar on your screen that you would not like to hide, or instances where you would like to reserve space on the top of your screen for other views, MediaView possesses the ability to offset the subviews at the top of the screen to avoid hiding these views. Setting the 'topOffset' property of a MediaView would move down the 'closeButton' and any other top-anchored views. Again, a major use case for this would be to set the 'topOffset' property to 20px in order to avoid covering the UIStatusBar.

```swift
mediaView.topBuffer = 20
```


By default, there is a buffer of 12px between the minimized MediaView and the screen's bottom. More space can be added by adjusting the 'bottomBuffer' value for the MediaView. This is useful in order to have the mediaView show above views such as UITabBars and UIToolbars, to avoid covering these views that need reserved space on the bottom of the screen.

```swift
mediaView.bottomBuffer = 0
```


To make these buffers easier to use, I have extended CGFloat to include the following values.

```swift
// .statusBarBuffer = 20px OR 44px if iPhone X
// .navigationBarBuffer = 44px
// .statusAndNavigationBuffer = 64px OR 104px if iPhone X
// .tabBarBuffer = 49px

mediaView.topBuffer = .statusBarBuffer
mediaView.bottomBuffer = .tabBarBuffer
```


MediaView has functionality to set the frame from which the fullscreen pop-up will originate. This functionality is useful to combine with 'shouldDisplayFullscreen', as it will allow the pop-up to originate from the frame of the mediaView with 'shouldDisplayFullscreen' enabled.

```swift
// Rect that specifies where the mediaView's frame will originate from when presenting, and will be converted into its position in the mainWindow
mediaView.originRect = view.frame

// Rect that specifies where the mediaView's frame will originate from when presenting, and is already converted into its position in the mainWindow
mediaView.originRectConverted = view.frame
```


However, if one is using dynamic UI, and therefore can not determine the originRect of the MediaView, one can set the property 'shouldPresentFromOriginRect' to true. With this functionality enabled, the fullscreen MediaView will popup from frame of the MediaView which presents it. If 'shouldPresentFromOriginRect' is enabled, then there is no need to set 'originRect' or 'originRectConverted', as this property supersedes both.

```swift
mediaView.shouldPresentFromOriginRect = true
```


One can specify whether or not the MediaView is going to be displayed in a reusable view, which will allow for better UI transition performance for MediaView's that are not going to be reused. By default it is assumed that the MediaView will be reused, so the value that can be set is 'imageViewNotReused' to true if not reused.

```swift
mediaView.imageViewNotReused = true
```


When a MediaView's 'isMinimizable' value is enabled, the size ratio of the minimized view can be customized. The default value for this ratio is the preset ABMediaViewRatioPresetLandscape, which is a landscape 16:9 aspect ratio. There are also preset options for square (ABMediaViewRatioPresetSquare) and portrait 9:16 (ABMediaViewRatioPresetPortrait).

```swift

// Aspect ratio of the minimized view
mediaView.minimizedAspectRatio = .landscapeRatio
mediaView.minimizedAspectRatio = .square
mediaView.minimizedAspectRatio = .portrait
mediaView.minimizedAspectRatio = .landscapeRatio
mediaView.minimizedAspectRatio = (6.0 / 5.0) // Height/Width
```


Accompanying the above option, the ratio of the screen's width that the minimized view will stretch across can also be specified. By default, the minimized view stretches across half the screen (0.5 ratio). This functionality is useful in adjusting the size of the minimized view for instances where the MediaView's 'minimizedAspectRatio' is greater than landscape.

```swift
// Ratio of the screen's width that the minimized view will stretch across
mediaView.minimizedWidthRatio = 0.5
```


***
### Caching
If your project does not have a caching system, and you are looking for an automated caching system, MediaView has that! With MediaView, images and GIFs are saved in memory using NSCache, while videos and audio files are saved to disk. There are several options available for managing the cache, but let's start with how to enable automated caching. It can be done by setting the 'cacheMediaWhenDownloaded' value on the CacheManager shared instance. In addition, setting 'shouldCacheStreamedMedia' on a MediaView will cache videos as they are streamed. At this moment, video is cached when the buffer is fully loaded from the stream. Audio is currently a work in progress.

```swift
// Saves media to cache
CacheManager.cacheMediaWhenDownloaded = true

// Caches videos when streaming
mediaView.shouldCacheStreamedMedia = true
```

If you are looking to have videos and audio preloaded to cache, you can have MediaView set to always download video and audio when the video or audio URL is set on a mediaView by specifying 'shouldPreloadPlayableMedia' on ABMediaView's sharedManager. However, if you are looking to preload video or audio on an individual instance basis, it can be done using the 'preloadVideo' and 'preloadAudio'. If you aren't looking to have videos or audio preloaded, and just have 'shouldCacheStreamedMedia' set to true, then video and audio will be streamed.

```swift
// Ensure that all video and audio is preloaded before playing, instead of just streaming (works best if your app plays videos/audio that is short in length)
mediaView.shouldPreloadPlayableMedia = true

// Preload the video for this specific mediaView
mediaView.preloadVideo()

// Preload the audio for this specific mediaView
mediaView.preloadAudio()
```


If one is looking to clear the memory cache of images and GIFs, just set 'shouldCacheMedia' to false on the MediaView sharedManager. However, to clear caches on disk for the Documents directory and the tmp directory, CacheManager comes with an easy class function to clear these caches.

```swift
// Clear all of the documents directory of cached items in the ABMedia folder
CacheManager.clear(directory: .all)

// Clear the video directory of cached items in the ABMedia folder
CacheManager.clear(directory: .video)

// Clear the audio directory of cached items in the ABMedia folder
CacheManager.clear(directory: .audio)

// Clear all of the temp directory of cached items
CacheManager.clear(directory: .temp)
```

***
### Delegate
There is a delegate with optional methods to determine when the ABMediaView has played or paused the video in its AVPlayer, as well as how much the view has minimized.

```swift
/// A listener to know what percentage that the view has minimized, at a value from 0 to 1
- (void) mediaView: (ABMediaView *) mediaView didChangeOffset: (float) offsetPercentage;

/// When the mediaView begins playing a video
- (void) mediaViewDidPlayVideo: (ABMediaView *) mediaView;

/// When the mediaView pauses a video
- (void) mediaViewDidPauseVideo: (ABMediaView *) mediaView;
```


In addition, there are also delegate methods to help determine whether a ABMediaView is about to be shown, has been shown, about to be dismissed, and has been dismissed.

```swift
/// Called when the mediaView has begun the presentation process
- (void) mediaViewWillPresent: (ABMediaView *) mediaView;

/// Called when the mediaView has been presented
- (void) mediaViewDidPresent: (ABMediaView *) mediaView;

/// Called when the mediaView has begun the dismissal process
- (void) mediaViewWillDismiss: (ABMediaView *) mediaView;

/// Called when the mediaView has completed the dismissal process. Useful if not looking to utilize the dismissal completion block
- (void) mediaViewDidDismiss: (ABMediaView *) mediaView;
```


If looking to determine whether a mediaView has finished playing its video, you can utilize the 'mediaViewDidFinishVideo:withLoop:' method. This also specifies whether the mediaView is set to loop after it has finished playing.

```swift
/// When the mediaView finishes playing a video, and whether it will loop
- (void)mediaViewDidFinishVideo:(ABMediaView *)mediaView withLoop:(BOOL)willLoop;
```


The following delegate methods are useful when looking to determine if the ABMediaView has begun, is in the process, or has completed minimizing. A popular use case for this would be adjust the UIStatusBarStyle depending on whether the ABMediaView is visible behind it.

```swift
/// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
- (void) mediaViewWillChangeMinimization:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and has made a change in frame
- (void) mediaViewDidChangeMinimization:(ABMediaView *)mediaView;

/// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
- (void) mediaViewWillEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized;

/// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
- (void) mediaViewDidEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized;
```


On the other hand, if one has the 'isDismissable' value set on their ABMediaView, delegate methods are provided to listen for when the mediaView will and has begun/ended the dismissing process.

```swift
/// Called when the mediaView is in the process of minimizing, and is about to make a change in frame
- (void) mediaViewWillChangeDismissing:(ABMediaView *)mediaView;

/// Called when the mediaView is in the process of minimizing, and has made a change in frame
- (void) mediaViewDidChangeDismissing:(ABMediaView *)mediaView;

/// Called before the mediaView ends minimizing, and informs whether the minimized view will snap to minimized or fullscreen mode
- (void) mediaViewWillEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss;

/// Called when the mediaView ends minimizing, and informs whether the minimized view has snapped to minimized or fullscreen mode
- (void) mediaViewDidEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss;
```


If one is looking to detect if the image contained in the ABMediaView has been set or changed, they can listen to the following delegate method.

```swift
/// Called when the mediaView 'image' property has been set or changed
- (void) mediaView:(ABMediaView *)mediaView didSetImage:(UIImage *) image;
```


If one is looking to cache the images, videos, or GIFs that are being downloaded via the ABMediaView, delegates have been made handle to get these objects.


```swift
/// Called when the mediaView has completed downloading the image from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadImage:(UIImage *) image;

/// Called when the mediaView has completed downloading the video from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadVideo: (NSString *)video;

/// Called when the mediaView has completed downloading the GIF from the web
- (void) mediaView:(ABMediaView *)mediaView didDownloadGif:(UIImage *)gif;
```

## Complimentary Libraries

* [ABVolumeControl](https://github.com/AndrewBoryk/ABVolumeControl): Overrides MPVolumeView with differents styles for a volumeView, as well as a delegate to implement one's own custom volumeView.
* [ABUtils](https://github.com/AndrewBoryk/ABUtils): A collections of useful methods that can be dropped into any project.
* [ABKeyboardAccessory](https://github.com/AndrewBoryk/ABKeyboardAccessory): UIView subclass which can be used as an 'inputAccessory', with delegate methods for knowing when keyboard frame changes, such as for appearance and disappearance.


## Author

Andrew Boryk, andrewcboryk@gmail.com

Reach out to me on Twitter: [@TrepIsLife](https://twitter.com/TrepIsLife) [![alt text][1.2]][1]

[1.2]: http://i.imgur.com/wWzX9uB.png (twitter icon without padding)
[1]: http://www.twitter.com/TrepIsLife

## License

MediaView is available under the MIT license. See the LICENSE file for more info.
