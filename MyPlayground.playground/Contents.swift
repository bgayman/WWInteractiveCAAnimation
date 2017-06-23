//: Playground - noun: a place where people can play

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

DownloadManager.shared.onProgress =
{ progress in
    print(progress)
}

DownloadManager.shared.activate().downloadTask(with: URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2017/222ijxk2akkrebmr/222/222_sd_advanced_touch_bar.mp4?dl=1")!)