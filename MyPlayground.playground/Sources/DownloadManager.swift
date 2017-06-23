//
//  DownloadManager.swift
//  2xWWDC
//
//  Created by B Gay on 6/7/17.
//  Copyright © 2017 B Gay. All rights reserved.
//

import Foundation

public  class DownloadManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate
{
    public static var shared = DownloadManager()
    
    public typealias ProgressHandler = (Float) -> ()
    
    public var onProgress: ProgressHandler?
    {
        didSet
        {
            if onProgress != nil
            {
                activate()
            }
        }
    }
    
    override private init()
    {
        super.init()
    }
    
    @discardableResult
    public func activate() -> URLSession
    {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).something")
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    }
    
    private func calculateProgress(session: URLSession, completionHandler: @escaping (Float) -> ())
    {
        session.getTasksWithCompletionHandler
        { (tasks, uploads, downloads) in
            let progress: [Float] = downloads.map
            { (task) in
                if task.countOfBytesExpectedToReceive > 0
                {
                    return Float(task.countOfBytesReceived) / Float(task.countOfBytesExpectedToReceive)
                }
                else
                {
                    return 0.0
                }
            }
            completionHandler(progress.reduce(0.0, +))
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64)
    {
        if totalBytesExpectedToWrite > 0
        {
            if let onProgress = onProgress
            {
                calculateProgress(session: session, completionHandler: onProgress)
            }
        }
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        guard let url = downloadTask.originalRequest?.url else { return }
        print("location \(location) \(url)")
        let newURL = FileStorage().url(for: url)
        try? FileManager.default.moveItem(at: location, to: newURL)
        print("New URL \(newURL.path)")
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
    }
}

struct FileStorage
{
    let baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    
    subscript(key: String) -> Data?
    {
        get
        {
            let url = baseURL.appendingPathComponent(key)
            return try? Data(contentsOf: url)
        }
        
        set
        {
            let url = baseURL.appendingPathComponent(key)
            _ = try? newValue?.write(to: url)
        }
    }
    
    func url(for url: URL) -> URL
    {
        let url = baseURL.appendingPathComponent("download\(url.hashValue).mp4")
        return url
    }
}


