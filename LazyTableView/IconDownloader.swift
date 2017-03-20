//
//  IconDownloader.swift
//  LazyTableView
//
//  Created by Godfather on 3/20/17.
//  Copyright © 2017 Godfather. All rights reserved.
//

import UIKit

private let kAppIconSize : CGFloat = 48
class IconDownloader: NSObject, NSURLConnectionDataDelegate {
    
    var appRecord: AppRecord?
    var completionHandler: (() -> Void)?
    private var sessionTask: URLSessionDataTask?
    
    // startDownload
    func startDownload() {
        
        let urlRequest = URLRequest(url: URL(string: self.appRecord!.imageURLString!)!)
        sessionTask = URLSession.shared.dataTask(with: urlRequest, completionHandler: { (data, response, error) in
            if let actualError = error as NSError? {
                if #available(iOS 9.0, *) {
                    if actualError.code == NSURLErrorAppTransportSecurityRequiresSecureConnection {
                        abort()
                    }
                }
            }
            OperationQueue.main.addOperation {
                let image = UIImage(data: data!)!
                if image.size.width != kAppIconSize || image.size.height != kAppIconSize {
                    let itemSize = CGSize(width: kAppIconSize, height: kAppIconSize)
                    UIGraphicsBeginImageContextWithOptions(itemSize, false, 0.0)
                    let imageRect = CGRect(x: 0.0, y: 0.0, width: itemSize.width, height: itemSize.height)
                    image.draw(in: imageRect)
                    self.appRecord?.appIcon = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                } else {
                    self.appRecord?.appIcon = image
                }
                self.completionHandler?()
            }
        })
        self.sessionTask?.resume()
    }
    
    
    // cancelDownload
    
    func cacelDownload() {
        self.sessionTask?.cancel()
        sessionTask = nil // Nếu không gán nil thì hiện tượng gì xảy ra ?
    }
    
}




