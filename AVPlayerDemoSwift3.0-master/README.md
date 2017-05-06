# AVPlayerDemoSwift

A Swift version of the AVPlayerDemo on the Apple Web Site

## Usage

The `VideoViewController.swift` file is intended to be used as a child view controller.  The video methods are pretty self explanatory.  It utilizes the `AVPlayer` library which you should familiarize yourself with at [Apple Dev](https://developer.apple.com/library/ios/samplecode/AVPlayerDemo/Introduction/Intro.html).
I altered it slightly so that a swipe left and swipe right will skip 15 seconds.  You can touch to scrub by utilizing the scrubber.  I found the touch-to-scrub method tends to cause performance issues.

## Examples

The video control functions begin on line 636:
* `func play(sender: AnyObject?)`
* `func pause(sender: AnyObject?)`
* `func playAtTime(startTime: Double)`
* `func rw15()`
* `func ff15()`
* `func playClip(startTime: Double, endTime: Double)`
